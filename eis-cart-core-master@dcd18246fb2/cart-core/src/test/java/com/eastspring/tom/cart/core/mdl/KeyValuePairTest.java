package com.eastspring.tom.cart.core.mdl;

import org.junit.Assert;
import org.junit.Test;

import static org.junit.Assert.assertTrue;

public class KeyValuePairTest {
    @Test
    public void testToString() {
        KeyValuePair kvp = new KeyValuePair("a", "b");
        String kvpToString = kvp.toString();
        Assert.assertNotNull(kvpToString);
        assertTrue(kvpToString.startsWith("com.eastspring.tom.cart.core.mdl.KeyValuePair@"));
        assertTrue(kvpToString.endsWith("[key=a,value=b]"));
        Assert.assertEquals("a", kvp.getKey());
        Assert.assertEquals("b", kvp.getValue());
    }
}
