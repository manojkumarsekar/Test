package com.eastspring.qa.context;

import solv.db.CartDatabaseConfig;
import com.eastspring.qa.solvency.pages.CartPageConfig;
import com.eastspring.qa.cart.context.CartCoreConfig;
import com.eastspring.qa.solvency.utils.CartUtilConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import com.eastspring.qa.solvency.reusablesteps.CartStepConfig;

/**
 * This is the Java annotation based Spring dependency injection configuration.
 */
@Configuration
@Import({CartCoreConfig.class, CartPageConfig.class, CartDatabaseConfig.class, CartUtilConfig.class, CartStepConfig.class})
public class CartExtendedConfig {

}