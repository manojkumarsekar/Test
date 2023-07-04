package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.utl.CartCoreUtlConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import({CartCoreSvcConfig.class, CartCoreUtlConfig.class})
public class CartCoreSvcUtlTestConfig {
}
