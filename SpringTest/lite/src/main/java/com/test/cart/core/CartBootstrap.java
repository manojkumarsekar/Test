package com.eastspring.qa.cart.core;

import com.eastspring.qa.cart.context.CartCoreConfig;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.google.common.base.Strings;
import com.eastspring.qa.cart.core.configmanagers.CoreConfigManager;
import org.apache.log4j.xml.DOMConfigurator;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.util.Assert;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * <p>This class encapsulates the bootstrap process of CART Test Automation.</p>
 */
public class CartBootstrap {
    private static String baseDir = "";
    static boolean unitTestMode = false;

    private static final String BASE_DIR_NOT_SET_WARNING = "Test Repo Base directory has not set, Must use System Property tomcart.basedir=<> or set tomcart.relative.path=true incase Linux or Mac";

    private static ConfigurableApplicationContext context;
    private static boolean initialized = false;
    private static Class configClass = CartCoreConfig.class;

    private CartBootstrap() {
    }

    private static void initNonContainer() {
        configureLogging();
    }

    /**
     * <p>This method is required to allow overriding the org.eis.cart.config class, not using the default <b>cart-core</b>
     * bootstrap. This is for example used by the downstream project <b>cart-bdd</b> in the <b>Main</b> class&aphos;
     * <b>main</b> method to bootstrap using its configuration.</p>
     * <p>When not specified, it will default the org.eis.cart.config class to {@link CartCoreConfig} class.</p>
     *
     * @param configClass the org.eis.cart.config class
     */
    public static void setConfigClass(Class configClass) {
        CartBootstrap.configClass = configClass;
    }

    /**
     * Initialize the lifecycle.
     */
    public static synchronized void init() {
        if (!initialized) {
            initNonContainer();
            configureContainer();
            initialized = true;
            CartLogger.debug("bootstrap: initialized.");
        }
    }

    /**
     * Configure the Spring application context.
     */
    private static synchronized void configureContainer() {
        if (context == null) {
            context = new AnnotationConfigApplicationContext(configClass);
        }
    }

    private static String getLogConfigLocation() {
        final String LOG4J_CONFIG = CoreConfigManager.LOG4J_CONFIG_PATH;
        if (!LOG4J_CONFIG.equals("")) {
            String logConfigLocation = System.getProperty(LOG4J_CONFIG);
            if (!Strings.isNullOrEmpty(logConfigLocation)) return logConfigLocation;
        }

        InputStream wdStream = CartBootstrap.class.getResourceAsStream("/config/log4j.xml");
        Assert.notNull(wdStream, "/config/log4j.xml file is not found in resources");
        Path localLog4jConfigDir = Paths.get(System.getProperty("user.dir"), "target");
        Path localLog4jConfig = Paths.get(localLog4jConfigDir.toString(), "log4j.xml");
        try {
            if (!Files.exists(localLog4jConfigDir)) {
                Files.createDirectory(localLog4jConfigDir);
            }
            Files.copy(wdStream, localLog4jConfig, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            CartLogger.error(e.getMessage());
            throw new CartException(e, CartExceptionType.IO_ERROR,
                    "Failed to copy LogConfig file to [{}]", localLog4jConfig);
        }
        return localLog4jConfig.toString();
    }

    /**
     * Configures Log4J logging framework using default org.eis.cart.config file.
     */
    private static void configureLogging() {
        String logConfigLocation = getLogConfigLocation();
        System.out.println(String.format("logConfigLocation: [%s]", logConfigLocation)); // NOSONAR
        DOMConfigurator.configure(logConfigLocation);
    }

    /**
     *
     */
    public synchronized static void done() {
        if (context != null) {
            context = null;
            initialized = false;
        }
        CartLogger.debug("bootstrap: closed.");
    }

    public static ApplicationContext getContext() {
        init();
        return context;
    }

    public static Object getBean(String name) {
        init();
        return context.getBean(name);
    }

    public static Object getBean(Class class1) {
        init();
        return context.getBean(class1);
    }


}