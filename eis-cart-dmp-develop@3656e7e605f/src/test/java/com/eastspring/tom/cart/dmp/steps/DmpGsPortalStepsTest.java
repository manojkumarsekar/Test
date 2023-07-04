package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.mdl.GSUISpec;
import com.eastspring.tom.cart.dmp.pages.HomePage;
import com.eastspring.tom.cart.dmp.pages.LoginPage;
import com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage;
import com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage;
import com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage;
import com.eastspring.tom.cart.dmp.utl.DmpGsPortalUtl;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;
import org.openqa.selenium.WebElement;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.Mockito.*;

public class DmpGsPortalStepsTest {

    @Spy
    @InjectMocks
    private DmpGsPortalSteps dmpGsPortalSteps;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Mock
    private WebElement mockElement;

    @Mock
    private ThreadSvc threadSvc;

    @Mock
    private LoginPage loginPage;

    @Mock
    private HomePage homePage;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private WebTaskSvc webTaskSvc;

    @Mock
    private DmpGsPortalUtl dmpGsPortalUtl;

    @Mock
    private BenchmarkPage benchmarkPage;

    @Mock
    private GSUISpec GSUISpec;

    @Mock
    private MyWorkListPage myWorkListPage;

    @Mock
    private TransactionAndExceptionsPage transactionAndExceptionsPage;


    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testSelectGsMenu() {
        dmpGsPortalSteps.selectGsMenu("FakeMainMenu::FakeSubMenu");
        verify(homePage, times(1)).clickMenuDropdown();
        verify(homePage, times(1)).selectMenu("FakeMainMenu");
        verify(homePage, times(1)).selectMenu("FakeSubMenu");

    }

    @Test
    public void testCloseGsTab() {
        dmpGsPortalSteps.closeGsTab("FakeTab");
        verify(threadSvc, times(1)).inbetweenStepsWait();
        verify(homePage, times(1)).closeGSTab("FakeTab");
        verify(threadSvc, times(1)).sleepMillis(1000);
    }

    @Test
    public void testLoginGsUIWithNamedConfig() {
        when(stateSvc.getStringVar("gs.web.UI.url")).thenReturn("Fake_Url");
        when(stateSvc.getStringVar("gs.web.UI.username")).thenReturn("Fake_User");
        when(stateSvc.getStringVar("gs.web.UI.password")).thenReturn("Fake_Password");
        dmpGsPortalSteps.loginGsUIWithNamedConfig("gs.web.UI");
        verify(webTaskSvc, times(1)).openWebUrl("Fake_Url");
        verify(loginPage, times(1)).loginIntoGs("Fake_User", "Fake_Password");
    }

    @Test
    public void testverifyTabDisplayed() {
        dmpGsPortalSteps.verifyTabDisplayed("FakeTab");
        verify(homePage, times(1)).verifyGSTabDisplayed("FakeTab");
    }

    @Test
    public void testLoginToGSWithUserRoleTaskAssignee() {
        when(stateSvc.getStringVar("gs.web.UI.url")).thenReturn("mock_url");
        when(stateSvc.getStringVar("gs.web.UI.taskassignee.username")).thenReturn("mock_user");
        when(stateSvc.getStringVar("gs.web.UI.taskassignee.password")).thenReturn("mock_password");
        dmpGsPortalSteps.loginToGSWithUserRole("task_assignee");
        verify(loginPage, times(1)).loginIntoGs("mock_user", "mock_password");
        //verify(dmpGsPortalSteps, times(1)).loginGsWithInlineUrl("Fake_Url", "Fake_User", "Fake_Password");
    }


    @Test
    public void testVerifyDropdownValues_AllMatch() {
        String elementProps = "id:test";
        List<String> expected = new ArrayList<>();
        expected.add("A");
        expected.add("B");

        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");
        actual.add("B");

        when(webTaskSvc.waitForElementToAppear(elementProps, 10)).thenReturn(mockElement);
        doNothing().when(mockElement).click();

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValues(elementProps, expected, true);
    }

    @Test
    public void testVerifyDropdownValues_AllMatch_ButOneIsMissing() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Dropdown Values verification failed, list values Count check is [true] and missing values are [[B]]");
        String elementProps = "id:test";
        List<String> expected = new ArrayList<>();
        expected.add("A");
        expected.add("B");

        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");
        actual.add("C");

        when(webTaskSvc.waitForElementToAppear(elementProps, 10)).thenReturn(mockElement);
        doNothing().when(mockElement).click();

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValues(elementProps, expected, true);
    }

    @Test
    public void testVerifyDropdownValues_AllMatch_ButCountMisMatch() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Dropdown Values verification failed, list values Count check is [false] and missing values are [[B]]");
        String elementProps = "id:test";
        List<String> expected = new ArrayList<>();
        expected.add("A");
        expected.add("B");

        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");

        when(webTaskSvc.waitForElementToAppear(elementProps, 10)).thenReturn(mockElement);
        doNothing().when(mockElement).click();

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValues(elementProps, expected, true);
    }

    @Test
    public void testVerifyDropdownValues_AllMatch_CountMisMatchButAllMatch() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Dropdown Values verification failed, list values Count check is [false] and missing values are [[]]");
        String elementProps = "id:test";
        List<String> expected = new ArrayList<>();
        expected.add("A");
        expected.add("B");

        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");
        actual.add("B");
        actual.add("C");

        when(webTaskSvc.waitForElementToAppear(elementProps, 10)).thenReturn(mockElement);
        doNothing().when(mockElement).click();

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValues(elementProps, expected, true);
    }

    @Test
    public void testVerifyDropdownValues_Contains() {
        String elementProps = "id:test";
        List<String> expected = new ArrayList<>();
        expected.add("A");

        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");
        actual.add("B");
        actual.add("C");
        actual.add("D");

        when(webTaskSvc.waitForElementToAppear(elementProps, 10)).thenReturn(mockElement);
        doNothing().when(mockElement).click();

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValues(elementProps, expected, false);
    }

    @Test
    public void testVerifyDropdownValues_Contains_NotFound() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Dropdown Values verification failed, missing values are [[E]]");
        String elementProps = "id:test";
        List<String> expected = new ArrayList<>();
        expected.add("E");

        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");
        actual.add("B");
        actual.add("C");
        actual.add("D");

        when(webTaskSvc.waitForElementToAppear(elementProps, 10)).thenReturn(mockElement);
        doNothing().when(mockElement).click();

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValues(elementProps, expected, false);
    }

    @Test
    public void testVerifyDropdownValuesCount_CountsMatch() {
        String elementProps = "id:test";
        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");
        actual.add("B");
        actual.add("C");
        actual.add("D");

        Map<String, String> expected = new HashMap<>();
        expected.put("A", "1");
        expected.put("B", "1");
        expected.put("C", "1");

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValuesCount(elementProps, expected);
    }

    @Test
    public void testVerifyDropdownValuesCount_CountsNotMatch() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Dropdown Values Count verification failed, Actual counts are [{A=2, C=2}]");

        String elementProps = "id:test";
        List<String> actual = new ArrayList<>();
        actual.add(" ");
        actual.add("A");
        actual.add("A");
        actual.add("B");
        actual.add("C");
        actual.add("C");
        actual.add("D");

        Map<String, String> expected = new HashMap<>();
        expected.put("A", "1");
        expected.put("B", "1");
        expected.put("C", "1");

        when(stateSvc.expandVar(elementProps)).thenReturn(elementProps);
        when(dmpGsPortalUtl.getDropDownFieldValues()).thenReturn(actual);
        dmpGsPortalSteps.verifyDropdownValuesCount(elementProps, expected);
    }


}
