package stepdefinitions;

import io.cucumber.spring.CucumberContextConfiguration;
import com.eastspring.qa.context.CartExtendedConfig;
import org.springframework.test.context.ContextConfiguration;


@CucumberContextConfiguration
@ContextConfiguration(classes = CartExtendedConfig.class)
public class CartCucumberStepConfig {
}