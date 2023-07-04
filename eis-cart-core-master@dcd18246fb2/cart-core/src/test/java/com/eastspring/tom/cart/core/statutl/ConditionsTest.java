package com.eastspring.tom.cart.core.statutl;

import org.junit.Assert;
import org.junit.Test;

import java.util.*;

public class ConditionsTest {
    @Test
    public void testIsNullOrEmpty_collection() throws Exception {
        Collection<String> collection = Arrays.asList("abc");
        Collection<String> nullCollection = null;
        Collection<String> emptyCollection = new ArrayList<>();
        Assert.assertTrue(Conditions.isNullOrEmpty(nullCollection));
        Assert.assertTrue(Conditions.isNullOrEmpty(emptyCollection));
        Assert.assertFalse(Conditions.isNullOrEmpty(collection));
    }

    @Test
    public void testIsNullOrEmpty_map() throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("abc", "def");
        Map<String, String> nullMap = null;
        Map<String, String> emptyMap = new HashMap<>();
        Assert.assertTrue(Conditions.isNullOrEmpty(nullMap));
        Assert.assertTrue(Conditions.isNullOrEmpty(emptyMap));
        Assert.assertFalse(Conditions.isNullOrEmpty(map));
    }
}
