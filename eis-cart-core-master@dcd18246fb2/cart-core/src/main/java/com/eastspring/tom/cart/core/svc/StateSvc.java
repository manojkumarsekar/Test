package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RegexVars;
import com.eastspring.tom.cart.core.utl.*;
import com.google.common.base.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;

import static com.eastspring.tom.cart.core.svc.WebDriverSvc.CUCUMBER_REPORTS_BROWSER;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class StateSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(StateSvc.class);

    public static final String WEB_INBETWEEN_STEPS_WAIT_MILLIS = "web.inbetween.steps.wait.millis";
    public static final String CURRENT_ENV_NAME = "current.env.name";
    public static final String VAR_INDICATOR = "${";

    private ThreadLocal<Map<String, String>> stringMap = ThreadLocal.withInitial(HashMap::new);
    private Map<String, Long> longMap = new HashMap<>();
    private Map<String, String> envStringMap = new HashMap<>();

    @Autowired
    private CredentialsUtil credentialsUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private SensitivePassAwareDebugLogUtil sensitivePassAwareDebugLogUtil;

    @Autowired
    private StatePropertiesSvc statePropertiesSvc;

    public StateSvc() {
        longMap.put(WEB_INBETWEEN_STEPS_WAIT_MILLIS, 0L);
    }

    public void loadProperties() {
        statePropertiesSvc.loadProperties();
    }


    /**
     * This method use (and load) the configuration from a named configuration, which maps to an environment
     * configuration file with the name of env_${EN_NAME}.properties.
     *
     * @param envName the name part of the &quot;named environment&quot;
     */
    public void useNamedEnvironment(String envName) {
        String expandEnvName = this.expandVar(envName);
        String envPropertiesPath = workspaceUtil.getEnvDir() + "/env_" + expandEnvName + ".properties";
        LOGGER.debug("loading environment properties from [{}]", envPropertiesPath);
        envStringMap = new HashMap<>();
        try {
            Properties props = new Properties();
            props.load(new FileInputStream(envPropertiesPath));
            for (String key : props.stringPropertyNames()) {
                LOGGER.debug("  [{}] => [{}]", key, props.getProperty(key));
                envStringMap.put(key, props.getProperty(key));
            }
            statePropertiesSvc.preExpandInTheMap(envStringMap);
            envStringMap.put(CURRENT_ENV_NAME, envName);
        } catch (IOException e) {
            LOGGER.error("failed when loading named environment [{}] config from environment properties file [{}]", expandEnvName, envPropertiesPath, e);
            throw new CartException(e, CartExceptionType.BOOTSTRAP_CONFIG, "failed when loading named environment [{}] config from environment properties file [{}]", expandEnvName, envPropertiesPath);
        }
    }


    /**
     * Gets string var.
     * Hierarchy of getting a value based on var name is
     * System property -> Strings assigned in features -> env properties -> tomcart-private.properties
     *
     * @param name the name
     * @return the string var
     */
    public String getStringVar(String name) {
        if (Strings.isNullOrEmpty(name)) {
            return "";
        }

        String result = System.getProperty(name);
        if (!Strings.isNullOrEmpty(result)) {
            return result;
        }

        if (!name.startsWith("cucumber.json")) {
            LOGGER.debug("lookup string var [{}]", name);
        }

        statePropertiesSvc.populateGlobalPropsMap();

        lazyExpandInTheMap(stringMap.get(), name);
        if (stringMap.get().containsKey(name)) {
            result = stringMap.get().get(name);
            sensitivePassAwareDebugLogUtil.sensitivePassAwareDebugLog(name, result, "  found in stringMap: [********]", "  found in stringMap: [{}]");
            return result;
        }

        lazyExpandInTheMap(envStringMap, name);
        if (envStringMap.containsKey(name)) {
            result = envStringMap.get(name);
            sensitivePassAwareDebugLogUtil.sensitivePassAwareDebugLog(name, result, "  found in envStringMap: [********]", "  found in envStringMap: [{}]");
            return result;
        }

        return statePropertiesSvc.getGlobalPropsMap(name);

    }

    private void lazyExpandInTheMap(Map<String, String> theMap, String name) {
        if (name != null && name.endsWith(StatePropertiesSvc.PASS_POSTFIX)) {
            String passPrefix = name.substring(0, name.length() - StatePropertiesSvc.PASS_POSTFIX.length());
            String encryptedPropKey = passPrefix + StatePropertiesSvc.PASS_ENCRYPTED_POSTFIX;
            if (theMap.containsKey(encryptedPropKey)) {
                String encryptedValue = theMap.get(encryptedPropKey);
                String decryptedValue = credentialsUtil.decrypt(encryptedValue, statePropertiesSvc.getMasterPassword());
                theMap.put(name, decryptedValue);
                LOGGER.debug("  decrypting {}=[*****]", encryptedPropKey);
            }
        }
    }

    public Long getLongVar(String name) {
        return longMap.get(name);
    }

    public void setStringVar(String varName, String varValue) {
        stringMap.get().put(varName, varValue);
        LOGGER.debug("setStringVar: [{}] => [{}]", varName, varValue);
        if (envStringMap.containsKey(varName)) {
            envStringMap.remove(varName);
        }
    }

    /**
     * Remove string var.
     * It remove variable var from String Map
     *
     * @param varName the var name
     */
    public void removeStringVar(final String varName) {
        if (stringMap.get().containsKey(varName)) {
            LOGGER.debug("varName [{}] is removed from String map", varName);
            stringMap.get().remove(varName);
        }
    }

    public String expandVar(String expression) {
        if (expression == null)
            return null;

        int varStart = expression.indexOf(VAR_INDICATOR);

        if (varStart >= 0) {
            String originalExpression = expression;
            String varName = "";
            String expanded = "";
            while (varStart >= 0) {
                int varEnd = expression.indexOf('}', varStart + 2);
                if (varEnd > varStart + 1) {
                    varName = expression.substring(varStart + VAR_INDICATOR.length(), varEnd);
                    String value = this.getStringVar(varName);
                    expanded = expression.substring(0, varStart) + value + expression.substring(varEnd + 1);
                } else {
                    LOGGER.debug("skipped: varEnd <= varStart + 1");
                }
                expression = expanded;
                varStart = expanded.indexOf(VAR_INDICATOR);
            }
            if (varName.endsWith(StatePropertiesSvc.PASS_POSTFIX)) {
                LOGGER.debug("expandVar: \"{}\" => \"********\"", originalExpression);
            } else {
                LOGGER.debug("expandVar: \"{}\" => \"{}\"", originalExpression, expanded);
            }
            return expanded;
        }
        return expression;
    }


    public void dumpVars() {
        LOGGER.debug("dumpVars:");
        SortedSet<String> sortedKeySet = new TreeSet<>(stringMap.get().keySet());
        for (String key : sortedKeySet) {
            debugLogVar(key);
        }
    }


    /**
     * This method gathers properties under certain prefix into a single {@link Map}&lt;{@link String}, {@link String}&gt;
     * providing simpler access to a group of properties.
     *
     * @param prefix     the prefix from the state string var from where we want the value map collected
     * @param expandVars whether to expand variables specified by those values or keep them as is
     * @return {@link Map}&lt;{@link String}, {@link String}&gt; the value map object
     */
    public Map<String, String> getValueMapFromPrefix(String prefix, boolean expandVars) {
        List<String> keys = envStringMap.keySet().stream().filter(row -> row.startsWith(prefix)).collect(Collectors.toList());
        int prefixLen = prefix.length();
        Map<String, String> result = new HashMap<>();
        for (String key : keys) {
            String shortenedKey = key.substring(prefixLen + 1);
            String value = envStringMap.get(key);
            result.put(shortenedKey, expandVars ? expandVar(value) : value);
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
    public Map<String, String> getValueStringMapFromPrefix(String prefix, boolean expandVars) {
        List<String> keys = stringMap.get().keySet().stream().filter(row -> row.startsWith(prefix)).collect(Collectors.toList());
        int prefixLen = prefix.length();
        Map<String, String> result = new HashMap<>();
        for (String key : keys) {
            String shortenedKey = key.substring(prefixLen + 1);
            String value = stringMap.get().get(key);
            result.put(shortenedKey, expandVars ? expandVar(value) : value);
        }
        return result;
    }

    public void debugLogVar(String varName) {
        if (varName == null) {
            return;
        }

        if (varName.endsWith(StatePropertiesSvc.PASS_POSTFIX)) {
            LOGGER.debug("  {} = [********] (obfuscated)", varName);
        } else {
            LOGGER.debug("  {} = [{}]", varName, getStringVar(varName));
        }
    }

    /**
     * Expand an expression having variables with patten REGEX{var} into Regex group (.*).
     * Ex: Fund size \(REGEX{var1}\) REGEX{var2} => Fund size \((.*)\) (.*)
     *
     * @param expression the expression
     * @return the regex vars
     */
    public RegexVars expandToRegExGroups(final String expression) {
        if (expression == null)
            return null;

        List<String> varsList = new ArrayList<>();
        String result = expression;

        int varStart = result.indexOf("REGEX{");
        String regExFormat = "";

        if (varStart >= 0) {
            while (varStart >= 0) {
                int varEnd = result.indexOf('}', varStart);
                String substring = result.substring(varStart, varEnd + 1);
                varsList.add(substring.replace("REGEX{", "").replace("}", ""));
                regExFormat = result.replace(substring, "(.*)");
                result = regExFormat;
                varStart = result.indexOf("REGEX{");
            }
        }
        LOGGER.debug("Expanded Expression [{}] ==> [{}]", expression, result);
        return new RegexVars(result, varsList);
    }

    public String getBrowserName() {
        return getStringVar(CUCUMBER_REPORTS_BROWSER);
    }

}
