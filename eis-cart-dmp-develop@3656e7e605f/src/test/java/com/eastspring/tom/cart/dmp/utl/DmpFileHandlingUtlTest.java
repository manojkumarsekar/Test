package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.CsvUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Created by GummarajuM on 10/1/2018.
 */
public class DmpFileHandlingUtlTest {

    @InjectMocks
    private DmpFileHandlingUtl dmpFileHandlingUtl;

    @Mock
    private FileDirUtil fileDirUtil;

    @Mock
    private CsvUtil csvUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    private static final String TEST_STRING = "abc|def|xyz|1|2|4|yxyx";

    @Test
    public void testConvertStringWithDelimeterToAList_withReference() {
        List<String> list = dmpFileHandlingUtl.convertStringWithDelimiterToAList(TEST_STRING, "def", '|');
        Assert.assertEquals("def", list.get(0));
        Assert.assertEquals("yxyx", list.get(5));
    }

    @Test
    public void testConvertStringWithDelimeterToAList_withInvalidReference() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Reference string not found");
        dmpFileHandlingUtl.convertStringWithDelimiterToAList(TEST_STRING, "ffff", '|');
    }

    @Test
    public void testConvertStringWithDelimeterToAList_EmptySubject() {
        thrown.expect(CartException.class);
        thrown.expectMessage(DmpFileHandlingUtl.SUBJECT_CANNOT_BE_NULL_OR_EMPTY);
        dmpFileHandlingUtl.convertStringWithDelimiterToAList("", "def", '|');
    }

    @Test
    public void testConvertStringWithDelimeterToAList_withoutReference() {
        List<String> list = dmpFileHandlingUtl.convertStringWithDelimiterToAList(TEST_STRING, "", '|');
        Assert.assertEquals("abc", list.get(0));
    }

    @Test
    public void testConvertStringWithDelimeterToAList_withDifferentDelimiter() {
        List<String> list = dmpFileHandlingUtl.convertStringWithDelimiterToAList(TEST_STRING.replaceAll(Pattern.quote("|"), ","), "", ',');
        Assert.assertEquals("abc", list.get(0));
    }

    @Test
    public void testGetFieldValuesFromFileWithHeader_ZeroHeaderRowException() {
        thrown.expect(CartException.class);
        thrown.expectMessage(DmpFileHandlingUtl.HEADER_ROW_MUST_BE_NON_ZERO);
        String fileName = "esi.out";
        dmpFileHandlingUtl.getFieldValuesFromFileWithHeader(fileName, 0, "HeaderRef", "Header3", '|');
    }

    @Test
    public void testConvertListToInputStream() throws IOException {
        List<String> list = new ArrayList<>();
        list.add("Test Input Stream1");
        list.add("Test Input Stream2");
        InputStream inputStream = dmpFileHandlingUtl.convertListToInputStream(list);
        int c;
        StringBuilder sb = new StringBuilder();
        while ((c = inputStream.read()) != -1) {
            sb.append((char) c);
        }
        Assert.assertEquals("Test Input Stream1\nTest Input Stream2", sb.toString().trim());
    }

}
