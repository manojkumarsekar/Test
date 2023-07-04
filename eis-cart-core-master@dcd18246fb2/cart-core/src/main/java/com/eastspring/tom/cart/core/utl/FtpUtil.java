package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;
import org.apache.commons.net.ftp.FTPReply;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class FtpUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(FtpUtil.class);

    private FTPClient ftpClient;

    public FTPClient openFtp(final String hostname, final Integer port, final String username, final String password) {
        try {
            if (!(ftpClient != null && ftpClient.isConnected())) {
                ftpClient = new FTPClient();
                ftpClient.connect(hostname, port);
                int reply = ftpClient.getReplyCode();
                if (!FTPReply.isPositiveCompletion(reply)) {
                    ftpClient.disconnect();
                }
                boolean status = ftpClient.login(username, password);
                ftpClient.enterLocalPassiveMode();
                LOGGER.debug("Ftp connection to server [{}] is [{}]", hostname, status);
                return ftpClient;
            }
        } catch (Exception e) {
            LOGGER.error("Exception while Opening FTPClient", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception while Opening FTPClient");
        }
        return ftpClient;
    }


    public void download(final String remotePath, final String localPath, final String regExPattern) {
        LOGGER.debug("remote path: [{}]", remotePath);
        LOGGER.debug("local path: [{}]", localPath);
        LOGGER.debug("regex pattern [{}]", regExPattern);
        try {
            FTPFile[] ftpFiles = ftpClient.listFiles(remotePath);
            if (ftpFiles.length == 0) {
                LOGGER.error("[{}] not found", remotePath);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "[{}] not found", remotePath);
            }

            for (FTPFile remoteFile : ftpFiles) {
                if (!remoteFile.getName().equals(".") && !remoteFile.getName().equals("..")) {
                    if (remoteFile.isDirectory()) {
                        new File(localPath + File.separator + remoteFile.getName()).mkdirs();
                        download(remotePath + File.separator + remoteFile.getName(),
                                localPath + File.separator + remoteFile.getName(),
                                regExPattern);
                    } else {
                        if (remoteFile.getName().matches(regExPattern)) {
                            downloadFtpFile(remotePath, localPath, remoteFile);
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.error("Exception during ftp download");
            throw new CartException(CartExceptionType.IO_ERROR, "Exception during ftp download", e);
        }
    }

    private void downloadFtpFile(final String remotePath, final String localPath, final FTPFile remoteFile) {
        LOGGER.debug("Downloading file [{}] from [{}]", remoteFile.getName(), new File(remotePath).getParent());

        String remoteFilePath = remotePath + File.separator + remoteFile.getName();
        String localFilePath = localPath + File.separator + remoteFile.getName();

        if (!isDirectory(remotePath)) {
            remoteFilePath = new File(remotePath).getParent() + File.separator + remoteFile.getName();
            localFilePath = new File(localPath).getParent() + File.separator + remoteFile.getName();
        }
        File localFolder = new File(new File(localFilePath).getParent());
        if (!localFolder.exists()) {
            localFolder.mkdirs();
        }
        try (FileOutputStream fos = new FileOutputStream(localFilePath)) {
            this.ftpClient.retrieveFile(remoteFilePath, fos);
        } catch (IOException e) {
            LOGGER.error("Exception while downloading file [{}]", remotePath);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception while downloading file [{}]", remotePath, e);
        }

    }

    public boolean isDirectory(final String dirPath) {
        try {
            ftpClient.changeWorkingDirectory(dirPath);
            if (ftpClient.getReplyCode() == 550) {
                return false;
            }
        } catch (IOException e) {
            //
        }
        return true;
    }


    public void closeFtp() {
        try {
            if (null != ftpClient && ftpClient.isConnected()) {
                LOGGER.debug("Closing ftp connection...");
                ftpClient.logout();
                ftpClient.disconnect();
            }
        } catch (IOException e) {
            LOGGER.error("Exception while closing ftp connection");
            throw new CartException(CartExceptionType.IO_ERROR, "Exception while closing ftp connection", e);
        }
    }
}
