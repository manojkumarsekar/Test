package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.cfg.CartCoreConfig;
import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.Arrays;
import java.util.List;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreConfig.class})
public class ReconciliationSvcRunIT {
    public static final List<String> COLUMN_LIST = Arrays.asList("SEQ_ID", "NAME", "PORTFOLIO_ID", "MONTHLY_AMOUNT", "DESCRIPTION");
    public static final List<String> KEY_COLUMN_LIST = Arrays.asList("NAME", "PORTFOLIO_ID");
    public static final String csvFilename = "myfile.csv";
    public static final String tableName1 = "BASELINE_TABLE";
    public static final String tableName2 = "TARGET_TABLE";

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private ReconciliationSvc reconciliationSvc;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(ReconciliationSvcRunIT.class);
    }

    @Test
    public void testGenerateOuterOnlyQuery() throws Exception {
        String expectedLeftOnlyQuery = "CALL CSVWRITE('myfile.csv', 'SELECT a.SEQ_ID, a.NAME, a.PORTFOLIO_ID, a.MONTHLY_AMOUNT, a.DESCRIPTION FROM BASELINE_TABLE a LEFT JOIN TARGET_TABLE b ON a.NAME=b.NAME AND a.PORTFOLIO_ID=b.PORTFOLIO_ID WHERE b.NAME IS NULL', 'charset=UTF-8 fieldSeparator=,')";
        String expectedRightOnlyQuery = "CALL CSVWRITE('myfile.csv', 'SELECT a.SEQ_ID, a.NAME, a.PORTFOLIO_ID, a.MONTHLY_AMOUNT, a.DESCRIPTION FROM TARGET_TABLE a LEFT JOIN BASELINE_TABLE b ON a.NAME=b.NAME AND a.PORTFOLIO_ID=b.PORTFOLIO_ID WHERE b.NAME IS NULL', 'charset=UTF-8 fieldSeparator=,')";
        String leftOnlySqlQuery = reconciliationSvc.generateOuterOnlyQuery(csvFilename, tableName1, tableName2, COLUMN_LIST, KEY_COLUMN_LIST);
        String rightOnlySqlQuery = reconciliationSvc.generateOuterOnlyQuery(csvFilename, tableName2, tableName1, COLUMN_LIST, KEY_COLUMN_LIST);
        Assert.assertEquals(expectedLeftOnlyQuery, leftOnlySqlQuery);
        Assert.assertEquals(expectedRightOnlyQuery, rightOnlySqlQuery);
    }
}
