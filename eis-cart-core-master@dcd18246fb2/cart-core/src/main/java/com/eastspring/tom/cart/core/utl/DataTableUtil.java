package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.google.common.base.Strings;
import io.cucumber.datatable.DataTable;
import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;


public class DataTableUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(DataTableUtil.class);

    public List<String> getFirstColsAsList(DataTable dataTable) {
        ArrayList result = new ArrayList();
        if (dataTable == null) {
            LOGGER.error("required data table is empty or null");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "required data table is empty or null");
        }
        result.addAll(dataTable.asList(String.class));
        return result;
    }

    /**
     * <p>This method converts the given dataTable into a key value pair (Java {@link Map} object), with the value of \
     * the first column as the key and the value of the second column as the value.</p>
     *
     * @param dataTable {@link DataTable} object
     * @return Map
     */
    public Map<String, String> getTwoColumnAsMap(DataTable dataTable) {
        HashMap<String, String> result = new HashMap<>();

        List<String> firstColList = this.getFirstColsAsList(dataTable);
        String emptyMap = dataTable.toString().replace(" ", "").trim();
        if ("|||".equals(emptyMap) || "||".equals(emptyMap)) {
            LOGGER.debug("Returning Empty map ");
            return result;
        } else if (!Strings.isNullOrEmpty(firstColList.get(0))) {
            LOGGER.debug("Returning Default map");
            Map<String, String> map = dataTable.asMap(String.class, String.class);
            result.putAll(map);
            return result;
        } else {
            List<String> secondColList = dataTable.column(1);
            int index = 0;
            for (String key : firstColList) {
                result.put(key, secondColList.get(index));
                index++;
            }
            LOGGER.debug("Returning customized map");
            return result;
        }
    }

    /**
     * <p>This method converts the given dataTable into a List of key value pair (Java {@link Map} object)
     *
     * @param dataTable {@link DataTable} object
     * @return List<Map<String, String>>
     */
    public List<Map<String, String>> getListOfMaps(DataTable dataTable) {
        List<Map<String, String>> maps = dataTable.asMaps(String.class, String.class);
        ArrayList<Map<String, String>> result = new ArrayList();

        for (Map m : maps) {
            HashMap<String, String> localMap = new HashMap<>();
            localMap.putAll(m);
            result.add(m);
        }
        return result;
    }

    private Random random = new Random();

    public String generateRandomTableNameWithPrefix(String prefix) {
        return prefix + DateTimeFormat.forPattern("yyyyMMddHHMMss").print(DateTime.now()) + Math.abs(random.nextInt() % 1000);
    }

}