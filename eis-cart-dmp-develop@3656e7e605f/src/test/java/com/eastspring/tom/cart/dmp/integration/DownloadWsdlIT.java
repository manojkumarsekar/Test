package com.eastspring.tom.cart.dmp.integration;

import com.eastspring.tom.cart.dmp.utl.CartDmpUtlConfig;
import com.eastspring.tom.cart.dmp.utl.DmpWsdlUtil;
import com.eastspring.tom.cart.dmp.utl.mdl.RowInfo;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.log4j.xml.DOMConfigurator;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartDmpUtlConfig.class})
public class DownloadWsdlIT {

    @Autowired
    private DmpWsdlUtil dmpWsdlUtil;

    @Test
    public void test() {
        String password = "user1@123";
        String hostname = "vsgeisldapp07.pru.intranet.asia";
        int port = 8680;
        String username = "user1";
        String sourceUrl = "http://" + hostname + ":" + port + "/standardvddb/webservice/Events";
        String downloadDestDir = "/tomcart-local/wsdls";
        String patternString = "<tr>(.*?)</td><td>(.*?)</td><td><a href=\"(.*?)\">WSDL...</a></td></tr>";

        DOMConfigurator.configure("/tomrt-win/cart/conf/allinfo.xml");

        CredentialsProvider cp = new BasicCredentialsProvider();
        cp.setCredentials(new AuthScope(hostname, port), new UsernamePasswordCredentials(username, password));

        String body = dmpWsdlUtil.downloadBodyAsString(sourceUrl, cp);

        if (body == null) {
            System.out.println("Body is null, something is wrong...");
            System.exit(1);
        }

        List<String> result = null;
        Pattern pattern = Pattern.compile(patternString);
        Matcher m = pattern.matcher(body);
        if (m.find()) {
            result = new ArrayList<>();
            result.add(m.group());
            while (m.find()) {
                result.add(m.group());
            }
        }

        List<RowInfo> rows = dmpWsdlUtil.parseWsdlRows(result);

        dmpWsdlUtil.downloadAllWsdl(rows, downloadDestDir, cp);
    }

}
