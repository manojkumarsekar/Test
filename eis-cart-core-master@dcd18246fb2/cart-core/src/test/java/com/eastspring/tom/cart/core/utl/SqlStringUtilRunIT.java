package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static tomcart.glue.DatabaseStepsDef.DEFAULT_QUERY_DELIMITER;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class SqlStringUtilRunIT {
    public static final String[] COLUMN_ARRAY_1 = new String[]{"COL_A", "COL_B", "COL_C"};
    public static final List<String> COLUMN_LIST_1 = Arrays.asList(COLUMN_ARRAY_1);

    public static final String[] COLUMN_ARRAY_2 = new String[]{"COL_A"};
    public static final List<String> COLUMN_LIST_2 = Arrays.asList(COLUMN_ARRAY_2);

    public static final List<String> COLUMN_LIST_EMPTY = new ArrayList<String>();

    @Autowired
    private SqlStringUtil sqlStringUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(SqlStringUtilRunIT.class);
    }

    @Test
    public void testZipJoin_success_threeItems() throws Exception {
        String result = sqlStringUtil.zipJoin(COLUMN_LIST_1, ", ", "[a].[", "]");
        Assert.assertEquals("[a].[COL_A], [a].[COL_B], [a].[COL_C]", result);
    }

    @Test
    public void testZipJoin_success_singleItem() throws Exception {
        String result = sqlStringUtil.zipJoin(COLUMN_LIST_2, ", ", "[a].[", "]");
        Assert.assertEquals("[a].[COL_A]", result);
    }

    @Test
    public void testZipJoin_success_empty() throws Exception {
        String result = sqlStringUtil.zipJoin(COLUMN_LIST_EMPTY, ", ", "[a].[", "]");
        Assert.assertEquals("", result);
    }

    @Test(expected = CartException.class)
    public void testZipJoin_success_null() throws Exception {
        String result = sqlStringUtil.zipJoin(null, ", ", "[a].[", "]");
        Assert.assertEquals("", result);
    }

    @Test
    public void testZipJoinJoinClause_success_threeItems() throws Exception {
        String result = sqlStringUtil.zipJoinJoinClause(COLUMN_LIST_1, "a", "[b]");
        Assert.assertEquals("a.COL_A=[b].COL_A AND a.COL_B=[b].COL_B AND a.COL_C=[b].COL_C", result);
    }

    @Test
    public void testZipJoinJoinClause_success_singleItem() throws Exception {
        String result = sqlStringUtil.zipJoinJoinClause(COLUMN_LIST_2, "[a]", "b");
        Assert.assertEquals("[a].COL_A=b.COL_A", result);
    }

    @Test
    public void testZipJoinJoinClause_success_empty() throws Exception {
        String result = sqlStringUtil.zipJoinJoinClause(COLUMN_LIST_EMPTY, "a", "[b]");
        Assert.assertEquals("", result);
    }

    @Test(expected = CartException.class)
    public void testZipJoinJoinClause_success_null() throws Exception {
        String result = sqlStringUtil.zipJoinJoinClause(null, "a", "[b]");
        Assert.assertEquals("", result);
    }

    @Test
    public void testZipJoinWithDelimiter_zeroItems() throws Exception {
        String result = sqlStringUtil.zipJoinWithDelimiter(0, "?", ",");
        Assert.assertEquals("", result);
    }

    @Test
    public void testZipJoinWithDelimiter_singleItem() throws Exception {
        String result1 = sqlStringUtil.zipJoinWithDelimiter(1, "?", ",");
        Assert.assertEquals("?", result1);
        String result2 = sqlStringUtil.zipJoinWithDelimiter(1, "abc", "::");
        Assert.assertEquals("abc", result2);
    }

    @Test
    public void testZipJoinWithDelimiter_threeItems() throws Exception {
        String result1 = sqlStringUtil.zipJoinWithDelimiter(3, "?", ",");
        Assert.assertEquals("?,?,?", result1);
        String result2 = sqlStringUtil.zipJoinWithDelimiter(3, "abc", "::");
        Assert.assertEquals("abc::abc::abc", result2);
    }

    @Test
    public void testGetPreparedCallableStatementWithParams() {
        String result = sqlStringUtil.getPreparedCallableStatementWithParams("abc", 3);
        Assert.assertEquals("{call abc(?,?,?)}", result);
    }

    @Test
    public void testSplitQueries_DefaultDelimiter() {
        String queries = "Select * from A; Select * from B; Select * from C";
        List<String> list = sqlStringUtil.splitQueries(queries, DEFAULT_QUERY_DELIMITER);
        Assert.assertEquals(3, list.size());
        Assert.assertEquals("Select * from A", list.get(0));
        Assert.assertEquals("Select * from B", list.get(1));
        Assert.assertEquals("Select * from C", list.get(2));
    }

    @Test
    public void testSplitQueries_NonDefaultDelimiter() {
        String queries = "Select * from A ### Select * from B ### Select * from C";
        List<String> list = sqlStringUtil.splitQueries(queries, "###");
        Assert.assertEquals(3, list.size());
        Assert.assertEquals("Select * from A", list.get(0));
        Assert.assertEquals("Select * from B", list.get(1));
        Assert.assertEquals("Select * from C", list.get(2));
    }
}
