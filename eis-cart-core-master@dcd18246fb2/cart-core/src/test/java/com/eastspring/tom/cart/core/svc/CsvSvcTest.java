package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.CsvProfile;
import com.eastspring.tom.cart.core.mdl.KeyMetadata;
import com.eastspring.tom.cart.core.utl.SqlStringUtil;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.List;

import static com.eastspring.tom.cart.core.svc.CsvSvc.POSTFIX_TO_REMOVE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY;

public class CsvSvcTest {

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(CsvSvcTest.class);
    }

    @InjectMocks
    private CsvSvc csvSvc;

    @Mock
    private JdbcSvc jdbcSvc;

    @Mock
    private SqlStringUtil sqlStringUtil;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGetKeyMetadataFromHeader_success() throws Exception {
        CsvProfile csvProfile = new CsvProfile();
        String[] headers = new String[] { "abc", "def (KEY)", "ghi", "jkl (KEY)", "mno" };
        csvProfile.setHeaders(headers);
        String keyName = "KEY";
        List<KeyMetadata> result = csvSvc.getKeyMetadataFromHeader(csvProfile, keyName);
        Assert.assertNotNull(result);
        Assert.assertEquals(2, result.size());
        Assert.assertEquals(1, result.get(0).getColumnIndex());
        Assert.assertEquals(3, result.get(1).getColumnIndex());
    }

    @Test
    public void testGetKeyMetadataFromHeader_noKeysHeaders() throws Exception {
        CsvProfile csvProfile = new CsvProfile();
        String[] headers = new String[] { "abc", "def", "ghi", "jkl", "mno" };
        csvProfile.setHeaders(headers);
        String keyName = "KEY";
        List<KeyMetadata> result = csvSvc.getKeyMetadataFromHeader(csvProfile, keyName);
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testGetKeyMetadataFromHeader_nullHeaders() throws Exception {
        CsvProfile csvProfile = new CsvProfile();
        String[] headers = null;
        csvProfile.setHeaders(headers);
        String keyName = "KEY";
        List<KeyMetadata> result = csvSvc.getKeyMetadataFromHeader(csvProfile, keyName);
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    @Test
    public void testGetKeyMetadataFromHeader_zeroLengthHeaders() throws Exception {
        CsvProfile csvProfile = new CsvProfile();
        String[] headers = new String[0];
        csvProfile.setHeaders(headers);
        String keyName = "KEY";
        List<KeyMetadata> result = csvSvc.getKeyMetadataFromHeader(csvProfile, keyName);
        Assert.assertNotNull(result);
        Assert.assertEquals(0, result.size());
    }

    public static final String POSTFIX_TO_REMOVE = ":00 AM";
    public static final String SRC_FILE = "c:/tomwork/csv-l1/dir/src.csv";
    public static final String DST_FILE = "c:/tomwork/csv-l1/dir/dst.csv";
    public static List<String> COLS_NAMES = Arrays.asList("COL1", "colAbc", "DEF");

    @Test
    public void testRemovePostfixFromCols_null() throws Exception {
        Exception thrownException = null;
        try {
            csvSvc.removePostfixFromCols(null, SRC_FILE, COLS_NAMES, DST_FILE);
        } catch(Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals(POSTFIX_TO_REMOVE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY, thrownException.getMessage());
    }

    @Test
    public void testRemovePostfixFromCols_emptyString() throws Exception {
        Exception thrownException = null;
        try {
            csvSvc.removePostfixFromCols("", SRC_FILE, COLS_NAMES, DST_FILE);
        } catch(Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals(POSTFIX_TO_REMOVE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY, thrownException.getMessage());
    }
}
