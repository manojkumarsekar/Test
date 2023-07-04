package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.annotations.DBTable;
import com.eastspring.tom.cart.core.mdl.ColumnMetadata;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.SqlStringUtil;
import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.*;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.util.*;

/**
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class JdbcSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(JdbcSvc.class);
    protected static final String NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED = "named connection [{}] is null, probably it has not been created?";
    private static final String FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION = "failed to execute query [{}] on named connection [{}]";
    private static final String JDBC_DRIVER_CLASS_NOT_FOUND = "jdbc driver class [{}] not found in classpath; either provide the correct driver class name or provide the driver in the classpath";
    private static final String FAILED_TO_EXPORT_SQL_QUERY_RESULTS_TO_CSV_FILE = "failed to export SQL query results to CSV file";
    private static final String NUMERIC = "numeric";
    public static final String INTERNAL_DB_RECON = "internal.db.RECON";
    public static final String INTERNAL_DB_CSV_STAGING = "internal.db.CSV_STAGING";
    public static final int BUFFER_SIZE = 4096;
    public static final int BATCH_SIZE = 1000;

    private static final String SQL_INSERT = "INSERT INTO ${table}(${keys}) VALUES(${values})";
    private static final String TABLE_REGEX = "\\$\\{table\\}";
    private static final String KEYS_REGEX = "\\$\\{keys\\}";
    private static final String VALUES_REGEX = "\\$\\{values\\}";

    private Map<String, Connection> namedConnections = new HashMap<>();

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private SqlStringUtil sqlStringUtil;


    private boolean isDBConnectionEstablished(final String connectionName) {
        try {
            Connection conn = namedConnections.get(connectionName);
            if (conn != null && conn.isValid(5)) {
                return true;
            }
        } catch (SQLException e) {
            //ignore
        }
        return false;
    }

    void disconnectNamedConnection(final String connectionName) {
        namedConnections.remove(connectionName);
    }

    public void createNamedConnection(String connectionName) {
        if (isDBConnectionEstablished(connectionName)) {
            LOGGER.debug("Connection for [{}] is already established...", connectionName);
            return;
        }

        LOGGER.debug("creating Named Connection [{}]", connectionName);
        String connTypeProp = connectionName + ".type";
        LOGGER.debug("  connTypeProp: [{}]", connTypeProp);
        String connectionType = stateSvc.getStringVar(connTypeProp);
        if (!"jdbc_a".equalsIgnoreCase(connectionType)) {
            LOGGER.error("unsupported connection type [{}]", connectionType);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "unsupported connection type [{}]", connectionType);
        }

        String jdbcUrl = stateSvc.getStringVar(connectionName + ".jdbc.url");
        String jdbcClass = stateSvc.getStringVar(connectionName + ".jdbc.class");
        String jdbcUser = stateSvc.getStringVar(connectionName + ".jdbc.user");
        String jdbcPass = stateSvc.getStringVar(connectionName + ".jdbc.pass");
        String jdbcDescription = stateSvc.getStringVar(connectionName + ".jdbc.description");

        LOGGER.debug("  jdbcUrl: [{}]", jdbcUrl);
        LOGGER.debug("  jdbcClass: [{}]", jdbcClass);
        LOGGER.debug("  jdbcUser: [{}]", jdbcUser);
        LOGGER.debug("  jdbcPass: ********", jdbcPass);
        LOGGER.debug("  jdbcDescription: [{}]", jdbcDescription);

        try {
            Class.forName(jdbcClass);
        } catch (ClassNotFoundException e) {
            LOGGER.error(JDBC_DRIVER_CLASS_NOT_FOUND, jdbcClass, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, JDBC_DRIVER_CLASS_NOT_FOUND, jdbcClass);
        }
        try {
            Connection result = DriverManager.getConnection(jdbcUrl, jdbcUser, jdbcPass);
            namedConnections.put(connectionName, result);
        } catch (SQLException e) {
            LOGGER.error("failed to create connection", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to create connection");
        }
    }

    public boolean executeOnNamedConnection(String connName, String sqlStatement) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }

        boolean result;

        try (Statement stmt = conn.createStatement()) {
            result = stmt.execute(sqlStatement);
        } catch (SQLException e) {
            LOGGER.error(FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlStatement, connName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlStatement, connName);
        }

        return result;
    }

    public void executeCommandsOnNamedConnection(String connName, List<String> sqlCommands) {
        for (String command : sqlCommands) {
            executeOnNamedConnection(connName, command);
        }

    }

    public PreparedStatement getPreparedStatementOnNamedConnection(String connName, String preparedSql) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        PreparedStatement result;
        try {
            result = conn.prepareStatement(preparedSql);
        } catch (SQLException e) {
            LOGGER.error("failed executing prepared statement [{}]", preparedSql, e);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "failed executing prepared statement [{}]", preparedSql);
        }

        return result;
    }

    public boolean getAutoCommitOnNamedConnection(String connName) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        boolean result;
        try {
            result = conn.getAutoCommit();
        } catch (SQLException e) {
            LOGGER.error("failed to get autocommit mode", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to get autocommit mode");
        }
        return result;
    }

    public void commitOnNamedConnection(String connName) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        try {
            conn.commit();
        } catch (SQLException e) {
            LOGGER.error("failed to commit", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to commit");
        }
    }

    public void setAutoCommitOnNamedConnection(String connName, boolean newMode) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }

        try {
            conn.setAutoCommit(newMode);
        } catch (SQLException e) {
            LOGGER.error("failed to set autocommit mode", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to set autocommit mode");
        }
    }

    public String executeQueryOnNamedConnection(String connName, String sqlQuery) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }

        StringBuilder sb = new StringBuilder();
        try (Statement stmt = conn.createStatement()) {

            try (ResultSet rs = stmt.executeQuery(sqlQuery)) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                for (int i = 0; i < columnCount; i++) {
                    sb.append("|");
                    sb.append(rsmd.getColumnName(i + 1));
                }
                sb.append("|\n");
                while (rs.next()) {
                    for (int i = 0; i < columnCount; i++) {
                        sb.append("|");
                        sb.append(rs.getString(i + 1));
                    }
                    sb.append("|\n");
                }
            }
        } catch (SQLException e) {
            LOGGER.error("SQLException", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlQuery, connName);
        }

        return sb.toString();
    }

    public void executeStoredProcedureOnNamedConnection(final String connName, final String spName, final List<String> inParams, final List<String> outParams) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }

        List<String> spInParams;
        if (inParams == null) {
            spInParams = new ArrayList<>();
        } else {
            spInParams = inParams;
        }
        int inParamSize = spInParams.size();
        int outParamSize = outParams.size();

        LOGGER.debug("executing stored procedure [{}] with params {}", spName, Objects.toString(spInParams));
        String callableCmd = sqlStringUtil.getPreparedCallableStatementWithParams(spName, inParamSize + outParamSize);
        try (CallableStatement cStmt = conn.prepareCall(callableCmd)) {
            for (int i = 1; i <= inParamSize; i++) {
                cStmt.setString(i, spInParams.get(i - 1));
            }
            for (int i = inParamSize + 1; i <= inParamSize + outParamSize; i++) {
                cStmt.registerOutParameter(i, Types.VARCHAR);
            }
            cStmt.execute();
            for (int i = inParamSize + 1; i <= inParamSize + outParamSize; i++) {
                String outVal = cStmt.getString(i);
                LOGGER.debug("Out value for {} argument is [{}]", i, outVal);
                stateSvc.setStringVar(outParams.get(i - inParamSize - 1), outVal);
            }
        } catch (SQLException e) {
            LOGGER.error("failed to run stored procedure [{}] on named connection [{}]", spName, connName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to run stored procedure [{}] on named connection [{}]", spName, connName);
        }
    }

    public void executePlSqlBlock(final String connName, final String plsqlBlock) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        CallableStatement cStmt;
        try {
            cStmt = conn.prepareCall(plsqlBlock);
            cStmt.execute();
        } catch (SQLException e) {
            LOGGER.error("Failed to execute anonymous block on named connection [{}]", connName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Failed to execute anonymous block on named connection [{}]", connName);
        }
    }

    public Map<String, String> executeSingleRowQueryOnNamedConnection(String connName, String sqlQuery) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        List<String> columnNames = new ArrayList<>();
        Map<String, String> valueMap = new HashMap<>();

        int retry = 0;
        boolean resultsAvailable = false;

        try (Statement stmt = conn.createStatement()) {
            while (retry < 3 && !resultsAvailable) {
                try (ResultSet rs = stmt.executeQuery(sqlQuery)) {
                    while (rs.next()) {
                        ResultSetMetaData rsmd = rs.getMetaData();
                        int columnCount = rsmd.getColumnCount();
                        for (int i = 0; i < columnCount; i++) {
                            columnNames.add(rsmd.getColumnName(i + 1));
                            valueMap.put(columnNames.get(i), rs.getString(i + 1));
                            resultsAvailable = true;
                        }
                    }
                } catch (SQLRecoverableException recover) {
                    LOGGER.error("Ignoring SQL Recoverable Exception");
                }
                retry++;
            }
        } catch (SQLException e) {
            LOGGER.error(FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlQuery, connName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlQuery, connName);
        }

        return valueMap;
    }

    public List<String> getColumnValuesOnNamedConnection(String connName, String sqlQuery, String columnName) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }

        List<String> valueList = new ArrayList<>();
        int retry = 0;
        boolean resultsAvailable = false;

        try (Statement stmt = conn.createStatement()) {
            while (retry < 3 && !resultsAvailable) {
                try (ResultSet rs = stmt.executeQuery(sqlQuery)) {
                    while (rs.next()) {
                        valueList.add(rs.getString(columnName));
                        resultsAvailable = true;
                    }
                } catch (SQLRecoverableException recover) {
                    LOGGER.error("Ignoring SQL Recoverable Exception");
                }
                retry++;
            }
        } catch (SQLException e) {
            LOGGER.error(FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlQuery, connName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlQuery, connName);
        }
        return valueList;
    }

    public void executeSqlQuerySaveBlobToFile(final String connName, final String sqlQuery, final String filename) {
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        try (Statement stmt = conn.createStatement()) {
            try (ResultSet rs = stmt.executeQuery(sqlQuery)) {
                while (rs.next()) {
                    Blob blob = rs.getBlob(1);
                    InputStream inputStream = blob.getBinaryStream();
                    OutputStream outputStream = new FileOutputStream(filename);
                    int bytesRead;
                    byte[] buffer = new byte[BUFFER_SIZE];
                    while ((bytesRead = inputStream.read(buffer)) != -1) {
                        outputStream.write(buffer, 0, bytesRead);
                    }
                    inputStream.close();
                    outputStream.close();
                }
            }
        } catch (IOException | SQLException e) {
            LOGGER.error(FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlQuery, connName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXECUTE_QUERY_ON_NAMED_CONNECTION, sqlQuery, connName);
        }
    }

    public void exportSqlQueryNamedConnectionToCsv(String connectionName, String sqlQuery, String fileFullpath) {
        try (CSVWriter writer = new CSVWriter(new FileWriter(fileFullpath))) {
            final Boolean includeHeaders = true;
            final Boolean applyQuotes = false;
            final Boolean applyTrim = false;
            Connection conn = namedConnections.get(connectionName);
            try (Statement stmt = conn.createStatement()) {
                ResultSet rs = stmt.executeQuery(sqlQuery);
                writer.writeAll(rs, includeHeaders, applyTrim, applyQuotes);
                LOGGER.debug("Table data exported to CSV file [{}]", fileFullpath);
            }
        } catch (SQLException | IOException e) {
            LOGGER.error(FAILED_TO_EXPORT_SQL_QUERY_RESULTS_TO_CSV_FILE, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXPORT_SQL_QUERY_RESULTS_TO_CSV_FILE);
        }
    }

    public void exportSqlQueryNamedConnectionToCsvWithFixedDigitNums(String connectionName, String sqlQuery, String fileFullpath, int outputScale) {
        try (CSVWriter writer = new CSVWriter(new FileWriter(fileFullpath))) {
            Connection conn = namedConnections.get(connectionName);
            Set<Integer> numericCols = new HashSet<>();
            try (Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sqlQuery)) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                String[] nextRow = new String[columnCount];
                // process header
                for (int i = 0; i < columnCount; i++) {
                    int colNum = i + 1;
                    String columnName = rsmd.getColumnName(colNum);
                    String columnTypeName = rsmd.getColumnTypeName(colNum);
                    if (NUMERIC.equalsIgnoreCase(columnTypeName)) {
                        numericCols.add(colNum);
                    }
                    nextRow[i] = columnName;
                }
                // writing the header
                writer.writeNext(nextRow);

                // process the rows
                while (rs.next()) {
                    for (int i = 0; i < columnCount; i++) {
                        int colNum = i + 1;
                        if (numericCols.contains(colNum)) {
                            BigDecimal bd = rs.getBigDecimal(colNum);
                            nextRow[i] = bd != null ? bd.setScale(outputScale, RoundingMode.HALF_UP).toPlainString() : null;
                        } else {
                            nextRow[i] = rs.getString(colNum);
                        }
                    }
                    writer.writeNext(nextRow);
                }
            }
        } catch (SQLException | IOException e) {
            LOGGER.error(FAILED_TO_EXPORT_SQL_QUERY_RESULTS_TO_CSV_FILE, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXPORT_SQL_QUERY_RESULTS_TO_CSV_FILE);
        }
    }

    public void exportSqlQueryNamedConnectionToExcel(String connectionName, String sqlQuery, String fileFullpath) {
        try (CSVWriter writer = new CSVWriter(new FileWriter(fileFullpath))) {
            Boolean includeHeaders = true;
            Connection conn = namedConnections.get(connectionName);
            try (Statement stmt = conn.createStatement()) {
                ResultSet rs = stmt.executeQuery(sqlQuery);
                writer.writeAll(rs, includeHeaders);
            }
        } catch (SQLException | IOException e) {
            LOGGER.error(FAILED_TO_EXPORT_SQL_QUERY_RESULTS_TO_CSV_FILE, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, FAILED_TO_EXPORT_SQL_QUERY_RESULTS_TO_CSV_FILE);
        }
    }

    public List<ColumnMetadata> getColumnMetadataOnNamedConnection(String connectionName, String tableName) {
        Connection conn = namedConnections.get(connectionName);
        if (conn == null) {
            LOGGER.error("connection [{}] is null, probably it has not been created yet", connectionName);
            throw new CartException(CartExceptionType.UNSATISFIED_IMPLICIT_ASSUMPTION, "connection [{}] is null, probably it has not been created yet", connectionName);
        }

        List<ColumnMetadata> result = new ArrayList<>();

        try (Statement stmt = conn.createStatement()) {

            try (ResultSet rs = stmt.executeQuery(String.format("SELECT TOP 1 * FROM %s", tableName))) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                for (int i = 1; i <= columnCount; i++) {
                    result.add(new ColumnMetadata(rsmd.getColumnName(i), rsmd.getColumnTypeName(i), rsmd.getPrecision(i), rsmd.getScale(i)));
                }
            }
        } catch (SQLException e) {
            LOGGER.error("failed to get columns metadata on table [{}]", tableName, e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to get columns metadata on table [{}]", tableName);
        }
        return result;
    }

    public void createTableWithHeader(String connName, List<String> columns, String tableName) {
        this.executeOnNamedConnection(connName, "IF OBJECT_ID('" + tableName + "', 'U') IS NOT NULL DROP TABLE " + tableName);
        String dataType = "VARCHAR(MAX)";
        StringBuilder sb = new StringBuilder("CREATE TABLE ").append(tableName).append(" (");
        for (String column : columns) {
            sb.append(column).append(" ").append(dataType).append(",");
        }
        this.executeOnNamedConnection(connName, sb.toString().substring(0, sb.toString().length() - 1) + ")");
    }

    public void loadFlatFile(String connectionName, String file, String tableName, boolean truncateBeforeLoad, char separator) {
        Connection connection = namedConnections.get(connectionName);
        try {
            if (null == connection) {
                LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connectionName);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connectionName);
            }

            connection.setAutoCommit(false);

            String[] headerRow;
            try (CSVReader csvReader = new CSVReader(new FileReader(file), separator)) {
                headerRow = csvReader.readNext();
                if (null == headerRow) {
                    LOGGER.error("No columns defined in given file, Please check the file format.");
                    throw new CartException(CartExceptionType.PROCESSING_FAILED, "No columns defined in given file, Please check the file format.");
                }

                String questionMarks = StringUtils.repeat("?,", headerRow.length);
                questionMarks = (String) questionMarks.subSequence(0, questionMarks.length() - 1);

                String query = SQL_INSERT.replaceFirst(TABLE_REGEX, tableName);
                query = query.replaceFirst(KEYS_REGEX, StringUtils.join(headerRow, separator));
                query = query.replaceFirst(VALUES_REGEX, questionMarks);

                String[] nextLine;

                PreparedStatement ps = connection.prepareStatement(query);

                if (truncateBeforeLoad) {
                    connection.createStatement().execute("DELETE FROM " + tableName);
                }

                int count = 0;
                while ((nextLine = csvReader.readNext()) != null) {
                    int index = 1;
                    for (String string : nextLine) {
                        ps.setString(index++, string);
                    }
                    ps.addBatch();
                    if (++count % BATCH_SIZE == 0) {
                        ps.executeBatch();
                    }
                }
                ps.executeBatch(); // insert remaining records
            }
            connection.commit();
        } catch (Exception e) {
            LOGGER.error("Error occured while loading data from file to database.", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Error occured while loading data from file to database.");
        }
    }

    public <T> List<T> executeQueryOnNamedConnectionLoadResultIntoObject(final String connName, String sqlQuery, Class<T> type) {
        List<T> list = new ArrayList<T>();
        Connection conn = namedConnections.get(connName);
        if (conn == null) {
            LOGGER.error(NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, NAMED_CONNECTION_IS_NULL_PROBABLY_IT_HAS_NOT_BEEN_CREATED, connName);
        }
        try (Statement stmt = conn.createStatement()) {
            try (ResultSet rs = stmt.executeQuery(sqlQuery)) {
                while (rs.next()) {
                    T t = type.newInstance();
                    this.loadResultSetIntoObject(rs, t);
                    list.add(t);
                }
            }
            return list;
        } catch (IllegalAccessException | SQLException | InstantiationException e) {
            LOGGER.error("Exception occurred while processing Result set into Object");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred while processing Result set into Object");
        }
    }

    private void loadResultSetIntoObject(ResultSet resultSet, Object object) {
        Class<?> aClass = object.getClass();
        try {
            for (Field field : aClass.getDeclaredFields()) {
                field.setAccessible(true);
                DBTable column = field.getAnnotation(DBTable.class);
                Object value = resultSet.getObject(column.columnName());
                Class<?> type = field.getType();
                if (this.isPrimitive(type)) {
                    Class<?> boxed = this.boxPrimitiveClass(type);
                    value = boxed.cast(value);
                }
                field.set(object, value);
            }
        } catch (Exception e) {
            LOGGER.error("Exception occurred while loading Result set into Object", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Exception occurred while loading Result set into Object");
        }
    }

    private boolean isPrimitive(Class<?> type) {
        return (type == int.class || type == long.class || type == double.class || type == float.class
                || type == boolean.class || type == byte.class || type == char.class || type == short.class);
    }

    private Class<?> boxPrimitiveClass(Class<?> type) {
        if (type == int.class) {
            return Integer.class;
        } else if (type == long.class) {
            return Long.class;
        } else if (type == double.class) {
            return Double.class;
        } else if (type == float.class) {
            return Float.class;
        } else if (type == boolean.class) {
            return Boolean.class;
        } else if (type == byte.class) {
            return Byte.class;
        } else if (type == char.class) {
            return Character.class;
        } else if (type == short.class) {
            return Short.class;
        } else {
            LOGGER.error("class '" + type.getName() + "' is not a primitive");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "class '" + type.getName() + "' is not a primitive");
        }
    }

}
