package com.eastspring.qa.cart.core.utils.file;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.usermodel.*;

import java.io.File;
import java.io.FileInputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.file.Path;
import java.util.*;


public class ExcelUtil {

    public static final String FILE_NOT_FOUND = "file [{}] not found";
    public static final String ERROR_READING_EXCEL = "IO error while processing Excel file [{}]";
    public static final String ERROR_WHILE_PROCESSING_EXCEL_FILE = "error while processing Excel file [{}]";
    public static final String WORKBOOK_CANNOT_BE_NULL = "Workbook cannot be Null!";
    public static final String INVALID_EXCEL_CELL_VALUE_NONE = "invalid Excel cell value _NONE";

    public static List<String> getRecordsAsStringList(Path filepath, String sheetName, String delimiter) {
        return getRecordsAsStringList(filepath, sheetName, delimiter, false);
    }

    public static List<String> getRecordsAsStringList(Path filepath, String sheetName, String delimiter, boolean ignoreInvalidCell) {
        List<String> records = new ArrayList<>();
        List<LinkedHashMap<String, String>> stringMapList = getRecordsAsStringMap(filepath, sheetName, ignoreInvalidCell);
        for (Map<String, String> record : stringMapList) {
            records.add(String.join(delimiter, record.values()));
        }
        return records;
    }

    public static List<LinkedHashMap<String, String>> getRecordsAsStringMap(Path filepath, String sheetName) {
        return getRecordsAsStringMap(filepath, sheetName, false);
    }

    public static List<LinkedHashMap<String, String>> getRecordsAsStringMap(Path filepath, String sheetName, boolean ignoreInvalidCell) {
        List<LinkedHashMap<String, String>> records = new ArrayList<>();
        List<LinkedHashMap<String, Cell>> cellMapList = getRecordsAsCellMap(filepath, sheetName, ignoreInvalidCell);
        for (LinkedHashMap<String, Cell> record : cellMapList) {
            LinkedHashMap<String, String> updatedRecord = new LinkedHashMap<>();
            for (String key : record.keySet()) {
                updatedRecord.put(key, getCellValueAsString(record.get(key)));
            }
            records.add(updatedRecord);
        }
        return records;
    }

    public static List<LinkedHashMap<String, Cell>> getRecordsAsCellMap(Path filepath, String sheetName) {
        return getRecordsAsCellMap(filepath, sheetName, false);
    }

    public static List<LinkedHashMap<String, Cell>> getRecordsAsCellMap(Path filepath, String sheetName, boolean ignoreInvalidCell) {
        Sheet sheet = getSheet(getWorkbook(filepath), sheetName);
        int colCount = getColumnCount(sheet, 0);
        int rowCount = getRowCount(sheet);
        Row headerRow = getRow(sheet, 0, false);
        List<LinkedHashMap<String, Cell>> records = new ArrayList<>();
        for (int i = 1; i <= rowCount; i++) {
            LinkedHashMap<String, Cell> record = new LinkedHashMap<>();
            Row row = getRow(sheet, i, ignoreInvalidCell);
            if (row == null) {
                records.add(record);
                continue;
            }
            for (int j = 0; j < colCount; j++) {
                Cell headerCell = getCell(sheet, headerRow, j, ignoreInvalidCell);
                if (headerCell == null) continue;
                String key = getCellValueAsString(headerCell);
                if (record.containsKey(key)) key = key + StringUtils.right("000" + j, 4);
                Cell cell = getCell(sheet, row, j, ignoreInvalidCell);
                record.put(key, cell);
            }
            records.add(record);
        }
        return records;
    }

    //********************** ********************** ********************** ********************** **********************
    private static Row getRow(Sheet sheet, int index, boolean ignoreInvalidCell) {
        Row row = sheet.getRow(index);
        if (row == null) {
            if (ignoreInvalidCell) {
                CartLogger.warn("Invalid record found at index [{}] in '[{}]' sheet", index, sheet.getSheetName());
            } else {
                throw new CartException(CartExceptionType.IO_ERROR, "Invalid record found at index [{}] in '[{}]' sheet",
                        index, sheet.getSheetName());
            }
        }
        return row;
    }

    private static Cell getCell(Sheet sheet, Row row, int colIndex, boolean ignoreInvalidCell) {
        Cell cell = row.getCell(colIndex);
        if (cell == null) {
            if (ignoreInvalidCell) {
                CartLogger.warn("Invalid cell found at index ([{}],[{}]) in '[{}]' sheet",
                        row.getRowNum(), colIndex, sheet.getSheetName());
            } else {
                throw new CartException(CartExceptionType.IO_ERROR, "Invalid cell found at index ([{}],[{}]) in '[{}]' sheet",
                        row.getRowNum(), colIndex, sheet.getSheetName());
            }
        }
        return cell;
    }

    //ToDo: ========================================= copied from Cart v1.0 ; to be refactored =========================================

    private static Workbook getWorkbook(Path excelFilePath) {
        Workbook workbook;
        try {
            FileInputStream fis = new FileInputStream(new File(excelFilePath.toString()));
            workbook = WorkbookFactory.create(fis);
        } catch (Exception e) {
            throw new CartException(e, CartExceptionType.IO_ERROR, ERROR_WHILE_PROCESSING_EXCEL_FILE, excelFilePath);
        }
        return workbook;
    }

    private static Sheet getSheet(Workbook workbook, String sheetName) {
        Sheet sheet;
        if (workbook != null) {
            sheet = workbook.getSheet(sheetName);
        } else {
            CartLogger.error(WORKBOOK_CANNOT_BE_NULL);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, WORKBOOK_CANNOT_BE_NULL);
        }
        if (sheet == null) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Sheet named [{}] not found in the Workbook!", sheetName);
        }
        return sheet;
    }

    private static Integer getRowCount(Sheet sheet) {
        Integer rowCount = -1;
        if (sheet != null) {
            rowCount = sheet.getLastRowNum();
        }
        CartLogger.debug("getRowCount(): returned [{}]", rowCount);
        return rowCount;
    }

    private static Integer getColumnCount(Sheet sheet, int rowIndex) {
        return (int) sheet.getRow(rowIndex).getLastCellNum();
    }

    private static String getCellValueAsString(Cell cell) {
        if (cell == null) return null;

        //ToDo: check interpretation of numeric value

        String result;
        CellType cellType = cell.getCellType();
        if (CellType.STRING.equals(cellType)) {
            result = cell.getRichStringCellValue().getString();
        } else if (CellType.NUMERIC.equals(cellType)) {
            result = BigDecimal.valueOf(cell.getNumericCellValue()).setScale(6, RoundingMode.HALF_UP).toPlainString();
        } else if (CellType.FORMULA.equals(cellType)) {
            FormulaEvaluator evaluator = cell.getSheet().getWorkbook().getCreationHelper().createFormulaEvaluator();
            CellValue cellValue = evaluator.evaluate(cell);
            if (CellType.NUMERIC.equals(cellValue.getCellType())) {
                result = BigDecimal.valueOf(cellValue.getNumberValue()).setScale(6, RoundingMode.HALF_UP).toPlainString();
            } else {
                result = cellValue.getStringValue();
            }
        } else if (CellType.BLANK.equals(cellType)) {
            result = "";
        } else if (CellType.BOOLEAN.equals(cellType)) {
            result = cell.getStringCellValue();
        } else if (CellType.ERROR.equals(cellType)) {
            result = "<ERROR>";
        } else {
            CartLogger.error(INVALID_EXCEL_CELL_VALUE_NONE);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, INVALID_EXCEL_CELL_VALUE_NONE);
        }
        return result;
    }
}