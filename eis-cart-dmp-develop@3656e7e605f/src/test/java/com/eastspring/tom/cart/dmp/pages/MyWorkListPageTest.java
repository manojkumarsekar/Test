package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.MockSelenium;
import com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_CLOSE_COMMENTS_BUTTON;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_COMPLETE_COMMENTS_BUTTON;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_DATA_TABLE_ROW;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_MYWORKLIST_COMMENTS;
import static com.eastspring.tom.cart.constant.CommonLocators.GS_REJECT_COMMENTS_BUTTON;
import static com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage.GS_WORKLIST_MYWORKLIST_CLOSE_BUTTON;
import static com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage.GS_WORKLIST_MYWORKLIST_COMPLETE_BUTTON;
import static com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage.GS_WORKLIST_MYWORKLIST_REJECT_BUTTON;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class MyWorkListPageTest extends MockSelenium {
    @InjectMocks
    private MyWorkListPage myWorkListPage;

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
    public void testNavigateToMyWorkList() {
        when(webTaskSvc.getWebDriverWait(200)).thenReturn(webDriverWait);
        when(webDriverWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.until(ExpectedConditions.elementToBeClickable((By) any()))).thenReturn(webElement);
        myWorkListPage.navigateToMyWorkList();

        verify(webElement, times(1)).click();
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(1)).selectMenu(anyString());
    }

    @Test
    public void testFilterMyWorkListWithEntityId() {
        myWorkListPage.filterMyWorkListWithEntityId("Main Entity Id");
        verify(dmpGsPortalUtl, times(1)).filterTable("Main Entity Id", "Main Entity Id", false);
    }

    @Test
    public void testOpenRecordToAuthorize() {
        doNothing().when(dmpGsPortalUtl).openRecord(GS_DATA_TABLE_ROW, "MOCK_CELL");
        when(webTaskSvc.getWebDriverWait(60)).thenReturn(webDriverWait);
        when(webDriverWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.until(ExpectedConditions.elementToBeClickable((By) any()))).thenReturn(webElement);
        myWorkListPage.openRecordToAuthorize("MOCK_CELL");
        verify(dmpGsPortalUtl, times(1)).openRecord(GS_DATA_TABLE_ROW, "MOCK_CELL");
    }

    @Test
    public void testOpenRecordToAuthorize_withRetries() {
        doNothing().when(dmpGsPortalUtl).openRecord(GS_DATA_TABLE_ROW, "MOCK_CELL");
        when(webTaskSvc.getWebDriverWait(60)).thenReturn(webDriverWait);
        when(webDriverWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.ignoring(any())).thenReturn(fluentWait);
        when(fluentWait.until(ExpectedConditions.elementToBeClickable((By) any()))).thenReturn(null);
        myWorkListPage.openRecordToAuthorize("MOCK_CELL");
        verify(dmpGsPortalUtl, times(8)).openRecord(GS_DATA_TABLE_ROW, "MOCK_CELL");
    }

    @Test
    public void testAuthorizeRequest() {
        doNothing().when(webTaskSvc).clickXPath(GS_WORKLIST_MYWORKLIST_COMPLETE_BUTTON);
        doNothing().when(dmpGsPortalUtl).inputText(GS_MYWORKLIST_COMMENTS, "Authorized by automation user", "", true);
        doNothing().when(threadSvc).sleepSeconds(1);
        doNothing().when(webTaskSvc).click(GS_COMPLETE_COMMENTS_BUTTON);
        doNothing().when(webTaskSvc).waitForElementDisappear(GS_COMPLETE_COMMENTS_BUTTON, 360);
        doNothing().when(dmpGsPortalUtl).waitTillNotificationMessageAppears();
        myWorkListPage.authorizeRequest();
        verify(webTaskSvc, times(1)).clickXPath(GS_WORKLIST_MYWORKLIST_COMPLETE_BUTTON);
        verify(dmpGsPortalUtl, times(1)).inputText(GS_MYWORKLIST_COMMENTS, "Authorized by automation user", "", true);
        verify(webTaskSvc, times(1)).waitForElementDisappear(GS_COMPLETE_COMMENTS_BUTTON, 360);
    }

    @Test
    public void testRejectRequest() {
        doNothing().when(webTaskSvc).click(GS_WORKLIST_MYWORKLIST_REJECT_BUTTON);
        doNothing().when(dmpGsPortalUtl).inputText(GS_MYWORKLIST_COMMENTS, "Rejected by automation user", "", true);
        doNothing().when(threadSvc).sleepSeconds(1);
        doNothing().when(webTaskSvc).click(GS_REJECT_COMMENTS_BUTTON);
        doNothing().when(webTaskSvc).waitForElementDisappear(GS_REJECT_COMMENTS_BUTTON, 360);
        myWorkListPage.rejectRequest();
        verify(webTaskSvc, times(1)).click(GS_WORKLIST_MYWORKLIST_REJECT_BUTTON);
        verify(dmpGsPortalUtl, times(1)).inputText(GS_MYWORKLIST_COMMENTS, "Rejected by automation user", "", true);
        verify(webTaskSvc, times(1)).waitForElementDisappear(GS_REJECT_COMMENTS_BUTTON, 360);
    }

    @Test
    public void testCloseRequest() {
        doNothing().when(webTaskSvc).click(GS_WORKLIST_MYWORKLIST_CLOSE_BUTTON);
        doNothing().when(dmpGsPortalUtl).inputText(GS_MYWORKLIST_COMMENTS, "Closed by automation user", "", true);
        doNothing().when(threadSvc).sleepSeconds(1);
        doNothing().when(webTaskSvc).click(GS_CLOSE_COMMENTS_BUTTON);
        doNothing().when(webTaskSvc).waitForElementDisappear(GS_CLOSE_COMMENTS_BUTTON, 360);
        myWorkListPage.closeRequest();
        verify(webTaskSvc, times(1)).click(GS_WORKLIST_MYWORKLIST_CLOSE_BUTTON);
        verify(dmpGsPortalUtl, times(1)).inputText(GS_MYWORKLIST_COMMENTS, "Closed by automation user", "", true);
        verify(webTaskSvc, times(1)).waitForElementDisappear(GS_CLOSE_COMMENTS_BUTTON, 360);
    }
}
