package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.internaldomaindatafeed.InternalDomainDataFeedPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static com.eastspring.tom.cart.dmp.pages.internaldomaindatafeed.InternalDomainDataFeedPage.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

public class InternalDomainDataFeedPageTest {
    @InjectMocks
    private InternalDomainDataFeedPage internalDomainDataFeedPage;

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
    public void testnavigateToInternalDomainDataFeed() {
        when(homePage.clickMenuDropdown()).thenReturn(homePage);
        when(homePage.selectMenu("Generic Setup")).thenReturn(homePage);
        when(homePage.selectMenu("Internal Domain For Data Field")).thenReturn(homePage);
        internalDomainDataFeedPage.navigateToInternalDomainDataFeed();
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(2)).selectMenu(anyString());
    }


    @Test
    public void testsaveDetails() {
        doNothing().when(dmpGsPortalUtl).saveChanges();
        internalDomainDataFeedPage.saveDetails();
    }

    @Test
    public void testgetActiveDomainValuedDetails() {
        when(webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVALNAME_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVAL_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_MODIREST_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVALDESC_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_QUAFIELDID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_QUALIVAL_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_TABLEID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_COLNAME_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_DOMAINSETID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_DOMAINVALPURTYPE_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_DATASTREAMID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDF_FIELDDATACLASSID_TEXTFIELD, "value")).thenReturn("test");
        internalDomainDataFeedPage.getActiveDomainValuedDetails();
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDF_DOMAINVALNAME_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDF_DOMAINVAL_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDF_MODIREST_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDF_DOMAINVALDESC_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDF_QUAFIELDID_TEXTFIELD, "value");
    }
}
