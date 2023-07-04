package com.eastspring.qa.cart.core.services.db;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.utils.secret.SecretUtil;

import java.sql.*;


class JdbcConnSvc {

    private final String className = "oracle.jdbc.driver.OracleDriver";

    private static final String JDBC_DRIVER_CLASS_NOT_FOUND = "jdbc driver class [{}] not found in classpath; either provide the correct driver class name or provide the driver in the classpath";


    public Connection createNamedConnection(String jdbcUrl, String jdbcUser, String jdbcEncryptedPass, String jdbcDescription) {
        return createNamedConnection(this.className, jdbcUrl, jdbcUser, jdbcEncryptedPass, jdbcDescription);
    }

    public Connection createNamedConnection(String jdbcClass, String jdbcUrl, String jdbcUser, String jdbcEncryptedPass, String jdbcDescription) {
        CartLogger.debug("  jdbcUrl: [{}]", jdbcUrl);
        CartLogger.debug("  jdbcClass: [{}]", jdbcClass);
        CartLogger.debug("  jdbcUser: [{}]", jdbcUser);
        CartLogger.debug("  jdbcPass: ********", jdbcEncryptedPass);
        CartLogger.debug("  jdbcDescription: [{}]", jdbcDescription);

        String decryptedPassword = SecretUtil.decrypt(jdbcEncryptedPass);

        try {
            Class.forName(jdbcClass);
        } catch (ClassNotFoundException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, JDBC_DRIVER_CLASS_NOT_FOUND, jdbcClass);
        }
        try {
            return DriverManager.getConnection(jdbcUrl, jdbcUser, decryptedPassword);
        } catch (SQLException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed to create connection");
        }
    }

    void closeNamedConnection(final Connection connection) {
        try {
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


}