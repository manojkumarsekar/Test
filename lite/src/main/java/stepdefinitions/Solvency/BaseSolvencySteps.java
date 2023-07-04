package stepdefinitions.Solvency;

import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;
import com.eastspring.qa.solvency.pages.solvency.*;
import com.eastspring.qa.solvency.pages.solvency.FileUploadPopUpPage;
import com.eastspring.qa.solvency.pages.solvency.HomePage;
import com.eastspring.qa.solvency.pages.solvency.LbuUploadPage;
import com.eastspring.qa.solvency.pages.solvency.ValidationPage;
import org.springframework.beans.factory.annotation.Autowired;
import solv.db.solvb.SolvencyDatabase;

import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;



public class BaseSolvencySteps {

    @Autowired
    protected AppConfigManager appConfigManager;

    @Autowired
    protected HomePage homePage;

    @Autowired
    protected LbuUploadPage lbuUploadPage;

    @Autowired
    protected FileUploadPopUpPage fileUploadPopUpPage;

    @Autowired
    protected SolvencyDatabase gcDatabase;

    @Autowired
    protected ValidationPage validationPage;


    @Autowired
    protected ReportPage reportpage;

    @Autowired
    protected DataUploadPage dataUploadPage;

}