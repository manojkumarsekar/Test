package com.eastspring.tom.cart.core.svc;

import net.masterthought.cucumber.Configuration;
import net.masterthought.cucumber.ReportBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class MTReportsSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(MTReportsSvc.class);

    private String targetDir;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private WebDriverSvc webDriverSvc;

    private void setDefaultProperties() {
        stateSvc.setStringVar("cucumber.reports.platform", System.getProperty("os.name"));
    }

    public void setTargetDir(String targetDir) {
        this.targetDir = workspaceDirSvc.normalize(targetDir);
    }

    private String getTargetDir() {
        return targetDir;
    }

    private List<String> getAllJsonFilesUnderTarget(String folderLocation) {
        List<String> jsonFiles = new ArrayList<>();
        File directory = new File(folderLocation);
        File[] files = directory.listFiles((file, name) -> name.endsWith(".json"));
        if (files != null && files.length > 0) {
            for (File f : files) {
                jsonFiles.add(folderLocation + "/" + f.getName());
            }
        }
        return jsonFiles;
    }

    //report.json will be available under /features folder, but reports should be generated under /summary folder
    private void generateReports() {
        File reportOutputDirectory = new File(getTargetDir().replace("/features", "/summary"));
        List<String> jsonFiles = this.getAllJsonFilesUnderTarget(getTargetDir());

        this.setDefaultProperties();

        String projectName = stateSvc.getStringVar("cucumber.reports.projectName");
        String buildNumber = stateSvc.getStringVar("cucumber.reports.buildnumber");

        Configuration configuration = new Configuration(reportOutputDirectory, projectName);
        configuration.setBuildNumber(buildNumber);
        configuration.setTagsToExcludeFromChart("^@com.eastspring.tom.*", "^@eisst.*");
        configuration.addClassifications("Platform", stateSvc.getStringVar("cucumber.reports.platform"));
        configuration.addClassifications("Browser", stateSvc.getStringVar("cucumber.reports.browser"));
        configuration.addClassifications("Environment", stateSvc.getStringVar("cucumber.reports.env.name"));
        configuration.addClassifications("AppUrl", stateSvc.getStringVar("cucumber.reports.app.url"));

        ReportBuilder reportBuilder = new ReportBuilder(jsonFiles, configuration);
        reportBuilder.generateReports();
    }

    public void generateReports(String targetDir) {
        setTargetDir(targetDir);
        generateReports();
    }

}
