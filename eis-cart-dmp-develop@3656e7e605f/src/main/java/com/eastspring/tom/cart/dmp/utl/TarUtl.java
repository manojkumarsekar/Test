package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.apache.commons.compress.archivers.ArchiveException;
import org.apache.commons.compress.archivers.ArchiveInputStream;
import org.apache.commons.compress.archivers.ArchiveStreamFactory;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveOutputStream;
import org.apache.commons.compress.utils.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

public class TarUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(TarUtl.class);

    private static final String PROCESSING_FAILED = "Processing failed";

    public void compress(final String name, final List<String> fileNames) throws IOException {
        try (TarArchiveOutputStream out = getTarArchiveOutputStream(name)) {
            for (String file : fileNames) {
                addToArchiveCompression(out, new File(file), ".");
            }
        }
    }

    private void addToArchiveCompression(final TarArchiveOutputStream out, final File file, final String dir) throws IOException {
        String entry = dir + File.separator + file.getName();
        if (file.isFile()) {
            out.putArchiveEntry(new TarArchiveEntry(file, entry));
            try (FileInputStream in = new FileInputStream(file)) {
                IOUtils.copy(in, out);
            }
            out.closeArchiveEntry();
        } else {
            LOGGER.error(PROCESSING_FAILED);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    private TarArchiveOutputStream getTarArchiveOutputStream(final String name) throws IOException {
        TarArchiveOutputStream taos = new TarArchiveOutputStream(new FileOutputStream(name));
        // TAR has an 8 gig file limit by default, this gets around that
        taos.setBigNumberMode(TarArchiveOutputStream.BIGNUMBER_STAR);
        // TAR originally didn't support long file names, so enable the support for it
        taos.setLongFileMode(TarArchiveOutputStream.LONGFILE_GNU);
        taos.setAddPaxHeadersForNonAsciiNames(true);
        return taos;
    }

    public File getFileFromTar(final File tarFile, final String fileToExtract) {
        try {
            try (ArchiveInputStream ais = new ArchiveStreamFactory().
                    createArchiveInputStream("tar", new FileInputStream(tarFile))) {
                TarArchiveEntry entry;

                while ((entry = (TarArchiveEntry) ais.getNextEntry()) != null) {
                    if (entry.getName().endsWith(fileToExtract)) {
                        String tarFileFolderPath = tarFile.getParent();
                        return new File(tarFileFolderPath + File.separator + fileToExtract);
                    }
                }
                return null;
            }
        } catch (IOException | ArchiveException e) {
            LOGGER.error("Processing failed while extracting file [{}] from [{}]", fileToExtract, tarFile, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while extracting file [{}] from [{}]", fileToExtract, tarFile);
        }
    }

}
