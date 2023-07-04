package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.HeaderMetadata;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Iterator;

/**
 * <p>This utilities class encapsulates common utility operations on Excel files.</p>
 *
 * @author Daniel Baktiar
 * @since 2017-08-31
 */
public class PerformanceExcelUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(PerformanceExcelUtil.class);

    public HeaderMetadata extractHeaderMetadataFromFileH(String filename) throws IOException {
        FileInputStream fis = new FileInputStream(new File(filename));
        HSSFWorkbook workbook = new HSSFWorkbook(fis);
        return extractHeaderMetadataFromFileGeneric(workbook);
    }
    public HeaderMetadata extractHeaderMetadataFromFileX(String filename) throws IOException {
        FileInputStream fis = new FileInputStream(new File(filename));
        XSSFWorkbook workbook = new XSSFWorkbook(fis);
        return extractHeaderMetadataFromFileGeneric(workbook);
    }

    public HeaderMetadata extractHeaderMetadataFromFileGeneric(Workbook workbook) {
        Sheet datatypeSheet = workbook.getSheetAt(0);
        int firstRowNum = datatypeSheet.getFirstRowNum();
        if (firstRowNum != 0) {
            throw new IllegalStateException("header columns specified and required however it is an empty row");
        }
        Iterator<Row> iterator = datatypeSheet.iterator();

        HeaderMetadata headerMetadata = new HeaderMetadata();
        headerMetadata.setHasHeaderRow(true);

        if (headerMetadata.isHasHeaderRow()) {
            if (iterator.hasNext()) {
                Row headerRow = datatypeSheet.getRow(firstRowNum);
                addHeaders(headerMetadata, headerRow);
            }
        } else {
            if (iterator.hasNext()) {
                int headerNum = 1;
                Row firstRow = iterator.next();
                addGeneratedNameHeaders(headerMetadata, headerNum, firstRow);
            }
        }

        return headerMetadata;
    }

    private void addGeneratedNameHeaders(HeaderMetadata headerMetadata, int headerNum1, Row firstRow) {
        Iterator<Cell> cellIterator = firstRow.iterator();
        int headerNum = headerNum1;
        while (cellIterator.hasNext()) {
            cellIterator.next();
            headerMetadata.addHeader("COL" + headerNum);
            headerNum++;
        }
    }

    private void addHeaders(HeaderMetadata headerMetadata, Row headerRow) {
        if (headerRow != null) {
            Iterator<Cell> cellIterator = headerRow.iterator();
            while (cellIterator.hasNext()) {
                Cell currentCell = cellIterator.next();
                headerMetadata.addHeader(currentCell.getStringCellValue());
            }
        } else {
            throw new IllegalStateException("header row does not have any columns");
        }
    }

    public String extractAsString(String inFilename, String sheetName, int headerRowsToSkip) throws IOException {
        StringBuilder sbOut = new StringBuilder();
        FileInputStream fis = new FileInputStream(new File(inFilename));
        try(XSSFWorkbook workbook = new XSSFWorkbook(fis)) {

            if (sheetName == null) {
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "sheet name must not be null");
            }

            int sourceSheetIdx = workbook.getSheetIndex(sheetName);
            if (sourceSheetIdx == -1) {
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "sheetName [{}] does not exist in the Excel file", sheetName);
            }
            Sheet sourceSheet = workbook.getSheetAt(sourceSheetIdx);

            String pattern = "^[A-Z0-9_ ]*$";
            processSheets(headerRowsToSkip, sbOut, sourceSheet, pattern);

        }
        return sbOut.toString();
    }

    private void processSheets(int headerRowsToSkip, StringBuilder sbOut, Sheet sourceSheet, String pattern) {
        // iterate through rows
        Iterator<Row> rowIterator = sourceSheet.iterator();
        long rowsCount = 0;
        while (rowIterator.hasNext()) {
            Row row = rowIterator.next();
            if (rowsCount >= headerRowsToSkip) {
                int colCount = 0;
                Iterator<Cell> colIterator = row.iterator();
                boolean skipRow = false;
                processColumns(sbOut, pattern, colCount, colIterator, skipRow);
            }
            rowsCount++;
        }
    }

    private void processColumns(StringBuilder sbOut, String pattern, int colCount2, Iterator<Cell> colIterator, boolean skipRow1) {
        StringBuilder sbRow = new StringBuilder();
        int colCount = colCount2;
        boolean skipRow = skipRow1;
        while (colIterator.hasNext()) {
            Cell currentCol = colIterator.next();
            CellType cellType = currentCol.getCellTypeEnum();
            if (colCount == 0) {
                skipRow = cellCanBeSkipped(currentCol, pattern);
            }
            if (skipRow) break;

            if (CellType.NUMERIC.equals(cellType)) {
                sbRow.append(currentCol.getNumericCellValue());
            } else if (CellType.STRING.equals(cellType)) {
                String content = currentCol.getStringCellValue() == null ? "" : currentCol.getStringCellValue();
                String sterilizedContent = content.trim().replaceAll("\r", "").replaceAll("\n", "");
                sbRow.append(sterilizedContent);
            } else if (CellType.FORMULA.equals(cellType)) {
                sbRow.append(cellType);
            } else {
                sbRow.append(cellType);
            }
            sbRow.append(",");
            colCount++;
        }
        if (!skipRow) {
            LOGGER.trace("{}", sbRow);
            sbRow.append("\n");
            sbOut.append(sbRow.toString());
        }
    }

    private boolean cellCanBeSkipped(Cell currentCol, String pattern) {
        CellType cellType = currentCol.getCellTypeEnum();
        if(!CellType.STRING.equals(cellType)) {
            return true;
        }
        String cellContent = currentCol.getStringCellValue();
        if(null == cellContent) {
            return true;
        }
        if(!cellContent.matches(pattern)) {
            return true;
        }
        String trimmedContent = cellContent.trim();
        if("".equals(trimmedContent)) {
            return true;
        }

        return trimmedContent.length() < 4 || trimmedContent.length() > 9;
    }

}
