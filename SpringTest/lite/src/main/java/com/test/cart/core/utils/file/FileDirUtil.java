package com.eastspring.qa.cart.core.utils.file;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.lookUps.EncodingType;
import com.google.common.base.Strings;
import com.google.common.io.Files;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.comparator.LastModifiedFileComparator;
import org.apache.commons.io.filefilter.WildcardFileFilter;

import java.io.*;
import java.nio.charset.UnsupportedCharsetException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;


public class FileDirUtil {

    protected static final String PATH_NAME_MUST_BE_SPECIFIED = "path name must be specified";
    private static final String READ_FILE_TO_STRING_FAILED_TO_READ_FILE_TO_STRING = "readFileToString(): failed to read file to string [{}]";
    private static final String WRITE_STRING_TO_FILE_FAILED_TO_WRITE_TO_FILE = "writeStringToFile(): failed to write to file [{}]";
    private static final String FORCE_MKDIR_FAILED_TO_CREATE_FOLDER = "forceMkdir(): failed to create folder [{}]";
    private static final String FAILED_TO_MOVE_FILE_FROM_TO = "failed to move file from [{}] to [{}]";
    private static final String FAILED_TO_COPY_FILE_FROM_TO = "failed to copy file from [{}] to [{}]";
    private static final String FAILED_TO_MOVE_RENAME_FILE_FROM_TO = "failed to move/rename file from [{}] to [{}]";
    private static final String FAILED_TO_MAKE_DIR_WITH_FORCE = "failed to make dir with force [{}]";

