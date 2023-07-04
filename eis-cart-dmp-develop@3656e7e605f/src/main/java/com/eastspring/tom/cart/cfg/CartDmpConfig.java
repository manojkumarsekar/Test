package com.eastspring.tom.cart.cfg;

import com.eastspring.tom.cart.dmp.pages.CartDmpPagesConfig;
import com.eastspring.tom.cart.dmp.steps.CartDmpStepsConfig;
import com.eastspring.tom.cart.dmp.svc.CartDmpSvcConfig;
import com.eastspring.tom.cart.dmp.utl.CartDmpUtlConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@Import({CartDmpStepsConfig.class, CartDmpSvcConfig.class, CartDmpUtlConfig.class , CartDmpPagesConfig.class})
public class CartDmpConfig {

}
