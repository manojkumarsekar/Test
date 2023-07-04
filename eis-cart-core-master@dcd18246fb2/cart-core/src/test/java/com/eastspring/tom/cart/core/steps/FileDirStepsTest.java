package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.svc.FileDirSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class FileDirStepsTest {

    @InjectMocks
    private FileDirSteps steps;

    @Mock
    private FileDirSvc fileDirSvc;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private WorkspaceDirSvc workspaceDirSvc;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileDirStepsTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testVerifyFileExists() throws Exception {
        when(stateSvc.expandVar("abc")).thenReturn("abc");
        when(workspaceDirSvc.normalize("abc")).thenReturn("/abc");
        steps.verifyFileExists("abc");
        verify(fileDirSvc, times(1)).verifyFileExists("/abc");
    }

    @Test
    public void testVerifyFileSizeNonZero() throws Exception {
        when(stateSvc.expandVar("abc")).thenReturn("abc");
        when(workspaceDirSvc.normalize("abc")).thenReturn("/abc");
        steps.verifyFileSizeNonZero("abc");
        verify(fileDirSvc, times(1)).verifyFileSizeNonZero("/abc");
    }

    @Test
    public void testCreateFolderIfNotExist() throws Exception {
        steps.createFolderIfNotExist("abc/def/ghi");
        verify(fileDirSvc, times(1)).forceMakeDirs("abc/def/ghi");
    }

    @Test
    public void testVerifyNoOfRecordsInFile() {
        when(stateSvc.expandVar("abc")).thenReturn("abc");
        when(stateSvc.expandVar("1")).thenReturn("1");
        when(workspaceDirSvc.normalize("abc")).thenReturn("abc");
        steps.verifyNoOfRecordsInFile("abc", 1);
        verify(fileDirSvc, times(1)).verifyFileRecordCount("abc", 1);
    }

}
