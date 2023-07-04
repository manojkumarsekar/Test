package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.dmp.utl.mdl.TrdNuggetsSpec;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartDmpUtlConfig {
    @Bean
    public DmpWsdlUtil dmpWsdlUtil() {
        return new DmpWsdlUtil();
    }

    @Bean
    public DmpFileHandlingUtl dmpFileHandlingUtl() {
        return new DmpFileHandlingUtl();
    }

    @Bean
    public DmpGsPortalUtl dmpGsPortalUtl() {
        return new DmpGsPortalUtl();
    }

    @Bean
    public DmpGsWorkflowUtl dmpGsWorkflowUtl() {
        return new DmpGsWorkflowUtl();
    }

    @Bean
    public TrdNuggetsSpec tradeNuggetsTemplates() {
        return new TrdNuggetsSpec();
    }

    @Bean
    public TarUtl tarUtl() {
        return new TarUtl();
    }

    @Bean
    public TradeLifeCycleUtl tradeLifeCycleUtl() {
        return new TradeLifeCycleUtl();
    }

    @Bean
    public BulkUploadUtl bulkUploadUtl() {
        return new BulkUploadUtl();
    }

    @Bean
    public BusinessDayUtl businessDayUtl() {
        return new BusinessDayUtl();
    }

    @Bean
    public EmailUtl emailUtl() {
        return new EmailUtl();
    }

    @Bean
    public BrsApiUtl brsApiUtl() {
        return new BrsApiUtl();
    }

    @Bean
    public TradeValidationUtl tradeValidationUtl() {
        return new TradeValidationUtl();
    }

    @Bean
    public ReconFileHandler reconFileHandler() {
        return new ReconFileHandler();
    }
}
