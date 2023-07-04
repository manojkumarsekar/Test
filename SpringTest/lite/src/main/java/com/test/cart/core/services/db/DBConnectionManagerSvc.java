package com.eastspring.qa.cart.core.services.db;

import com.eastspring.qa.cart.core.exceptions.CartException;
import com.eastspring.qa.cart.core.exceptions.CartExceptionType;
import com.eastspring.qa.cart.core.report.CartLogger;
import com.eastspring.qa.cart.core.configmanagers.AppConfigManager;
import org.springframework.beans.factory.annotation.Autowired;

import java.sql.*;
import java.util.concurrent.ConcurrentHashMap;


public class DBConnectionManagerSvc {
    private final ConcurrentHashMap<String, Connection> namedConnections = new ConcurrentHashMap<>();

    private final JdbcConnSvc jdbcConnSvc = new JdbcConnSvc();

    @Autowired
    protected AppConfigManager appConfigManager;

    protected boolean isConnectionEstablished(final String connectionName) {
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

    protected Connection getConnection(final String connectionName) {
        return namedConnections.get(connectionName);
    }

    public Connection getNullOrConnection(String connectionName) {
        Connection connection = null;
        try {
            if (isConnectionEstablished(connectionName)) connection = getConnection(connectionName);
        } catch (CartException ignored) {
        }
        return connection;
    }

    protected void createJDBCConnection(final String configPrefix) {
        CartLogger.debug("Creating Named JDBC Connection [{}]", configPrefix);
        String connectionType = appConfigManager.get(configPrefix + ".type");
        if (!"jdbc_a".equalsIgnoreCase(connectionType)) {
            throw new CartException(CartExceptionType.INVALID_CONFIG, "unsupported connection type [{}]", connectionType);
        }
        String jdbcUrl = appConfigManager.get(configPrefix + ".jdbc.url");
        String jdbcUser = appConfigManager.get(configPrefix + ".jdbc.user");
        String jdbcEncryptedPass = appConfigManager.get(configPrefix + ".jdbc.encrypted.password");
        String jdbcDescription = appConfigManager.get(configPrefix + ".jdbc.description");
        Connection connection = jdbcConnSvc.createNamedConnection(jdbcUrl, jdbcUser, jdbcEncryptedPass, jdbcDescription);
        namedConnections.put(configPrefix, connection);
    }

    protected void closeConnection(final String connectionName) {
        if (isConnectionEstablished(connectionName)) {
            jdbcConnSvc.closeNamedConnection(namedConnections.get(connectionName));
            namedConnections.remove(connectionName);
        }
    }

    public void closeAllConnections() {
        namedConnections.forEach((name, connection) -> {
            try {
                connection.close();
            } catch (SQLException ignored) {
            }
        });
        namedConnections.clear();
    }

}