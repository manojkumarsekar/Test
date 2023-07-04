package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;

public class EncodingUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(EncodingUtil.class);

    public void copyWithEncodingConversion(String srcFullpath, String dstFullpath, String srcEncoding, String dstEncoding) {
        try(InputStreamReader srcIsr = new InputStreamReader(new FileInputStream(new File(srcFullpath)), srcEncoding)) {
            try(OutputStreamWriter dstOsw = new OutputStreamWriter(new FileOutputStream(dstFullpath), dstEncoding)) {
                Writer out = new BufferedWriter(dstOsw);
                int ch;
                while((ch = srcIsr.read()) > -1) {
                    out.write(ch);
                }
                out.flush();
            }
        } catch(IOException e) {
            LOGGER.error("error while copying with encoding conversion");
            throw new CartException(CartExceptionType.IO_ERROR, "error while copying with encoding conversion");
        }
    }
}
