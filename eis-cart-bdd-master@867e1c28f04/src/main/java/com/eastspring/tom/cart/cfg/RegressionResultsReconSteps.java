package com.eastspring.tom.cart.cfg;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.HtmlGenUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.eastspring.tom.cart.dmp.utl.DmpFileHandlingUtl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class RegressionResultsReconSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(RegressionResultsReconSteps.class);
    private static final String RELEASE_REGRESSION_RECON_FAILED = "Release regression has {} new failures, which are not present in master regression";

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private HtmlGenUtil htmlGenUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private DmpFileHandlingUtl dmpFileHandlingUtl;

//    public void compareRegressionResults(String masterResults, String releaseResults) {
//        final String masterOverviewPath = returnOverViewHtmlPath(masterResults);
//        final String releaseOverviewPath = returnOverViewHtmlPath(releaseResults);
//
//        final List<String> master = getListOfFailedFeatures(masterOverviewPath);
//        final List<String> release = getListOfFailedFeatures(releaseOverviewPath);
//
//        final String header = htmlGenUtil.createHeader(Arrays.asList("Feature Name", "Is Failed In Master?"));
//        StringBuilder tableData = new StringBuilder(header);
//
//        for (String featureName : release) {
//            String status = "NO";
//            if (master.contains(featureName)) {
//                status = "YES";
//            }
//            tableData.append(htmlGenUtil.createRow(Arrays.asList(featureName, status)));
//        }
//        scenarioUtil.embed(htmlGenUtil.generateHtmlCode(tableData.toString()).getBytes(), "text/html");
//    }
//
//    private List<String> getListOfFailedFeatures(final String overViewPath) {
//        List<String> result;
//        File input = new File(overViewPath);
//        try {
//            Document doc = Jsoup.parse(input, "UTF-8", "http://example.com/");
//            result = doc.select("table#tablesorter tbody tr td:nth-of-type(12).failed")
//                    .stream()
//                    .map(x -> x.parent().getElementsByClass("tagname").text())
//                    .collect(Collectors.toList());
//        } catch (IOException e) {
//            throw new CartException(CartExceptionType.IO_ERROR, e);
//        }
//        return result;
//    }
//
//    private String returnOverViewHtmlPath(final String basePath) {
//        String expandBasePath = stateSvc.expandVar(basePath);
//        if (!expandBasePath.endsWith("cucumber-html-reports\\overview-features.html")) {
//            expandBasePath = expandBasePath + File.separator + "cucumber-html-reports" + File.separator + "overview-features.html";
//        }
//        return expandBasePath;
//    }

    public void compareRegressionResults(final String releasePath, final String masterPath) {
        final String absReleasePath = workspaceDirSvc.normalize(stateSvc.expandVar(releasePath));
        final String absMasterPath = workspaceDirSvc.normalize(stateSvc.expandVar(masterPath));

        Map<String, String> releaseFailuresMap = getMapOfFeaturesAndTags(absReleasePath);
        Map<String, String> masterFailuresMap = getMapOfFeaturesAndTags(absMasterPath);

        if (!releaseFailuresMap.isEmpty()) {

            Map<String, String> releaseOnlyFailures = new HashMap<>();

            final Set<String> releaseFeatures = releaseFailuresMap.keySet();
            for (String failure : releaseFeatures) {
                if (!masterFailuresMap.containsKey(failure)) {
                    releaseOnlyFailures.put(failure, releaseFailuresMap.get(failure));
                }
            }

            if (!releaseOnlyFailures.isEmpty()) {
                scenarioUtil.write("Below Attachment shows Release specific failures");
                embedFailuresToReport(releaseOnlyFailures);
                LOGGER.error(RELEASE_REGRESSION_RECON_FAILED, releaseOnlyFailures.size());
                throw new CartException(CartExceptionType.VERIFICATION_FAILED, RELEASE_REGRESSION_RECON_FAILED, releaseOnlyFailures.size());
            }
        }
    }

    private void embedFailuresToReport(final Map<String, String> map) {
        final String header = htmlGenUtil.createHeader(Arrays.asList("Feature Name", "Tags to execute"));
        StringBuilder tableData = new StringBuilder(header);

        for (Map.Entry<String, String> entry : map.entrySet()) {
            tableData.append(htmlGenUtil.createRow(Arrays.asList(entry.getKey(), entry.getValue())));
        }
        scenarioUtil.embed(htmlGenUtil.generateHtmlCode(tableData.toString()).getBytes(), "text/html");
    }

    public void checkFileExistsInLocalFolder(final String filepath) {
        final String absolutePath = workspaceDirSvc.normalize(stateSvc.expandVar(filepath));
        if (!fileDirUtil.verifyFileExists(absolutePath)) {
            LOGGER.error("[{}] file is not available or created", absolutePath);
            throw new CartException(CartExceptionType.IO_ERROR, "[{}] file is not available or created", absolutePath);
        }

    }

    private Map<String, String> getMapOfFeaturesAndTags(final String failuresFilePath) {
        Map<String, String> result = new HashMap<>();
        for (String row : dmpFileHandlingUtl.getFileContentToList(failuresFilePath)) {
            final String[] arr = row.split(":");
            result.put(arr[0].trim(), arr[1].trim());
        }
        return result;
    }


}
