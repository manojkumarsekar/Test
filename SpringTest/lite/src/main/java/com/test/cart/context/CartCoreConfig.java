package com.eastspring.qa.cart.context;

import com.eastspring.qa.cart.core.report.CartCoreReportConfig;
import com.eastspring.qa.cart.core.utils.CartCoreUtilConfig;
import com.eastspring.qa.cart.pages.CartPageConfig;
import com.eastspring.qa.cart.core.configmanagers.CartConfigMgrSvcConfig;
import com.eastspring.qa.cart.core.reusablesteps.CartCoreStepsConfig;
import com.eastspring.qa.cart.core.services.CartCoreSvcConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * This is the Java annotation based Spring dependency injection configuration.
 */

@Configuration
@Import({
        CartCoreUtilConfig.class,
        CartCoreSvcConfig.class,
        CartCoreStepsConfig.class,
        CartCoreReportConfig.class,
        CartPageConfig.class,
        CartConfigMgrSvcConfig.class
})
public class CartCoreConfig {
}