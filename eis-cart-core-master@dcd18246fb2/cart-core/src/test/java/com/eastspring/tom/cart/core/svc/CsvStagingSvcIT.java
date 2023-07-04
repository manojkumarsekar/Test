package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class CsvStagingSvcIT {
    private static final Logger LOGGER = LoggerFactory.getLogger(CsvStagingSvcIT.class);

    @Autowired
    private CsvStagingSvc csvStagingSvc;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(CsvStagingSvcIT.class);
    }

    @Test
    public void loadPsvFileToDb() throws Exception {
        String baseDir = "c:/tomwork/curated/2017_01";

//        String tableName = "PortfolioMaster";
//        csvStagingSvc.loadCsvToDb(baseDir + "/PortfolioMaster.psv", tableName, '|');
//        csvStagingSvc.dumpTableContent(tableName);
//
//        String kdriveFile = baseDir + "/KDrive_EQ_Security_Raw_20180117105031653.psv";
//        String kdriveTableName = "KDrive_EQ_Security_Raw_20180117105031653";
//        csvStagingSvc.loadCsvToDb(kdriveFile, kdriveTableName, '|');
//        csvStagingSvc.dumpTableContent(kdriveTableName);

//        String dnaFile = baseDir + "/DNA_EQ_Security_Raw_20180117105031653.psv";
//        String dnaTableName = "DNA_EQ_Security_Raw_20180117105031653";
//        csvStagingSvc.loadCsvToDb(dnaFile, dnaTableName, '|');
//        csvStagingSvc.dumpTableContent(dnaTableName);

        String kdriveFile = baseDir + "/KDrive_EQ_Security_Raw_20180117105031653.psv";
        String kdriveTableName = "KDrive_EQ_Security_Raw_20180117105031653";
        csvStagingSvc.loadCsvToDb(kdriveFile, kdriveTableName, '|');
        csvStagingSvc.dumpTableContent(kdriveTableName);
    }
}
