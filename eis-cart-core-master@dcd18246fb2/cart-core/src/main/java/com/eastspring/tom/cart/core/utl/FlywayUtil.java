package com.eastspring.tom.cart.core.utl;

import org.flywaydb.core.Flyway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class FlywayUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(FlywayUtil.class);

    @Autowired
    private Flyway flyway;

    public void setDataSource(String jdbcUrl, String username, String password) {
        flyway.setDataSource(jdbcUrl, username, password);
    }

    public void baseline() {
        LOGGER.debug("establishing baseline");
        flyway.baseline();
    }

    public void migrate() {
        LOGGER.debug("migrating database");
        flyway.migrate();
    }
}
