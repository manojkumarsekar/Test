package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.cst.EncodingConstants;
import org.junit.Assert;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

//@RunWith(SpringJUnit4ClassRunner.class)
//@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class EncodingUtilRunIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(EncodingUtil.class);

    @Autowired
    private EncodingUtil encodingUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FileValidatorUtil fileValidatorUtil;

//    @Test
    public void testCopyWithEncodingConversion() throws Exception {
        String srcFullpath = fileDirUtil.getMavenTestResourcesPath("recon/tsv-utf16-sample.csv");
        String refUtf8Fullpath = fileDirUtil.getMavenTestResourcesPath("recon/tsv-utf16-converted-utf8-sample.csv");
        String dstFullpath = fileDirUtil.getMavenMainResourcesPath("recon/tsv-utf16-sample.csv.converted");
        String srcEncoding = EncodingConstants.UTF_16;
        String dstEncoding = EncodingConstants.UTF_8;

        LOGGER.info("validating encoding of file [{}]", srcFullpath);
        fileValidatorUtil.validateEncoding(srcFullpath, "UTF-16LE");
        String containingDir = fileDirUtil.getDirnameFromPath(dstFullpath);

        fileDirUtil.ensureDirExist(containingDir);

        LOGGER.info("copy with encoding conversion from [{}] ({}) to [{}] ({})", srcFullpath, srcEncoding, dstFullpath, dstEncoding);
        encodingUtil.copyWithEncodingConversion(srcFullpath, dstFullpath, srcEncoding, dstEncoding);

        LOGGER.info("verifying that of the newly created [{}] is as expected", dstFullpath);
        Assert.assertTrue(fileDirUtil.contentEquals(refUtf8Fullpath, dstFullpath));
    }
}
