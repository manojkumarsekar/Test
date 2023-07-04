package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.cst.EncodingConstants;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateExceptionHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;

/**
 * Freemarker Template encapsulation with some default settings.
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class FmTemplateSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(FmTemplateSvc.class);

    private Configuration fmConfig;

    /**
     *
     * @param templateLocation template folder location
     */
    public void setTemplateLocation(String templateLocation) {
        LOGGER.debug("setTemplateLocation(\"{}\")", templateLocation);
        fmConfig = new Configuration(Configuration.VERSION_2_3_23);
        try {
            fmConfig.setDirectoryForTemplateLoading(new File(templateLocation));
        } catch (IOException e) {
            LOGGER.error("setting template to folder [{}] which does not exists", e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "folder does not exist");
        }
        fmConfig.setDefaultEncoding(EncodingConstants.UTF_8);
        fmConfig.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        fmConfig.setLogTemplateExceptions(false);
        LOGGER.debug("fmConfig: [{}]", fmConfig);
    }

    public Template getTemplate(String templateFile) throws IOException {
        LOGGER.debug("invoking: fmConfig.getTemplate(\"{}\")", templateFile);
        return fmConfig.getTemplate(templateFile);
    }
}
