package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class FileValidationSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(FileValidationSvc.class);

    @Autowired
    private FileDirUtil fileDirUtil;

    public void validateContentEquals(String file1, String file2) {
        if(!fileDirUtil.contentEquals(file1, file2)) {
            LOGGER.error("the content of file [{}] does not exactly match the content of file [{}]", file1, file2);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "the content of file [{}] does not exactly match the content of file [{}]", file1, file2);
        }
    }
}
