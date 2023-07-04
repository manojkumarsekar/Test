package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.RemoteOutput;
import com.eastspring.tom.cart.core.utl.*;
import com.google.common.base.Strings;
import net.schmizz.sshj.SSHClient;
import net.schmizz.sshj.common.IOUtils;
import net.schmizz.sshj.connection.channel.direct.Session;
import net.schmizz.sshj.transport.verification.PromiscuousVerifier;
import net.schmizz.sshj.xfer.FileSystemFile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.TimeUnit;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class RuntimeRemoteSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(RuntimeRemoteSvc.class);
    public static final String ERROR_OPENING_SSH_CONNECTION = "error opening ssh connection";
    private static final String EXIT_STATUS_INFO = "**exit status: {}";
    public static final String FILE_NOT_AVAILABLE = "File [{}] not available";
    public static final String CHMOD664 = "chmod 664 ";
    public static final String UNIX_SEPERATOR = "/";

    @Autowired
    private LinuxRuntimeUtil linuxRuntimeUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WindowsRuntimeUtil windowsRuntimeUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FtpUtil ftpUtil;

    @Autowired
    private AwaitilityUtil awaitilityUtil;

    private IRuntimeUtil runtimeUtil;

    private synchronized void checkAndSetRuntime() {
        String osName = System.getProperty("os.name");
        String osNameLowercase = osName != null ? osName.toLowerCase() : "";
        if (runtimeUtil == null) {
            if (osNameLowercase.startsWith("windows")) {
                runtimeUtil = windowsRuntimeUtil;
            } else if (osNameLowercase.startsWith("linux")) {
                runtimeUtil = linuxRuntimeUtil;
            } else {
                throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "only windows and linux supported at the moment");
            }
        }
    }

    public String getRuntimeDir() {
        checkAndSetRuntime();
        return runtimeUtil.getRuntimeDir();
    }

    public boolean isWindowsRuntime() {
        return true;
    }

    public String getOsNormalizedRuntimePath(String relativePath) {
        String result;
        if (isWindowsRuntime()) {
            result = (getRuntimeDir() + relativePath).replaceAll("/", "\\\\");
        } else {
            result = null;
        }
        return result;
    }

    public void sshDownload(String hostname, int port, String username, String remoteSrcDir, String localDestDir) {
        LOGGER.debug("sshDownload: {}@{}:{} to local [{}]", username, hostname, remoteSrcDir, localDestDir);
        SSHClient ssh = new SSHClient();
        try {
            connectAuthPublicKey(hostname, port, username, ssh);
            ssh.newSCPFileTransfer().download(remoteSrcDir, new FileSystemFile(localDestDir));
        } catch (IOException e) {
            LOGGER.error(ERROR_OPENING_SSH_CONNECTION, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, ERROR_OPENING_SSH_CONNECTION);
        } finally {
            finalCleanUp(ssh);
        }
    }

    public void ftpDownload(final Map<String, String> configMap, final String remotePath, final String localPath, final String regExPattern) {
        try {
            ftpUtil.openFtp(configMap.get("host"), Integer.valueOf(configMap.get("port")), configMap.get("user"), configMap.get("password"));
            ftpUtil.download(remotePath, localPath, (regExPattern == null ? ".*" : regExPattern));
        } catch (Exception e) {
            LOGGER.error("Exception while downloading from FTP connection");
            throw new CartException(CartExceptionType.IO_ERROR, "Exception while downloading from FTP connection", e);
        } finally {
            ftpUtil.closeFtp();
        }
    }

    private void finalCleanUp(SSHClient ssh) {
        if (ssh != null) {
            try {
                ssh.disconnect();
            } catch (Exception e) {
                // intentionally swallowed
            }
            try {
                ssh.close();
            } catch (Exception e) {
                // intentionally swallowed
            }
        }
    }

    public void sshUpload(String hostname, int port, String username, String localSrcFile, String remoteDestDir) {
        if (!fileDirUtil.fileDirExist(localSrcFile)) {
            LOGGER.error(FILE_NOT_AVAILABLE, localSrcFile);
            throw new CartException(CartExceptionType.IO_ERROR, FILE_NOT_AVAILABLE, localSrcFile);
        }


        LOGGER.debug("sshUpload: local [{}] to {}@{}:{}", localSrcFile, username, hostname, remoteDestDir);
        SSHClient ssh = new SSHClient();
        try {
            connectAuthPublicKey(hostname, port, username, ssh);
            ssh.newSCPFileTransfer().upload(new FileSystemFile(localSrcFile), remoteDestDir);
            String command = CHMOD664 + remoteDestDir + UNIX_SEPERATOR + new File(localSrcFile).getName();
            LOGGER.debug("Change permissions comamnd [{}]", command);
            sshRemoteExecute(hostname, port, username, command);
        } catch (IOException e) {
            LOGGER.error(ERROR_OPENING_SSH_CONNECTION, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, ERROR_OPENING_SSH_CONNECTION);
        } finally {
            finalCleanUp(ssh);
        }
    }

    /**
     * <p>This method connect to the host specified by params.</p>
     *
     * @param hostname remote host hostname
     * @param port     remote host port
     * @param username remote user name
     * @param ssh      {@link SSHClient} object to use
     * @throws IOException IOException
     */
    private void connectAuthPublicKey(String hostname, int port, String username, SSHClient ssh) throws IOException {
        ssh.useCompression();
        ssh.addHostKeyVerifier(new PromiscuousVerifier());
        ssh.loadKnownHosts();
        ssh.connect(hostname, port);

        String sshKeyPath = System.getProperty("tomcart.ssh.key.path");

        if (Strings.isNullOrEmpty(sshKeyPath)) {
            LOGGER.debug("using default location for ssh key file.");
            ssh.authPublickey(username);
        } else {
            LOGGER.debug("using custom location [{}] for ssh key file.", sshKeyPath);
            ssh.authPublickey(username, sshKeyPath);
        }
    }

    public RemoteOutput sshRemoteExecute(String hostname, int port, String username, String cmdLine) {
        LOGGER.debug("sshRemoteExecute");

        SSHClient ssh = new SSHClient();
        String output;
        String error;

        try {
            connectAuthPublicKey(hostname, port, username, ssh);
            try (Session session = ssh.startSession()) {
                final Session.Command cmd = session.exec(cmdLine);
                ByteArrayOutputStream inputBaos = IOUtils.readFully(cmd.getInputStream());
                ByteArrayOutputStream errorBaos = IOUtils.readFully(cmd.getErrorStream());
                cmd.join(5, TimeUnit.SECONDS);
                LOGGER.debug(EXIT_STATUS_INFO, cmd.getExitStatus());
                output = inputBaos.toString("UTF-8");
                error = errorBaos.toString("UTF-8");
            }
        } catch (IOException e) {
            LOGGER.error(ERROR_OPENING_SSH_CONNECTION, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, ERROR_OPENING_SSH_CONNECTION);
        } finally {
            finalCleanUp(ssh);
        }

        return new RemoteOutput(output, error);
    }

    public String getTimeStamp(final String hostname, final int port, final String username, final String dateFormat) {
        String cmd = "date";
        if (!Strings.isNullOrEmpty(dateFormat)) {
            cmd = "date +\"" + dateFormat + "\"";
        }
        RemoteOutput output = this.sshRemoteExecute(hostname, port, username, cmd);
        return output.getOutput().trim();
    }

    public boolean sshFileExists(String hostname, int port, String username, String filePath) {
        return sshFileExists(hostname, port, username, filePath, 1);
    }

    public boolean sshFileExists(String hostname, int port, String username, String filePath, Integer maxPollingInSeconds) {
        String cmdLine = "test -f " + filePath + " && echo true||echo false";
        SSHClient ssh = new SSHClient();

        try {
            connectAuthPublicKey(hostname, port, username, ssh);
            return waitTillFileExists(ssh, cmdLine, maxPollingInSeconds);
        } catch (IOException e) {
            LOGGER.error(ERROR_OPENING_SSH_CONNECTION, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, ERROR_OPENING_SSH_CONNECTION);
        } finally {
            finalCleanUp(ssh);
        }
    }

    private boolean waitTillFileExists(SSHClient ssh, String cmdLine, Integer timeoutInSec) {
        final Callable<Boolean> condition = () -> {
            try (Session session = ssh.startSession()) {
                final Session.Command cmd = session.exec(cmdLine);
                String output = IOUtils.readFully(cmd.getInputStream()).toString();
                LOGGER.debug("inputStream: [{}]", output.trim());
                LOGGER.debug(EXIT_STATUS_INFO, cmd.getExitStatus());
                return output.trim().equals("true");
            }
        };
        return awaitilityUtil.waitUntil(condition, timeoutInSec);
    }

    public boolean sshFileExistsWithRegEx(String hostname, int port, String username, String fileDir, String fileNamePattern) {
        LOGGER.debug("sshFileExistsWithRegEx");
        boolean result = false;
        String cmdLine = "find " + fileDir + " -maxdepth 1 -name '" + fileNamePattern + "'|wc -l";
        SSHClient ssh = new SSHClient();

        try {
            connectAuthPublicKey(hostname, port, username, ssh);
            try (Session session = ssh.startSession()) {
                final Session.Command cmd = session.exec(cmdLine);
                Integer noOfFiles = Integer.parseInt(IOUtils.readFully(cmd.getInputStream()).toString().trim());
                if (noOfFiles >= 1) {
                    result = true;
                }
                LOGGER.debug("No. Of Files with pattern [{}] found are [{}]", fileNamePattern, noOfFiles);
                LOGGER.debug(EXIT_STATUS_INFO, cmd.getExitStatus());
            }
        } catch (IOException e) {
            LOGGER.error(ERROR_OPENING_SSH_CONNECTION, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, ERROR_OPENING_SSH_CONNECTION);
        } finally {
            finalCleanUp(ssh);
        }
        return result;
    }

}
