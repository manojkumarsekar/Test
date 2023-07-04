package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.io.PrintWriter;

public class WriterUtil {
    public PrintWriter getPrintWriterByPrintStream(PrintStream printStream) {
        return new PrintWriter(printStream);
    }

    public PrintWriter getPrintWriterByFilename(String filename) {
        try {
            return new PrintWriter(new File(filename));
        } catch(IOException e) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "failed to open print writer on file [{}]", filename);
        }
    }
}
