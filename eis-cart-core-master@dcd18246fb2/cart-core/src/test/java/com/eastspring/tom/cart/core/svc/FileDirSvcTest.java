package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.utl.EncodingUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.*;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.*;

public class FileDirSvcTest {
    @InjectMocks
    private FileDirSvc fileDirSvc;

    @Mock
    private EncodingUtil encodingUtil;

    @Mock
    private FileDirUtil fileDirUtil;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private WorkspaceUtil workspaceUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileDirSvcTest.class);
    }


    @Test
    public void testCreateTestEvidenceSubDir_withSlash() {
        when(workspaceUtil.getTestEvidenceDir()).thenReturn("evidence");
        String result = fileDirSvc.createTestEvidenceSubDir("/abc");
        verify(fileDirUtil, times(1)).forceMkdir("evidence/abc");
        assertEquals("evidence/abc", result);
    }

    @Test
    public void testCreateTestEvidenceSubDir_withBackslash() {
        when(workspaceUtil.getTestEvidenceDir()).thenReturn("evidence");
        String result = fileDirSvc.createTestEvidenceSubDir("\\abc\\def");
        verify(fileDirUtil, times(1)).forceMkdir("evidence\\abc\\def");
        assertEquals("evidence\\abc\\def", result);
    }

    @Test
    public void testCreateTestEvidenceSubDir_noSlash() {
        when(workspaceUtil.getTestEvidenceDir()).thenReturn("evidence");
        String result = fileDirSvc.createTestEvidenceSubDir("abc");
        verify(fileDirUtil, times(1)).forceMkdir("evidence/abc");
        assertEquals("evidence/abc", result);
    }

    @Test
    public void testVerifyFileExists_fileExists() {
        String fileFullpath = new FileDirUtil().getMavenTestResourcesPath("conf/log4j.xml");
        fileDirSvc.verifyFileExists(fileFullpath);
    }

    @Test
    public void testVerifyFileExists_notExists() {
        thrown.expect(CartException.class);
        thrown.expectMessage("file [/abc/file_doest_not_exist_of_course] does not exist");
        fileDirSvc.verifyFileExists("/abc/file_doest_not_exist_of_course");
    }

    @Test
    public void testVerifyFileRecordCount() {
        when(fileDirUtil.getRowsCountInFile("/abc/def.csv")).thenReturn(30L);
        fileDirSvc.verifyFileRecordCount("/abc/def.csv", 30);
    }

    @Test
    public void testVerifyFileRecordCount_failed() {
        when(fileDirUtil.getRowsCountInFile("/abc/def.csv")).thenReturn(30L);
        thrown.expect(CartException.class);
        thrown.expectMessage("No. of records in file are [30], expected are [25]");
        fileDirSvc.verifyFileRecordCount("/abc/def.csv", 25);
    }

    @Test
    public void testRename() {
        fileDirSvc.rename("abc", "def");
        verify(fileDirUtil, times(1)).move("abc", "def");
    }

    @Test
    public void testSaveAs() {
        fileDirSvc.saveAs("abc", "def");
        verify(fileDirUtil, times(1)).copyFile("abc", "def");
    }

    @Test
    public void testForceDelete() {
        fileDirSvc.forceDelete("abc");
        verify(fileDirUtil, times(1)).forceDelete("abc");
    }

    @Test
    public void testForceMakedirs() {
        fileDirSvc.forceMakeDirs("abc");
        verify(fileDirUtil, times(1)).forceMakeDirs("abc");
    }

    @Test
    public void testCopyWithEncodingConversion() {
        fileDirSvc.copyWithEncodingConversion("abc", "def", "UTF-8", "UTF-16");
        verify(encodingUtil, times(1)).copyWithEncodingConversion("abc", "def", "UTF-8", "UTF-16");
    }

    @Test
    public void testCopyWithDelimiterConversion() {
        when(fileDirUtil.readFileToString("abc")).thenReturn("a,b,c,d");
        fileDirSvc.copyWithDelimiterConversion("abc", "def", ",", ":");
        verify(fileDirUtil, times(1)).writeStringToFile("def", "a:b:c:d");
    }

    @Test
    public void testFileDir() {
        FileDirSvc.FileDir fileDir = new FileDirSvc.FileDir("abc", "def");
        assertEquals("abc", fileDir.getDir());
        assertEquals("def", fileDir.getFile());
    }

    @Test
    public void testVerifyFileSizeNonZero_sizeNonZero() {
        String fileFullpath = new FileDirUtil().getMavenTestResourcesPath("conf/log4j.xml");
        fileDirSvc.verifyFileSizeNonZero(fileFullpath);
    }

    @Test
    public void testVerifyFileSizeNonZero_fileDoesntExist() {
        thrown.expect(CartException.class);
        thrown.expectMessage("file [fileNotExist.adfiru] does not exist");
        fileDirSvc.verifyFileSizeNonZero("fileNotExist.adfiru");
    }

    @Test
    public void testVerifyFileSizeNonZero_sizeZero() {
        String fileFullpath = new FileDirUtil().getMavenTestResourcesPath("filedirutil/zeroSizedFile.txt");
        thrown.expect(CartException.class);
        fileDirSvc.verifyFileSizeNonZero(fileFullpath);
    }
}
