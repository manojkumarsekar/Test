package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.mdl.*;
import com.eastspring.tom.cart.core.utl.CsvUtil;
import com.eastspring.tom.cart.core.utl.SqlStringUtil;
import com.google.common.base.Strings;
import com.opencsv.CSVParser;
import com.opencsv.CSVParserBuilder;
import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.*;
import java.util.function.BiFunction;
import java.util.function.Function;
import java.util.stream.Collectors;

public class CsvSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(CsvSvc.class);
    private static final String UTF_16 = StandardCharsets.UTF_16.displayName();
    private static final String UTF_8 = StandardCharsets.UTF_8.displayName();
    private static final String FAILED_TO_EXECUTE_PREPARED_STATEMENT_ON_NAMED_CONNECTION = "failed to execute prepared statement on named connection [{}]";
    private static final String SELECT_S_FROM_S = "SELECT %s FROM %s";
    private static final String SELECT_S_FROM_S_WITH_WHERE_CLAUSE = "SELECT %s FROM %s WHERE %s";
    private static final String IO_ERROR_WHILE_READING_CSV_FILE = "IO error while reading CSV file [{}]";
    private static final String FAILED_TO_PARSE = "failed to parse [{}]";
    public static final String POSTFIX_TO_REMOVE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY = "postfixToRemove parameter must not be null or empty";

    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private FileTransformSvc fileTransformSvc;

    @Autowired
    private JdbcSvc jdbcSvc;

    @Autowired
    private SqlStringUtil sqlStringUtil;

    private String[] headers = null;

    public SqlCsvResult getSqlCreateTableFromCsv(String tableName, String fullpath, String encoding, char separator) {
        return getSqlCreateTableFromCsv2(tableName, fullpath, encoding, separator, 1);
    }

    public SqlCsvResult getSqlCreateTableFromCsv2(String tableName, String fullpath, String encoding, char separator, int minChar) {
        LOGGER.debug("  tableName: [{}]", tableName);
        LOGGER.debug("  fullpath: [{}]", fullpath);
        CsvProfile csvProfile = profileCsvCols(fullpath, encoding, separator);
        csvProfile.setHasHeader(true);

        Map<Integer, Integer> colLengthMaxMap = csvProfile.getColumnLengthMaxMap();

        headers = csvProfile.getHeaders();
        Set<String> headersSet = new HashSet<>();
        List<SqlFieldDef> fieldDefs = new ArrayList<>();

        int rowNum = 0;
        for (String header : headers) {
            fieldDefs.add(new SqlFieldDef(header, SqlFieldDef.FieldType.VARCHAR, Math.max(colLengthMaxMap.get(rowNum), minChar)));
            headersSet.add(header);
            rowNum++;
        }

        if (headersSet.size() != csvProfile.getHeaderCount()) {
            LOGGER.error("headers should be unique, headerSet.size={}, csvProfile.headerCount={}", headersSet.size(), csvProfile.getHeaderCount());
            if (LOGGER.isErrorEnabled()) {
                LOGGER.error("headers:{}", Objects.toString(csvProfile.getHeaders()));
            }
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "headers should be unique");
        }

        return new SqlCsvResult(sqlStringUtil.getSqlCreateTableDdl(tableName, fieldDefs), csvProfile);
    }

    public CsvProfile profileCsvCols(String fullpath, String encoding, char separator) {
        if (!UTF_8.equals(encoding) && !UTF_16.equals(encoding)) {
            LOGGER.error("unsupported encoding [{}]", encoding);
            throw new CartException(CartExceptionType.UNSUPPORTED_ENCODING, "unsupported encoding [{}]", encoding);
        }
        CsvProfile csvProfile = new CsvProfile();
        Map<Integer, Integer> colLengthMaxMap = new HashMap<>();
        Map<Integer, Integer> colLengthMinMap = new HashMap<>();
        int minRowColsCount = Integer.MAX_VALUE;
        int maxRowColsCount = 0;
        int lineNum = 0;
        final CSVParser parser = new CSVParserBuilder().withSeparator(separator).build();
        try (CSVReader reader = new CSVReaderBuilder(new InputStreamReader(new FileInputStream(fullpath), encoding)).withCSVParser(parser).build()) {
            String[] nextLine;

            while ((nextLine = reader.readNext()) != null) {
                int nextLineColsCount = nextLine.length;
                if (nextLineColsCount < minRowColsCount) {
                    minRowColsCount = nextLineColsCount;
                }
                if (nextLineColsCount > maxRowColsCount) {
                    maxRowColsCount = nextLineColsCount;
                }
                if (lineNum == 0) {
                    headers = nextLine;
                } else {
                    collectMinMaxLength(colLengthMinMap, colLengthMaxMap, nextLine, nextLineColsCount);
                }
                lineNum++;
            }
        } catch (FileNotFoundException e) {
            LOGGER.error("file [{}] not found", fullpath, e );
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "file [{}] not found", fullpath);
        } catch (IOException e) {
            LOGGER.error("IO error while profiling CSV file [{}]", fullpath, e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO error while profiling CSV file [{}]", fullpath);
        }
        csvProfile.setMinRowColsCount(minRowColsCount);
        csvProfile.setMaxRowColsCount(maxRowColsCount);
        csvProfile.setRowCount(lineNum);
        csvProfile.setHeaders(headers);
        csvProfile.setColumnLengthMaxMap(colLengthMaxMap);
        csvProfile.setColumnLengthMinMap(colLengthMinMap);
        csvProfile.setHasHeader(true);

        return csvProfile;
    }

    private void collectMinMaxLength(Map<Integer, Integer> colLengthMinMap, Map<Integer, Integer> colLengthMaxMap, String[] nextLine, int nextLineColsCount) {
        for (int i = 0; i < nextLineColsCount; i++) {
            if (colLengthMinMap.containsKey(i)) {
                int minLength = colLengthMinMap.get(i);
                if (nextLine[i].length() < minLength) {
                    colLengthMinMap.put(i, nextLine[i].length());
                }
            } else {
                colLengthMinMap.put(i, nextLine[i].length());
            }
            if (colLengthMaxMap.containsKey(i)) {
                int maxLength = colLengthMaxMap.get(i);
                if (nextLine[i].length() > maxLength) {
                    colLengthMaxMap.put(i, nextLine[i].length());
                }
            } else {
                colLengthMaxMap.put(i, nextLine[i].length());
            }
        }
    }

    public String getPrepStmtInsertCommand(String tableName, List<String> fieldNames) {
        if (fieldNames == null || fieldNames.isEmpty()) {
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "columnNames must not be empty or null");
        }
        List<String> questionMarks = Collections.nCopies(fieldNames.size(), "?");
        List<String> bracketedFields = fieldNames.stream().map(fieldName -> "[" + fieldName + "]").collect(Collectors.toList());
        return String.format("INSERT INTO %s (%s) VALUES (%s)", tableName, sqlStringUtil.zipJoin(bracketedFields, ",", "", ""), sqlStringUtil.zipJoin(questionMarks, ",", "", ""));
    }

    public void insertPreparedStatementFromCsvFile2(String fullpath, String namedConnection, int colsCount, PreparedStatement preparedStatement, ColumnFilterPredicate filterPredicate) {

        try (CSVReader reader = new CSVReader(new FileReader(fullpath))) {
            executeInPreparedStatement(colsCount, preparedStatement, filterPredicate, reader);
        } catch (SQLException e) {
            LOGGER.error(FAILED_TO_EXECUTE_PREPARED_STATEMENT_ON_NAMED_CONNECTION, namedConnection);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_PREPARED_STATEMENT_ON_NAMED_CONNECTION, namedConnection);
        } catch (IOException e) {
            LOGGER.error("IOException", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "IOException", namedConnection);
        }
    }

    private void executeInPreparedStatement(int colsCount, PreparedStatement preparedStatement, ColumnFilterPredicate filterPredicate, CSVReader reader) throws IOException, SQLException {
        String[] nextLine;

        boolean firstLine = true;
        while ((nextLine = reader.readNext()) != null) {
            if (firstLine) {
                firstLine = false;
                continue;
            }
            for (int i = 0; i < colsCount; i++) {
                String value = nextLine[i];
                preparedStatement.setString(i + 1, filterPredicate.operation(i, value));
            }
            preparedStatement.execute();
        }
    }

    private void bnpDnaExecuteInPreparedStatement(int colsCount, PreparedStatement preparedStatement, ColumnFilterPredicate filterPredicate, CSVReader reader) throws IOException, SQLException {
        String[] nextLine;

        boolean firstLine = true;
        while ((nextLine = reader.readNext()) != null) {
            if (firstLine) {
                firstLine = false;
                continue;
            }
            for (int i = 0; i < colsCount; i++) {
                String value = nextLine[i];
                if (i >= 9 && i != 20) {
                    preparedStatement.setBigDecimal(i + 1, Strings.isNullOrEmpty(value) ? null : new BigDecimal(filterPredicate.operation(i, value)));
                } else {
                    preparedStatement.setString(i + 1, filterPredicate.operation(i, value));
                }
            }
            preparedStatement.execute();
        }
    }

    public void insertPreparedStatementFromCsvFile(String fullpath, String namedConnection, int colsCount, PreparedStatement preparedStatement, ColumnFilterPredicate filterPredicate, String encoding, char separator) {
        final CSVParser parser = new CSVParserBuilder().withSeparator(separator).build();
        try (CSVReader reader = new CSVReaderBuilder(new InputStreamReader(new FileInputStream(fullpath), encoding)).withCSVParser(parser).build()) {
            executeInPreparedStatement(colsCount, preparedStatement, filterPredicate, reader);
        } catch (SQLException e) {
            LOGGER.error(FAILED_TO_EXECUTE_PREPARED_STATEMENT_ON_NAMED_CONNECTION, namedConnection, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_PREPARED_STATEMENT_ON_NAMED_CONNECTION, namedConnection);
        } catch (IOException e) {
            LOGGER.error(IO_ERROR_WHILE_READING_CSV_FILE, fullpath, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, IO_ERROR_WHILE_READING_CSV_FILE, fullpath);
        }
    }

    public void bnpDnaInsertPreparedStatementFromCsvFile(String fullpath, String namedConnection, int colsCount, PreparedStatement preparedStatement, ColumnFilterPredicate filterPredicate, String encoding, char separator) {
        final CSVParser parser = new CSVParserBuilder().withSeparator(separator).build();
        try (CSVReader reader = new CSVReaderBuilder(new InputStreamReader(new FileInputStream(fullpath), encoding)).withCSVParser(parser).build()) {
            bnpDnaExecuteInPreparedStatement(colsCount, preparedStatement, filterPredicate, reader);
        } catch (SQLException e) {
            LOGGER.error(FAILED_TO_EXECUTE_PREPARED_STATEMENT_ON_NAMED_CONNECTION, namedConnection, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_PREPARED_STATEMENT_ON_NAMED_CONNECTION, namedConnection);
        } catch (IOException e) {
            LOGGER.error(IO_ERROR_WHILE_READING_CSV_FILE, fullpath, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, IO_ERROR_WHILE_READING_CSV_FILE, fullpath);
        }
    }


    public List<ComparisonColPairMetadata> getComparisonColPairMetadataFromHeader(CsvProfile csvProfile, SourceTargetMatch sourceTargetMatch, String matchWithToleranceName) {
        List<String> headerList = Arrays.asList(csvProfile.getHeaders());
        String sourceNamePostfix = " (" + sourceTargetMatch.getSource() + ")";
        String targetNamePostfix = " (" + sourceTargetMatch.getTarget() + ")";
        String matchNamePostfix = " (" + sourceTargetMatch.getMatch() + ")";
        String matchWithToleranceNamePostfix = " (" + matchWithToleranceName + ")";

        List<String> sourceColumnNames = headerList.stream().filter(x -> x != null && x.endsWith(sourceNamePostfix)).collect(Collectors.toList());
        List<String> targetColumnNames = headerList.stream().filter(x -> x != null && x.endsWith(targetNamePostfix)).collect(Collectors.toList());
        List<String> matchColumnNames = headerList.stream().filter(x -> x != null && (x.endsWith(matchNamePostfix) || x.endsWith(matchWithToleranceNamePostfix))).collect(Collectors.toList());
        List<String> genericColumnNames = sourceColumnNames.stream().map(x -> x.substring(0, x.length() - sourceNamePostfix.length())).collect(Collectors.toList());

        LOGGER.debug("headerlist: {}\nsource: {}\ntarget: {}\nmatch: {}\ngeneric: {}", headerList, sourceColumnNames, targetColumnNames, matchColumnNames, genericColumnNames);
        if (sourceColumnNames.size() != targetColumnNames.size() || genericColumnNames.size() != sourceColumnNames.size()) {
            LOGGER.error("source, target, generic column must be of the same count");
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "source, target, match and generic column must be of the same count");
        }
        final int matchNamePostfixLen = matchNamePostfix.length();
        final int matchWithToleranceNamePostfixLen = matchWithToleranceNamePostfix.length();
        List<String> normalizedMatchColumnNames = matchColumnNames.stream().map(x -> x.endsWith(matchNamePostfix) ? x.substring(0, x.length() - matchNamePostfixLen) : x.substring(0, x.length() - matchWithToleranceNamePostfixLen)).collect(Collectors.toList());
        HashSet<String> normalizedMatchColumnNamesSet = new HashSet<>(normalizedMatchColumnNames);

        return genericColumnNames.stream().map(getStringComparisonColPairMetadataFunction(headerList, sourceNamePostfix, targetNamePostfix, matchNamePostfix, matchWithToleranceNamePostfix, matchColumnNames, normalizedMatchColumnNamesSet)).collect(Collectors.toList());
    }

    private Function<String, ComparisonColPairMetadata> getStringComparisonColPairMetadataFunction(List<String> headerList, String sourceNamePostfix, String targetNamePostfix, String matchNamePostfix, String matchWithToleranceNamePostfix, List<String> matchColumnNames, HashSet<String> normalizedMatchColumnNamesSet) {
        return x -> {
            ComparisonColPairMetadata metadata = new ComparisonColPairMetadata();
            if (normalizedMatchColumnNamesSet.contains(x)) {
                metadata.setPasshtruColumn(false);
            } else {
                metadata.setPasshtruColumn(true);
            }
            metadata.setComparisonResult(matchColumnNames.contains(x + matchNamePostfix) ? ComparisonResult.MATCH : ComparisonResult.TOLERANCE_MATCH);
            metadata.setGenericColumnName(x);
            String sourceColumnName = x + sourceNamePostfix;
            String targetColumnName = x + targetNamePostfix;
            String matchColumnName = x + matchNamePostfix;
            String matchWithToleranceColumnName = x + matchWithToleranceNamePostfix;
            metadata.setSourceColumnName(sourceColumnName);
            metadata.setTargetColumnName(targetColumnName);
            metadata.setSourceColumnIndex(headerList.indexOf(sourceColumnName));
            metadata.setTargetColumnIndex(headerList.indexOf(targetColumnName));
            metadata.setMatchColumnIndex(headerList.indexOf(matchColumnName) != -1 ? headerList.indexOf(matchColumnName) : headerList.indexOf(matchWithToleranceColumnName));
            metadata.setMatchColumnName(x + (ComparisonResult.MATCH.equals(metadata.getComparisonResult()) ? matchNamePostfix : matchWithToleranceNamePostfix));
            return metadata;
        };
    }

    /**
     * <p>This method extracts the key metadata from headers information in the given {@link CsvProfile} object.</p>
     *
     * @param csvProfile CSV profile object
     * @param keyName    the key signature
     * @return list of {@link KeyMetadata}
     */
    public List<KeyMetadata> getKeyMetadataFromHeader(CsvProfile csvProfile, String keyName) {
        List<String> headerList = csvProfile.getHeaders() != null ? Arrays.asList(csvProfile.getHeaders()) : new ArrayList<>();
        String keyNamePostfix = " (" + keyName + ")";

        return headerList.stream()
                .filter(x -> x != null && x.endsWith(keyNamePostfix))
                .map(keyColumnName -> new KeyMetadata(headerList.indexOf(keyColumnName)))
                .collect(Collectors.toList());
    }


    /**
     * <p>This method implements the capability to convert CSV column that is in a date format.</p>
     *
     * @param srcFile
     * @param colsToConvert
     * @param sourcePattern
     * @param targetPattern
     * @param dstFile
     */
    public void convertCsvColsDateFormat(String srcFile, List<String> colsToConvert, String sourcePattern, String targetPattern, String dstFile) {
        final DateTimeFormatter srcParser = DateTimeFormat.forPattern(sourcePattern);
        final DateTimeFormatter dstFormatter = DateTimeFormat.forPattern(targetPattern);
        fileTransformSvc.csvTransformColsByNamesDefault(colsToConvert, srcFile, dstFile, (String x, Integer m) -> {
            try {
                return x != null && !"".equals(x) ? dstFormatter.print(srcParser.parseDateTime(x)) : "";
            } catch (Exception e) {
                LOGGER.error(FAILED_TO_PARSE, x, e);
                throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, FAILED_TO_PARSE, x);
            }
        });
    }

    /**
     * <p>This method implements the capability to convert CSV column that is in a date format.</p>
     *
     * @param srcFile
     * @param colsToConvert
     * @param decimalPoint
     * @param dstFile
     */
    public void convertColsNumPrecision(String srcFile, List<String> colsToConvert, int decimalPoint, String dstFile) {
        fileTransformSvc.csvTransformColsByNamesDefault(colsToConvert, srcFile, dstFile, getStringIntegerStringBiFunction(decimalPoint));
    }

    private BiFunction<String, Integer, String> getStringIntegerStringBiFunction(int decimalPoint) {
        return (String y, Integer m) -> {
            if (y == null) {
                return "";
            }
            String z = y.trim();
            String x;
            boolean hasPercentage;
            if (z.endsWith("%")) {
                x = z.substring(0, z.length() - 1);
                hasPercentage = true;
            } else {
                x = z;
                hasPercentage = false;
            }
            try {
                return getString(decimalPoint, x, hasPercentage);
            } catch (Exception e) {
                LOGGER.error(FAILED_TO_PARSE, x, e);
                throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, FAILED_TO_PARSE, x);
            }
        };
    }

    private String getString(int decimalPoint, String x, boolean hasPercentage) {
        if (!"".equals(x)) {
            return new BigDecimal(x).setScale(decimalPoint, RoundingMode.HALF_UP).toPlainString() + (hasPercentage ? "%" : "");
        } else {
            return (hasPercentage ? "%" : "");
        }
    }


    public void removePostfixFromCols(String postfixToRemove, String srcFile, List<String> colsToConvert, String dstFile) {
        if (Strings.isNullOrEmpty(postfixToRemove)) {
            LOGGER.error(POSTFIX_TO_REMOVE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY);
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, POSTFIX_TO_REMOVE_PARAMETER_MUST_NOT_BE_NULL_OR_EMPTY);
        }
        fileTransformSvc.csvTransformColsByNamesDefault(colsToConvert, srcFile, dstFile, (String value, Integer colIdx) -> {
            if(Strings.isNullOrEmpty(value)) {
                return "";
            } else if(value.endsWith(postfixToRemove)) {
                return value.substring(value.length() - postfixToRemove.length());
            } else {
                return value;
            }
        });
    }

    // the new Reconciliation world 2017-11-24
    public void exportTableViewToCsvFile(String connectionName, String viewName, String fileFullpath) {
        List<ColumnMetadata> result = jdbcSvc.getColumnMetadataOnNamedConnection(connectionName, viewName);
        String columnList = sqlStringUtil.zipJoin(result.stream().map(ColumnMetadata::getBracketedColumnName).collect(Collectors.toList()), ",", "", "");
        String selectQuery = String.format(SELECT_S_FROM_S, columnList, viewName);
        LOGGER.debug("exportTableViewToCsvFile: executing: [{}]", selectQuery);
        jdbcSvc.exportSqlQueryNamedConnectionToCsv(connectionName, selectQuery, fileFullpath);
    }

    // the new Reconciliation world 2017-11-24
    public void exportTableViewToCsvFileWithWhereClause(String connectionName, String viewName, String fileFullpath, String whereClause) {
        List<ColumnMetadata> result = jdbcSvc.getColumnMetadataOnNamedConnection(connectionName, viewName);
        String columnList = sqlStringUtil.zipJoin(result.stream().map(ColumnMetadata::getBracketedColumnName).collect(Collectors.toList()), ",", "", "");
        String selectQuery = String.format(SELECT_S_FROM_S_WITH_WHERE_CLAUSE, columnList, viewName, whereClause);
        LOGGER.debug("exportTableViewToCsvFileWithWhereClause: executing: [{}]", selectQuery);
        jdbcSvc.exportSqlQueryNamedConnectionToCsv(connectionName, selectQuery, fileFullpath);
    }

    public void exportTableViewToCsvFileWithFixedDigitNums(String connectionName, String mismatchView, String fileFullpath, int outputScale) {
        List<ColumnMetadata> result = jdbcSvc.getColumnMetadataOnNamedConnection(connectionName, mismatchView);
        String columnList = sqlStringUtil.zipJoin(result.stream().map(ColumnMetadata::getBracketedColumnName).collect(Collectors.toList()), ",", "", "");
        String selectQuery = String.format(SELECT_S_FROM_S, columnList, mismatchView);
        LOGGER.debug("exportTableViewToCsvFileWithFixedDigitNums: executing: [{}]", selectQuery);
        jdbcSvc.exportSqlQueryNamedConnectionToCsvWithFixedDigitNums(connectionName, selectQuery, fileFullpath, outputScale);
    }

    public void exportTableViewToCsvFileWithFixedDigitNumsWithWhereClause(String connectionName, String mismatchView, String fileFullpath, int outputScale, String whereClause) {
        List<ColumnMetadata> result = jdbcSvc.getColumnMetadataOnNamedConnection(connectionName, mismatchView);
        String columnList = sqlStringUtil.zipJoin(result.stream().map(ColumnMetadata::getBracketedColumnName).collect(Collectors.toList()), ",", "", "");
        String selectQuery = String.format(SELECT_S_FROM_S_WITH_WHERE_CLAUSE, columnList, mismatchView, whereClause);
        LOGGER.debug("exportTableViewToCsvFileWithFixedDigitNumsWithWhereClause: executing: [{}]", selectQuery);
        jdbcSvc.exportSqlQueryNamedConnectionToCsvWithFixedDigitNums(connectionName, selectQuery, fileFullpath, outputScale);
    }

}
