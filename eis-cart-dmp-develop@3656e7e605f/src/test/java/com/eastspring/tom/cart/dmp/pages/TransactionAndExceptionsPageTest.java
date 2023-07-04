package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.MockSelenium;
import com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

import static com.eastspring.tom.cart.constant.CommonLocators.GS_RELOAD_BUTTON;
import static com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage.GS_CLOSE_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage.GS_NOTIFICATION_OCC_COUNT_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage.GS_RESUBMIT_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage.GS_SUBMITTED_MESSAGE_LOCATOR;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class TransactionAndExceptionsPageTest extends MockSelenium {

    @InjectMocks
    @Spy
    private TransactionAndExceptionsPage transactionAndExceptionsPage;

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
    public void testNavigateToTransAndExceptions() {
        when(homePage.clickMenuDropdown()).thenReturn(homePage);
        when(homePage.selectMenu("Exception Management")).thenReturn(homePage);
        when(homePage.selectMenu("Transactions & Exceptions")).thenReturn(homePage);
        transactionAndExceptionsPage.navigateToTransactionAndExceptions();
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(2)).selectMenu(anyString());
    }

    @Test
    public void testResubmitTransactionAndExceptions() {
        when(webTaskSvc.getWebElementAttribute(GS_NOTIFICATION_OCC_COUNT_LOCATOR, "value")).thenReturn("5");
        doNothing().when(dmpGsPortalUtl).inputText(GS_SUBMITTED_MESSAGE_LOCATOR, "Test Automation", "ENTER", false);
        doNothing().when(threadSvc).sleepSeconds(1);
        doNothing().when(transactionAndExceptionsPage).waitForNotificationCountToReflect(anyInt());
        doNothing().when(webTaskSvc).click(GS_RESUBMIT_LOCATOR);
        doNothing().when(webTaskSvc).click(GS_RELOAD_BUTTON);
        transactionAndExceptionsPage.resubmitTransactionAndExceptions();
        doNothing().when(threadSvc).sleepSeconds(1);
        verify(dmpGsPortalUtl, times(1)).inputText(GS_SUBMITTED_MESSAGE_LOCATOR, "Test Automation", "ENTER", false);
        verify(webTaskSvc, times(1)).click(GS_RESUBMIT_LOCATOR);
    }

    @Test
    public void testCloseTransactionAndExceptions() {
        doNothing().when(webTaskSvc).click(GS_CLOSE_LOCATOR);
        doNothing().when(threadSvc).sleepSeconds(5);
        doNothing().when(webTaskSvc).click(GS_RELOAD_BUTTON);
        doNothing().when(webTaskSvc).waitForAttributeValueEqualsExpectedValue(GS_CLOSE_LOCATOR,"value","CLOSED",30);
        transactionAndExceptionsPage.closeTransactionAndExceptions();
        verify(webTaskSvc, times(1)).click(GS_CLOSE_LOCATOR);
        verify(webTaskSvc, times(1)).click(GS_RELOAD_BUTTON);
    }


}
