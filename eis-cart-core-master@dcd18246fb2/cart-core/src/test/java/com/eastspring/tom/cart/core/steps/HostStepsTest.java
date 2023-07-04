package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.RemoteOutput;
import com.eastspring.tom.cart.core.svc.RuntimeRemoteSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.eastspring.tom.cart.core.steps.HostSteps.HOSTMAP_NAME;
import static com.eastspring.tom.cart.core.steps.HostSteps.HOSTMAP_PORT;
import static com.eastspring.tom.cart.core.steps.HostSteps.HOSTMAP_USER;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class HostStepsTest {

    private static final String HOST_NAME = "host1";
    private static final String HOST_PORT = "22";
    private static final String HOST_USER = "user1";

    @InjectMocks
    private HostSteps steps;

    @Mock
    private FileDirUtil fileDirUtil;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private RuntimeRemoteSvc runtimeRemoteSvc;

    @Mock
    WorkspaceUtil workspaceUtil;

    @Mock
    private WorkspaceDirSvc workspaceDirSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void initLogging() {
        CartCoreTestConfig.configureLogging(HostStepsTest.class);
    }

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    private Map<String, String> getNamedHostMap() {
        return new HashMap<String, String>() {{
            put(HOSTMAP_NAME, HOST_NAME);
            put(HOSTMAP_USER, HOST_USER);
            put(HOSTMAP_PORT, HOST_PORT);
        }};
    }

    @Test
    public void testCopyLocalFilesToRemote() throws Exception {
        String localDir = "dir1/dir2";
        List<String> fileList = new ArrayList<>();
        fileList.add("abc.csv");
        fileList.add("def.tgz");
        Map<String, String> namedHostMap = this.getNamedHostMap();
        String destNamedHost = "this.is.host";
        String destRemoteDir = "/home/test/inbound";
        String expectedLocalSrcFile1 = "c:/tomwork/cart-tests/dir1/dir2/abc.csv";
        String expectedLocalSrcFile2 = "c:/tomwork/cart-tests/dir1/dir2/def.tgz";
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        when(workspaceUtil.getBaseDir()).thenReturn("c:/tomwork/cart-tests");
        when(stateSvc.expandVar("abc.csv")).thenReturn("abc.csv");
        when(stateSvc.expandVar("def.tgz")).thenReturn("def.tgz");
        when(stateSvc.expandVar(localDir)).thenReturn(localDir);
        when(workspaceDirSvc.normalize(localDir + File.separator + "abc.csv")).thenReturn(expectedLocalSrcFile1);
        when(workspaceDirSvc.normalize(localDir + File.separator + "def.tgz")).thenReturn(expectedLocalSrcFile2);
        when(stateSvc.expandVar(destRemoteDir)).thenReturn(destRemoteDir);
        steps.copyLocalFilesToRemote(localDir, fileList, destNamedHost, destRemoteDir);
        verify(runtimeRemoteSvc, times(1)).sshUpload(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, expectedLocalSrcFile1, destRemoteDir);
        verify(runtimeRemoteSvc, times(1)).sshUpload(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, expectedLocalSrcFile2, destRemoteDir);
    }

    @Test
    public void testCopyRemoteFilesToLocal() throws Exception {
        String srcNamedHost = "my.name.remote.host";
        String srcRemoteDir = "/home/test/copyfrom";
        String localDestDir = "tests/test-data/dir1";
        List<String> fileList = new ArrayList<>();
        fileList.add("abc.csv");
        fileList.add("def.tgz");
        Map<String, String> namedHostMap = this.getNamedHostMap();
        String localDestDirFullpath = "c:/tomwork/cart-tests/tests/test-data/dir1";
        when(stateSvc.getValueMapFromPrefix(srcNamedHost, true)).thenReturn(namedHostMap);
        when(stateSvc.expandVar(localDestDir)).thenReturn(localDestDir);
        when(stateSvc.expandVar(srcRemoteDir)).thenReturn(srcRemoteDir);
        when(workspaceDirSvc.normalize(localDestDir)).thenReturn(localDestDirFullpath);

        when(stateSvc.expandVar("abc.csv")).thenReturn("abc.csv");
        when(stateSvc.expandVar("def.tgz")).thenReturn("def.tgz");
        steps.copyRemoteFilesToLocal(srcNamedHost, srcRemoteDir, localDestDir, fileList);
        verify(fileDirUtil, times(1)).forceMkdir(localDestDirFullpath);
        verify(runtimeRemoteSvc, times(1)).sshDownload(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, "/home/test/copyfrom/abc.csv", localDestDirFullpath);
        verify(runtimeRemoteSvc, times(1)).sshDownload(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, "/home/test/copyfrom/def.tgz", localDestDirFullpath);
    }

    @Test
    public void testExpectFileAvailableInFolderAfterProcessing_FileExist() {
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName = "abc.csv";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName);
        when(stateSvc.expandVar(fileName)).thenReturn(fileName);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName, 10)).thenReturn(true);
        steps.expectFileAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName, 10);
    }

    @Test
    public void testExpectFileAvailableInFolderAfterProcessing_FileDoesnotExist() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file abc.csv is NOT available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName = "abc.csv";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName);
        when(stateSvc.expandVar(fileName)).thenReturn(fileName);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName)).thenReturn(false);
        steps.expectFileAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName);
    }

    @Test
    public void testExpectFileAvailableInFolderAfterProcessing_TwoFilesDoesnotExist() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file abc.csv is NOT available in the Folder /home/test/removefrom\nVerification Failed, file def.tgz is NOT available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName1 = "abc.csv";
        String fileName2 = "def.tgz";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName1);
        fileList.add(fileName2);
        when(stateSvc.expandVar(fileName1)).thenReturn(fileName1);
        when(stateSvc.expandVar(fileName2)).thenReturn(fileName2);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName1)).thenReturn(false);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName2)).thenReturn(false);
        steps.expectFileAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName1);
        verify(runtimeRemoteSvc, times(1)).sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName2);
    }

    @Test
    public void testExpectFileAvailableInFolderAfterProcessing_OneFileDoesnotExistFromListOfTwo() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file abc.csv is NOT available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName1 = "abc.csv";
        String fileName2 = "def.tgz";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName1);
        fileList.add(fileName2);
        when(stateSvc.expandVar(fileName1)).thenReturn(fileName1);
        when(stateSvc.expandVar(fileName2)).thenReturn(fileName2);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName1)).thenReturn(false);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName2)).thenReturn(true);
        steps.expectFileAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName1);
        verify(runtimeRemoteSvc, times(1)).sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName2);
    }


    @Test
    public void testExpectFileNotAvailableInFolderAfterProcessing_FileExists() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file def.tgz is available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName = "def.tgz";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName);
        when(stateSvc.expandVar(fileName)).thenReturn(fileName);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName)).thenReturn(true);
        steps.expectFileNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
    }

    @Test
    public void testExpectFileNotAvailableInFolderAfterProcessing_TwoFilesExists() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file def.tgz is available in the Folder /home/test/removefrom\nVerification Failed, file abc.csv is available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName1 = "def.tgz";
        String fileName2 = "abc.csv";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName1);
        fileList.add(fileName2);
        when(stateSvc.expandVar(fileName1)).thenReturn(fileName1);
        when(stateSvc.expandVar(fileName2)).thenReturn(fileName2);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName1)).thenReturn(true);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName2)).thenReturn(true);
        steps.expectFileNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
    }

    @Test
    public void testExpectFileNotAvailableInFolderAfterProcessing_OneFileExistsAmongTwo() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file def.tgz is available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName1 = "def.tgz";
        String fileName2 = "abc.csv";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName1);
        fileList.add(fileName2);
        when(stateSvc.expandVar(fileName1)).thenReturn(fileName1);
        when(stateSvc.expandVar(fileName2)).thenReturn(fileName2);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName1)).thenReturn(true);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName2)).thenReturn(false);
        steps.expectFileNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
    }

    @Test
    public void testExpectFileNotAvailableInFolderAfterProcessing_FileNotExists() {
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName = "def.tgz";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName);
        when(stateSvc.expandVar(fileName)).thenReturn(fileName);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName)).thenReturn(false);
        steps.expectFileNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + fileName);
    }

    @Test
    public void testExpectFilePatternAvailableInFolderAfterProcessing_FileExists() {
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName = "abc.csv";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName);
        when(stateSvc.expandVar(fileName)).thenReturn(fileName);
        when(runtimeRemoteSvc.sshFileExistsWithRegEx(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation, fileName)).thenReturn(true);
        steps.expectFilePatternAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshFileExistsWithRegEx(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation, fileName);
    }

    @Test
    public void testExpectFilePatternAvailableInFolderAfterProcessing_FileNotExists() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file with pattern abc.csv is NOT available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String fileName = "abc.csv";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(fileName);
        when(stateSvc.expandVar(fileName)).thenReturn(fileName);
        when(runtimeRemoteSvc.sshFileExistsWithRegEx(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation, fileName)).thenReturn(false);
        steps.expectFilePatternAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
    }

    @Test
    public void testExpectFilePatternNotAvailableInFolderAfterProcessing_FileExists() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Verification Failed, file with pattern def.* is available in the Folder /home/test/removefrom");
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String filePattern = "def.*";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(filePattern);
        when(stateSvc.expandVar(filePattern)).thenReturn(filePattern);
        when(runtimeRemoteSvc.sshFileExistsWithRegEx(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation, filePattern)).thenReturn(true);
        steps.expectFilePatternNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
    }

    @Test
    public void testExpectFilePatternNotAvailableInFolderAfterProcessing_FileDoesntExist() {
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        String filePattern = "def.*";
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        List<String> fileList = new ArrayList<>();
        fileList.add(filePattern);
        when(stateSvc.expandVar(filePattern)).thenReturn(filePattern);
        when(runtimeRemoteSvc.sshFileExistsWithRegEx(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation, filePattern)).thenReturn(false);
        steps.expectFilePatternNotAvailableInFolderAfterProcessing(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshFileExistsWithRegEx(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation, filePattern);
    }


    @Test
    public void testRemoveFileIfExists() {
        String destNamedHost = "my.name.remote.host";
        String folderLocation = "/home/test/removefrom";
        List<String> fileList = new ArrayList<>();
        fileList.add("abc.csv");
        fileList.add("def.tgz");
        Map<String, String> namedHostMap = this.getNamedHostMap();
        when(stateSvc.expandVar(folderLocation)).thenReturn(folderLocation);
        when(stateSvc.getValueMapFromPrefix(destNamedHost, true)).thenReturn(namedHostMap);
        when(stateSvc.expandVar("abc.csv")).thenReturn("abc.csv");
        when(stateSvc.expandVar("def.tgz")).thenReturn("def.tgz");
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + "abc.csv")).thenReturn(true);
        when(runtimeRemoteSvc.sshFileExists(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, folderLocation + "/" + "def.tgz")).thenReturn(false);
        steps.removeFileIfExists(destNamedHost, folderLocation, fileList);
        verify(runtimeRemoteSvc, times(1)).sshRemoteExecute(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, "rm " + folderLocation + "/" + "abc.csv");
        verify(runtimeRemoteSvc, times(0)).sshRemoteExecute(HOST_NAME, Integer.parseInt(HOST_PORT), HOST_USER, "rm " + folderLocation + "/" + "def.tgz");
    }

    @Test
    public void testRenameFile() {
        Map<String, String> namedHostMap = new HashMap<>();
        namedHostMap.put(HOSTMAP_NAME, "hostname");
        namedHostMap.put(HOSTMAP_USER, "hostuser");
        namedHostMap.put(HOSTMAP_PORT, "2222");
        when(stateSvc.expandVar("file.src")).thenReturn("abc.txt");
        when(stateSvc.expandVar("file.dst")).thenReturn("def.txt");
        when(stateSvc.getValueMapFromPrefix("named.host", true)).thenReturn(namedHostMap);
        steps.renameFile("file.src", "file.dst", "named.host");
        verify(runtimeRemoteSvc, times(1)).sshRemoteExecute("hostname", 2222, "hostuser", "mv abc.txt def.txt");
    }

    @Test
    public void testSaveFileAs() {
        Map<String, String> namedHostMap = new HashMap<>();
        namedHostMap.put(HOSTMAP_NAME, "hostname");
        namedHostMap.put(HOSTMAP_USER, "hostuser");
        namedHostMap.put(HOSTMAP_PORT, "2222");
        when(stateSvc.expandVar("file.src")).thenReturn("abc.txt");
        when(stateSvc.expandVar("file.dst")).thenReturn("def.txt");
        when(stateSvc.getValueMapFromPrefix("named.host", true)).thenReturn(namedHostMap);
        steps.saveFileAs("file.src", "file.dst", "named.host");
        verify(runtimeRemoteSvc, times(1)).sshRemoteExecute("hostname", 2222, "hostuser", "cp abc.txt def.txt");
    }

    @Test
    public void testValidateUnixFormat_unixFile() {
        Map<String, String> namedHostMap = new HashMap<>();
        namedHostMap.put(HOSTMAP_NAME, "hostname");
        namedHostMap.put(HOSTMAP_USER, "hostuser");
        namedHostMap.put(HOSTMAP_PORT, "2222");
        when(stateSvc.expandVar("file.src")).thenReturn("abc.txt");
        when(stateSvc.getValueMapFromPrefix("named.host", true)).thenReturn(namedHostMap);
        when(runtimeRemoteSvc.sshRemoteExecute("hostname", 2222, "hostuser", "grep -U $'\r' abc.txt|wc -l")).thenReturn(new RemoteOutput("0", ""));
        steps.validateUnixFormat("file.src", "named.host");
    }

    @Test
    public void testValidateUnixFormat_notUnixFile() {
        Map<String, String> namedHostMap = new HashMap<>();
        namedHostMap.put(HOSTMAP_NAME, "hostname");
        namedHostMap.put(HOSTMAP_USER, "hostuser");
        namedHostMap.put(HOSTMAP_PORT, "2222");
        when(stateSvc.expandVar("file.src")).thenReturn("abc.txt");
        when(stateSvc.getValueMapFromPrefix("named.host", true)).thenReturn(namedHostMap);
        when(runtimeRemoteSvc.sshRemoteExecute("hostname", 2222, "hostuser", "grep -U $'\r' abc.txt|wc -l")).thenReturn(new RemoteOutput("12452", ""));
        thrown.expect(CartException.class);
        thrown.expectMessage("File [abc.txt] is not in Unix format");
        steps.validateUnixFormat("file.src", "named.host");
    }
}
