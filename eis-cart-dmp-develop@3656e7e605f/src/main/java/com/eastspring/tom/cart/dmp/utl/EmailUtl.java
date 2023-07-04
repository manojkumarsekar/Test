package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.EmailConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;
import java.util.Date;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

public class EmailUtl {
    private static final Logger LOGGER = LoggerFactory.getLogger(EmailUtl.class);

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileutil;

    public Session setEmailSession() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", stateSvc.getStringVar(EmailConstants.EMAIL_SMTP_HOST));
        props.put("mail.smtp.port", stateSvc.getStringVar(EmailConstants.EMAIL_SMTP_PORT));
        props.put("mail.smtp.ssl.trust", stateSvc.getStringVar(EmailConstants.EMAIL_SMTP_HOST));

        Session session = Session.getInstance(props,
                new javax.mail.Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(stateSvc.getStringVar(EmailConstants.EMAIL_USERNAME), stateSvc.getStringVar(EmailConstants.EMAIL_PASSWORD));
                    }
                });
        session.setDebug(true);
        LOGGER.info("Email Authentication success!!");
        return session;
    }

    public void sendEmail(String emailBodyFile) {

        Session session = setEmailSession();
        session.setDebug(false);
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(stateSvc.getStringVar(EmailConstants.EMAIL_FROM)));
            message.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse(stateSvc.getStringVar(EmailConstants.EMAIL_TO)));
            message.setSubject(stateSvc.getStringVar(EmailConstants.EMAIL_SUBJECT));
            String msg = fileutil.readFileToString(emailBodyFile);
            Multipart multipart = new MimeMultipart();
            BodyPart messageBodyPart = new MimeBodyPart();
            messageBodyPart.setContent(msg, "text/html");
            multipart.addBodyPart(messageBodyPart);
            message.setContent(multipart);
            message.setSentDate(new Date());
            Transport.send(message);
            LOGGER.info("Email sent successfully");

        } catch (MessagingException e) {
            LOGGER.error("Error while sending email", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error while sending email");
        }
    }


    public void constructEmailTemplateParamsFromMap(Map<String, String> templateParamsMap) {
        Set<String> keys = templateParamsMap.keySet();
        for (String key : keys) {
            String paramValueExpanded = stateSvc.expandVar(templateParamsMap.get(key));
            stateSvc.setStringVar(key, paramValueExpanded);
        }
    }

}
