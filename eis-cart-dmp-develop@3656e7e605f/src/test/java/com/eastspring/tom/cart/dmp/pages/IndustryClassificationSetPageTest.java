package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage.CLASSIFICATION_CREATED_ON_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage.CLASSIFICATION_ID_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage.CLASSIFICATION_VALUE_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage.CLASS_DESCRIPTION_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage.CLASS_NAME_LOCATOR;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class IndustryClassificationSetPageTest {

    @InjectMocks
    private IndustryClassificationSetPage industryClassificationSetPage;

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
    public void testNavigateToIndusClassifSet() {
        when(homePage.clickMenuDropdown()).thenReturn(homePage);
        when(homePage.selectMenu("Generic Setup")).thenReturn(homePage);
        when(homePage.selectMenu("Industry Classification Set")).thenReturn(homePage);
        industryClassificationSetPage.navigateToIndusClassifSet();
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(2)).selectMenu(anyString());
    }

    @Test
    public void testGetActiveIndustryClassificationDetails() {
        when(webTaskSvc.getWebElementAttribute(CLASS_NAME_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(CLASS_DESCRIPTION_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(CLASSIFICATION_VALUE_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(CLASSIFICATION_ID_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(CLASSIFICATION_CREATED_ON_LOCATOR, "value")).thenReturn("test");
        industryClassificationSetPage.getActiveIndustryClassificationDetails();
        verify(webTaskSvc, times(1)).getWebElementAttribute(CLASS_NAME_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(CLASS_DESCRIPTION_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(CLASSIFICATION_VALUE_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(CLASSIFICATION_ID_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(CLASSIFICATION_CREATED_ON_LOCATOR, "value");
    }
}
