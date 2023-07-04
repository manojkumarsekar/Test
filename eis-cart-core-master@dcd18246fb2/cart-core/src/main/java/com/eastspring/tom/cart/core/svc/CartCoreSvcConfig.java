package com.eastspring.tom.cart.core.svc;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartCoreSvcConfig {

    @Bean
    public MsTeamsIntegrationSvc msTeamsIntegrationSvc() {
        return new MsTeamsIntegrationSvc();
    }

    @Bean
    public BambooQtestRptSvc bambooQtestRptSvc() {
        return new BambooQtestRptSvc();
    }

    @Bean
    public ControlMSvc controlMSvc() {
        return new ControlMSvc();
    }

    @Bean
    public CompressionSvc compressionSvc() {
        return new CompressionSvc();
    }

    @Bean
    public CsvStagingSvc csvStagingSvc() {
        return new CsvStagingSvc();
    }

    @Bean
    public CsvSvc csvSvc() {
        return new CsvSvc();
    }

    @Bean
    public DatabaseSvc databaseSvc() {
        return new DatabaseSvc();
    }

    @Bean
    public EnvVerificationSvc envVerificationSvc() {
        return new EnvVerificationSvc();
    }

    @Bean
    public ExcelFileSvc excelFileSvc() {
        return new ExcelFileSvc();
    }

    @Bean
    public FileDirSvc fileDirSvc() {
        return new FileDirSvc();
    }

    @Bean
    public FileTransformSvc fileTransformSvc() {
        return new FileTransformSvc();
    }

    @Bean
    public FileValidationSvc fileValidationSvc() {
        return new FileValidationSvc();
    }

    @Bean
    public FmTemplateSvc fmTemplateSvc() {
        return new FmTemplateSvc();
    }

    @Bean
    public JdbcSvc jdbcSvc() {
        return new JdbcSvc();
    }

    @Bean
    public RuntimeRemoteSvc runtimeRemoteSvc() {
        return new RuntimeRemoteSvc();
    }

    @Bean
    public ReconciliationSvc reconciliationSvc() {
        return new ReconciliationSvc();
    }

    @Bean
    public StatePropertiesSvc statePropertiesSvc() {
        return new StatePropertiesSvc();
    }

    @Bean
    public StateSvc stateSvc() {
        return new StateSvc();
    }

    @Bean
    public StringFunctionSvc stringFunctionSvc() {
        return new StringFunctionSvc();
    }

    @Bean
    public ThreadSvc threadSvc() {
        return new ThreadSvc();
    }

    @Bean
    public VerificationSvc verificationSvc() {
        return new VerificationSvc();
    }

    @Bean
    public WebTaskSvc webTaskSvc() {
        return new WebTaskSvc();
    }

    @Bean
    public WorkspaceDirSvc workspaceDirSvc() {
        return new WorkspaceDirSvc();
    }

    @Bean
    public XmlSvc xmlSvc() {
        return new XmlSvc();
    }

    @Bean
    public MTReportsSvc mtReportsSvc() {
        return new MTReportsSvc();
    }

    @Bean
    public PdfValidationSvc pdfValidationSvc() {
        return new PdfValidationSvc();
    }

    @Bean
    public RestApiSvc restApiSvc() {
        return new RestApiSvc();
    }

    @Bean
    public DataTableSvc dataTableSvc() {
        return new DataTableSvc();
    }

    @Bean
    public WebDriverSvc webDriverSvc() {
        return new WebDriverSvc();
    }


}
