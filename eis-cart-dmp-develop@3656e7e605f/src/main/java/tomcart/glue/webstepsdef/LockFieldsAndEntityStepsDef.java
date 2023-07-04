package tomcart.glue.webstepsdef;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.dmp.steps.websteps.LockFieldsAndEntitySteps;
import cucumber.api.java.en.*;

public class LockFieldsAndEntityStepsDef {

    private LockFieldsAndEntitySteps steps = (LockFieldsAndEntitySteps) CartBootstrap.getBean(LockFieldsAndEntitySteps.class);

    @When("I lock an entity")
    public void i_lock_an_entity() {
        steps.iLockEntity();
    }

    @When("I unlock an entity")
    public void i_unlock_lock() {
        steps.iUnlockEntity();
    }

    @When("I add {string} lock for {string} field")
    public void i_add_lock_on_field(String lockType, String fieldName) {
        steps.iAddLockOnField(lockType, fieldName);
    }

    @When("I remove lock for {string} field")
    public void i_remove_lock_on_fild(String fieldName) {
        steps.iRemoveLockOnField(fieldName);
    }

    @Then("I should see the {string} is locked using {string} lock")
    public void i_verify_field_is_locked(String fieldName, String lockType) {
        steps.iVerifyLockOnField(fieldName, lockType);
    }

    @Then("I should see the {string} lock from the {string} is removed")
    public void i_verify_field_is_unlocked(String fieldName, String lockType) {
        steps.iVerifyFieldUnlocked(fieldName, lockType);
    }

    @Then("I should see the entity {string} is {string}")
    public void i_verify_entity_locked(String entityName, String actionType) {
        steps.iVerifyEntitylocked(entityName, actionType);
    }

    @Then("I should see the record {string} is {string}")
    public void i_verify_record_locked(String recordName, String actionType) {
        steps.iVerifyRecordlocked(recordName, actionType);
    }
}

