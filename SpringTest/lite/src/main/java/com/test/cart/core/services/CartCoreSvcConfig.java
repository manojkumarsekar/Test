package com.eastspring.qa.cart.core.services;

import com.eastspring.qa.cart.core.services.data.SparkSvc;
import com.eastspring.qa.cart.core.services.db.DBConnectionManagerSvc;
import com.eastspring.qa.cart.core.services.web.WebDriverManagerSvc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class CartCoreSvcConfig {

    @Bean
    public DBConnectionManagerSvc dbConnectionManagerSvc() {
        return new DBConnectionManagerSvc();
    }

    @Bean
    public WebDriverManagerSvc webDriverManagerSvc() {
        return new WebDriverManagerSvc();
    }

    @Bean
    public SparkSvc sparkSvc() {
        return new SparkSvc();
    }
}