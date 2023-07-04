package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.HashMap;
import java.util.Map;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class AuditLogReportPageTest {

    @InjectMocks
    private AuditLogReportPage page;

    @Mock
    private HomePage homePage;

    @Mock
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testNavigateToAuditLogReport() {
        when(dmpGsPortalUtl.getActiveScreenName()).thenReturn("mock");
        when(homePage.clickMenuDropdown()).thenReturn(homePage);
        when(homePage.selectMenu(anyString())).thenReturn(homePage);
        page.navigateToAuditLogReport();
        verify(homePage, times(1)).selectMenu("AuditLog");
        verify(homePage, times(1)).selectMenu("Audit Log Report");
    }

    @Test
    public void testNavigateToAuditLogReport_WhenAlreadyOpened() {
        when(dmpGsPortalUtl.getActiveScreenName()).thenReturn("Audit Log Report");
        page.navigateToAuditLogReport();
        verify(homePage, times(0)).selectMenu("AuditLog");
        verify(homePage, times(0)).selectMenu("Audit Log Report");
    }

    @Test
    public void testSearchAuditLog() {
        Map<String, String> map = new HashMap<>();
        map.put("Column1", "Benchmark");
        when(dmpGsPortalUtl.filterTable("Column1", "Benchmark", false)).thenReturn(true);
        Assert.assertNotNull(page.searchAuditLog(map));
        verify(dmpGsPortalUtl, times(1)).filterTable("Column1", "Benchmark", false);

    }
}
