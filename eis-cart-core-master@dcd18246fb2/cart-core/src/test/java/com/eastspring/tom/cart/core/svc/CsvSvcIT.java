package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.mdl.ComparisonColPairMetadata;
import com.eastspring.tom.cart.core.mdl.CsvProfile;
import com.eastspring.tom.cart.core.mdl.KeyMetadata;
import com.eastspring.tom.cart.core.mdl.SourceTargetMatch;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.cst.EncodingConstants;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.List;

import static com.eastspring.tom.cart.core.svc.JdbcSvc.INTERNAL_DB_RECON;


@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class CsvSvcIT {
    public static final String RECON_TSV_UTF16_SAMPLE_CSV = "recon/tsv-utf16-sample.csv";
    public static final String RECON_CSV_UTF8_SAMPLE_CSV = "recon/csv-utf8-sample.csv";
    public static final String SOURCE_MONIKER_CPR = "CPR";
    public static final String TARGET_MONIKER_BNP = "BNP";

    @Autowired
    private CsvSvc csvSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private JdbcSvc jdbcSvc;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(CsvSvcIT.class);
    }

    @Test
    public void testGetComparisonColPairMetadataFromHeader() throws Exception {
        String csvFileFullpath = fileDirUtil.getMavenTestResourcesPath(RECON_TSV_UTF16_SAMPLE_CSV);
        CsvProfile csvProfile = csvSvc.profileCsvCols(csvFileFullpath, EncodingConstants.UTF_16, '\t');
        List<ComparisonColPairMetadata> metadataList = csvSvc.getComparisonColPairMetadataFromHeader(csvProfile, new SourceTargetMatch(SOURCE_MONIKER_CPR, TARGET_MONIKER_BNP, ReconciliationSvc.MATCH_NAME), ReconciliationSvc.MATCH_WITH_TOLERANCE_NAME);
        System.out.println(metadataList);
    }

    @Test
    public void testProfileCsvCols_tsv_utf16() throws Exception {
        String fullpath = fileDirUtil.getMavenTestResourcesPath(RECON_TSV_UTF16_SAMPLE_CSV);
        CsvProfile csvProfile = csvSvc.profileCsvCols(fullpath, EncodingConstants.UTF_16, '\t');
        Assert.assertNotNull(csvProfile);
        Assert.assertTrue(csvProfile.isHasHeader());
        Assert.assertEquals(5, csvProfile.getRowCount());
        String[] headers = csvProfile.getHeaders();
        Assert.assertNotNull(headers);
        Assert.assertEquals(91, headers.length);
        System.out.println(csvProfile);

        Assert.assertEquals("Fund ID", headers[0]);
        Assert.assertEquals("Asset Class", headers[1]);
        Assert.assertEquals("Fund Code", headers[2]);
        Assert.assertEquals("Accounting Code", headers[3]);
        Assert.assertEquals("Fund Name", headers[4]);
        Assert.assertEquals("Benchmark Name", headers[5]);
        Assert.assertEquals("Currency", headers[6]);
        Assert.assertEquals("Value Date", headers[7]);
        Assert.assertEquals("ShareClass AUM (M.)", headers[8]);
        Assert.assertEquals("1M Fund Net Return", headers[9]);
        Assert.assertEquals("1M Fund Gross Return", headers[10]);
        Assert.assertEquals("1M Fund Pri. Benchmark Return", headers[11]);
        Assert.assertEquals("1M Fund Net Relative Return", headers[12]);
        Assert.assertEquals("1M Fund Gross Relative Return", headers[13]);
        Assert.assertEquals("3M Date", headers[14]);
        Assert.assertEquals("3M Fund Net Return", headers[15]);
        Assert.assertEquals("3M Fund Gross Return", headers[16]);
        Assert.assertEquals("3M Fund Pri. Benchmark Return", headers[17]);
        Assert.assertEquals("3M Fund Net Relative Return", headers[18]);
        Assert.assertEquals("3M Fund Gross Relative Return", headers[19]);
        Assert.assertEquals("6M Date", headers[20]);
        Assert.assertEquals("6M Fund Net Return", headers[21]);
        Assert.assertEquals("6M Fund Gross Return", headers[22]);
        Assert.assertEquals("6M Fund Pri. Benchmark Return", headers[23]);
        Assert.assertEquals("6M Fund Net Relative Return", headers[24]);
        Assert.assertEquals("6M Fund Gross Relative Return", headers[25]);
        Assert.assertEquals("FYTD Date", headers[26]);
        Assert.assertEquals("FYTD Fund Net Return", headers[27]);
        Assert.assertEquals("FYTD Fund Gross Return", headers[28]);
        Assert.assertEquals("FYTD Fund Pri. Benchmark Return", headers[29]);
        Assert.assertEquals("FYTD Fund Net Relative Return", headers[30]);
        Assert.assertEquals("FYTD Fund Gross Relative Return", headers[31]);
        Assert.assertEquals("YTD Date", headers[32]);
        Assert.assertEquals("YTD Fund Net Return", headers[33]);
        Assert.assertEquals("YTD Fund Gross Return", headers[34]);
        Assert.assertEquals("YTD Fund Pri. Benchmark Return", headers[35]);
        Assert.assertEquals("YTD Fund Net Relative Return", headers[36]);
        Assert.assertEquals("YTD Fund Gross Relative Return", headers[37]);
        Assert.assertEquals("1Y Date", headers[38]);
        Assert.assertEquals("1Y Fund Net Return", headers[39]);
        Assert.assertEquals("1Y Fund Gross Return", headers[40]);
        Assert.assertEquals("1Y Fund Pri. Benchmark Return", headers[41]);
        Assert.assertEquals("1Y Fund Net Relative Return", headers[42]);
        Assert.assertEquals("1Y Fund Gross Relative Return", headers[43]);
        Assert.assertEquals("2Y Date", headers[44]);
        Assert.assertEquals("2Y Fund Net Return (Ann.)", headers[45]);
        Assert.assertEquals("2Y Fund Gross Return (Ann.)", headers[46]);
        Assert.assertEquals("2Y Fund Pri. Benchmark Return (Ann.)", headers[47]);
        Assert.assertEquals("2Y Fund Net Relative Return (Ann.)", headers[48]);
        Assert.assertEquals("2Y Fund Gross Relative Return (Ann.)", headers[49]);
        Assert.assertEquals("3Y Date", headers[50]);
        Assert.assertEquals("3Y Fund Net Return (Ann.)", headers[51]);
        Assert.assertEquals("3Y Fund Gross Return (Ann.)", headers[52]);
        Assert.assertEquals("3Y Fund Pri. Benchmark Return (Ann.)", headers[53]);
        Assert.assertEquals("3Y Fund Net Relative Return (Ann.)", headers[54]);
        Assert.assertEquals("3Y Fund Gross Relative Return (Ann.)", headers[55]);
        Assert.assertEquals("4Y Date", headers[56]);
        Assert.assertEquals("4Y Fund Net Return (Ann.)", headers[57]);
        Assert.assertEquals("4Y Fund Gross Return (Ann.)", headers[58]);
        Assert.assertEquals("4Y Fund Pri. Benchmark Return (Ann.)", headers[59]);
        Assert.assertEquals("4Y Fund Net Relative Return (Ann.)", headers[60]);
        Assert.assertEquals("4Y Fund Gross Relative Return (Ann.)", headers[61]);
        Assert.assertEquals("5Y Date", headers[62]);
        Assert.assertEquals("5Y Fund Net Return (Ann.)", headers[63]);
        Assert.assertEquals("5Y Fund Gross Return (Ann.)", headers[64]);
        Assert.assertEquals("5Y Fund Pri. Benchmark Return (Ann.)", headers[65]);
        Assert.assertEquals("5Y Fund Net Relative Return (Ann.)", headers[66]);
        Assert.assertEquals("5Y Fund Gross Relative Return (Ann.)", headers[67]);
        Assert.assertEquals("7Y Date", headers[68]);
        Assert.assertEquals("7Y Fund Net Return (Ann.)", headers[69]);
        Assert.assertEquals("7Y Fund Gross Return (Ann.)", headers[70]);
        Assert.assertEquals("7Y Fund Pri. Benchmark Return (Ann.)", headers[71]);
        Assert.assertEquals("7Y Fund Net Relative Return (Ann.)", headers[72]);
        Assert.assertEquals("7Y Fund Gross Relative Return (Ann.)", headers[73]);
        Assert.assertEquals("10Y Date", headers[74]);
        Assert.assertEquals("10Y Fund Net Return (Ann.)", headers[75]);
        Assert.assertEquals("10Y Fund Gross Return (Ann.)", headers[76]);
        Assert.assertEquals("10Y Fund Pri. Benchmark Return (Ann.)", headers[77]);
        Assert.assertEquals("10Y Fund Net Relative Return (Ann.)", headers[78]);
        Assert.assertEquals("10Y Fund Gross Relative Return (Ann.)", headers[79]);
        Assert.assertEquals("SI Date", headers[80]);
        Assert.assertEquals("SI Fund Net Return", headers[81]);
        Assert.assertEquals("SI Fund Gross Return", headers[82]);
        Assert.assertEquals("SI Fund Pri. Benchmark Return", headers[83]);
        Assert.assertEquals("SI Fund Net Relative Return", headers[84]);
        Assert.assertEquals("SI Fund Gross Relative Return", headers[85]);
        Assert.assertEquals("SI Fund Net Return (Ann.)", headers[86]);
        Assert.assertEquals("SI Fund Gross Return (Ann.)", headers[87]);
        Assert.assertEquals("SI Fund Pri. Benchmark Return (Ann.)", headers[88]);
        Assert.assertEquals("SI Fund Net Relative Return (Ann.)", headers[89]);
        Assert.assertEquals("SI Fund Gross Relative Return (Ann.)", headers[90]);
    }

    @Test
    public void testProfileCsvCols_csv_utf8() throws Exception {
        String fullpath = fileDirUtil.getMavenTestResourcesPath(RECON_CSV_UTF8_SAMPLE_CSV);
        CsvProfile csvProfile = csvSvc.profileCsvCols(fullpath, EncodingConstants.UTF_8, ',');
        Assert.assertNotNull(csvProfile);
        Assert.assertTrue(csvProfile.isHasHeader());
        Assert.assertEquals(18, csvProfile.getRowCount());
        String[] headers = csvProfile.getHeaders();
        Assert.assertNotNull(headers);
        Assert.assertEquals(84, headers.length);
        Assert.assertEquals("Entity Id", headers[0]);
        Assert.assertEquals("Fund Name", headers[1]);
        Assert.assertEquals("Official Benchmark Name", headers[2]);
        Assert.assertEquals("Fund Mgt House", headers[3]);
        Assert.assertEquals("Asset Class", headers[4]);
        Assert.assertEquals("Investment Team / Entity", headers[5]);
        Assert.assertEquals("Fund Manager", headers[6]);
        Assert.assertEquals("Fund/ Client Type", headers[7]);
        Assert.assertEquals("Client Name", headers[8]);
        Assert.assertEquals("KPI Measure", headers[9]);
        Assert.assertEquals("Aggregate Fund Tag", headers[10]);
        Assert.assertEquals("FUM $ Base in mio", headers[11]);
        Assert.assertEquals("FUM $ USD in mio", headers[12]);
        Assert.assertEquals("Perf Ccy", headers[13]);
        Assert.assertEquals("Inception Date", headers[14]);
        Assert.assertEquals("Term", headers[15]);
        Assert.assertEquals("Return Source", headers[16]);
        Assert.assertEquals("Return Type", headers[17]);
        Assert.assertEquals("Status", headers[18]);
        Assert.assertEquals("Fund 1M", headers[19]);
        Assert.assertEquals("Official BM 1M", headers[20]);
        Assert.assertEquals("Rel 1M Eagle", headers[21]);
        Assert.assertEquals("Internal BM 1M", headers[22]);
        Assert.assertEquals("Rel 1M (Internal)", headers[23]);
        Assert.assertEquals("1M Ptl", headers[24]);
        Assert.assertEquals("Fund 3M", headers[25]);
        Assert.assertEquals("Official BM 3M", headers[26]);
        Assert.assertEquals("Rel 3M Eagle", headers[27]);
        Assert.assertEquals("Internal BM 3M", headers[28]);
        Assert.assertEquals("Rel 3M (Internal)", headers[29]);
        Assert.assertEquals("3M Ptl", headers[30]);
        Assert.assertEquals("6M", headers[31]);
        Assert.assertEquals("Official BM 6M", headers[32]);
        Assert.assertEquals("Rel 6M Eagle", headers[33]);
        Assert.assertEquals("Internal BM 6M", headers[34]);
        Assert.assertEquals("Rel 6M (Internal)", headers[35]);
        Assert.assertEquals("6M ptl", headers[36]);
        Assert.assertEquals("Fund YTD", headers[37]);
        Assert.assertEquals("Official BM YTD", headers[38]);
        Assert.assertEquals("Rel YTD Eagle", headers[39]);
        Assert.assertEquals("Internal-BM YTD", headers[40]);
        Assert.assertEquals("Rel YTD (Internal)", headers[41]);
        Assert.assertEquals("YTD Ptl", headers[42]);
        Assert.assertEquals("Fund 1Y", headers[43]);
        Assert.assertEquals("Official BM 1Y", headers[44]);
        Assert.assertEquals("Rel 1Y Eagle", headers[45]);
        Assert.assertEquals("Internal BM 1Y", headers[46]);
        Assert.assertEquals("Rel 1Y (Internal)", headers[47]);
        Assert.assertEquals("1Y Ptl", headers[48]);
        Assert.assertEquals("2Y PA", headers[49]);
        Assert.assertEquals("Official BM 2Y PA", headers[50]);
        Assert.assertEquals("Rel 2Y pa Eagle", headers[51]);
        Assert.assertEquals("Internal BM 2Y PA", headers[52]);
        Assert.assertEquals("Rel 2Y pa (Internal)", headers[53]);
        Assert.assertEquals("2Y p.a. Ptl", headers[54]);
        Assert.assertEquals("Fund 3Y pa", headers[55]);
        Assert.assertEquals("Official BM 3Y pa", headers[56]);
        Assert.assertEquals("Rel 3Y pa Eagle", headers[57]);
        Assert.assertEquals("Internal BM 3Y PA", headers[58]);
        Assert.assertEquals("Rel 3Y pa (Internal)", headers[59]);
        Assert.assertEquals("3Y p.a. Ptl", headers[60]);
        Assert.assertEquals("4Y PA", headers[61]);
        Assert.assertEquals("Official BM 4Y PA", headers[62]);
        Assert.assertEquals("Rel 4Y pa(Official)", headers[63]);
        Assert.assertEquals("Internal BM 4Y PA", headers[64]);
        Assert.assertEquals("Rel 4Y pa(Internal)", headers[65]);
        Assert.assertEquals("Fund 5Y pa", headers[66]);
        Assert.assertEquals("Official BM 5Y pa", headers[67]);
        Assert.assertEquals("Rel 5Y pa Eagle", headers[68]);
        Assert.assertEquals("Internal BM 5Y PA", headers[69]);
        Assert.assertEquals("Rel 5Y pa(Internal)", headers[70]);
        Assert.assertEquals("5Y p.a. Ptl", headers[71]);
        Assert.assertEquals("10Y PA", headers[72]);
        Assert.assertEquals("Official BM 10Y PA", headers[73]);
        Assert.assertEquals("Rel 10Y pa(Official)", headers[74]);
        Assert.assertEquals("Internal BM 10Y PA", headers[75]);
        Assert.assertEquals("Rel 10Y pa(Internal)", headers[76]);
        Assert.assertEquals("10Y p.a. Ptl", headers[77]);
        Assert.assertEquals("Fund SI pa", headers[78]);
        Assert.assertEquals("Official BM SI pa", headers[79]);
        Assert.assertEquals("Rel SI pa", headers[80]);
        Assert.assertEquals("Internal BM SI PA", headers[81]);
        Assert.assertEquals("Rel SI pa (Internal)", headers[82]);
        Assert.assertEquals("SI p.a. Ptl", headers[83]);
    }

    @Test
    public void testGetKeyMetadataFromHeader_noKeys() throws Exception {
        String csvFileFullpath = fileDirUtil.getMavenTestResourcesPath("recon/csv-utf8-sample.csv");
        CsvProfile csvProfile = csvSvc.profileCsvCols(csvFileFullpath, EncodingConstants.UTF_8, ',');
        List<KeyMetadata> metadataList = csvSvc.getKeyMetadataFromHeader(csvProfile, ReconciliationSvc.KEY);
        Assert.assertNotNull(metadataList);
        Assert.assertEquals(0, metadataList.size());
    }

    @Test
    public void testGetKeyMetadataFromHeader_succcessWithKeys() throws Exception {
        String csvFileFullpath = fileDirUtil.getMavenTestResourcesPath("recon/csv-utf8-withKeys.csv");
        CsvProfile csvProfile = csvSvc.profileCsvCols(csvFileFullpath, EncodingConstants.UTF_8, ',');
        List<KeyMetadata> metadataList = csvSvc.getKeyMetadataFromHeader(csvProfile, ReconciliationSvc.KEY);
        System.out.println(metadataList);
        Assert.assertNotNull(metadataList);
        Assert.assertEquals(3, metadataList.size());
        Assert.assertEquals(0, metadataList.get(0).getColumnIndex());
        Assert.assertEquals(1, metadataList.get(1).getColumnIndex());
        Assert.assertEquals(2, metadataList.get(2).getColumnIndex());
    }

    @Test
    public void testGetKeyMetadataFromHeader_succcessWithKeysScrambledOrder() throws Exception {
        String csvFileFullpath = fileDirUtil.getMavenTestResourcesPath("recon/csv-utf8-withKeysScrambledOrder.csv");
        CsvProfile csvProfile = csvSvc.profileCsvCols(csvFileFullpath, EncodingConstants.UTF_8, ',');
        List<KeyMetadata> metadataList = csvSvc.getKeyMetadataFromHeader(csvProfile, ReconciliationSvc.KEY);
        System.out.println(metadataList);
        Assert.assertNotNull(metadataList);
        Assert.assertEquals(3, metadataList.size());
        Assert.assertEquals(3, metadataList.get(0).getColumnIndex());
        Assert.assertEquals(8, metadataList.get(1).getColumnIndex());
        Assert.assertEquals(16, metadataList.get(2).getColumnIndex());
    }


    //    @Test
    public void testBnpDxportTableViewToCsvFile() throws Exception {
        String connectionName = INTERNAL_DB_RECON;
        String mismatchView = "dbo.vwMismatch_7";
        String fileFullpath = "c:/temp/mismatch.csv";
        jdbcSvc.createNamedConnection(INTERNAL_DB_RECON);
        csvSvc.exportTableViewToCsvFileWithFixedDigitNums(connectionName, mismatchView, fileFullpath, 4);
    }


    @Test
    public void testProfileCsvCols_bnpDnaFile() throws Exception {
//        String fullpath = fileDirUtil.getMavenTestResourcesPath(RECON_TSV_UTF16_SAMPLE_CSV);
        String fullpath = "i:/DNA_L3_PocketLevel.csv";
        CsvProfile csvProfile = csvSvc.profileCsvCols(fullpath, EncodingConstants.UTF_16, '\t');
        System.out.println(csvProfile);
    }
    }
