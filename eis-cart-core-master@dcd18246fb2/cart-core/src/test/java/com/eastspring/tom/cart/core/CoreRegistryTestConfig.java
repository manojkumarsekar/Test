package com.eastspring.tom.cart.core;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CoreRegistryTestConfig {
    @Bean
    public CoreRegistryTestBean coreRegistryTestBean() {
        return new CoreRegistryTestBean();
    }
}
