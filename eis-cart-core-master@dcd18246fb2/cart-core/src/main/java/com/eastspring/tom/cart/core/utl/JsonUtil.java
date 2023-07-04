package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.Strings;
import com.jayway.jsonpath.JsonPath;
import com.jayway.jsonpath.PathNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.util.Map;

public class JsonUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(JsonUtil.class);

    public Map<String, Object> jsonStringIntoMap(final String jsonString) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readValue(jsonString, new TypeReference<Map<String, String>>() {
            });
        } catch (Exception e) {
            LOGGER.error("Failed to convert Json string [{}] to MAP", jsonString, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Failed to convert Json string [{}] to MAP", jsonString, e);
        }
    }

    public Map<String, Object> jsonFileToMap(final File file) {
        ObjectMapper mapper = new ObjectMapper();
        try {
            return mapper.readValue(file, new TypeReference<Map<String, Object>>() {
            });
        } catch (Exception e) {
            LOGGER.error("Failed to convert Json File [{}] to MAP", file.getAbsolutePath(), e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Failed to convert Json File [{}] to MAP", file.getAbsolutePath(), e);
        }
    }

    public Object readObjectByJsonpath(final String jsonContent, final String jsonPath) {
        if (Strings.isNullOrEmpty(jsonContent)) {
            LOGGER.error("json content cannot be empty");
            throw new CartException(CartExceptionType.IO_ERROR, "json content cannot be empty");
        }
        try {
            final String enrichedPath = enrichJsonPath(jsonPath);
            final Object value = JsonPath.read(jsonContent, enrichedPath);
            LOGGER.debug("Jsonpath and value, [{}] -> [{}]", jsonPath, value);
            return value;
        } catch (PathNotFoundException e) {
            LOGGER.error("Unable to parse the json string using jsonpath [{}]", jsonPath, e);
            throw new CartException(CartExceptionType.IO_ERROR, "Unable to parse the json string using jsonpath [{}]", jsonPath, e);
        }
    }

    private String enrichJsonPath(final String jsonPath) {
        String absolutePath = jsonPath;
        if (!absolutePath.startsWith("$.")) {
            absolutePath = "$." + jsonPath;
        }
        return absolutePath;
    }

}
