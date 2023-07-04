package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.steps.WebSteps;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import com.eastspring.tom.cart.dmp.svc.DmpWorkflowSvc;
import com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl;
import com.google.common.base.Strings;
import cucumber.api.java.After;
import cucumber.api.java.Before;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collection;

/**
 * <p>This class contains @Before hooks for DMP GS Database and API</p>
 *
 * @author Mahesh
 * @since 2018-06
 */
public class DmpHooks {

    private static final Logger LOGGER = LoggerFactory.getLogger(DmpHooks.class);
    private static final String DMP_WS_WORKFLOW = "dmp.ws.WORKFLOW";
    private static final String DMP_DB_GC = "dmp.db.GC";

    private DmpWorkflowSvc dmpWorkflowSvc = (DmpWorkflowSvc) CartBootstrap.getBean(DmpWorkflowSvc.class);
    private DatabaseSvc databaseSvc = (DatabaseSvc) CartBootstrap.getBean(DatabaseSvc.class);
    private DmpGsWorkflowUtl dmpGsWorkflowUtl = (DmpGsWorkflowUtl) CartBootstrap.getBean(DmpGsWorkflowUtl.class);
    private DmpGsPortalSteps dmpGsPortalSteps = (DmpGsPortalSteps) CartBootstrap.getBean(DmpGsPortalSteps.class);
    private WebTaskSvc webTaskSvc = (WebTaskSvc) CartBootstrap.getBean(WebTaskSvc.class);
    private WebSteps webSteps = (WebSteps) CartBootstrap.getBean(WebSteps.class);
    private StateSvc stateSvc = (StateSvc) CartBootstrap.getBean(StateSvc.class);
    private ScenarioUtil scenarioUtil = (ScenarioUtil) CartBootstrap.getBean(ScenarioUtil.class);

    private boolean isItDmpTest() {
        return stateSvc.getValueMapFromPrefix(DMP_DB_GC, true).size() > 0;
    }

    @Before( order = 1 )
    public void setupGsDbConfig() {
        if (isItDmpTest()) {
            if (!scenarioUtil.getTagNames().contains("@ignore_hooks")) {
                LOGGER.debug("Setting Database Connection ConfigName as [{}]", DMP_DB_GC);
                databaseSvc.setDatabaseConnectionToConfig(DMP_DB_GC);
            }
        }
    }

    @Before( order = 1 )
    public void setupGsApiConfig() {
        if (isItDmpTest()) {
            if (!scenarioUtil.getTagNames().contains("@ignore_hooks")) {
                LOGGER.debug("Setting Web Service ConfigName as [{}]", DMP_WS_WORKFLOW);
                dmpWorkflowSvc.setWebServiceConfigName(DMP_WS_WORKFLOW);
            }
        }
    }

    @Before( "not @web" )
    public void clearWorkflowTemplateParams() {
        if (isItDmpTest()) {
            dmpGsWorkflowUtl.clearAllTemplateParams();
        }
    }


    @After( "@gs_ui_menu_verification" )
    public void recoverGsUiWhenFailure() {
        if (scenarioUtil.isScenarioFailed()) {
            Collection<String> tagNames = scenarioUtil.getTagNames();
            String role = "";
            if (tagNames.contains("@gs_ui_verify_admin_menu")) {
                role = "administrators";
            } else if (tagNames.contains("@gs_ui_verify_user_role_menu")) {
                role = "users";
            } else if (tagNames.contains("@gs_ui_verify_task_supervisor_menu")) {
                role = "task_supervisor";
            } else if (tagNames.contains("@gs_ui_verify_task_assignee_menu")) {
                role = "task_assignee";
            } else if (tagNames.contains("@gs_ui_verify_task_auth_menu")) {
                role = "task_authorizer";
            } else if (tagNames.contains("@gs_ui_verify_readonly_menu")) {
                role = "readonly";
            }
            LOGGER.info("Recovering GS UI with role [{}]", role);
            webTaskSvc.quitWebDriver();
            dmpGsPortalSteps.loginToGSWithUserRole(role);
        }
    }

    @Before( "@tlc9000" )
    public void waitBeforeEachTLCScenario() {
        Integer seconds = Integer.valueOf(stateSvc.getStringVar("tlc.scenario.wait.seconds"));
        if (Strings.isNullOrEmpty(String.valueOf(seconds))) {
            seconds = 1;
        }
        webSteps.pauseForSeconds(seconds);
    }
}
