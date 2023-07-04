package stepdefinitions;

import io.cucumber.spring.CucumberContextConfiguration;
import com.eastspring.qa.cart.context.CartCoreConfig;
import org.springframework.test.context.ContextConfiguration;


@CucumberContextConfiguration
@ContextConfiguration(classes = CartCoreConfig.class)
public class CartCucumberStepConfig {
}