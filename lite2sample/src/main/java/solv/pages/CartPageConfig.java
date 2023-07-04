package com.eastspring.qa.modelaut.pages;


import com.eastspring.qa.modelaut.pages.google.ResultPage;
import com.eastspring.qa.modelaut.pages.google.SearchPage;
import com.eastspring.qa.modelaut.pages.gs.HomePage;
import com.eastspring.qa.modelaut.pages.gs.LoginPage;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class CartPageConfig {

    @Bean
    public HomePage homePage() { return new HomePage(); }

    @Bean
    public LoginPage loginPage() {
        return new LoginPage();
    }

    @Bean
    public SearchPage searchPage() { return new SearchPage(); }

    @Bean
    public ResultPage resultPage() {
        return new ResultPage();
    }
}