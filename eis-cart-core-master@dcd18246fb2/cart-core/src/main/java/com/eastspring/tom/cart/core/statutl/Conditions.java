package com.eastspring.tom.cart.core.statutl;

import java.util.Collection;
import java.util.Map;

public class Conditions {
    private Conditions() {
    }

    /**
     * <p>This is a convenient method to perform is null or empty check on {@link Collection} object, including {@link java.util.List}</p>
     *
     * @param collection collection object to check
     * @return boolean value indicating whether the collection is null or empty
     */
    public static boolean isNullOrEmpty(final Collection<?> collection) {
        return collection == null || collection.isEmpty();
    }

    /**
     * <p>This is a convenient method to perform is null or empty checks on {@link Map}</p>
     *
     * @param map map object to check
     * @return boolean value indicating whether the map is null or empty
     */
    public static boolean isNullOrEmpty(final Map<?, ?> map) {
        return map == null || map.isEmpty();
    }
}
