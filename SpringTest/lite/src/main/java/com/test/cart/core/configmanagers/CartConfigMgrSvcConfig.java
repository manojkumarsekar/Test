package com.eastspring.qa.cart.core.configmanagers;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class CartConfigMgrSvcConfig {

    @Bean
    public AppConfigManager appConfigManager() {
        return new AppConfigManager();
    }

}