    public byte[] readFileToByteArray(final String filename) {
        try {
            return FileUtils.readFileToByteArray(new File(filename));
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, READ_FILE_TO_STRING_FAILED_TO_READ_FILE_TO_STRING, filename);
        }
    }

    public void touch(final String filePath) {
        try {
            FileUtils.touch(new File(filePath));
            CartLogger.info("[{}] file created", filePath);
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to create file [{}]", filePath);
        }
    }

    public static String readFileToString(String filename) {
        try {
            return FileUtils.readFileToString(new File(filename), EncodingType.UTF_8.name);
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, READ_FILE_TO_STRING_FAILED_TO_READ_FILE_TO_STRING, filename);
        }
    }

    public String convertFileEncoding(final String filename, final String srcEncoding, final String targetEncoding) {
        try {
            final String newFileName = this.getFileParentAbsolutePath(filename)
                    + File.separator
                    + this.getFileName(filename, true)
                    + "_"
                    + targetEncoding
                    + "."
                    + this.getFileExtension(filename);
            final String fileContent = FileUtils.readFileToString(new File(filename), srcEncoding);
            FileUtils.writeStringToFile(new File(newFileName), fileContent, targetEncoding, false);
            return newFileName;
        } catch (IOException | UnsupportedCharsetException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to convert File Encoding from [{}] to [{}]", srcEncoding, targetEncoding);
        }
    }

    public void writeStringToFile(String filename, String stringToWrite) {
        this.writeStringToFile(filename, stringToWrite, false);
    }

    public void writeStringToFile(String filename, String stringToWrite, boolean append) {
        try {
            FileUtils.writeStringToFile(new File(filename), stringToWrite, EncodingType.UTF_8.name, append);
        } catch (IOException e) {
            throw new CartException(CartExceptionType.IO_ERROR, WRITE_STRING_TO_FILE_FAILED_TO_WRITE_TO_FILE, filename);
        }
    }

    public void forceMkdir(String dir) {
        try {
            FileUtils.forceMkdir(new File(dir));
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FORCE_MKDIR_FAILED_TO_CREATE_FOLDER, dir);
        }
    }

    public void moveFileToDirectory(String srcFullpath, String destFullpath, boolean createDestDir) {
        try {
            FileUtils.moveFileToDirectory(new File(srcFullpath), new File(destFullpath), createDestDir);
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_MOVE_FILE_FROM_TO, srcFullpath, destFullpath);
        }
    }

    /**
     * copy file with {@link File} parameters.
     *
     * @param src source file
     * @param dst destination file
     */
    public void copyFile(File src, File dst) {
        try {
            FileUtils.copyFile(src, dst);
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_COPY_FILE_FROM_TO, src, dst);
        }
    }

    /**
     * copy file with {@link String} parameters.
     *
     * @param src source file
     * @param dst destination file
     */
    public void copyFile(String src, String dst) {
        copyFile(new File(src), new File(dst));
    }

    /**
     * <p>This method performs force delete, and keep silent when there is no such files.</p>
     *
     * @param filename filename to delete
     */
    public void forceDelete(String filename) {
        try {
            FileUtils.forceDelete(new File(filename));
        } catch (IOException e) {
            // inntentionally swallowed
        }
    }

    /**
     * <p>This method moves files from source to destination.</p>
     *
     * @param src source file
     * @param dst destination file
     */
    public void move(String src, String dst) {
        try {
            Files.move(new File(src), new File(dst));
        } catch (IOException e) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, FAILED_TO_MOVE_RENAME_FILE_FROM_TO, src, dst);
        }
    }


    public String getClassAbsolutePath(Class class1) {
        return class1.getProtectionDomain().getCodeSource().getLocation().getPath();
    }

    public String getTestResourcesPath(Class class1, String relativePath) {
        return getClassAbsolutePath(class1) + relativePath;
    }

    /**
     * <p>This method verifies that the given path name exists, regardless of it is a file or a directory.</p>
     *
     * @param pathName path name
     * @return
     */
    public boolean fileDirExist(String pathName) {
        if (pathName == null) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, PATH_NAME_MUST_BE_SPECIFIED);
        }
        return new File(pathName).exists();
    }

    /**
     * <p>This method verifies that the given path name exists and is a file.</p>
     *
     * @param pathName path name
     * @return
     */
    public boolean verifyFileExists(String pathName) {
        if (pathName == null) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, PATH_NAME_MUST_BE_SPECIFIED);
        }
        File file = new File(pathName);
        return file.exists() && file.isFile();
    }

    /**
     * This method verifies that the given path name exists and is a directory.
     *
     * @param pathName path name
     * @return boolean value indicating whether dir exists (true), otherwise false.
     */
    public boolean verifyDirExists(String pathName) {
        if (pathName == null) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, PATH_NAME_MUST_BE_SPECIFIED);
        }
        File file = new File(pathName);
        return file.exists() && file.isDirectory();
    }

    public String addPrefixIfNotAbsolute(String filename, String prefix) {
        String result;
        if (filename != null) {
            File file = new File(filename);
            if (!file.isAbsolute()) {
                result = prefix + '/' + filename;
            } else {
                result = filename;
            }
        } else {
            result = null;
        }
        return result;
    }


    /**
     * <p>
     * This method returns the absolute path of the given class <b>class1</b>.
     * </p>
     *
     * @param class1 the {@link Class} to find the absolute path
     * @return absolute path
     */
    public String getAbsolutePath(Class class1) {
        return class1.getProtectionDomain().getCodeSource().getLocation().getPath();
    }

    public void forceCreateDirContainingFile(String filePath) {
        File file = new File(filePath);
        String containingDir = file.getParent();
        try {
            FileUtils.forceMkdir(new File(containingDir));
        } catch (Exception e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed creating containing dir [{}]", containingDir);
        }
    }

    public void forceMakeDirs(String dir) {
        try {
            FileUtils.forceMkdir(new File(dir));
        } catch (Exception e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed creating containing dir [{}]", dir);
        }
    }


    public String getClassFullpath(Class theClass) {
        return theClass.getProtectionDomain().getCodeSource().getLocation().getPath();
    }

    public String getMavenBaseDir() {
        return normalizePath(getClassFullpath(FileDirUtil.class) + "../..");
    }

    public String getMavenTestResourcesPath(String resourceDir) {
        return normalizePath(getClassFullpath(FileDirUtil.class) + "../../target/test-classes/" + resourceDir);
    }

    public String getMavenMainResourcesPath(String resourceDir) {
        return normalizePath(getClassFullpath(FileDirUtil.class) + "../../target/classes/" + resourceDir);
    }

    public String ensureTestOutDirExist(String testOutDir) {
        String testOutDirFullpath = normalizePath(getClassFullpath(FileDirUtil.class) + "../../target/testout/" + testOutDir);
        try {
            org.codehaus.plexus.util.FileUtils.forceMkdir(new File(testOutDirFullpath));
        } catch (IOException e) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, FAILED_TO_MAKE_DIR_WITH_FORCE, testOutDirFullpath);
        }
        return testOutDirFullpath;
    }

    public String ensureDirExist(String dir) {
        try {
            org.codehaus.plexus.util.FileUtils.forceMkdir(new File(dir));
        } catch (IOException e) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, FAILED_TO_MAKE_DIR_WITH_FORCE, dir);
        }
        return dir;
    }

    public String normalizePath(String rawClassFullpath) {
        return Paths.get(normalizeWindowsDrive(rawClassFullpath)).normalize().toString();
    }

    public String normalizePathToUnix(String rawClassFullpath) {
        if (Strings.isNullOrEmpty(rawClassFullpath)) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "rawClassFullpath must not be empty or null");
        }
        String classFullpath;

        if (rawClassFullpath.length() > 2 && rawClassFullpath.charAt(1) == ':' && Character.isAlphabetic(rawClassFullpath.charAt(0))) {
            classFullpath = rawClassFullpath.substring(2);
        } else {
            classFullpath = rawClassFullpath;
        }
        return normalizePath(classFullpath.replaceAll("\\\\", "/")).replaceAll("\\\\", "/");
    }

    public String normalizeWindowsDrive(String pathWithWindowsDrive) {
        String result;
        if (pathWithWindowsDrive.length() > 3 && pathWithWindowsDrive.startsWith("/") && pathWithWindowsDrive.charAt(2) == ':') {
            result = pathWithWindowsDrive.substring(1);
        } else {
            result = pathWithWindowsDrive;
        }
        return result;
    }

    public Path getPathFromFile(File file) {
        return Paths.get(normalizePathToUnix(file.toString()));
    }

    public String getUnixPathStringFromFile(File file) {
        return normalizePath(getPathFromFile(file).toString());
    }

    public String getFilenameFromPath(String path) {
        if (path == null) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "getFilenameFromPath(): path must not be null");
        }
        String unixPath = normalizePathToUnix(path);
        int a = unixPath.lastIndexOf('/');
        if (a < 0) {
            return unixPath;
        } else {
            return unixPath.substring(a + 1);
        }
    }

    public String getDirnameFromPath(String path) {
        if (path == null) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "getDirnameFromPath(): path must not be null");
        }
        String unixPath = normalizePathToUnix(path);
        int a = unixPath.lastIndexOf('/');
        if (a < 0) {
            return ".";
        } else {
            return unixPath.substring(0, a);
        }
    }

    /**
     * <p>This method verifies whether the contents of two files are equal (byte to byte).</p>
     *
     * @param file1 first file
     * @param file2 second file
     * @return true if content equals, otherwise false
     */
    public boolean contentEquals(String file1, String file2) {
        try {
            return FileUtils.contentEquals(new File(file1), new File(file2));
        } catch (IOException e) {
            throw new CartException(CartExceptionType.IO_ERROR, "IO error while comparing the contents of [{}] and [{}]", file1, file2);
        }
    }

    public void copyInputStreamToFile(InputStream ais, File outFile) {
        try {
            FileUtils.copyInputStreamToFile(ais, outFile);
        } catch (IOException e) {
            throw new CartException(CartExceptionType.IO_ERROR, "IO error while copying input stream to file [{}]", outFile);
        }
    }

    public long getRowsCountInFile(String filename) {
        try {
            try (FileReader fr = new FileReader(new File(filename))) {
                try (LineNumberReader lnr = new LineNumberReader(fr)) {
                    int linenumber = 0;
                    while (lnr.readLine() != null) {
                        linenumber++;
                    }
                    return linenumber;
                }
            }
        } catch (Exception e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "getRowsCountInFile(): failed to read file line/rows count to string [{}]", filename);
        }
    }

    public String readFileLineToString(String filename, int lineNumber) {
        try {
            if (new File(filename).length() > 0 && lineNumber > 0) {
                try (Stream<String> lines = java.nio.file.Files.lines(Paths.get(filename))) {
                    Optional optional = lines.skip(lineNumber - 1L).findFirst();
                    if (optional.isPresent()) {
                        return (String) optional.get();
                    }
                }
            }
        } catch (Exception e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "readFileLineToString(): failed to read file line to string [{}]", filename);
        }
        return null;
    }

    public List<File> getSubdirsAbs(File file) {
        List<File> subdirs = Arrays.asList(file.listFiles((File f) -> f != null && f.isDirectory()));
        subdirs = new ArrayList<>(subdirs);

        List<File> deepSubdirs = new ArrayList<>();
        for (File subdir : subdirs) {
            deepSubdirs.addAll(getSubdirsAbs(subdir));
        }
        subdirs.addAll(deepSubdirs);
        return subdirs;
    }

    public List<String> getSubdirsRel(String stringSubDir) {
        File file = new File(stringSubDir);
        List<File> subdirs = Arrays.asList(file.listFiles((File f) -> f != null && f.isDirectory()));
        subdirs = new ArrayList<>(subdirs);

        List<File> deepSubdirs = new ArrayList<>();
        for (File subdir : subdirs) {
            deepSubdirs.addAll(getSubdirsAbs(subdir));
        }
        subdirs.addAll(deepSubdirs);
        return subdirs.stream().map(File::getAbsolutePath).collect(Collectors.toList());
    }


    /**
     * <p>This method returns the files within base dir that contain specific patterns in the filenames.</p>
     *
     * @param baseDir         the base dir to search for files
     * @param containPatterns the patterns to look for in the filename
     * @return List of {@link File} object(s)
     */
    public List<File> getFilesFromBaseDirWithFilterPatterns(String baseDir, List<String> containPatterns) {
        File dir = new File(baseDir);
        File[] files = dir.listFiles((dir1, name) -> {
            CartLogger.debug("  checking file [{}]", name);
            if (Strings.isNullOrEmpty(name)) {
                return false;
            }
            String filename = name.toUpperCase();
            if (containPatterns == null) {
                return false;
            }
            for (String containPattern : containPatterns) {
                if (filename.contains(containPattern)) {
                    return true;
                }
            }
            return false;
        });

        return files != null ? new ArrayList<>(Arrays.asList(files)) : new ArrayList<>();
    }

    public Integer getFileLineNumberMatchingText(String filePath, String regExPattern) {
        if (Strings.isNullOrEmpty(regExPattern)) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "RegExPattern Cannot be Null or Empty");
        }

        Pattern pattern = Pattern.compile(regExPattern, Pattern.MULTILINE);
        Integer rowNum = -1;
        Integer counter = 1;

        try (BufferedReader bufferedReader = new BufferedReader(new FileReader(filePath))) {
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                if (pattern.matcher(line).matches()) {
                    rowNum = counter;
                    break;
                }
                counter++;
            }
        } catch (IOException e) {
            throw new CartException(CartExceptionType.IO_ERROR, "IO Error while processing file [{}]", filePath);
        }
        return rowNum;
    }

    public File createTempDir(final String tempFolderName) {
        try {
            File tempDir = java.nio.file.Files.createTempDirectory(tempFolderName).toFile();
            CartLogger.debug("TempDir [{}] created...", tempDir.getAbsolutePath());
            return tempDir;
        } catch (IOException e) {
            throw new CartException(CartExceptionType.IO_ERROR, "Exception creating Temp Dir...");
        }
    }

    public String getTempDir() {
        return FileUtils.getTempDirectoryPath();
    }

    public void openFolderInFileExplorer(final String folderPath) {
        if (System.getProperty("os.name").toLowerCase().startsWith("windows")) {
            try {
                Runtime.getRuntime().exec("cmd /c start " + folderPath);
            } catch (IOException e) {
                throw new CartException(CartExceptionType.IO_ERROR, "IO Error while opening folder [{}]", folderPath);
            }
        }
    }

    /**
     * copy latest file with {@link File}  with pattern
     *
     * @param srcPath     source file path
     * @param filePattern file pattern
     * @param dstPath     destination file path
     */
    public String copyLatestFileWithPattern(String srcPath, String filePattern, String dstPath) {
        try {
            File theNewestFile = null;
            File srcFile = new File(srcPath);
            FileFilter fileFilter = new WildcardFileFilter(filePattern + "*");
            File[] files = srcFile.listFiles(fileFilter);
            if (files.length > 0) {
                /** The newest file comes first **/
                Arrays.sort(files, LastModifiedFileComparator.LASTMODIFIED_REVERSE);
                theNewestFile = files[0];
            }
            String dstFileName = theNewestFile.getName();
            File dstFile = new File(dstPath + File.separator + dstFileName);
            FileUtils.copyFile(theNewestFile, dstFile);
            return dstFileName;
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_COPY_FILE_FROM_TO, srcPath, dstPath);
        }
    }

    public String getFileParentAbsolutePath(final String filepath) {
        return new File(new File(filepath).getAbsolutePath()).getParent();
    }

    public String getFileName(final String filepath, final Boolean removeExtension) {
        final String filename = getFilenameFromPath(filepath);
        if (removeExtension) {
            return filename.replace("." + getFileExtension(filename), "");
        }
        return filename;
    }

    public String getFileExtension(final String filepath) {
        return org.codehaus.plexus.util.FileUtils.getExtension(filepath);
    }


}