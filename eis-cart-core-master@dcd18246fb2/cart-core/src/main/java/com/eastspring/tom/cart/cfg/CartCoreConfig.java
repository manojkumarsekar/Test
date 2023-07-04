package com.eastspring.tom.cart.cfg;

import com.eastspring.tom.cart.core.steps.CartCoreStepsConfig;
import com.eastspring.tom.cart.core.svc.CartCoreSvcConfig;
import com.eastspring.tom.cart.core.utl.CartCoreUtlConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

/**
 * This is the Java annotation based Spring dependency injection configuration.
 */
@Configuration
@Import({CartCoreUtlConfig.class, CartCoreSvcConfig.class, CartCoreStepsConfig.class})
public class CartCoreConfig {
    public static final String GLBCONF_WORKING_DIR = "working.dir";
    public static final String SKIP_FEATURE_TESTS = "skipFeatureTests";
}
