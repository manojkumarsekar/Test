package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.customer.master.ExternalAccountPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static com.eastspring.tom.cart.dmp.pages.customer.master.ExternalAccountPage.*;
import static org.mockito.Mockito.*;

public class ExternalAccountPageTest {


    @InjectMocks
    private ExternalAccountPage externalAccountPage;

    @Mock
    private HomePage homePage;

    @Mock
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Mock
    private WebTaskSvc webTaskSvc;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testInvokeExternalAccountScreen() {
        when(homePage.clickMenuDropdown()).thenReturn(homePage);
        when(homePage.selectMenu("Customer Master")).thenReturn(homePage);
        when(homePage.selectMenu("External Account")).thenReturn(homePage);
        externalAccountPage.invokeExternalAccountScreen();
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(2)).selectMenu(anyString());
    }

    @Test
    public void testGetExternalAccountDetails() {
        when(webTaskSvc.getWebElementAttribute(EXT_ACCT_INST_NAME_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_NME_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_NO_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(EXT_ACCT_ROLE_TYPE_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_DATE_LOCATOR, "value")).thenReturn("test");
        externalAccountPage.getExternalAccountDetails();
        verify(webTaskSvc, times(1)).getWebElementAttribute(EXT_ACCT_INST_NAME_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_NME_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_NO_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(EXT_ACCT_ROLE_TYPE_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(EXT_ACCT_EXTERNAL_ACCOUNT_DATE_LOCATOR, "value");
    }

}
