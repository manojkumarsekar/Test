package com.eastspring.tom.cart.core;

import com.eastspring.tom.cart.cfg.CartCoreConfig;
import com.eastspring.tom.cart.core.steps.HooksSteps;
import com.eastspring.tom.cart.core.svc.MTReportsSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.google.common.base.Strings;
import org.apache.log4j.xml.DOMConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.LinkedHashMap;
import java.util.stream.Collectors;

/**
 * <p>This class encapsulates the bootstrap process of CART Test Automation.</p>
 */
public class CartBootstrap {
    private static final Logger LOGGER = LoggerFactory.getLogger(CartBootstrap.class);

    private static final String JVM_OPT_WEBDRIVER_CHROME_DRIVER = "webdriver.chrome.driver";
    private static final String JVM_OPT_WEBDRIVER_IE_DRIVER = "webdriver.ie.driver";
    private static final String JVM_OPT_TOMCART_LOG4J_CONFIG = "tomcart.log4j.config";
    private static final String JVM_OPT_TOMCART_ENV_NAME = "tomcart.env.name";
    static boolean unitTestMode = false;

    private static final String IEDRIVER_LOCATION_DEFAULT = "c:/tomrt-win/cart/uidriver/IEDriverServer.exe";
    private static final String CHROMEDRIVER_LOCATION_DEFAULT = "c:/tomrt-win/cart/uidriver/chromedriver.exe";
    private static final String CHROMEDRIVER_LOCATION_UNIX = "/tomcart/ws/cart/uidriver/chromedriver";
    private static final String DEFAULT_LOG4J_FILE_LOCATION = "file:/tomrt-win/cart/conf/log4j.xml";
    private static final String DEFAULT_TOMCART_ENV_NAME = "TOM_DEV1";

    private static ConfigurableApplicationContext context;
    private static boolean initialized = false;
    private static Class configClass = CartCoreConfig.class;

    private CartBootstrap() {
    }

    private static void initNonContainer() {
        configureLogging();
        configureDrivers();
    }

    private static void configureDrivers() {
        configureChrome();
        configureIe();
    }

    /**
     * <p>This method is required to allow overriding the config class, not using the default <b>cart-core</b>
     * bootstrap. This is for example used by the downstream project <b>cart-bdd</b> in the <b>Main</b> class&aphos;
     * <b>main</b> method to bootstrap using its configuration.</p>
     * <p>When not specified, it will default the config class to {@link CartCoreConfig} class.</p>
     *
     * @param configClass the config class
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
            LOGGER.debug("bootstrap: initialized.");
        }
    }

    /**
     * Configure the Spring application context.
     */
    private static synchronized void configureContainer() {
        if (context == null) {
            context = new AnnotationConfigApplicationContext(configClass);
            StateSvc stateSvc = context.getBean(StateSvc.class);
            String tomcartEnvName = System.getProperty(JVM_OPT_TOMCART_ENV_NAME);
            String namedEnvironment;
            if (Strings.isNullOrEmpty(tomcartEnvName)) {
                namedEnvironment = DEFAULT_TOMCART_ENV_NAME;
                LOGGER.debug("using named environment [{}] from default value", namedEnvironment);
            } else {
                namedEnvironment = tomcartEnvName;
                LOGGER.debug("using named environment [{}] from JVM option [{}]", namedEnvironment, JVM_OPT_TOMCART_ENV_NAME);
            }
            stateSvc.setStringVar("cucumber.reports.env.name", namedEnvironment);
            stateSvc.useNamedEnvironment(namedEnvironment);
        }
    }

    /**
     * Configures WebDriver through System properties.
     */
    private static void configureChrome() {
        if (System.getProperty(JVM_OPT_WEBDRIVER_CHROME_DRIVER) == null) {
            String path = CHROMEDRIVER_LOCATION_DEFAULT;
            // https://stackoverflow.com/a/3282597
            if (!System.getProperty("os.name").startsWith("Windows")) {
                path = CHROMEDRIVER_LOCATION_UNIX;
            }
            System.setProperty(JVM_OPT_WEBDRIVER_CHROME_DRIVER, path);
        }
    }

    private static void configureIe() {
        if (System.getProperty(JVM_OPT_WEBDRIVER_IE_DRIVER) == null) {
            System.setProperty(JVM_OPT_WEBDRIVER_IE_DRIVER, IEDRIVER_LOCATION_DEFAULT);
        }
    }

    private static String getLogConfigLocation() {
        String logConfigLocation = System.getProperty(JVM_OPT_TOMCART_LOG4J_CONFIG);
        if (logConfigLocation == null || "".equals(logConfigLocation)) {
            logConfigLocation = DEFAULT_LOG4J_FILE_LOCATION;
        }

        return logConfigLocation;
    }

    /**
     * Configures Log4J logging framework using default config file.
     */
    private static void configureLogging() {
        String logConfigLocation = getLogConfigLocation();
        try {
            System.out.println(String.format("logConfigLocation: [%s]", logConfigLocation)); // NOSONAR
            DOMConfigurator.configure(new URL(logConfigLocation));
        } catch (MalformedURLException e) {
            System.out.println("FATAL: failed to configure logging."); // NOSONAR
            e.printStackTrace(); // NOSONAR
            System.exit(3);
        }
    }

    /**
     *
     */
    public synchronized static void done() {
        if (context != null) {
            try {
                if (!unitTestMode) {
                    generateExceptionFiles();
                    configureMasterThoughtReports();
                }
                context.close();
            } finally {
                context = null;
                initialized = false;
            }
        }
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

    public static void configureMasterThoughtReports() {
        final String baseDir = context.getBean(WorkspaceUtil.class).getBaseDir();
        final String jsonDir = baseDir + File.separator + "testout/report/features";
        LOGGER.debug("Json Directory : [{}]", jsonDir);
        MTReportsSvc mtReportsSvc = context.getBean(MTReportsSvc.class);
        mtReportsSvc.generateReports(jsonDir);
    }

    /**
     * This method creates 2 files one file: failures.txt in reports directory with list of features
     * and associated tags.
     * Second file: rerunFailedTags.txt in respective temp directory with failed tags concatenated with "or"
     * so, the content can be fed to runbytag.cmd or runbytag.sh for rerun
     */
    private static void generateExceptionFiles() {
        HooksSteps hooksSteps = context.getBean(HooksSteps.class);
        FileDirUtil fileDirUtil = context.getBean(FileDirUtil.class);
        WorkspaceUtil workspaceUtil = context.getBean(WorkspaceUtil.class);

        final String filepath = workspaceUtil.getReportsDir() + File.separator + "failures.txt";
        final LinkedHashMap<String, String> failedTestCases = hooksSteps.getFailuresMap();

        final String reRunnableTags = hooksSteps.getReRunnableTags();
        final String fileData = failedTestCases.keySet().stream()
                .map(key -> key + " : " + failedTestCases.get(key))
                .collect(Collectors.joining("\n"));

        final String rerunTagsPath = workspaceUtil.getReportsDir() + File.separator + "rerunTags.txt";

        fileDirUtil.writeStringToFile(rerunTagsPath, reRunnableTags);
        fileDirUtil.writeStringToFile(filepath, fileData);
    }
}
