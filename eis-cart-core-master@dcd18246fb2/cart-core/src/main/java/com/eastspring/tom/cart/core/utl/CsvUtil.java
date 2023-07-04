package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.CsvFileSpec;
import com.opencsv.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.Arrays;
import java.util.List;

public class CsvUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(CsvUtil.class);

    public List<String> getCsvHeaderNamesAsList(CsvFileSpec csvFileSpec) {
        return Arrays.asList(getCsvHeaderNamesAsArray(csvFileSpec));
    }

    public String[] getCsvHeaderNamesAsArray(CsvFileSpec csvFileSpec) {
        if (csvFileSpec == null) {
            LOGGER.error("csvFileSpec must not be null");
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "csvFileSpec must not be null");
        }

        try (CSVReader reader = getCSVReader(csvFileSpec)) {
            return reader.readNext();
        } catch (FileNotFoundException e) {
            LOGGER.error("file [{}] not found", csvFileSpec.getFilename(), e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "file [{}] not found", csvFileSpec.getFilename());
        } catch (IOException e) {
            LOGGER.error("IO error while profiling CSV file [{}]", csvFileSpec.getFilename(), e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO error while profiling CSV file [{}]", csvFileSpec.getFilename());
        }
    }

    public CSVReader getCSVReader(CsvFileSpec csvFileSpec) throws UnsupportedEncodingException, FileNotFoundException {
        final CSVParser parser = new CSVParserBuilder().withSeparator(csvFileSpec.getSeparator()).build();
        return new CSVReaderBuilder(new InputStreamReader(new FileInputStream(csvFileSpec.getFilename()), csvFileSpec.getEncoding())).withCSVParser(parser).build();
    }

    public CSVWriter getDefaultCSVWriter(String filename) throws IOException {
        return new CSVWriter(new FileWriter(filename), CSVWriter.DEFAULT_SEPARATOR, CSVWriter.DEFAULT_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);
    }

    public CSVWriter getCSVWriter(CsvFileSpec csvFileSpec) throws IOException {
        return new CSVWriter(new FileWriter(csvFileSpec.getFilename()), csvFileSpec.getSeparator(), CSVWriter.DEFAULT_QUOTE_CHARACTER, CSVWriter.DEFAULT_ESCAPE_CHARACTER, CSVWriter.DEFAULT_LINE_END);
    }
}
