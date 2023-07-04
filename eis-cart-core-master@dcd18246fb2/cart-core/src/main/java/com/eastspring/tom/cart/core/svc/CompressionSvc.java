package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.apache.commons.compress.archivers.ArchiveException;
import org.apache.commons.compress.archivers.ArchiveInputStream;
import org.apache.commons.compress.archivers.ArchiveStreamFactory;
import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class CompressionSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(CompressionSvc.class);

    @Autowired
    private FileDirUtil fileDirUtil;

    public String writeZipEntry(String dstDir, ArchiveInputStream ais, ZipArchiveEntry entry) {
        String resultFullpath;
        String resultName = entry.getName();
        resultFullpath = dstDir + File.separator + resultName;
        File outFile = new File(resultFullpath);
        if (outFile.isDirectory()) {
            if (!outFile.exists()) {
                outFile.mkdirs();
            }
        } else {
            fileDirUtil.copyInputStreamToFile(ais, outFile);
        }
        return resultFullpath;
    }

    public String unzipSingleFile(String srcFullpath, String dstDir) {
        LOGGER.debug("unzipSingleFile('{}', '{}')", srcFullpath, dstDir);

        String resultFullpath = null;

        try (InputStream is = new FileInputStream(new File(srcFullpath))) {
            try (ArchiveInputStream ais = new ArchiveStreamFactory().createArchiveInputStream("zip", is)) {
                ZipArchiveEntry entry;
                while ((entry = (ZipArchiveEntry) ais.getNextEntry()) != null) {
                    resultFullpath = writeZipEntry(dstDir, ais, entry);
                }
            }
        } catch (IOException e) {
            LOGGER.error("failed due to I/O error", e);
            throw new CartException(CartExceptionType.IO_ERROR, "failed due to I/O error", e);
        } catch (ArchiveException e) {
            LOGGER.error("ZIP archive error", e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "ZIP archive error", e);
        }

        return resultFullpath;
    }


}
