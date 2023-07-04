package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.ComparisonColPairMetadata;
import com.eastspring.tom.cart.core.mdl.KeyMetadata;
import com.eastspring.tom.cart.core.utl.CsvUtil;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.core.utl.ExcelFormatUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.google.common.base.Strings;
import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.NumberToTextConverter;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

public class ExcelFileSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(ExcelFileSvc.class);

    public static final String ERROR_WHILE_READING_CSV_FILE = "error while reading CSV file [{}]";
    public static final String ERROR_WHILE_WRITING_EXCEL_FILE_FILE = "error while writing Excel file file [{}]";
    public static final String ERROR_WHILE_PROCESSING_EXCEL_FILE = "error while processing Excel file [{}]";
    public static final String GET_SHEET_PROCESSING_FAILED = "getSheet:Processing Failed";
    public static final String GET_CELL_PROCESSING_FAILED = "getCell:Processing Failed";
    public static final String INVALID_EXCEL_CELL_VALUE_NONE = "invalid Excel cell value _NONE";
    public static final String FALSE = "False";
    public static final String WORKBOOK_CANNOT_BE_NULL = "Workbook cannot be Null!";

    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private ExcelFormatUtil excelFormatUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private StateSvc stateSvc;

    public String getValueAtRowCol(Sheet sheet, int rowNum, int colNum) {
        Row row = sheet.getRow(rowNum);
        if (row == null) return null;
        Cell cell = row.getCell(colNum);
        if (cell == null) return null;
        return getCellValueAsString(cell);
    }

    public String getCellValueAsDate(Cell cell) {
        if (cell != null) {
            final DateTimeFormatter dstFormatter = DateTimeFormat.forPattern("yyyy-MM-dd");
            Date theDateValue = cell.getDateCellValue();
            if (theDateValue != null) {
                long theDateLong = theDateValue.getTime();
                return dstFormatter.print(theDateLong);
            }
        }

        return null;
    }


    /**
     * <p>This method get the cell value as a string.</p>
     *
     * @param cell the Excel cell
     * @return string value of the Excel cell
     */
    public String getCellValueAsString(Cell cell) {
        if (cell == null) return null;

        String result;
        CellType cellType = cell.getCellTypeEnum();
        if (CellType.STRING.equals(cellType)) {
            result = cell.getRichStringCellValue().getString();
        } else if (CellType.NUMERIC.equals(cellType)) {
            result = BigDecimal.valueOf(cell.getNumericCellValue()).setScale(6, RoundingMode.HALF_UP).toPlainString();
        } else if (CellType.FORMULA.equals(cellType)) {
            FormulaEvaluator evaluator = cell.getSheet().getWorkbook().getCreationHelper().createFormulaEvaluator();
            CellValue cellValue = evaluator.evaluate(cell);
            if (CellType.NUMERIC.equals(cellValue.getCellTypeEnum())) {
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
            LOGGER.error(INVALID_EXCEL_CELL_VALUE_NONE);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, INVALID_EXCEL_CELL_VALUE_NONE);
        }

        return result;
    }

    public boolean verifyRowColEquals(Sheet sheet, int rowNum, int colNum, String exactString) {
        String value = getValueAtRowCol(sheet, rowNum, colNum);
        return value != null && value.equals(exactString);
    }

    public void writeSheetRangeToCsv(Sheet sheet, String csvFileFullpath, int startingRowNum, int noOfCols) {
        writeSheetRangeToCsvWithPrefix(null, null, sheet, csvFileFullpath, startingRowNum, noOfCols);
    }

    /**
     * <p>This method writes a range in given Excel sheet into a CSV file.</p>
     * <p>The value list will be ignored if the headerList is empty or null.</p>
     *
     * @param sheet           Excel sheet
     * @param csvFileFullpath CSV file full path
     * @param startingRowNum  starting row number
     * @param noOfCols        number of columns in the range to convert
     */
    public void writeSheetRangeToCsvWithPrefix(final List<String> headers, final List<String> prefixValues, final Sheet sheet, final String csvFileFullpath, final int startingRowNum, final int noOfCols) {
        int rowNum = startingRowNum;
        int headerCount = getCount(headers);
        int prefixValuesCount = getCount(prefixValues);

        try (CSVWriter writer = csvUtil.getDefaultCSVWriter(csvFileFullpath)) {

            rowNum = getRowNum(prefixValues, sheet, noOfCols, rowNum, headerCount, prefixValuesCount, writer);

        } catch (Exception e) {
            LOGGER.error("Error while writing Excel sheet range to CSV at row #{}", rowNum, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error while writing Excel sheet range to CSV at row #{}", rowNum, e);
        }
    }

    private int getRowNum(List<String> prefixValues, Sheet sheet, int noOfCols, int rowNum, int headerCount, int prefixValuesCount, CSVWriter writer) {
        boolean skipLine;
        String indicatorCellValue;
        if (headerCount > 0) {
            String[] headerLine = new String[headerCount];
            writer.writeNext(headerLine);
        }
        do {
            skipLine = false;
            indicatorCellValue = getValueAtRowCol(sheet, rowNum, 0);
            skipLine = isSkipLine(sheet, rowNum, indicatorCellValue, skipLine);
            if (!skipLine) {
                String[] nextLine = getStrings(prefixValues, sheet, noOfCols, rowNum, prefixValuesCount);
                if (!Strings.isNullOrEmpty(indicatorCellValue)) {
                    writer.writeNext(nextLine);
                }
            }
            rowNum++;
        } while (skipLine || !Strings.isNullOrEmpty(indicatorCellValue));
        return rowNum;
    }

    private int getCount(List<String> values) {
        int result = 0;
        if (values != null) {
            result = values.size();
        }
        return result;
    }

    private boolean isSkipLine(Sheet sheet, int rowNum, String indicatorCellValue, boolean skipLine) {
        if (Strings.isNullOrEmpty(indicatorCellValue)) {
            String nextRowValue = getValueAtRowCol(sheet, rowNum + 1, 0);
            if (!Strings.isNullOrEmpty(nextRowValue)) {
                skipLine = true;
            }
        }
        return skipLine;
    }

    public String[] getStrings(List<String> prefixValues, Sheet sheet, int noOfCols, int rowNum, int prefixValuesCount) {
        String[] nextLine = new String[noOfCols + prefixValuesCount];
        for (int i = 0; i < prefixValuesCount; i++) {
            nextLine[i] = prefixValues.get(i);
        }
        for (int i = 0; i < noOfCols; i++) {
            nextLine[i + prefixValuesCount] = getValueAtRowCol(sheet, rowNum, i);
        }
        return nextLine;
    }

    public enum WorkbookType {
        XLS,
        XLSX
    }

    public class ExcelWorkbook {
        private WorkbookType type;
        private Workbook workbook;

        ExcelWorkbook(WorkbookType type) {
            this.type = type;
            if (WorkbookType.XLS.equals(type)) {
                this.workbook = new HSSFWorkbook();
            } else if (WorkbookType.XLSX.equals(type)) {
                this.workbook = new XSSFWorkbook();
            } else {
                throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "invalid workbook type [{}]", type);
            }
        }

        public WorkbookType getType() {
            return type;
        }

        Workbook getWorkbook() {
            return workbook;
        }
    }

    public ExcelWorkbook createNewWorkbook(WorkbookType type) {
        return new ExcelWorkbook(type);
    }

    public void writeAsHighlightedFile(ExcelWorkbook excelWorkbook, String csvFileFullpath, String excelFileFullpath, List<KeyMetadata> keyMetadataList, List<ComparisonColPairMetadata> metadataList, String sheetName) {
        if (excelWorkbook == null) {
            LOGGER.error("excelWorkbook must not be null");
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "excelWorkbook must not be null");
        }
        Workbook workbook = excelWorkbook.getWorkbook();
        Sheet sheet = workbook.createSheet(sheetName);

        ExcelFormatUtil.ComparisonHighlightCellStyles styles = excelFormatUtil.getComparisonHighlightCellStyles(workbook);
        CellStyle leftStyle = styles.getLeft();
        CellStyle rightStyle = styles.getRight();

        int rowNum = 0;
        try (CSVReader reader = new CSVReader(new FileReader(csvFileFullpath))) {
            String[] nextLine;

            Row row;
            while ((nextLine = reader.readNext()) != null) {
                int colNum = 0;
                row = sheet.createRow(rowNum++);
                for (KeyMetadata keyMetadata : keyMetadataList) {
                    Cell keyCell = row.createCell(colNum++);
                    keyCell.setCellValue(nextLine[keyMetadata.getColumnIndex()]);
                }
                for (ComparisonColPairMetadata m : metadataList) {
                    if (m.isPasshtruColumn()) {
                        Cell passthruCell = row.createCell(colNum++);
                        passthruCell.setCellValue(nextLine[m.getSourceColumnIndex()]);
                    } else {
                        Cell comparisonSourceCell = row.createCell(colNum++);
                        highlightCell(leftStyle, nextLine, m, comparisonSourceCell, nextLine[m.getSourceColumnIndex()]);
                        Cell comparisonTargetCell = row.createCell(colNum++);
                        highlightCell(rightStyle, nextLine, m, comparisonTargetCell, nextLine[m.getTargetColumnIndex()]);
                    }
                }
            }
        } catch (IOException e) {
            LOGGER.error(ERROR_WHILE_READING_CSV_FILE, csvFileFullpath, e);
            throw new CartException(CartExceptionType.IO_ERROR, ERROR_WHILE_READING_CSV_FILE, csvFileFullpath);
        }

        try (FileOutputStream fos = new FileOutputStream(excelFileFullpath)) {
            workbook.write(fos);
        } catch (IOException e) {
            LOGGER.error(ERROR_WHILE_WRITING_EXCEL_FILE_FILE, excelFileFullpath, e);
            throw new CartException(CartExceptionType.IO_ERROR, ERROR_WHILE_WRITING_EXCEL_FILE_FILE, excelFileFullpath);
        }
    }

    private void highlightCell(CellStyle highlightedCellStyle, String[] rowValues, ComparisonColPairMetadata m, Cell cell, String value) {
        cell.setCellValue(value);
        int matchColumnIndex = m.getMatchColumnIndex();
        String matchColumnValue = rowValues[matchColumnIndex];
        if (FALSE.equals(matchColumnValue)) {
            cell.setCellStyle(highlightedCellStyle);
        }
    }

    public void writeCellToFileWriter(FileWriter fileWriter, Cell cell, String toBeAppended, int cellRowNum, int cellColNum) throws IOException {
        if (cell == null) {
            fileWriter.write(toBeAppended);
        } else {
            CellType cellType = cell.getCellTypeEnum();
            if (cellType != null) {
                if (CellType.NUMERIC.equals(cellType) || CellType.FORMULA.equals(cellType)) {
                    fileWriter.write(String.valueOf(cell.getNumericCellValue()));
                } else if (CellType.ERROR.equals(cellType)) {
                    LOGGER.debug("  cell error at ({},{})", cellRowNum, cellColNum);
                } else {
                    fileWriter.write(cell.getStringCellValue());
                }
                fileWriter.write(toBeAppended);
            }
        }
    }


    public Workbook getWorkbook(String excelFilePath) {
        Workbook workbook;
        try {
            FileInputStream fis = new FileInputStream(new File(excelFilePath));
            workbook = WorkbookFactory.create(fis);
        } catch (Exception e) {
            LOGGER.error(ERROR_WHILE_PROCESSING_EXCEL_FILE, excelFilePath, e);
            throw new CartException(CartExceptionType.IO_ERROR, ERROR_WHILE_PROCESSING_EXCEL_FILE, excelFilePath);
        }
        return workbook;
    }

    public Sheet getSheet(Workbook workbook, String sheetName) {
        Sheet sheet;
        if (workbook != null) {
            sheet = workbook.getSheet(sheetName);
        } else {
            LOGGER.error(WORKBOOK_CANNOT_BE_NULL);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, WORKBOOK_CANNOT_BE_NULL);
        }
        if (sheet == null) {
            LOGGER.error("Sheet named [{}] not found in the Workbook!", sheetName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Sheet named [{}] not found in the Workbook!", sheetName);
        }
        return sheet;
    }

    public Sheet getSheet(Workbook workbook, int sheetIndex) {
        Sheet sheet;
        try {
            if (workbook != null) {
                sheet = workbook.getSheetAt(sheetIndex);
            } else {
                LOGGER.error(WORKBOOK_CANNOT_BE_NULL);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, WORKBOOK_CANNOT_BE_NULL);
            }
        } catch (Exception e) {
            LOGGER.error(GET_SHEET_PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, GET_SHEET_PROCESSING_FAILED);
        }
        return sheet;
    }

    public Integer getRowCount(Sheet sheet) {
        Integer rowCount = -1;
        if (sheet != null) {
            rowCount = sheet.getLastRowNum();
        }
        LOGGER.debug("getRowCount(): returned [{}]", rowCount);
        return rowCount;
    }

    public Integer getColumnCount(Sheet sheet, int rowIndex){
        return (int) sheet.getRow(rowIndex).getLastCellNum();
    }

    public Cell getCell(Sheet sheet, Integer rowNum, Integer colNum) {
        Cell cell = null;
        try {
            if (sheet != null) {
                Row row = sheet.getRow(rowNum);
                cell = row.getCell(colNum);
            }
        } catch (Exception e) {
            LOGGER.error(GET_CELL_PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, GET_CELL_PROCESSING_FAILED);
        }
        return cell;
    }

    public Integer getColumnNumber(Sheet sheet, Integer rowNum, String columnValue) {
        Integer columnNum = -1;
        try {
            if (sheet != null) {
                Row row = sheet.getRow(rowNum);
                Iterator<Cell> cellIterator = row.cellIterator();
                while (cellIterator.hasNext()) {
                    Cell cell = cellIterator.next();
                    if (this.getCellValueAsString(cell).equals(columnValue)) {
                        columnNum = cell.getColumnIndex();
                        break;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.error("getColumnNumber(): processing failed", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "getColumnNumber(): processing failed");
        }
        return columnNum;
    }

    public Integer getRowNumber(Sheet sheet, String strToSearchRow, Integer columnNum) {
        Integer rowNum = -1;
        if (sheet != null) {
            Integer rowCount = this.getRowCount(sheet);
            for (int i = 0; i <= rowCount - 1; i++) {
                Cell cell = getCell(sheet, i, columnNum);
                if (this.getCellValueAsString(cell).equals(strToSearchRow)) {
                    rowNum = i;
                    break;
                }
            }
        }
        return rowNum;
    }

    public void expandVarsInExcelAndSaveAs(String inFile, String outFile) {
        try {
            Workbook workbook = this.getWorkbook(inFile);
            Iterator<Sheet> sheetIterator = workbook.sheetIterator();
            while (sheetIterator.hasNext()) {
                Sheet currSheet = sheetIterator.next();
                for (Row row : currSheet) {
                    for (Cell cell : row) {
                        String cellContent = this.getCellValueAsString(cell);
                        if (cellContent.contains("${")) {
                            LOGGER.debug("Variable found at Cell Reference [{}] with content as [{}]", cell.getAddress(), cellContent);
                            String expandedContent = stateSvc.expandVar(cellContent);
                            cell.setCellValue(expandedContent);
                        }
                    }
                }
            }
            FileOutputStream fos = new FileOutputStream(new File(outFile));
            workbook.write(fos);
            workbook.close();
            fos.close();
        } catch (IOException e) {
            LOGGER.error("File Output stream processing failed", e);
            throw new CartException(CartExceptionType.IO_ERROR, "File Output stream processing failed");
        }
    }

    public void convertExcelToCsv(String excelPath, String csvPath, Integer sheetIndex) {
        try {
            try (FileInputStream inputStream = new FileInputStream(new File(excelPath))) {
                Workbook wb = WorkbookFactory.create(inputStream);
                InputStream stream = this.csvConverter(wb.getSheetAt(sheetIndex));
                fileDirUtil.copyInputStreamToFile(stream, new File(csvPath));
            }
        } catch (InvalidFormatException | IOException | IllegalArgumentException e) {
            LOGGER.error("Unable to convert Excel file [{}] to Csv", excelPath, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to convert Excel file [{}] to Csv", excelPath);
        }
    }

    private InputStream csvConverter(Sheet sheet) {
        Row row;
        StringBuilder str = new StringBuilder();
        for (int i = 0; i < sheet.getLastRowNum() + 1; i++) {
            row = sheet.getRow(i);
            StringBuilder rowString = new StringBuilder();
            String val;
            for (int j = 0; j < row.getLastCellNum(); j++) {
                Cell cell = row.getCell(j);
                if (cell == null) {
                    rowString.append(" " + ",");
                } else {
                    if (cell.getCellTypeEnum().equals(CellType.NUMERIC)) {
                        val = NumberToTextConverter.toText(cell.getNumericCellValue());
                    } else {
                        val = cell.getStringCellValue();
                    }
                    rowString.append(val).append(",");
                }
            }
            str.append(rowString.substring(0, rowString.length() - 1)).append(System.lineSeparator());
        }
        return new ByteArrayInputStream(str.toString().getBytes(StandardCharsets.UTF_8));
    }

}
