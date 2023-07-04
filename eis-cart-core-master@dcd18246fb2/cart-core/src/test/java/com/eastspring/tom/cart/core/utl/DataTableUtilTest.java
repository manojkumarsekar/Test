package com.eastspring.tom.cart.core.utl;

import io.cucumber.datatable.DataTable;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DataTableUtilTest {

    @Spy
    @InjectMocks
    private DataTableUtil dataTableUtil;

    @Mock
    private DataTable.TableConverter tableConverter;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGetFirstColsAsList() {
        List<List<String>> raw = Arrays.asList(
                Collections.singletonList("one"),
                Collections.singletonList("4444")
        );

        DataTable simpleTable = DataTable.create(raw, tableConverter);

        Mockito.when(tableConverter.toList(simpleTable, String.class)).thenReturn(Arrays.asList("one", "4444"));
        List<String> firstColsAsList = dataTableUtil.getFirstColsAsList(simpleTable);
        Assert.assertEquals(2, firstColsAsList.size());
    }

    @Test
    public void testGetTwoColumnAsMap_withNonNullKey() {
        List<List<String>> raw = Arrays.asList(
                Arrays.asList("one", "1"),
                Arrays.asList("4444", "4Fours")
        );

        Map<Object, Object> result = new HashMap<>();
        result.put("one", "1");
        result.put("4444", "4Fours");

        DataTable simpleTable = DataTable.create(raw, tableConverter);
        Mockito.when(tableConverter.toMap(simpleTable, String.class, String.class)).thenReturn(result);
        Mockito.when(dataTableUtil.getFirstColsAsList(simpleTable)).thenReturn(Arrays.asList("one", "4444"));

        Map<String, String> twoColumnAsMap = dataTableUtil.getTwoColumnAsMap(simpleTable);

        Assert.assertEquals(2, twoColumnAsMap.size());
        Assert.assertEquals("1", twoColumnAsMap.get("one"));
        Assert.assertEquals("4Fours", twoColumnAsMap.get("4444"));
    }

    @Test
    public void testGetTwoColumnAsMap_withNullKey() {
        List<List<String>> raw = Arrays.asList(
                Arrays.asList("", "1"),
                Arrays.asList("4444", "4Fours")
        );

        Map<Object, Object> result = new HashMap<>();
        result.put("", "1");
        result.put("4444", "4Fours");

        DataTable simpleTable = DataTable.create(raw, tableConverter);
        Mockito.when(tableConverter.toMap(simpleTable, String.class, String.class)).thenReturn(result);
        Mockito.when(dataTableUtil.getFirstColsAsList(simpleTable)).thenReturn(Arrays.asList("", "4444"));

        Map<String, String> twoColumnAsMap = dataTableUtil.getTwoColumnAsMap(simpleTable);

        Assert.assertEquals(2, twoColumnAsMap.size());
        Assert.assertEquals("1", twoColumnAsMap.get(""));
        Assert.assertEquals("4Fours", twoColumnAsMap.get("4444"));
    }

    @Test
    public void testGetTwoColumnAsMap_withNullKeyAndValue() {
        List<List<String>> raw = Arrays.asList(
                Arrays.asList("")
        );

        Map<Object, Object> result = new HashMap<>();
        result.put("", "");

        DataTable simpleTable = DataTable.create(raw, tableConverter);
        Mockito.when(tableConverter.toMap(simpleTable, String.class, String.class)).thenReturn(result);
        Mockito.when(dataTableUtil.getFirstColsAsList(simpleTable)).thenReturn(Arrays.asList(""));

        Map<String, String> twoColumnAsMap = dataTableUtil.getTwoColumnAsMap(simpleTable);

        Assert.assertEquals(0, twoColumnAsMap.size());

    }
}
