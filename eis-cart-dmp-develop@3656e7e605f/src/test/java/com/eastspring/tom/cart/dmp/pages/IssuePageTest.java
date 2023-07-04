package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.issue.IssuePage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.beans.factory.annotation.Autowired;

import static com.eastspring.tom.cart.dmp.pages.issue.IssueOR.ISSUE_SOURCE_CCY_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.issue.IssueOR.ISSUE_TARGET_CCY_LOCATOR;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class IssuePageTest {
    @InjectMocks
    private IssuePage issuePage;

    @Mock
    private HomePage homePage;

    @Mock
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Mock
    private ThreadSvc threadSvc;

    @Mock
    private WebTaskSvc webTaskSvc;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testSearchIssue() {
        doNothing().when(homePage).globalSearchAndWaitTillSuccess("FAKE_ISSUE", "Issue", 20);
        issuePage.searchIssue("FAKE_ISSUE");
        verify(homePage, times(1)).globalSearchAndWaitTillSuccess("FAKE_ISSUE", "Issue", 20);
    }

    @Test
    public void testIsIssuePresent() {
        doNothing().when(homePage).globalSearchAndWaitTillSuccess("FAKE_ISSUE", "Issue", 120);
        doNothing().when(threadSvc).sleepSeconds(2);
        when(dmpGsPortalUtl.isSearchRecordAvailable("FAKE_ISSUE")).thenReturn(true);
        boolean flag = issuePage.isIssuePresent("FAKE_ISSUE");
        verify(dmpGsPortalUtl, times(1)).isSearchRecordAvailable("FAKE_ISSUE");
        Assert.assertTrue(flag);
    }

    @Test
    public void testInvokeIssue() {
        doNothing().when(homePage).globalSearchAndWaitTillSuccess("FAKE_ISSUE", "Issue", 120);
        doNothing().when(threadSvc).sleepSeconds(2);
        when(dmpGsPortalUtl.isSearchRecordAvailable("FAKE_ISSUE")).thenReturn(true);
        doNothing().when(dmpGsPortalUtl).invokeSetUpScreen(null, null, null);
        issuePage.invokeIssue("FAKE_ISSUE");
        verify(dmpGsPortalUtl, times(1)).invokeSetUpScreen(null, null, null);
    }


    @Test
    public void testGetIssueDetails() {
        when(webTaskSvc.getWebElementAttribute(ISSUE_SOURCE_CCY_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(ISSUE_TARGET_CCY_LOCATOR, "value")).thenReturn("test");
        issuePage.getIssueDetails();
        verify(webTaskSvc, times(1)).getWebElementAttribute(ISSUE_SOURCE_CCY_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(ISSUE_TARGET_CCY_LOCATOR, "value");
    }
}
