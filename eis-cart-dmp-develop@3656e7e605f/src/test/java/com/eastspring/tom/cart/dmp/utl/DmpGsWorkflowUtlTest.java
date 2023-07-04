package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.steps.DatabaseSteps;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import org.joda.time.DateTimeUtils;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

import java.io.FileNotFoundException;
import java.util.Collections;
import java.util.LinkedHashMap;

import static com.eastspring.tom.cart.dmp.mdl.WorkflowSpec.WORKFLOW_CHECK_SQL;
import static com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl.WF_RUNTIME_STAT_TYP;
import static com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl.WORKFLOW_PUB_DESCRIPTION_QUERY;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

public class DmpGsWorkflowUtlTest {

    @InjectMocks
    @Spy
    private DmpGsWorkflowUtl dmpGsWorkflowUtl;

    @Mock
    private DatabaseSteps databaseSteps;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private DateTimeUtil dateTimeUtil;

    @Mock
    private ThreadSvc threadSvc;

    @Mock
    private ScenarioUtil scenarioUtil;

    @Mock
    private DatabaseSvc databaseSvc;

    @Mock
    private FormatterUtil formatterUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void setup() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testPollUntilWorkflowCompletionStatus_StatusDoneImmediately() throws FileNotFoundException {

        doNothing().when(databaseSteps).executeQueryAndExtractValues(WORKFLOW_CHECK_SQL, Collections.singletonList(WF_RUNTIME_STAT_TYP));
        when(stateSvc.getStringVar(WF_RUNTIME_STAT_TYP)).thenReturn("DONE");
        when(dateTimeUtil.currentTimeMillis()).thenReturn(DateTimeUtils.currentTimeMillis());

        dmpGsWorkflowUtl.pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, "+-71AMumh5ysy007", 40);

