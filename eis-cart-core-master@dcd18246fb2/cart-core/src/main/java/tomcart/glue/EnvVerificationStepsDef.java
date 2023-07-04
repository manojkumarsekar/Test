package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.core.svc.EnvVerificationSvc;
import cucumber.api.java8.En;

/**
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class EnvVerificationStepsDef implements En {
    private EnvVerificationSvc envVerificationSvc = (EnvVerificationSvc) CartBootstrap.getBean(EnvVerificationSvc.class);

    public EnvVerificationStepsDef() {
        Then("I expect to be able to reach TCP service listening to port {string} on host {string}", (String tcpPortStr, String host) -> envVerificationSvc.verifyReachableTcpService(host, tcpPortStr));

        Then("I expect to be able to login to named host {string}", (String namedHost) -> envVerificationSvc.verifyNamedHostSshLogin(namedHost));
    }
}
