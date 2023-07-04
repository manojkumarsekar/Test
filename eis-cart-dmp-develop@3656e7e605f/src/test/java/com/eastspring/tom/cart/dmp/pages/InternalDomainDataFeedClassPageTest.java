package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.internaldomaindatafeedclass.InternalDomainDataFeedClassPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static com.eastspring.tom.cart.dmp.pages.internaldomaindatafeedclass.InternalDomainDataFeedClassPage.*;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

public class InternalDomainDataFeedClassPageTest {

    @InjectMocks
    private InternalDomainDataFeedClassPage internalDomainDataFeedClassPage;

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
    public void testnavigateToInternalDomainDataFeedClass() {
        when(homePage.clickMenuDropdown()).thenReturn(homePage);
        when(homePage.selectMenu("Generic Setup")).thenReturn(homePage);
        when(homePage.selectMenu("Internal Domain For Data Field Class")).thenReturn(homePage);
        internalDomainDataFeedClassPage.navigateToInternalDomainDataFeedClass();
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(2)).selectMenu(anyString());
    }


    @Test
    public void testsaveDetails() {
        doNothing().when(dmpGsPortalUtl).saveChanges();
        internalDomainDataFeedClassPage.saveDetails();
    }

    @Test
    public void testgetActiveDomainValuedDetails() {
        when(webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVALNAME_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVAL_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_MODIREST_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVALDESC_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_QUAFIELDID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_QUALIVAL_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_TABLEID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_COLNAME_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINSETID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_DOMAINVALPURTYPE_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_DATASOURCEID_TEXTFIELD, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(IDFDFC_DATASTATUS_TEXTFIELD, "value")).thenReturn("test");
        internalDomainDataFeedClassPage.getActiveDomainValuedDetails();
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDFC_DOMAINVALNAME_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDFC_DOMAINVAL_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDFC_MODIREST_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDFC_DOMAINVALDESC_TEXTFIELD, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(IDFDFC_QUAFIELDID_TEXTFIELD, "value");
    }
}
