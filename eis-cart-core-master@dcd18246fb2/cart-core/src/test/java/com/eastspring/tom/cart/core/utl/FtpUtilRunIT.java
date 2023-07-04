package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import org.apache.commons.net.ftp.FTPClient;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.mockftpserver.fake.FakeFtpServer;
import org.mockftpserver.fake.UserAccount;
import org.mockftpserver.fake.filesystem.DirectoryEntry;
import org.mockftpserver.fake.filesystem.FileEntry;
import org.mockftpserver.fake.filesystem.FileSystem;
import org.mockftpserver.fake.filesystem.UnixFakeFileSystem;
import org.mockftpserver.fake.filesystem.WindowsFakeFileSystem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.annotation.Order;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class FtpUtilRunIT {

    private static final String LOCAL_FTP_TEST_DOWNLOAD_PATH = "target/test-classes/remote/ftp/download";

    @Autowired
    private FtpUtil ftpUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    private FakeFtpServer fakeFtpServer;
    private FTPClient ftpClient;
    private String remotePath = System.getProperty("user.dir");

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FtpUtilRunIT.class);
    }

    @Before
    @Order(value = 0)
    public void cleanUpLocalTargetFolder() {
        fileDirUtil.forceDelete(LOCAL_FTP_TEST_DOWNLOAD_PATH);
    }

    @Before
    @Order(value = 1)
    public void startFtpServer() {
        fakeFtpServer = new FakeFtpServer();
        fakeFtpServer.setServerControlPort(0);

        FileSystem fileSystem = new WindowsFakeFileSystem();

        if (!System.getProperty("os.name").startsWith("Windows")) {
            remotePath = "/data";
            fileSystem = new UnixFakeFileSystem();
        }

        fakeFtpServer.addUserAccount(new UserAccount("user", "password", remotePath));
        DirectoryEntry fakeDirectory = new DirectoryEntry(remotePath);
        fileSystem.add(fakeDirectory);

        FileEntry fakeFile1 = new FileEntry(remotePath + File.separator + "file1.csv");
        FileEntry fakeFile2 = new FileEntry(remotePath + File.separator + "file2.csv");
        FileEntry fakeFile3 = new FileEntry(remotePath + File.separator + "file3.txt");
        FileEntry fakeFile4 = new FileEntry(remotePath + File.separator + "file4.psv");

        fileSystem.add(fakeFile1);
        fileSystem.add(fakeFile2);
        fileSystem.add(fakeFile3);
        fileSystem.add(fakeFile4);

        fakeFtpServer.setFileSystem(fileSystem);
        fakeFtpServer.start();
        ftpClient = ftpUtil.openFtp("localhost", fakeFtpServer.getServerControlPort(), "user", "password");
    }

    @Test
    public void testOpenFtp_Successful_Connection() {
        Assert.assertNotNull(ftpClient);
    }

    @Test
    public void testDownload_file() {
        String localFilePath = LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file4.psv";
        ftpUtil.download(remotePath + File.separator + "file4.psv", localFilePath, ".*");
        Assert.assertTrue(fileDirUtil.fileDirExist(localFilePath));
    }

    @Test
    public void testDownload_file_exception() {
        thrown.expectMessage("Exception during ftp download");
        thrown.expect(CartException.class);

        String localFilePath = LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file4.csv";
        ftpUtil.download(remotePath + File.separator + "file4.csv", localFilePath, ".*");
        Assert.assertTrue(fileDirUtil.fileDirExist(localFilePath));
    }

    @Test
    public void testDownload_file_not_downloaded() {
        String localFilePath = LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file4.psv";
        ftpUtil.download(remotePath + File.separator + "file4.psv", localFilePath, ".*.sh");
        Assert.assertFalse(fileDirUtil.fileDirExist(localFilePath));
    }

    @Test
    public void testDownload_folder_without_pattern() {
        ftpUtil.download(remotePath, LOCAL_FTP_TEST_DOWNLOAD_PATH, ".*");
        Assert.assertTrue(fileDirUtil.fileDirExist(LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file1.csv"));
        Assert.assertTrue(fileDirUtil.fileDirExist(LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file2.csv"));
        Assert.assertTrue(fileDirUtil.fileDirExist(LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file3.txt"));
        Assert.assertTrue(fileDirUtil.fileDirExist(LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file4.psv"));
    }

    @Test
    public void testDownload_folder_with_pattern1() {
        ftpUtil.download(remotePath, LOCAL_FTP_TEST_DOWNLOAD_PATH, ".*.txt");
        Assert.assertTrue(fileDirUtil.fileDirExist(LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file3.txt"));
    }

    @Test
    public void testDownload_folder_with_pattern2() {
        ftpUtil.download(remotePath, LOCAL_FTP_TEST_DOWNLOAD_PATH, ".*.txt|.*.psv");
        Assert.assertTrue(fileDirUtil.fileDirExist(LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file3.txt"));
        Assert.assertTrue(fileDirUtil.fileDirExist(LOCAL_FTP_TEST_DOWNLOAD_PATH + File.separator + "file4.psv"));
    }

    @After
    @Order(value = 1)
    public void stopFtpServer() {
        fakeFtpServer.stop();
    }

    @After
    @Order(value = 0)
    public void closeFtpClient() {
        ftpUtil.closeFtp();
    }
}
