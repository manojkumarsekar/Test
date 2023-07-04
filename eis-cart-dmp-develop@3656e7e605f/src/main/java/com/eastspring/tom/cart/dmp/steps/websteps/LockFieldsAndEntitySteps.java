package com.eastspring.tom.cart.dmp.steps.websteps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.dmp.pages.LockFieldsAndEntityPage;
import com.eastspring.tom.cart.dmp.pages.customer.master.ExternalAccountPage;
import com.eastspring.tom.cart.dmp.steps.DmpGsPortalSteps;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Map;

public class LockFieldsAndEntitySteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(LockFieldsAndEntitySteps.class);

    @Autowired
    private LockFieldsAndEntityPage lockFieldsAndEntityPage;

    @Autowired
    private DmpGsPortalSteps portalSteps;

    @Autowired
    private StateSvc stateSvc;

    public void iLockEntity() {
        lockFieldsAndEntityPage.lockEntity();
    }

    public void iUnlockEntity() {
        lockFieldsAndEntityPage.unLockEntity();
    }

    public void iAddLockOnField(String lockType, String fieldName) {
        String expandFieldName = stateSvc.expandVar(fieldName);
        lockFieldsAndEntityPage.AddLockOnField(lockType, expandFieldName);
    }

    public void iRemoveLockOnField(String fieldName) {
        String expandFieldName = stateSvc.expandVar(fieldName);
        lockFieldsAndEntityPage.removeLockOnField(expandFieldName);
    }

    public void iVerifyLockOnField(String fieldName, String lockType) {
        String expandFieldName = stateSvc.expandVar(fieldName);
        if (!lockFieldsAndEntityPage.isFieldLocked(lockType)) {
            LOGGER.error("Field {} not locked using {} ", expandFieldName, lockType);
        }
    }

    public void iVerifyFieldUnlocked(String fieldName, String lockType) {
        String expandFieldName = stateSvc.expandVar(fieldName);
        if (lockFieldsAndEntityPage.isFieldLocked(lockType)) {
            LOGGER.error("{} lock type is still present after unlocking the field {}", lockType, expandFieldName);
        }
    }

    public void iVerifyEntitylocked(String entityName, String actionType) {
        String expandEntityName = stateSvc.expandVar(entityName);
        if (actionType.equals("locked")) {
            if (!lockFieldsAndEntityPage.isEntityLocked()) {
                LOGGER.error("Locking of entity {} has failed", expandEntityName);
            }
        } else if (lockFieldsAndEntityPage.isEntityLocked()) {
            LOGGER.error("Unlocking of entity {} has failed", expandEntityName);
        }
    }

    public void iVerifyRecordlocked(String recordName, String actionType) {
        String expandRecordName = stateSvc.expandVar(recordName);
        if (actionType.equals("locked")) {
            if (!lockFieldsAndEntityPage.isRecordLocked(actionType)) {
                LOGGER.error("Record lock not applied to the record {}", expandRecordName);
            }
        } else if (lockFieldsAndEntityPage.isRecordLocked(actionType)) {
            LOGGER.error("Record lock not removed from the record {}", expandRecordName);
        }
    }
}
