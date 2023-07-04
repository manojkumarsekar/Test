package com.eastspring.tom.cart.cfg;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import( {CartCoreConfig.class, CartLgcyConfig.class, CartDmpConfig.class, CartMospConfig.class, CartPomsConfig.class} )
public class CartBddConfig {

    @Bean
    public RegressionResultsReconSteps regressionResultsReconSteps() {
        return new RegressionResultsReconSteps();
    }
}
