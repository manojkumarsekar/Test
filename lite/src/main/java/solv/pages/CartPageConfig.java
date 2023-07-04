package com.eastspring.qa.solvency.pages;

import com.eastspring.qa.solvency.pages.solvency.*;
import com.eastspring.qa.solvency.utils.business.ValidationReportFileUtil;
import com.eastspring.qa.solvency.utils.common.ZipFolderUtil;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class CartPageConfig {


    @Bean
    public HomePage homePage() {
        return new HomePage();
    }

    @Bean
    public LbuUploadPage lbuPage() {
        return new LbuUploadPage();
    }

    @Bean
    public ValidationPage validationPage() {
        return new ValidationPage();
    }

    @Bean
    public FileUploadPopUpPage fileUploadPopUpPage() {
        return new FileUploadPopUpPage();
    }


    @Bean
    public ReportPage reportPage() {
        return new ReportPage();
    }

    @Bean
    public DataUploadPage dataUploadPage() {
        return new DataUploadPage();

    }


}