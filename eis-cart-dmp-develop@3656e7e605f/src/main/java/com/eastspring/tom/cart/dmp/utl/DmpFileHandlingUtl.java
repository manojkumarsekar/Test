package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.CsvFileSpec;
import com.eastspring.tom.cart.core.svc.ExcelFileSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.CsvUtil;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.XmlUtil;
import com.eastspring.tom.cart.dmp.utl.mdl.ReconInputSpec;
import com.eastspring.tom.cart.dmp.utl.mdl.ReconOutputSpec;
import com.google.common.base.Strings;
import com.google.common.collect.Sets;
import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.LineIterator;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static com.codesnippets4all.json.constants.JSONConstants.COMMA;

/**
 * This class will have File handling operations for DMP work flows
 * Created by GummarajuM on 10/1/2018.
 */

public class DmpFileHandlingUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(DmpFileHandlingUtl.class);

    public static final String BB_START_OF_FIELDS = "START-OF-FIELDS";
    public static final String BB_END_OF_FIELDS = "END-OF-FIELDS";
    public static final String BB_START_OF_DATA = "START-OF-DATA";
    public static final String BB_END_OF_DATA = "END-OF-DATA";

    public static final String PROCESSING_FAILED = "Processing failed!";
    public static final String SUBJECT_CANNOT_BE_NULL_OR_EMPTY = "Subject cannot be Null or Empty";
    private static final String REFERENCE_STRING_NOT_FOUND = "Reference string not found [{}]";
    public static final String HEADER_ROW_MUST_BE_NON_ZERO = "Header Row Number must be Greater than 0";
    public static final String FILE_DOES_NOT_EXISTS = "File [{}] does not exists!";
    public static final String REGX_TIME_FORMAT = "\\d{2}:\\d{2}:\\d{2}";
    public static final String UTF_8 = "UTF-8";
    public static final String RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH = "Reconciliation failed because of data mismatch";
    public static final String EXCEPTIONS_ARE_LISTED_BELOW = "********************* Exceptions *********************";
    public static final String MISSING_RECORDS_HEADER = "\nBelow Records are missing in %s,\nbut available in %s\n";

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private ExcelFileSvc excelFileSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private XmlUtil xmlUtil;

    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    public List<String> convertStringWithDelimiterToAList(String subject, String referenceStringToConsiderSplit, char delimiter) {
        if (Strings.isNullOrEmpty(subject)) {
            LOGGER.error(SUBJECT_CANNOT_BE_NULL_OR_EMPTY);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, SUBJECT_CANNOT_BE_NULL_OR_EMPTY);
        }

        int refColumnIndex = subject.indexOf(referenceStringToConsiderSplit);
        if (refColumnIndex == -1) {
            LOGGER.error(REFERENCE_STRING_NOT_FOUND, referenceStringToConsiderSplit);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, REFERENCE_STRING_NOT_FOUND, referenceStringToConsiderSplit);
        }
        String actualStringToSplit = subject.substring(refColumnIndex, subject.length());
        return Arrays.stream(actualStringToSplit.split(Pattern.quote(String.valueOf(delimiter)))).map(String::trim).collect(Collectors.toList());
    }

    public List<String> getFieldValuesFromFileWithHeader(final String fileName, final Integer headerRow, final String refField, final String valuesField, final char delimiter) {
        List<String> result = new ArrayList<>();
        if (headerRow <= 0) {
            LOGGER.error(HEADER_ROW_MUST_BE_NON_ZERO);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, HEADER_ROW_MUST_BE_NON_ZERO);
        }
        final String headerString = fileDirUtil.readFileLineToString(fileName, headerRow);
        final Integer columnIndex = this.convertStringWithDelimiterToAList(headerString, refField, delimiter).indexOf(valuesField);
        if (columnIndex == -1) {
            LOGGER.error("Failed to find Value under Column [{}] in file [{}]", valuesField, fileName);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Failed to find Value under Column [{}] in file [{}]", valuesField, fileName);
        }
        try {
            CsvFileSpec spec = new CsvFileSpec(fileName, UTF_8, delimiter);
            CSVReader csvReader = csvUtil.getCSVReader(spec);
            List<String[]> data = csvReader.readAll();
            //removing Header row
            data.remove(headerRow - 1);
            data.forEach(item -> {
                        //Since we are converting into arrays, excluding first '[' and last char ']'
                        String substring = Arrays.toString(item).substring(1, Arrays.toString(item).length() - 1);
                        List<String> list = this.convertStringWithDelimiterToAList(substring, "", COMMA);
                        if (columnIndex < list.size()) {
                            result.add(list.get(columnIndex));
                        }
                    }
            );
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
        return result;
    }

    /**
     * Gets column value map from excel.
     *
     * @param filePath   the file path
     * @param sheetIndex the sheet index starts from 0 (Zero), 1st sheet in the workbook has index 0
     * @param dataRow    the data row starts from 1
     * @return the column value map from excel
     */
    public Map<String, String> getColumnValueMapFromExcel(String filePath, int sheetIndex, int dataRow) {
        try {
            Map<String, String> columnValueMap = new HashMap<>();
            Workbook workbook = excelFileSvc.getWorkbook(filePath);
            Sheet sheet = excelFileSvc.getSheet(workbook, sheetIndex);
            Integer lastColNum = Integer.parseInt(String.valueOf(sheet.getRow(0).getLastCellNum()));
            for (int i = 0; i <= lastColNum - 1; i++) {
                Cell headerCell = excelFileSvc.getCell(sheet, 0, i);
                Cell dataCell = excelFileSvc.getCell(sheet, dataRow, i);
                String headerString = excelFileSvc.getCellValueAsString(headerCell);
                String dataString = "";
                if (dataCell != null) {
                    if (CellType.STRING.equals(dataCell.getCellTypeEnum())) {
                        dataString = excelFileSvc.getCellValueAsString(dataCell);
                    }
                    if (CellType.NUMERIC.equals(dataCell.getCellTypeEnum())) {
                        dataString = String.valueOf(dataCell.getNumericCellValue());
                    }
                    columnValueMap.put(headerString, dataString);
                }
            }
            return columnValueMap;
        } catch (Exception e) {
            LOGGER.error(PROCESSING_FAILED, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, PROCESSING_FAILED);
        }
    }

    public List<String> getFileContentToList(final String fileName) {
        List<String> result;
        if (!fileDirUtil.verifyFileExists(fileName)) {
            LOGGER.error(FILE_DOES_NOT_EXISTS, fileName);
            throw new CartException(CartExceptionType.IO_ERROR, FILE_DOES_NOT_EXISTS, fileName);
        }

        File file = new File(fileName);
        try {
            try (InputStream is = new FileInputStream(file)) {
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(is))) {
                    result = reader.lines().collect(Collectors.toList());
                }
            }
        } catch (IOException e) {
            LOGGER.error("IO Exception while reading file [{}]", fileName, e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO Exception while reading file [{}]", fileName);
        }
        return result;
    }

    public InputStream convertListToInputStream(List<String> list) {
        InputStream in = null;
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            for (String line : list) {
                baos.write(line.getBytes());
                baos.write("\n".getBytes());
                byte[] bytes = baos.toByteArray();
                in = new ByteArrayInputStream(bytes);
            }
        } catch (IOException e) {
            LOGGER.error("Unable to write to Output Stream!");
            throw new CartException(CartExceptionType.IO_ERROR, "Unable to write to Output Stream!");
        }
        return in;
    }

    public List<String> getBBPriceFileFields(String filePath) {
        List<String> listOfFields = new ArrayList<>();
        int fieldsStartRow = fileDirUtil.getFileLineNumberMatchingText(filePath, BB_START_OF_FIELDS);
        int fieldsEndRow = fileDirUtil.getFileLineNumberMatchingText(filePath, BB_END_OF_FIELDS);
        for (int i = fieldsStartRow + 1; i < fieldsEndRow; i++) {
            String fieldName = fileDirUtil.readFileLineToString(filePath, i);
            listOfFields.add(fieldName);
        }
        return listOfFields;
    }

    public String getBBPriceFileFieldData(String filepath, int dataRow, String fieldName) {
        int dataStartRow = fileDirUtil.getFileLineNumberMatchingText(filepath, BB_START_OF_DATA);
        int dataEndRow = fileDirUtil.getFileLineNumberMatchingText(filepath, BB_END_OF_DATA);

        if (dataStartRow == dataEndRow - 1) {
            LOGGER.error("No data rows present in the file");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "No data rows present in the file");
        }

        List<String> listOfFields = getBBPriceFileFields(filepath);

        if (listOfFields.isEmpty()) {
            LOGGER.error("Unable to get Fields from price file");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to get Fields from price file");
        }

        String dataString = fileDirUtil.readFileLineToString(filepath, dataStartRow + dataRow);
        String[] dataArray = dataString.split(Pattern.quote(String.valueOf("|")));
        Integer fieldIndex = listOfFields.indexOf(fieldName);

        if (fieldIndex == -1) {
            LOGGER.error("Field [{}] not available in the Price file", fieldName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Field [{}] not available in the Price file", fieldName);
        }

        //Initial 3 fields in data row have to ignore.
        return dataArray[fieldIndex + 3];
    }

    public Integer getNoOfBBDataRecords(String filepath) {
        Integer dataStartRow = fileDirUtil.getFileLineNumberMatchingText(filepath, BB_START_OF_DATA);
        Integer dataEndRow = fileDirUtil.getFileLineNumberMatchingText(filepath, BB_END_OF_DATA);
        return dataEndRow - dataStartRow - 1;
    }

    public String getColumnValueFromDelimiterSeparatedFile(String filePath, int dataRow, String refField, String fieldName, char delimiter) {
        List<String> listOfValues = this.getFieldValuesFromFileWithHeader(filePath, 1, refField, fieldName, delimiter);
        String value = listOfValues.get(dataRow - 2).equals("") ? null : listOfValues.get(dataRow - 2);
        LOGGER.debug("Value Captured [{}] for field [{}]", value, fieldName);
        return value;
    }

    /**
     * Gets column value with reference value.
     * This function is required to read the value of Column1 based on Column2 and Value2 combination.
     * It identifies row number based on Column2 and value2 combination and returns value corresponding to Column1.
     *
     * @param filePath   the file path
     * @param columnName the Column name of the file for which value to be returned
     * @param refColumn  the ref column
     * @param refValue   the ref value
     * @param delimiter  the delimiter
     * @return the column value with reference value
     */
    public String getColumnValueWithReferenceValue(final String filePath, final String columnName, final String refColumn, final String refValue, final char delimiter) {

        final List<String> listOfRefColValues = this.getFieldValuesFromFileWithHeader(filePath, 1, "", refColumn, delimiter);
        final Integer refValRowNum = listOfRefColValues.indexOf(refValue);
        if (refValRowNum == -1) {
            LOGGER.error("Failed to find Value [{}] under Column [{}] in file [{}]", refValue, refColumn, filePath);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Failed to find Value [{}] under Column [{}] in file [{}]", refValue, refColumn, filePath);
        }
        final List<String> listOfColValues = this.getFieldValuesFromFileWithHeader(filePath, 1, "", columnName, delimiter);
        return listOfColValues.get(refValRowNum);
    }

    /**
     * Gets column value with reference value.
     * This function is required to read the value of Column1 based on multiple column-value map
     * It identifies unique row number based on column-value combinations and returns value corresponding to Column1
     * If multiples rows found with given combinations, then returns exception
     *
     * @param filePath       the file path
     * @param columnName     the column name
     * @param columnValueMap the column value map
     * @param delimiter      the delimiter
     * @return the column value with reference value
     */
    public String getColumnValueWithReferenceValue(final String filePath, final String columnName, final Map<String, String> columnValueMap, final char delimiter) {
        final Set<String> columns = columnValueMap.keySet();
        List<String> listOfRefColValues;
        String refValue;
        String refColumn;
        Set<Integer> tempSet = new HashSet<>();
        Set<Integer> indices;
        boolean uniqueFound = false;
        Integer columnCnt = 1;

        for (String column : columns) {
            refColumn = column;
            refValue = stateSvc.expandVar(columnValueMap.get(refColumn));
            listOfRefColValues = this.getFieldValuesFromFileWithHeader(filePath, 1, "", refColumn, delimiter);

            if (!listOfRefColValues.contains(refValue)) {
                LOGGER.error("Records not found with column [{}] and value [{}]", refColumn, refValue);
                throw new CartException(CartExceptionType.IO_ERROR, "Records not found with column [{}] and value [{}]", refColumn, refValue);
            }

            indices = this.getIndicesOfElement(listOfRefColValues, refValue);
            tempSet = tempSet.isEmpty() ? indices : Sets.intersection(indices, tempSet);
            if (tempSet.size() == 1 && columnCnt == columnValueMap.size()) {
                uniqueFound = true;
            }
            columnCnt++;
        }
        if (!uniqueFound) {
            LOGGER.error("Unique Record not found with given params [{}]", columnValueMap);
            throw new CartException(CartExceptionType.IO_ERROR, "Unique Record not found with given params [{}]", columnValueMap);
        }
        final Integer refValRowNum = (Integer) (tempSet.toArray())[0];
        final List<String> listOfColValues = this.getFieldValuesFromFileWithHeader(filePath, 1, "", columnName, delimiter);
        return listOfColValues.get(refValRowNum);
    }

    private Set<Integer> getIndicesOfElement(final List<String> list, final Object obj) {
        Set<Integer> result = new HashSet<>();
        for (int i = 0; i <= list.size() - 1; i++) {
            if (obj.equals(list.get(i))) {
                result.add(i);
            }
        }
        return result;
    }

    /**
     * It truncates (removes) Timestamp which is in the format HH:MM:SS from the file.
     * If overwriteFile is true, the resultant file will be overwritten, else creates a new file with suffix _1.
     *
     * @param filepath      filepath from which Timestamp to be removed
     * @param overwriteFile true or false
     */
    public void truncateTimestampInFile(final String filepath, final String regExFormat, final boolean overwriteFile) {
        String outfilePath = filepath;
        if (!overwriteFile) {
            final String name = FilenameUtils.removeExtension(FilenameUtils.getName(filepath));
            final String extension = FilenameUtils.getExtension(filepath);
            final String path = FilenameUtils.getPath(filepath);
            outfilePath = path + File.separator + name + "_1." + extension;
        }
        final String content = fileDirUtil.readFileToString(filepath);
        Pattern pattern = Pattern.compile(regExFormat);
        Matcher matcher = pattern.matcher(content);
        if(matcher.find()) {
            final String updatedText = matcher.replaceAll("");
            LOGGER.debug("Timestamp Truncated File saved as [{}]", outfilePath);
            fileDirUtil.writeStringToFile(outfilePath, updatedText);
        }
    }

    /**
     * It Formats given xml and overwrites the file if flag is true else it creates a new file with _1.
     *
     * @param xmlFile         the xml file
     * @param omitDeclaration the omit declaration true or false
     * @param overwriteFile   the overwrite file true or false
     */
    public void formatXml(final String xmlFile, final boolean omitDeclaration, final boolean overwriteFile) {
        String outfilePath = xmlFile;
        if (!overwriteFile) {
            final String name = FilenameUtils.removeExtension(FilenameUtils.getName(xmlFile));
            final String extension = FilenameUtils.getExtension(xmlFile);
            final String path = FilenameUtils.getPath(xmlFile);
            outfilePath = path + File.separator + name + "_1." + extension;
        }
        final String xmlString = fileDirUtil.readFileToString(xmlFile);
        final String formatted = xmlUtil.prettyPrint(xmlString, omitDeclaration);
        fileDirUtil.writeStringToFile(outfilePath, formatted);
    }


    /**
     * Reconcile flat files and returns {@link ReconOutputSpec}.
     * It compares two files based on 2 flags on returns status and list of exceptions
     * If ignoreRowCntChk is true, then it ignores if both files have different no. of records
     * else it throws exception and does not progress for compating records
     * If lookForRecords is true then it looks for all records in currentFile should exist in referenceFile
     * else if expects no record in currentFile should exist in referenceFile
     * If considerOrder is true, then while looking for each record in currentFile, same record is expected in the same order in referenceFile as well.
     * It truncates time stamp format d{2}:d{2}:d{2} in the file before starting reconciliation
     * If current file is xml and not in Pretty format, then it converts into Petty format before reconciliation
     *
     * @param reconInputSpec {@link ReconInputSpec} holds below data in order
     *                       currentFile     the file 1
     *                       referenceFile   the file 2
     *                       ignoreRowCntChk the ignore row cnt chk
     *                       lookForRecords  the look for records exists
     *                       considerOrder   order to be considered while looking for record exists, it will be meaningful when lookForRecords is true
     *                       ignoreHeader   ignore header from recon
     * @return {@link ReconOutputSpec}    ReconOutputSpec object
     */
    public ReconOutputSpec reconcileFlatFiles(ReconInputSpec reconInputSpec) {
        boolean dataMatch = true;

        //Truncating Timestamps from source and target files if files has data in d{2}:d{2}:d{2} format
        this.truncateTimestampInFile(reconInputSpec.getFile1(), REGX_TIME_FORMAT, true);
        this.truncateTimestampInFile(reconInputSpec.getFile2(), REGX_TIME_FORMAT, true);

        //If current file that we are going to compare against Ref file is not in pretty format, then it converts into pretty format
        if ("xml".equalsIgnoreCase(FilenameUtils.getExtension(reconInputSpec.getFile1()))) {
            this.formatXml(reconInputSpec.getFile1(), false, true);
            this.formatXml(reconInputSpec.getFile2(), false, true);
        }

        List<String> currFileData = this.getFileContentToList(reconInputSpec.getFile1()).stream()
                .map(String::trim)
                .collect(Collectors.toList());
        List<String> refFileData = this.getFileContentToList(reconInputSpec.getFile2()).stream()
                .map(String::trim)
                .collect(Collectors.toList());
        if (reconInputSpec.isIgnoreHeader()) {
            currFileData.remove(0);
            refFileData.remove(0);
        }
        List<String> exceptions = new ArrayList<>();
        exceptions.add(EXCEPTIONS_ARE_LISTED_BELOW);

        int currentFileCount = (int) fileDirUtil.getRowsCountInFile(reconInputSpec.getFile1());
        int referenceFileCount = (int) fileDirUtil.getRowsCountInFile(reconInputSpec.getFile2());

        if (!reconInputSpec.isIgnoreRowCount() && (currentFileCount != referenceFileCount)) {
            return this.getMissingRecords(reconInputSpec.getFile1(), reconInputSpec.getFile2());
        }

        if (reconInputSpec.isLookForRecords()) {
            ReconOutputSpec reconSpec = this.compareLists(currFileData, refFileData, reconInputSpec.isConsiderOrder());
            if (!reconSpec.getIsMatch()) {
                reconSpec.getExceptions().add(1, "\nExpected Records:");
                if (currentFileCount == referenceFileCount) {
                    List<String> exceptionList = this.compareLists(refFileData, currFileData, reconInputSpec.isConsiderOrder()).getExceptions();
                    exceptionList.set(0, "\nActual Records:");
                    reconSpec.getExceptions().addAll(exceptionList);
                }
                reconSpec.setErrorMessage(RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);
            }
            return reconSpec;
        } else {
            int lineNum = 1;
            ArrayList<String> tempRefFile = new ArrayList<>(refFileData);
            for (String currStr : currFileData) {
                if (tempRefFile.contains(currStr)) {
                    exceptions.add("\t [Line: " + lineNum + "] => " + currStr);
                    dataMatch = false;
                } else {
                    tempRefFile.remove(currStr);
                }
                lineNum++;
            }
            return new ReconOutputSpec(dataMatch, exceptions, RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);
        }
    }

    private ReconOutputSpec getMissingRecords(final String file1, final String file2) {
        final List<String> file1Data = this.getFileContentToList(file1).stream()
                .map(String::trim)
                .collect(Collectors.toList());
        final List<String> file2Data = this.getFileContentToList(file2).stream()
                .map(String::trim)
                .collect(Collectors.toList());

        ReconOutputSpec reconSpec;
        List<String> tempList = new ArrayList<>();

        reconSpec = this.compareLists(file1Data, file2Data, false);
        if (!reconSpec.getIsMatch()) {
            tempList.add(formatterUtil.format(MISSING_RECORDS_HEADER, new File(file2).getAbsolutePath(), new File(file1).getAbsolutePath()));
            reconSpec.getExceptions().remove(0);
            tempList.addAll(reconSpec.getExceptions());

        }
        reconSpec = this.compareLists(file2Data, file1Data, false);
        if (!reconSpec.getIsMatch()) {
            tempList.add(formatterUtil.format(MISSING_RECORDS_HEADER, new File(file1).getAbsolutePath(), new File(file2).getAbsolutePath()));
            reconSpec.getExceptions().remove(0);
            tempList.addAll(reconSpec.getExceptions());
        }
        return new ReconOutputSpec(false, tempList, RECONCILIATION_FAILED_BECAUSE_OF_DATA_MISMATCH);
    }

    private ReconOutputSpec compareLists(final List<String> list1, final List<String> list2, final boolean considerOrder) {
        boolean dataMatch = true;
        List<String> exceptions = new ArrayList<>();
        exceptions.add(EXCEPTIONS_ARE_LISTED_BELOW);

        ArrayList<String> tempList1 = new ArrayList<>(list1);
        ArrayList<String> tempList2 = new ArrayList<>(list2);

        int lineNum = 1;
        if (considerOrder) {
            Iterator<String> it1 = tempList1.stream().iterator();
            Iterator<String> it2 = tempList2.stream().iterator();

            while (it1.hasNext() && it2.hasNext()) {
                String val1 = it1.next();
                String val2 = it2.next();
                if (!val1.equals(val2)) {
                    dataMatch = false;
                    exceptions.add("\t [Line: " + lineNum + "] => " + val1);
                    break;
                }
                lineNum++;
            }
        } else {
            lineNum = 1;
            for (String currStr : tempList1) {
                if (!tempList2.contains(currStr)) {
                    exceptions.add("\t [Line: " + lineNum + "] => " + currStr);
                    dataMatch = false;
                } else {
                    tempList2.remove(currStr);
                }
                lineNum++;
            }
        }
        return new ReconOutputSpec(dataMatch, exceptions);
    }

    /**
     * Duplicate rows check boolean.
     *
     * @param filepath the filepath
     * @return the boolean
     */
    public boolean hasDuplicateRecordsInFile(final String filepath) {
        try {
            List<String> arrayList = new ArrayList<>();
            BufferedReader reader = new BufferedReader(new FileReader(filepath));
            String line;
            while ((line = reader.readLine()) != null) {
                if (arrayList.contains(line)) {
                    LOGGER.debug("First duplicate record found with [{}]", line);
                    return true;
                } else {
                    arrayList.add(line);
                }
            }
        } catch (IOException e) {
            LOGGER.error("Exception occurred while reading file [{}]", filepath, e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception occurred while reading file [{}]", filepath);
        }
        LOGGER.info("Duplicate records are not found in the file [{}]", filepath);
        return false;
    }

    private List<Integer> getColumnsIndices(String columns, List<String> excludeColumnsList, String separator) {
        List<Integer> indices = new ArrayList<>();
        List<String> list = Arrays.stream(columns.split(separator)).map(String::trim).collect(Collectors.toList());
        for (String col : excludeColumnsList) {
            indices.add(list.indexOf(col));
        }
        Collections.sort(indices);
        return indices;
    }

    private List<String> trimColumnValuesFromData(String line, List<Integer> indices, String separator) {
        List<String> list = Arrays.stream(line.split(separator + "(?=([^\"]*\"[^\"]*\")*[^\"]*$)", -1))
                .map(String::trim)
                .collect(Collectors.toList());
        int i = 0;
        for (Integer index : indices) {
            list.remove(index - i);
            i++;
        }
        return list;
    }

    /**
     * It removes given columns data form the given file and creates new file ,delimiter will be captured from the header\columns
     *
     * @param filePaths      File paths from which columns to be removed
     * @param excludeColumns list of the columns to be removed
     */

    @SuppressWarnings( "unchecked" )
    public <T> String[] getFilesExcludingColumns(List<T> excludeColumns, String... filePaths) {
        char delimiter = determineDelimiter(workspaceDirSvc.normalize(filePaths[0]));
        if (excludeColumns.get(0) instanceof String) {
            return getFilesExcludingColumns((List<String>) excludeColumns, delimiter, filePaths);
        }
        return getFilesExcludingColumnsByIndices((List<Integer>) excludeColumns, delimiter, filePaths);
    }

    private Character determineDelimiter(final String file) {
        final String header = fileDirUtil.readFileLineToString(file, 1);
        if (header == null) {
            LOGGER.error("File [{}] is empty", file);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "File [{}] is empty", file);
        }
        char delimiter = ',';
        if (header.contains("|")) {
            delimiter = '|';
        }
        return delimiter;
    }

    /**
     * It removes given columns data form the given file and creates new file
     *
     * @param filePaths      File paths from which columns to be removed
     * @param excludeColumns list of the columns to be removed
     * @param separator      Separator of the file data
     */

    public String[] getFilesExcludingColumns(List<String> excludeColumns, char separator, String... filePaths) {
        int index = 0;
        String delimiter = String.valueOf(separator);
        if (delimiter.equalsIgnoreCase("|")) delimiter = "\\|";
        for (String filepath : filePaths) {
            try {
                String newFileName = workspaceDirSvc.normalize(new File(filepath).getParent() + File.separator
                        + FilenameUtils.removeExtension(new File(filepath).getName()) + "_recon."
                        + FilenameUtils.getExtension(filepath));
                LOGGER.debug("New filename will be created [{}] for [{}]", newFileName, filepath);
                String columns = fileDirUtil.readFileLineToString(workspaceDirSvc.normalize(filepath), 1);
                columns = columns.replace("\"", "");
                List<Integer> indices = getColumnsIndices(columns, excludeColumns, delimiter);
                List<String[]> finalList = new ArrayList<>();
                CSVWriter csvWriter = null;
                try {
                    CsvFileSpec spec = new CsvFileSpec(newFileName, UTF_8, delimiter.charAt(delimiter.length() - 1));
                    csvWriter = new CSVWriter(new FileWriter(spec.getFilename()), spec.getSeparator(), CSVWriter.NO_QUOTE_CHARACTER,
                            CSVWriter.DEFAULT_ESCAPE_CHARACTER,
                            CSVWriter.DEFAULT_LINE_END);
                    LineIterator it = FileUtils.lineIterator(new File(filepath), UTF_8);
                    try {
                        while (it.hasNext()) {
                            String line = it.nextLine();
                            List<String> interimList = trimColumnValuesFromData(line, indices, delimiter);
                            String[] strings = interimList.toArray(new String[interimList.size()]);
                            finalList.add(strings);
                        }
                    } finally {
                        LineIterator.closeQuietly(it);
                    }
                    csvWriter.writeAll(finalList);
                } finally {
                    if (csvWriter != null) csvWriter.close();
                }
                filePaths[index++] = newFileName;
            } catch (Exception e) {
                LOGGER.error("Exception occurred while creating file [{}]", filepath, e);
                throw new CartException(CartExceptionType.IO_ERROR, "Exception occurred while creating file [{}]", filepath, e);
            }
        }
        return filePaths;
    }

    //TODO - Refactor methods
    public String[] getFilesExcludingColumnsByIndices(List<Integer> columnIndices, char separator, String... filePaths) {
        int index = 0;
        String delimiter = String.valueOf(separator);
        if (delimiter.equalsIgnoreCase("|")) delimiter = "\\|";
        for (String filepath : filePaths) {
            try {
                String newFileName = workspaceDirSvc.normalize(new File(filepath).getParent() + File.separator
                        + FilenameUtils.removeExtension(new File(filepath).getName()) + "_recon."
                        + FilenameUtils.getExtension(filepath));
                LOGGER.debug("New filename will be created [{}] for [{}]", newFileName, filepath);

                List<String[]> finalList = new ArrayList<>();
                CSVWriter csvWriter = null;
                try {
                    CsvFileSpec spec = new CsvFileSpec(newFileName, UTF_8, delimiter.charAt(delimiter.length() - 1));
                    csvWriter = new CSVWriter(new FileWriter(spec.getFilename()), spec.getSeparator(), CSVWriter.NO_QUOTE_CHARACTER,
                            CSVWriter.DEFAULT_ESCAPE_CHARACTER,
                            CSVWriter.DEFAULT_LINE_END);
                    LineIterator it = FileUtils.lineIterator(new File(filepath), UTF_8);
                    try {
                        while (it.hasNext()) {
                            String line = it.nextLine();
                            List<String> interimList = trimColumnValuesFromData(line, columnIndices, delimiter);
                            String[] strings = interimList.toArray(new String[interimList.size()]);
                            finalList.add(strings);
                        }
                    } finally {
                        LineIterator.closeQuietly(it);
                    }
                    csvWriter.writeAll(finalList);
                } finally {
                    if (csvWriter != null) csvWriter.close();
                }
                filePaths[index++] = newFileName;
            } catch (Exception e) {
                LOGGER.error("Exception occurred while creating file [{}]", filepath, e);
                throw new CartException(CartExceptionType.IO_ERROR, "Exception occurred while creating file [{}]", filepath, e);
            }
        }
        return filePaths;
    }

}
