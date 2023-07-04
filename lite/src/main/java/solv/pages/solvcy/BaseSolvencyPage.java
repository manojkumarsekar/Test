package com.eastspring.qa.solvency.pages.solvency;


import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.services.web.BaseWebPage;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;

import java.nio.file.Files;
import java.nio.file.Paths;


@SuppressWarnings("unchecked")
public abstract class BaseSolvencyPage extends BaseWebPage {

    public  void waitUntilFileIsDownloaded(String actualReportFileName){
        int i=10;
        while(!Files.exists(Paths.get(WorkspaceUtil.getExecutionReportsDir(),actualReportFileName))){
            waitTillPageLoads();
            i--;
        }

        if (!Files.exists(Paths.get(WorkspaceUtil.getExecutionReportsDir(), actualReportFileName))) {
            throw new CartException(CartExceptionType.ASSERTION_ERROR,
                    "Downloaded report [{}] is not found in [{}]",
                    actualReportFileName, WorkspaceUtil.getExecutionReportsDir());
        }
    }
}
