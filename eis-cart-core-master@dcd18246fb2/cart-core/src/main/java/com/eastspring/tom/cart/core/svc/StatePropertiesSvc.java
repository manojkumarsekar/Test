package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.KeyValuePair;
import com.eastspring.tom.cart.core.utl.CredentialsUtil;
import com.eastspring.tom.cart.core.utl.SensitivePassAwareDebugLogUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

public class StatePropertiesSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(StatePropertiesSvc.class);

    private Map<String, String> globalPropsMap = null;

    @Autowired
    private CredentialsUtil credentialsUtil;

    @Autowired
    private SensitivePassAwareDebugLogUtil sensitivePassAwareDebugLogUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    private String masterPassword; // NOSONAR

    @Autowired
    private StateSvc stateSvc;

    public static final String SYS_MASTER_PASS = "sys.master.pass";
    public static final String PASS_POSTFIX = ".pass";
    public static final String PASS_ENCRYPTED_POSTFIX = ".pass.encrypted";

    public synchronized void loadProperties() {
        String propsLocation = workspaceUtil.getEnvDir() + "/tomcart-private.properties";
        LOGGER.debug("loading properties from [{}]", propsLocation);
        try {
            Properties props = new Properties();
            props.load(new FileInputStream(propsLocation));
            masterPassword = props.getProperty(SYS_MASTER_PASS);
            if (masterPassword == null) {
                masterPassword = ""; // NOSONAR
            }
            LOGGER.debug("  assigning master password: [{}]", masterPassword);
            globalPropsMap = new HashMap<>();

            for (String key : props.stringPropertyNames()) {
                globalPropsMap.put(key, props.getProperty(key));
            }

            preExpandInTheMap(globalPropsMap);
        } catch (IOException e) {
            LOGGER.error("failed while loading properties file [{}]", propsLocation, e);
            throw new CartException(e, CartExceptionType.BOOTSTRAP_CONFIG, "failed while loading properties file [{}]", propsLocation);
        }
    }

    public void preExpandInTheMap(Map<String, String> theMap) {
        List<KeyValuePair> toDecryptKeyList = new ArrayList<>();
        for (String key : theMap.keySet()) { // NOSONAR
            if (key.endsWith(PASS_ENCRYPTED_POSTFIX)) {
                String passPrefix = key.substring(0, key.length() - PASS_ENCRYPTED_POSTFIX.length());
                String encryptedValue = theMap.get(key);
                String decryptedPropKey = passPrefix + PASS_POSTFIX;
                if (!theMap.containsKey(decryptedPropKey)) {
                    toDecryptKeyList.add(new KeyValuePair(decryptedPropKey, credentialsUtil.decrypt(encryptedValue, getMasterPassword())));
                    LOGGER.debug("  decrypting {}=[*****]", decryptedPropKey);
                }
            }
        }

        for (KeyValuePair kvp : toDecryptKeyList) {
            theMap.put(kvp.getKey(), kvp.getValue());
        }
    }

    public synchronized String getMasterPassword() {
        return masterPassword;
    }

    public void populateGlobalPropsMap() {
        if (globalPropsMap == null) {
            LOGGER.debug("loadProperties(): first time invocation.");
            this.loadProperties();
        }
    }

    public String getGlobalPropsMap(String name) {
        String result;
        if (globalPropsMap.containsKey(name)) {
            result = globalPropsMap.get(name);
            sensitivePassAwareDebugLogUtil.sensitivePassAwareDebugLog(name, result, "  found in globalPropsMap: [********]", "  found in globalPropsMap: [{}]");
        } else {
            LOGGER.debug("  not found");
            result = "";
        }

        return result;

    }

    /**
     * This method gathers properties under certain prefix into a single {@link Map}&lt;{@link String}, {@link String}&gt;
     * providing simpler access to a group of properties.
     *
     * @param prefix     the prefix from the state string var from where we want the value map collected
     * @param expandVars whether to expand variables specified by those values or keep them as is
     * @return {@link Map}&lt;{@link String}, {@link String}&gt; the value map object
     */
    public Map<String, String> getGlobalMapValueFromPrefix(String prefix, boolean expandVars) {
        List<String> keys = globalPropsMap.keySet().stream().filter(row -> row.startsWith(prefix)).collect(Collectors.toList());
        int prefixLen = prefix.length();
        Map<String, String> result = new HashMap<>();
        for (String key : keys) {
            String shortenedKey = key.substring(prefixLen + 1);
            String value = globalPropsMap.get(key);
            result.put(shortenedKey, expandVars ? stateSvc.expandVar(value) : value);
        }
        return result;
    }

}
