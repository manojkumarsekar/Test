package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

public class CsvStagingSvc {
    private static final Logger LOGGER = LoggerFactory.getLogger(CsvStagingSvc.class);

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private JdbcSvc jdbcSvc;

    public void loadCsvToDb(String csvFullpath, String tableName, char separatorChar) {
        jdbcSvc.createNamedConnection(JdbcSvc.INTERNAL_DB_CSV_STAGING);
        String csvCreateAndLoadQuery = String.format("CREATE TABLE %s AS SELECT * FROM CSVREAD('%s', null, 'charset=UTF-8 fieldSeparator=%c')", tableName, csvFullpath, separatorChar);
        jdbcSvc.executeOnNamedConnection(JdbcSvc.INTERNAL_DB_CSV_STAGING, csvCreateAndLoadQuery);
    }

    public void dumpTableContent(String tableName) {
        String selectQuery = String.format("SELECT * FROM %s", tableName);
        LOGGER.debug("selectQuery: [{}]", selectQuery);
        String result = jdbcSvc.executeQueryOnNamedConnection(JdbcSvc.INTERNAL_DB_CSV_STAGING, selectQuery);
        LOGGER.debug("result:\n{}", result);
        fileDirUtil.writeStringToFile("c:/temp/last-result.txt", result);
    }

}

