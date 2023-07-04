package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.customer.master.AccountMasterPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class AccountMasterPageTest {
    @InjectMocks
    private AccountMasterPage accountMasterPage;

    @Mock
    private HomePage homePage;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

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
    public void testSearchAccountMaster() {
        doNothing().when(homePage).globalSearchAndWaitTillSuccess("MOCK_ACCOUNT", "Account", 120);
        doNothing().when(webTaskSvc).waitTillPageLoads();
        accountMasterPage.searchAccountMaster("MOCK_ACCOUNT");
        verify(homePage, times(1)).globalSearchAndWaitTillSuccess("MOCK_ACCOUNT", "Account", 120);
    }

    @Test
    public void testIsAccountMasterPresent() {
        doNothing().when(homePage).globalSearchAndWaitTillSuccess("MOCK_ACCOUNT", "Account", 120);
        doNothing().when(threadSvc).sleepSeconds(2);
        when(dmpGsPortalUtl.isSearchRecordAvailable("MOCK_ACCOUNT")).thenReturn(true);
        boolean flag = accountMasterPage.isAccountMasterPresent("MOCK_ACCOUNT");
        verify(dmpGsPortalUtl, times(1)).isSearchRecordAvailable("MOCK_ACCOUNT");
        Assert.assertTrue(flag);
    }

    @Test
    public void testInvokeAccountMaster_RecordAvailable() {
        doNothing().when(homePage).globalSearchAndWaitTillSuccess("MOCK_ACCOUNT", "Account", 120);
        doNothing().when(threadSvc).sleepSeconds(2);
        when(dmpGsPortalUtl.isSearchRecordAvailable("MOCK_ACCOUNT")).thenReturn(false);
        doNothing().when(dmpGsPortalUtl).invokeSetUpScreen(null, null, null);
        accountMasterPage.invokeAccountMaster("MOCK_ACCOUNT");
        verify(dmpGsPortalUtl, times(1)).invokeSetUpScreen(null, null, null);
    }

    @Test
    public void testInvokeAccountMaster_RecordNotAvailable() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Account Master is present with name [MOCK_ACCOUNT]");

        doNothing().when(homePage).globalSearchAndWaitTillSuccess("MOCK_ACCOUNT", "Account", 120);
        doNothing().when(threadSvc).sleepSeconds(2);
        when(dmpGsPortalUtl.isSearchRecordAvailable("MOCK_ACCOUNT")).thenReturn(true);
        accountMasterPage.invokeAccountMaster("MOCK_ACCOUNT");
    }

    @Test
    public void testSaveAccountMaster() {
        doNothing().when(dmpGsPortalUtl).saveChanges();
        accountMasterPage.saveAccountMaster();
        verify(dmpGsPortalUtl, times(1)).saveChanges();
    }
}
