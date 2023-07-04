package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.apache.commons.io.FileUtils;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

@RunWith( SpringJUnit4ClassRunner.class )
@ContextConfiguration( classes = {CartCoreUtlConfig.class} )
public class FileDirUtilRunIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(FileDirUtilRunIT.class);

    @Autowired
    private FileDirUtil fileDirUtil;

    @Rule
    public TemporaryFolder temporaryFolder = new TemporaryFolder();

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FileDirUtilRunIT.class);
    }

    @Test
    public void testTouch() {
        String filePath = "target/test-classes/test_touch.txt";
        fileDirUtil.touch(filePath);
        Assert.assertTrue(fileDirUtil.verifyFileExists(filePath));
    }

    @Test
    public void testGetClassAbsolutePath() throws Exception {
        String result = fileDirUtil.getClassAbsolutePath(FileDirUtilRunIT.class);
        Assert.assertEquals(FileDirUtilRunIT.class.getProtectionDomain().getCodeSource().getLocation().getPath(), result);
    }

    @Test
    public void testReadFileToString() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/readFileToString.txt");
        String result = fileDirUtil.readFileToString(testFile);
        String osName = System.getProperty("os.name");
        if (osName != null && osName.toUpperCase().startsWith("WINDOWS")) {
            Assert.assertEquals("a quick brown fox\njumps over the lazy dog.", result);
        } else {
            Assert.assertEquals("a quick brown fox\njumps over the lazy dog.", result);
        }
    }

    @Test
    public void testConvertFileEncoding() {
        String testFile = "target/test-classes/filedirutil/encoding_test.csv";
        String newFile = "target/test-classes/filedirutil/encoding_test_UTF-8.csv";

        fileDirUtil.convertFileEncoding(testFile, String.valueOf(StandardCharsets.UTF_16LE), String.valueOf(StandardCharsets.UTF_8));

        Assert.assertTrue(fileDirUtil.readFileToString(newFile).contains("Date|Fund ID"));
    }

    @Test
    public void testConvertFileEncoding_InvalidSrcEncoding_ButValidType(){
        String testFile = "target/test-classes/filedirutil/encoding_test.csv";
        String newFile = "target/test-classes/filedirutil/encoding_test_UTF-8.csv";

        fileDirUtil.convertFileEncoding(testFile, String.valueOf(StandardCharsets.ISO_8859_1), String.valueOf(StandardCharsets.UTF_8));

        Assert.assertFalse(fileDirUtil.readFileToString(newFile).contains("Date|Fund ID"));
    }

    @Test
    public void testConvertFileEncoding_InvalidTargetEncoding_ButValidType(){
        String testFile = "target/test-classes/filedirutil/encoding_test.csv";
        String newFile = "target/test-classes/filedirutil/encoding_test_UTF-16LE.csv";

        fileDirUtil.convertFileEncoding(testFile, String.valueOf(StandardCharsets.UTF_16LE), String.valueOf(StandardCharsets.UTF_16LE));

        Assert.assertFalse(fileDirUtil.readFileToString(newFile).contains("Date|Fund ID"));
    }

    @Test
    public void testConvertFileEncoding_InvalidSrcEncoding_ThrowsException(){
        thrown.expect(CartException.class);
        thrown.expectMessage("Unable to convert File Encoding from [invalid] to [UTF-8]");

        String testFile = "target/test-classes/filedirutil/encoding_test.csv";

        fileDirUtil.convertFileEncoding(testFile, "invalid", String.valueOf(StandardCharsets.UTF_8));
    }

    @Test
    public void testWriteStringToFile() {
        String writeToDir = fileDirUtil.getMavenTestResourcesPath("filedirutil");
        fileDirUtil.forceMkdir(writeToDir);
        String writeToFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/writeStringToFile.txt");
        fileDirUtil.writeStringToFile(writeToFile, "abc\ndef");
        String result = fileDirUtil.readFileToString(writeToFile);
        Assert.assertEquals("abc\ndef", result);
    }

    @Test
    public void testFileDirExists_folder() throws Exception {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String dirPath = tempFolder.getAbsolutePath();
        boolean result1 = fileDirUtil.fileDirExist(dirPath);
        Assert.assertTrue(result1);
        tempFolder.delete();
        boolean result2 = fileDirUtil.fileDirExist(dirPath);
        Assert.assertFalse(result2);
    }

    @Test
    public void testFileDirExists_nullPath() throws Exception {
        Exception thrownException = null;
        try {
            fileDirUtil.fileDirExist(null);
        } catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals(FileDirUtil.PATH_NAME_MUST_BE_SPECIFIED, thrownException.getMessage());
    }

    @Test
    public void testFileDirExists_file() throws Exception {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/hello.txt";
        FileUtils.writeStringToFile(new File(fileFullpath), "hello, world!", Charset.forName(EncodingConstants.UTF_8), false);
        boolean result1 = fileDirUtil.fileDirExist(fileFullpath);
        Assert.assertTrue(result1);
        FileUtils.forceDelete(new File(fileFullpath));
        tempFolder.delete();
        boolean result2 = fileDirUtil.fileDirExist(fileFullpath);
        Assert.assertFalse(result2);
    }

    @Test
    public void testVerifyFileExists_nullPathName() throws Exception {
        Exception thrownException = null;
        try {
            fileDirUtil.verifyFileExists(null);
        } catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals(FileDirUtil.PATH_NAME_MUST_BE_SPECIFIED, thrownException.getMessage());
    }

    @Test
    public void testVerifyDirExists_nullPathName() throws Exception {
        Exception thrownException = null;
        try {
            fileDirUtil.verifyDirExists(null);
        } catch (Exception e) {
            thrownException = e;
        }
        Assert.assertNotNull(thrownException);
        Assert.assertTrue(thrownException instanceof CartException);
        Assert.assertEquals(FileDirUtil.PATH_NAME_MUST_BE_SPECIFIED, thrownException.getMessage());
    }


    @Test
    public void testVerifyFileExists() throws Exception {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/hello.txt";
        FileUtils.writeStringToFile(new File(fileFullpath), "hello, world!", Charset.forName(EncodingConstants.UTF_8), false);
        boolean result1 = fileDirUtil.verifyFileExists(fileFullpath);
        Assert.assertTrue(result1);
        boolean result2 = fileDirUtil.verifyFileExists(filePath);
        Assert.assertFalse(result2);
        boolean result3 = fileDirUtil.verifyDirExists(fileFullpath);
        Assert.assertFalse(result3);
        FileUtils.forceDelete(new File(fileFullpath));
        tempFolder.delete();
        boolean result4 = fileDirUtil.verifyFileExists(fileFullpath);
        Assert.assertFalse(result4);
        boolean result5 = fileDirUtil.verifyDirExists(fileFullpath);
        Assert.assertFalse(result5);
    }


    @Test
    public void testGetFilenameFromPath() throws Exception {
        Assert.assertEquals("d.tx.ad.f.a.f", fileDirUtil.getFilenameFromPath("c:/a/b/c/d.tx.ad.f.a.f"));
        Assert.assertEquals("abc", fileDirUtil.getFilenameFromPath("abc"));
        Assert.assertEquals("def", fileDirUtil.getFilenameFromPath("/def"));
    }


    @Test
    public void testreadFileLineToString() throws IOException {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/esi.out";
        String data = "|Hello|World|";
        FileUtils.writeStringToFile(new File(fileFullpath), data, Charset.forName(EncodingConstants.UTF_8), false);
        String actualData = fileDirUtil.readFileLineToString(fileFullpath, 1);
        FileUtils.forceDelete(new File(fileFullpath));
        Assert.assertEquals(data, actualData);
    }

    @Test
    public void testReadFileLineToString_invalidLineNumber() throws IOException {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/esi.out";
        String data = "|Hello|World|";
        FileUtils.writeStringToFile(new File(fileFullpath), data, Charset.forName(EncodingConstants.UTF_8), false);
        String actualData = fileDirUtil.readFileLineToString(fileFullpath, -1);
        FileUtils.forceDelete(new File(fileFullpath));
        Assert.assertEquals(null, actualData);
    }

    @Test
    public void testReadFileLineToString_2ndRow() throws IOException {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/esi.out";
        String data = "|Hello|World|\n|2nd|Row|";
        FileUtils.writeStringToFile(new File(fileFullpath), data, Charset.forName(EncodingConstants.UTF_8), false);
        String actualData = fileDirUtil.readFileLineToString(fileFullpath, 2);
        FileUtils.forceDelete(new File(fileFullpath));
        Assert.assertEquals("|2nd|Row|", actualData);
    }

    @Test
    public void testReadFileLineToString_null() throws IOException {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/esi.out";
        String data = "";
        FileUtils.writeStringToFile(new File(fileFullpath), data, Charset.forName(EncodingConstants.UTF_8), false);
        String actualData = fileDirUtil.readFileLineToString(fileFullpath, 1);
        FileUtils.forceDelete(new File(fileFullpath));
        Assert.assertEquals(null, actualData);
    }

    @Test
    public void testGetRowsCountOfFile() throws IOException {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/esi.out";
        String data = "|Hello|World|\n|2nd|Row|";
        FileUtils.writeStringToFile(new File(fileFullpath), data, Charset.forName(EncodingConstants.UTF_8), false);
        int actualCount = (int) fileDirUtil.getRowsCountInFile(fileFullpath);
        FileUtils.forceDelete(new File(fileFullpath));
        Assert.assertEquals(2, actualCount);
    }

    @Test
    public void testGetRowsCountOfFile_norows() throws IOException {
        temporaryFolder.delete();
        temporaryFolder.create();
        File tempFolder = temporaryFolder.newFolder();
        String filePath = tempFolder.getAbsolutePath();
        String fileFullpath = filePath + "/esi.out";
        String data = "";
        FileUtils.writeStringToFile(new File(fileFullpath), data, Charset.forName(EncodingConstants.UTF_8), false);
        int actualCount = (int) fileDirUtil.getRowsCountInFile(fileFullpath);
        FileUtils.forceDelete(new File(fileFullpath));
        Assert.assertEquals(0, actualCount);
    }

    @Test
    public void testNormalizePathToUnix_happy() throws IOException {
        String inputString1 = "C:\\test_1";
        String expectedString1 = "/test_1";
        String actualString1 = fileDirUtil.normalizePathToUnix(inputString1);
        Assert.assertEquals(expectedString1, actualString1);
    }

    @Test
    public void testNormalizePathToUnix_smbpath() throws IOException {
        String inputString1 = "\\test_1";
        String expectedString1 = "/test_1";
        String actualString1 = fileDirUtil.normalizePathToUnix(inputString1);
        Assert.assertEquals(expectedString1, actualString1);
    }

    @Test
    public void testNormalizePathToUnix_yubreak() throws IOException {
        String inputString1 = "abc";
        String expectedString1 = "abc";
        String actualString1 = fileDirUtil.normalizePathToUnix(inputString1);
        Assert.assertEquals(expectedString1, actualString1);
    }

    @Test
    public void testNormalizePathToUnix_unix2unix() throws IOException {
        String inputString1 = "/test_1";
        String expectedString1 = "/test_1";
        String actualString1 = fileDirUtil.normalizePathToUnix(inputString1);
        Assert.assertEquals(expectedString1, actualString1);
    }

    @Test( expected = CartException.class )
    public void testNormalizePathToUnix_emptystring() throws IOException {
        String inputString1 = "";
        String expectedString1 = "";
        String actualString1 = fileDirUtil.normalizePathToUnix(inputString1);
    }

    @Test
    public void testGetFileNumMatchingText_FirstLine() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        Integer rowNum = fileDirUtil.getFileLineNumberMatchingText(testFile, "START-OF-FILE");
        Assert.assertEquals(1, (int) rowNum);
    }

    @Test
    public void testGetFileNumMatchingText_MiddleLine() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        Integer rowNum = fileDirUtil.getFileLineNumberMatchingText(testFile, "START-OF-FIELDS");
        Assert.assertEquals(15, (int) rowNum);
    }

    @Test
    public void testGetFileNumMatchingText_LastLine() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        Integer rowNum = fileDirUtil.getFileLineNumberMatchingText(testFile, "END-OF-FILE");
        Assert.assertEquals(42, (int) rowNum);
    }

    @Test
    public void testGetFileNumMatchingText_NoMatch() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        Integer rowNum = fileDirUtil.getFileLineNumberMatchingText(testFile, "ABCD");
        Assert.assertEquals(-1, (int) rowNum);
    }

    @Test
    public void testGetFileNumMatchingText_WithRegEx() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        Integer rowNum = fileDirUtil.getFileLineNumberMatchingText(testFile, "END-OF-(.*)");
        Assert.assertEquals(36, (int) rowNum);
    }

    @Test
    public void testGetFileNumMatchingText_InString() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        Integer rowNum = fileDirUtil.getFileLineNumberMatchingText(testFile, "(.*)RDM_EGL_BBICON(.*)");
        Assert.assertEquals(3, (int) rowNum);
    }

    @Test
    public void testGetFileNumMatchingText_EmptyFile() {
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices_empty.out");
        Integer rowNum = fileDirUtil.getFileLineNumberMatchingText(testFile, "(.*)RDM_EGL_BBICON(.*)");
        Assert.assertEquals(-1, (int) rowNum);
    }

    @Test
    public void testGetFileNumMatchingText_EmptyMatchingText() {
        thrown.expect(CartException.class);
        thrown.expectMessage("RegExPattern Cannot be Null or Empty");
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        fileDirUtil.getFileLineNumberMatchingText(testFile, "");
    }

    @Test
    public void testGetFileNumMatchingText_NullMatchingText() {
        thrown.expect(CartException.class);
        thrown.expectMessage("RegExPattern Cannot be Null or Empty");
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/bbg_prices.out");
        fileDirUtil.getFileLineNumberMatchingText(testFile, null);
    }

    @Test
    public void testGetFileNumMatchingText_FileNotFound() {
        thrown.expect(CartException.class);
        thrown.expectMessage("IO Error while processing file");
        String testFile = fileDirUtil.getMavenTestResourcesPath("filedirutil/file_not_found.out");
        fileDirUtil.getFileLineNumberMatchingText(testFile, "(.*)RDM_EGL_BBICON(.*)");
    }

    @Test
    public void testGetTempDir() {
        System.out.println(fileDirUtil.getTempDir().toLowerCase());
    }

    @Test
    public void testGetFileParentAbsolutePath() {
        String filepath = "target/test-classes/excel/Expected.xlsx";
        System.out.println(fileDirUtil.getFileParentAbsolutePath(filepath));
    }

    @Test
    public void testGetFileNameWithExtension() {
        String filepath = "target/test-classes/excel/Expected.xlsx";
        Assert.assertEquals("Expected.xlsx", fileDirUtil.getFileName(filepath, false));
    }

    @Test
    public void testGetFileNameWithOutExtension() {
        String filepath = "target/test-classes/excel/Expected.xlsx";
        Assert.assertEquals("Expected", fileDirUtil.getFileName(filepath, true));
    }

    @Test
    public void testGetFileExtension() {
        String filepath = "target/test-classes/excel/Expected";
        Assert.assertEquals("", fileDirUtil.getFileExtension(filepath));
    }


}
