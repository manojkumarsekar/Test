package com.eastspring.qa.context;

import com.eastspring.qa.modelaut.databases.CartDatabaseConfig;
import com.eastspring.qa.modelaut.pages.CartPageConfig;
import com.eastspring.qa.cart.context.CartCoreConfig;
import com.eastspring.qa.modelaut.utils.CartUtilConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import com.eastspring.qa.modelaut.reusablesteps.CartStepConfig;

/**
 * This is the Java annotation based Spring dependency injection configuration.
 */
@Configuration
@Import({CartCoreConfig.class, CartPageConfig.class, CartDatabaseConfig.class, CartUtilConfig.class, CartStepConfig.class})
public class CartExtendedConfig {

}