package com.eastspring.qa.cart.pages;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class CartPageConfig {

    @Bean
    public DiagnosticPage diagnosticPage() {
        return new DiagnosticPage();
    }

}