package com.eastspring.tom.cart.dmp.pages.benchmark.master;

import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.openqa.selenium.WebElement;

import java.util.List;

import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_BENCHMARKMARK_CATEGORY_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_BENCHMARKMARK_LEVELACCESS_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_BENCHMARKMARK_PROVIDERNAME_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_CRTSCODE_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_CURRENCY_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_EIS_BENCHMARKMARK_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_HEGDEINDICATOR_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_OFFICIAL_BENCHMARKMARK_LOCATOR;
import static com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage.BENCHMARK_REBALANCE_FREQUENCY_LOCATOR;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class BenchmarkPageTest {

    @InjectMocks
    private BenchmarkPage benchmarkPage;

    @Mock
    private HomePage homePage;

    @Mock
    private WebTaskSvc webTaskSvc;

    @Mock
    private WebElement elementLocator;

    @Mock
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Mock
    private List<WebElement> webElementList;

    @Mock
    private List<WebElement> webElementList1;

    @Mock
    private ThreadSvc threadSvc;

    @Mock
    private FormatterUtil formatter;


    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testnavigateToBenchMarkScreen() {
        when(homePage.clickMenuDropdown()).thenReturn(homePage);
        when(homePage.selectMenu("Benchmark Master")).thenReturn(homePage);
        when(homePage.selectMenu("Benchmark")).thenReturn(homePage);
        benchmarkPage.navigateToBenchMarkScreen();
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(2)).selectMenu(anyString());
    }

    @Test
    public void testGetBenchmarkDetails() {
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_EIS_BENCHMARKMARK_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_OFFICIAL_BENCHMARKMARK_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_CURRENCY_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_HEGDEINDICATOR_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_REBALANCE_FREQUENCY_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_BENCHMARKMARK_LEVELACCESS_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_BENCHMARKMARK_PROVIDERNAME_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_BENCHMARKMARK_CATEGORY_LOCATOR, "value")).thenReturn("test");
        when(webTaskSvc.getWebElementAttribute(BENCHMARK_CRTSCODE_LOCATOR, "value")).thenReturn("test");
        benchmarkPage.getBenchmarkDetails();
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_EIS_BENCHMARKMARK_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_OFFICIAL_BENCHMARKMARK_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_CURRENCY_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_HEGDEINDICATOR_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_REBALANCE_FREQUENCY_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_BENCHMARKMARK_LEVELACCESS_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_BENCHMARKMARK_PROVIDERNAME_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_BENCHMARKMARK_CATEGORY_LOCATOR, "value");
        verify(webTaskSvc, times(1)).getWebElementAttribute(BENCHMARK_CRTSCODE_LOCATOR, "value");
    }


}
