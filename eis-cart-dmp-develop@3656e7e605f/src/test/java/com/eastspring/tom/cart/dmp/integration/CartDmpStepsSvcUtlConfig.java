package com.eastspring.tom.cart.dmp.integration;

import com.eastspring.tom.cart.core.steps.CartCoreStepsConfig;
import com.eastspring.tom.cart.core.svc.CartCoreSvcConfig;
import com.eastspring.tom.cart.core.utl.CartCoreUtlConfig;
import com.eastspring.tom.cart.dmp.pages.CartDmpPagesConfig;
import com.eastspring.tom.cart.dmp.steps.CartDmpStepsConfig;
import com.eastspring.tom.cart.dmp.svc.CartDmpSvcConfig;
import com.eastspring.tom.cart.dmp.utl.CartDmpUtlConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import({CartDmpStepsConfig.class, CartCoreStepsConfig.class, CartDmpSvcConfig.class, CartDmpUtlConfig.class, CartCoreSvcConfig.class, CartCoreUtlConfig.class, CartDmpPagesConfig.class})
public class CartDmpStepsSvcUtlConfig {
}