        verify(dmpGsWorkflowUtl, times(1)).pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, "+-71AMumh5ysy007", 40);
    }

    @Test
    public void testPollUntilWorkflowCompletionStatus_StatusDoneNotImmediately() throws FileNotFoundException {
        doNothing().when(databaseSteps).executeQueryAndExtractValues(WORKFLOW_CHECK_SQL, Collections.singletonList(WF_RUNTIME_STAT_TYP));
        when(stateSvc.getStringVar(WF_RUNTIME_STAT_TYP)).thenReturn("STARTED", "STARTED", "STARTED", "DONE");
        when(dateTimeUtil.currentTimeMillis()).thenReturn(DateTimeUtils.currentTimeMillis(), DateTimeUtils.currentTimeMillis());
        doNothing().when(threadSvc).sleepSeconds(1);

        dmpGsWorkflowUtl.pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, "+-71AMumh5ysy007", 10);

        verify(dmpGsWorkflowUtl, times(4)).pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, "+-71AMumh5ysy007", 10);
    }

    @Test
    public void testPollUntilWorkflowCompletionStatus_StatusFailedNotImmediately() throws FileNotFoundException {
        String flowResultId = "+-71AMumh5ysy007";

        thrown.expect(CartException.class);
        thrown.expectMessage("Workflow with instance id [" + flowResultId + "] is FAILED!!!");

        doNothing().when(databaseSteps).executeQueryAndExtractValues(WORKFLOW_CHECK_SQL, Collections.singletonList(WF_RUNTIME_STAT_TYP));
        when(stateSvc.getStringVar(WF_RUNTIME_STAT_TYP)).thenReturn("STARTED", "STARTED", "STARTED", "FAILED");
        when(dateTimeUtil.currentTimeMillis()).thenReturn(DateTimeUtils.currentTimeMillis());

        when(formatterUtil.format(WORKFLOW_PUB_DESCRIPTION_QUERY, flowResultId)).thenReturn("query");
        when(databaseSvc.executeSingleValueQueryOnNamedConnection("query", "PUB_DESCRIPTION")).thenReturn("description");

        doNothing().when(threadSvc).sleepSeconds(1);
        doNothing().when(scenarioUtil).write(any());
        dmpGsWorkflowUtl.pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, flowResultId, 10);
        verify(dmpGsWorkflowUtl, times(4)).pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, flowResultId, 10);
    }

    @Test
    public void testPollUntilWorkflowCompletionStatus_WithZeroTimeout() throws FileNotFoundException {
        String flowResultId = "+-71AMumh5ysy007";

        thrown.expect(CartException.class);
        thrown.expectMessage("Workflow with instance id [+-71AMumh5ysy007] status showing as [STARTED] even after max polling time");

        doNothing().when(databaseSteps).executeQueryAndExtractValues(WORKFLOW_CHECK_SQL, Collections.singletonList(WF_RUNTIME_STAT_TYP));
        when(stateSvc.getStringVar(WF_RUNTIME_STAT_TYP)).thenReturn("STARTED");
        when(dateTimeUtil.currentTimeMillis()).thenReturn(DateTimeUtils.currentTimeMillis());
        doNothing().when(threadSvc).sleepSeconds(1);
        dmpGsWorkflowUtl.pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, flowResultId, 0);

        verify(dmpGsWorkflowUtl, times(1)).pollUntilWorkflowComplete(WORKFLOW_CHECK_SQL, flowResultId, 0);
    }


    @Test
    public void testConstructNTELVerificationQuery_withJOBID() {

        final String expectedQuery = "SELECT COUNT(*) AS CNT FROM FT_T_NTEL NTEL " +
                "JOIN FT_T_TRID TRID " +
                "ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID " +
                "WHERE TRID.JOB_ID='1' " +
                "AND NTEL.SOURCE_ID like '%GC%' " +
                "AND NTEL.NOTFCN_ID='60009' " +
                "AND NTEL.MSG_TYP='BRS'";

        final LinkedHashMap<String, String> columnValues = new LinkedHashMap<>();

        columnValues.put("JOB_ID","1");
        columnValues.put("SOURCE_ID","%GC%");
        columnValues.put("NOTFCN_ID","60009");
        columnValues.put("MSG_TYP","BRS");

        when(stateSvc.expandVar("60009")).thenReturn("60009");
        when(stateSvc.expandVar("%GC%")).thenReturn("%GC%");
        when(stateSvc.expandVar("BRS")).thenReturn("BRS");

        final String actualQuery = dmpGsWorkflowUtl.constructNTELVerificationQuery(columnValues);
        Assert.assertEquals(expectedQuery, actualQuery);
    }

    @Test
    public void testConstructNTELVerificationQuery_withoutJOBID() {

        final String expectedQuery = "SELECT COUNT(*) AS CNT FROM FT_T_NTEL NTEL " +
                "JOIN FT_T_TRID TRID " +
                "ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID " +
                "WHERE TRID.JOB_ID='2' " +
                "AND NTEL.SOURCE_ID like '%GC%' " +
                "AND NTEL.NOTFCN_ID='60009' " +
                "AND NTEL.MSG_TYP='BRS'";

        when(stateSvc.getStringVar("JOB_ID")).thenReturn("2");
        final LinkedHashMap<String, String> columnValues = new LinkedHashMap<>();

        columnValues.put("SOURCE_ID","%GC%");
        columnValues.put("NOTFCN_ID","60009");
        columnValues.put("MSG_TYP","BRS");

        when(stateSvc.expandVar("60009")).thenReturn("60009");
        when(stateSvc.expandVar("%GC%")).thenReturn("%GC%");
        when(stateSvc.expandVar("BRS")).thenReturn("BRS");

        final String actualQuery = dmpGsWorkflowUtl.constructNTELVerificationQuery(columnValues);
        Assert.assertEquals(expectedQuery, actualQuery);
    }

    @Test
    public void testConstructNTELVerificationQuery_withTRID() {

        final String expectedQuery = "SELECT COUNT(*) AS CNT FROM FT_T_NTEL NTEL " +
                "JOIN FT_T_TRID TRID " +
                "ON NTEL.LAST_CHG_TRN_ID=TRID.TRN_ID " +
                "WHERE TRID.JOB_ID='2' AND TRID.RECORD_SEQ_NUM='2' " +
                "AND NTEL.MSG_TYP='BRS'";

        when(stateSvc.getStringVar("JOB_ID")).thenReturn("2");
        final LinkedHashMap<String, String> columnValues = new LinkedHashMap<>();

        columnValues.put("TRID.RECORD_SEQ_NUM","2");
        columnValues.put("MSG_TYP","BRS");

        when(stateSvc.expandVar("BRS")).thenReturn("BRS");
        when(stateSvc.expandVar("2")).thenReturn("2");

        final String actualQuery = dmpGsWorkflowUtl.constructNTELVerificationQuery(columnValues);
        Assert.assertEquals(expectedQuery, actualQuery);
    }
}
