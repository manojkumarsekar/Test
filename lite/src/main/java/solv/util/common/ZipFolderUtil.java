package com.eastspring.qa.solvency.utils.common;

import stepdefinitions.Solvency.BaseSolvencySteps;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;

public class ZipFolderUtil extends BaseSolvencySteps {

    public static void unzipFolder(String targetFolderName) {
        try {
            Path targetFilePath = Paths.get(WorkspaceUtil.getExecutionReportsDir(), targetFolderName);
            ZipInputStream zipFolder = new ZipInputStream(new FileInputStream(targetFilePath.toString()));
            ZipEntry zipEntry = zipFolder.getNextEntry();
            File destDir = new File(WorkspaceUtil.getExecutionReportsDir());
            byte[] buffer = new byte[1024];
            while (zipEntry != null) {
                String inputFileName = zipEntry.getName();
                File newFile = new File(destDir + File.separator + inputFileName);
                FileOutputStream fos = new FileOutputStream(newFile);
                int len;
                while ((len = zipFolder.read(buffer)) > 0) {
                    fos.write(buffer, 0, len);
                }
                fos.close();
                zipFolder.closeEntry();
                zipEntry = zipFolder.getNextEntry();
            }
            zipFolder.closeEntry();
            zipFolder.close();
        } catch (Exception e) {
            throw new CartException(CartExceptionType.IO_ERROR, "File processing failed during unzip process");
        }
    }
}