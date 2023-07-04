package com.eastspring.tom.cart.dmp;

import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.apache.log4j.xml.DOMConfigurator;

import java.net.MalformedURLException;
import java.net.URL;

public class CartDmpTestConfig {
    /**
     * Configures Log4J logging framework using default config file.
     */
    public static void configureLogging(Class theClass) {
        String absolutePath = new FileDirUtil().getAbsolutePath(theClass) + "../test-classes/conf/log4j.xml";
        System.out.println(absolutePath);
        try {
            DOMConfigurator.configure(new URL(
                    "file:" + absolutePath));
        } catch (MalformedURLException e) {
            System.out.println("FATAL: failed to configure logging."); // NOSONAR
            System.exit(3);
        }
    }
}
