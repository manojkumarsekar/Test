package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.dmp.utl.ReconFileHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartDmpSvcConfig {
    @Bean
    public DmpWorkflowSvc dmpWorkflowSvc() {
        return new DmpWorkflowSvc();
    }

    @Bean
    public BulkUploadFormatSvc bulkUploadFormatSvc() {
        return new BulkUploadFormatSvc();
    }

    @Bean
    public TradeLifeCycleSvc tradeLifeCycleSvc() {
        return new TradeLifeCycleSvc();
    }

    @Bean
    public ResearchReportEmailSvc emailSvc() {
        return new ResearchReportEmailSvc();
    }

    @Bean
    public ResearchReportBrsApiSvc researchReportBRSAPISvc() {
        return new ResearchReportBrsApiSvc();
    }

}
