package com.eastspring.tom.cart.bdd;


import com.eastspring.tom.cart.cfg.CartBddConfig;
import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.svc.BambooQtestRptSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.CredentialsUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.google.common.base.Strings;
import org.h2.tools.Server;
import org.kohsuke.args4j.Argument;
import org.kohsuke.args4j.CmdLineException;
import org.kohsuke.args4j.CmdLineParser;
import org.kohsuke.args4j.Option;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;


/**
 * <p>Main class where the execution starts. The method invokes some default parameters.</p>
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class Main {
    private static final Logger LOGGER = LoggerFactory.getLogger(Main.class);
    public static final String TRUE = "true";
    public static final String APPLY_CUSTOM_JSON = "cucumber.json.apply.custom.formatter";

    @Option(name = "--encrypt", usage = "encrypt text using a master password")
    private String toEncrypt;

    @Option(name = "--decrypt", usage = "decrypt text using a master password")
    private String toDecrypt;

    @Option(name = "--master-password", usage = "specify master password for encryption")
    private String masterPassword;

    @Option(name = "--embedded-db-server", usage = "run as embedded db server")
    private String embeddedDbServer;

    @Argument
    private List<String> arguments = new ArrayList<>();

    private void doMain(String... args) {
        CmdLineParser parser = new CmdLineParser(this);
        try {
            parser.parseArgument(args);
        } catch (CmdLineException e) {
            // intentionally swallowed
        }

        if (!Strings.isNullOrEmpty(embeddedDbServer) && TRUE.equals(embeddedDbServer)) {
            try {
                System.setProperty("javabase.jdbc.url", "jdbc:h2:tcp://localhost:9092/nio:/tomwork/cart-dash-db");
                System.setProperty("javabase.jdbc.driver", "org.h2.Driver");
                System.setProperty("javabase.jdbc.username", "sa");
                System.setProperty("javabase.jdbc.password", "");
                Server server = Server.createTcpServer().start();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return;
        }

        if (!Strings.isNullOrEmpty(toEncrypt)) {
            if (!Strings.isNullOrEmpty(toDecrypt)) {
                System.err.print("You can only specify one of --encrypt VAL or --decrypt VAL but not both."); // NOSONAR
                System.exit(2);
            }
            if (!Strings.isNullOrEmpty(masterPassword)) {
                CredentialsUtil credentialsUtil = (CredentialsUtil) CartBootstrap.getBean(CredentialsUtil.class);
                System.out.println(String.format("Encrypted as: [%s]", credentialsUtil.encrypt(toEncrypt, masterPassword))); // NOSONAR
                System.exit(0);
            } else {
                System.err.println("--master-password <master-password> is required to encrypt"); // NOSONAR
                System.exit(2);
            }
        }

        if (!Strings.isNullOrEmpty(toDecrypt)) {
            if (!Strings.isNullOrEmpty(masterPassword)) {
                CredentialsUtil credentialsUtil = (CredentialsUtil) CartBootstrap.getBean(CredentialsUtil.class);
                System.out.println(String.format("Decrypted as: [%s]", credentialsUtil.decrypt(toDecrypt, masterPassword))); // NOSONAR
                System.exit(0);
            } else {
                System.err.println("--master-password <master-password> is required to encrypt");
                System.exit(2);
            }
        }
    }

    /**
     * @param mainArgs arguments for the main methods
     * @throws Throwable catch all throwable
     */
    public static void main(String... mainArgs) throws Throwable {

        new Main().doMain(mainArgs);

        CartBootstrap.setConfigClass(CartBddConfig.class);
        WorkspaceUtil workspaceUtil = (WorkspaceUtil) CartBootstrap.getBean(WorkspaceUtil.class);
        StateSvc stateSvc = (StateSvc) CartBootstrap.getBean(StateSvc.class);

        final String jsonPlugin = stateSvc.getStringVar(APPLY_CUSTOM_JSON).equalsIgnoreCase(TRUE) ?
                "com.eastspring.tom.cart.core.formatter.JsonCustomFormatter" :
                "json";

        String[] alwaysArgs = new String[]{
                "--strict",
                "--monochrome",
                "--glue",
                "tomcart.glue",
                "--plugin",
                "pretty",
                "--plugin",
                "html:testout/report/features",
                "--plugin",
                jsonPlugin + ":testout/report/features/report.json"
        };

        String featuresDir = workspaceUtil.getFeaturesDir();

        String[] additionalArgs = new String[]{
                featuresDir
        };

        List<String> allArgsList = new ArrayList<>();
        allArgsList.addAll(Arrays.asList(alwaysArgs));
        allArgsList.addAll(Arrays.asList(mainArgs));
        allArgsList.addAll(Arrays.asList(additionalArgs));
        LOGGER.info("Main.main args: {}", Objects.toString(allArgsList));

        String[] resultType = new String[0];
        byte exitstatus = cucumber.api.cli.Main.run(allArgsList.toArray(resultType), Thread.currentThread().getContextClassLoader());
        BambooQtestRptSvc bambooQtestRptSvc = (BambooQtestRptSvc) CartBootstrap.getBean(BambooQtestRptSvc.class);
        if ("true".equals(System.getProperty("tomcart.runtime.bamboo.qtest"))) {
            String jsonReportFile = "testout/report/features/report.json";
            String outputFile = "target/surefire-reports/TEST-cart-bdd_output.xml";
            bambooQtestRptSvc.generateSurefireReport(jsonReportFile, outputFile);
        }

        CartBootstrap.done();
        System.exit(exitstatus);
    }
}
