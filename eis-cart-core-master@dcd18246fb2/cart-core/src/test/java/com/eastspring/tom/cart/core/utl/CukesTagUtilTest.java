package com.eastspring.tom.cart.core.utl;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.MockitoAnnotations;

import java.util.TreeSet;
import java.util.regex.Pattern;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

public class CukesTagUtilTest {

    @InjectMocks
    private CukesTagUtil cukesTagUtil;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Test
    public void testGetJiraTicketFromTag_empty() {
        TreeSet<String> jiraSpaces_tom = new TreeSet<String>() {{
        }};
        assertNull(cukesTagUtil.getJiraTicketTagPattern(jiraSpaces_tom));
    }

    @Test
    public void testGetJiraTicketFromTag_null() {
        assertNull(cukesTagUtil.getJiraTicketTagPattern(null));
    }

    @Test
    public void testGetJiraTicketFromTag() {
        TreeSet<String> jiraSpaces_tom = new TreeSet<String>() {{
            add("tom");
        }};
        Pattern pattern_tom = cukesTagUtil.getJiraTicketTagPattern(jiraSpaces_tom);
        assertEquals("TOM-123", cukesTagUtil.getJiraTicketFromTag("@tom_123", pattern_tom));
        assertEquals("TOM-1", cukesTagUtil.getJiraTicketFromTag("@tom_1", pattern_tom));
        assertEquals("TOM-1234567", cukesTagUtil.getJiraTicketFromTag("@tom_1234567", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom_123", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom_1", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom_1234567", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag(null, pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("a", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom1", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom1234567", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@a", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@tom1", pattern_tom));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@tom1234567", pattern_tom));

        TreeSet<String> jiraSpaces_TOM = new TreeSet<String>() {{
            add("TOM");
        }};
        Pattern pattern_TOM = cukesTagUtil.getJiraTicketTagPattern(jiraSpaces_TOM);
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM_123", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM_1", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM_1234567", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM_123", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM_1", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM_1234567", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag(null, pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("a", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM1", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM1234567", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@a", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM1", pattern_TOM));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM1234567", pattern_TOM));
    }

    @Test
    public void testGetJiraTicketFromTag_dualTags() {
        TreeSet<String> jiraSpaces = new TreeSet<String>() {{
            add("tom");
            add("eisst");
        }};
        Pattern patternLowercase = cukesTagUtil.getJiraTicketTagPattern(jiraSpaces);
        assertEquals("TOM-123", cukesTagUtil.getJiraTicketFromTag("@tom_123", patternLowercase));
        assertEquals("TOM-1", cukesTagUtil.getJiraTicketFromTag("@tom_1", patternLowercase));
        assertEquals("TOM-1234567", cukesTagUtil.getJiraTicketFromTag("@tom_1234567", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom_123", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom_1", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom_1234567", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag(null, patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("a", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom1", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("tom1234567", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@a", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@tom1", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@tom1234567", patternLowercase));

        assertEquals("EISST-123", cukesTagUtil.getJiraTicketFromTag("@eisst_123", patternLowercase));
        assertEquals("EISST-1", cukesTagUtil.getJiraTicketFromTag("@eisst_1", patternLowercase));
        assertEquals("EISST-1234567", cukesTagUtil.getJiraTicketFromTag("@eisst_1234567", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("eisst_123", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("eisst_1", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("eisst_1234567", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag(null, patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("a", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("eisst1", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("eisst1234567", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@a", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@eisst1", patternLowercase));
        assertEquals(null, cukesTagUtil.getJiraTicketFromTag("@eisst1234567", patternLowercase));

        Pattern patternUppercase = cukesTagUtil.getJiraTicketTagPattern(jiraSpaces);
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM_123", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM_1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM_1234567", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM_123", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM_1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM_1234567", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag(null, patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("a", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("TOM1234567", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@a", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@TOM1234567", patternUppercase));

        assertNull(cukesTagUtil.getJiraTicketFromTag("@EISST_123", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@EISST_1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@EISST_1234567", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("EISST_123", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("EISST_1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("EISST_1234567", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag(null, patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("a", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("EISST1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("EISST1234567", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@a", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@EISST1", patternUppercase));
        assertNull(cukesTagUtil.getJiraTicketFromTag("@EISST1234567", patternUppercase));

    }
}
