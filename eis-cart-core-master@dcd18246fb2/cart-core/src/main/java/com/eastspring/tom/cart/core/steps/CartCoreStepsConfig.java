package com.eastspring.tom.cart.core.steps;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartCoreStepsConfig {

    @Bean
    public HooksSteps hooksSteps() {
        return new HooksSteps();
    }

    @Bean
    public ConfigSteps configSteps() {
        return new ConfigSteps();
    }

    @Bean
    public ControlMSteps controlMSteps() {
        return new ControlMSteps();
    }

    @Bean
    public DatabaseSteps databaseSteps() {
        return new DatabaseSteps();
    }

    @Bean
    public FileDirSteps fileExtractionSteps() {
        return new FileDirSteps();
    }

    @Bean
    public HostSteps hostSteps() {
        return new HostSteps();
    }

    @Bean
    public ReconciliationSteps reconciliationSteps() {
        return new ReconciliationSteps();
    }

    @Bean
    public VerificationSteps verificationSteps() {
        return new VerificationSteps();
    }

    @Bean
    public WebSteps webSteps() {
        return new WebSteps();
    }

    @Bean
    public PdfValidationSteps pdfValidationSteps() {
        return new PdfValidationSteps();
    }

    @Bean
    public RestApiSteps restApiSteps() {
        return new RestApiSteps();
    }

    @Bean
    public XmlValidationSteps xmlValidationSteps() {
        return new XmlValidationSteps();
    }
}
