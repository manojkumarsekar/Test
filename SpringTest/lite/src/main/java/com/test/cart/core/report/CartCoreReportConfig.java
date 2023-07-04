package com.eastspring.qa.cart.core.report;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class CartCoreReportConfig {

    @Bean
    public CartLogger reportLogger() {
        return new CartLogger();
    }

}