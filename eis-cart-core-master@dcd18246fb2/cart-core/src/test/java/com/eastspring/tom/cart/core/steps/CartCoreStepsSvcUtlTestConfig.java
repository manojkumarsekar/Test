package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.svc.CartCoreSvcUtlTestConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import({CartCoreStepsConfig.class, CartCoreSvcUtlTestConfig.class})
public class CartCoreStepsSvcUtlTestConfig {
}
