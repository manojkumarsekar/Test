package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.svc.WebTaskSvc;
import com.eastspring.tom.cart.dmp.MockSelenium;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

import static com.eastspring.tom.cart.dmp.pages.LoginPage.*;
import static org.mockito.Mockito.*;

public class LoginPageTest extends MockSelenium {

    private static final String MOCK_USER = "MOCK_USER";
    private static final String MOCK_PWD = "MOCK_PWD";

    @Spy
    @InjectMocks
    private LoginPage loginPage;

    @Mock
    private WebTaskSvc webTaskSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testEnterUserName() {
        doNothing().when(webTaskSvc).enterTextIntoById(MOCK_USER, GS_UI_USERNAME_ID);
        loginPage.enterUserName(MOCK_USER);
        verify(webTaskSvc, times(1)).enterTextIntoById(MOCK_USER, GS_UI_USERNAME_ID);
    }

    @Test
    public void testEnterPassword() {
        doNothing().when(webTaskSvc).enterTextIntoById(MOCK_PWD, GS_UI_PASSWORD_ID);
        loginPage.enterPassword(MOCK_PWD);
        verify(webTaskSvc, times(1)).enterTextIntoById(MOCK_PWD, GS_UI_PASSWORD_ID);
    }

    @Test
    public void testClickLoginButton() {
        doNothing().when(webTaskSvc).submitId(GS_UI_LOGIN_ID);
        loginPage.clickLoginButton();
        verify(webTaskSvc, times(1)).submitId(GS_UI_LOGIN_ID);
    }

    @Test
    public void testLoginIntoGs_loginIsSuccess() {
        doReturn(true).when(loginPage).isLoginSuccessful();

        loginPage.loginIntoGs(MOCK_USER, MOCK_PWD);

        verify(webTaskSvc, times(1)).enterTextIntoById(MOCK_USER, GS_UI_USERNAME_ID);
        verify(webTaskSvc, times(1)).enterTextIntoById(MOCK_PWD, GS_UI_PASSWORD_ID);
        verify(webTaskSvc, times(1)).submitId(GS_UI_LOGIN_ID);
    }

    @Test
    public void testLoginIntoGs_loginNotSuccessful() {
        thrown.expect(CartException.class);
        thrown.expectMessage(LOGIN_IS_NOT_SUCCESSFUL_UNABLE_TO_NAVIGATE_TO_HOME_PAGE);

        doReturn(false).when(loginPage).isLoginSuccessful();

        loginPage.loginIntoGs(MOCK_USER, MOCK_PWD);

        verify(webTaskSvc, times(1)).enterTextIntoById(MOCK_USER, GS_UI_USERNAME_ID);
        verify(webTaskSvc, times(1)).enterTextIntoById(MOCK_PWD, GS_UI_PASSWORD_ID);
        verify(webTaskSvc, times(1)).submitId(GS_UI_LOGIN_ID);
    }

}
