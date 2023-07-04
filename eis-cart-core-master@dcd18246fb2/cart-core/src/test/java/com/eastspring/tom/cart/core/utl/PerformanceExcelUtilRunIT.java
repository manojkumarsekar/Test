package com.eastspring.tom.cart.core.utl;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.mdl.HeaderMetadata;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.List;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreUtlConfig.class})
public class PerformanceExcelUtilRunIT {
    @Autowired
    private PerformanceExcelUtil excelUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(PerformanceExcelUtilRunIT.class);
    }

    @Test
    public void testExtractHeaderMetadataFromFileH_successfulNineteenColsHeaders() throws Exception {
        String filename = fileDirUtil.getTestResourcesPath(getClass(),"/excel/PositionHeaders001.xls");
        HeaderMetadata headerMetadata = excelUtil.extractHeaderMetadataFromFileH(filename);

        Assert.assertNotNull(headerMetadata);
        Assert.assertTrue(headerMetadata.isHasHeaderRow());
        Assert.assertEquals(19, headerMetadata.getHeaderCount());
        List<String> headerNames = headerMetadata.getHeaderNames();
        Assert.assertNotNull(headerNames);
        Assert.assertEquals("CLIENT_ID", headerNames.get(0));
        Assert.assertEquals("TRADE_ID", headerNames.get(1));
        Assert.assertEquals("PORTFOLIO", headerNames.get(2));
        Assert.assertEquals("SM_SEC_GROUP", headerNames.get(3));
        Assert.assertEquals("SM_SEC_TYPE", headerNames.get(4));
        Assert.assertEquals("POS_DATE", headerNames.get(5));
        Assert.assertEquals("TRD_TRADE_DATE", headerNames.get(6));
        Assert.assertEquals("TRD_SETTLE_DATE", headerNames.get(7));
        Assert.assertEquals("MATURITY", headerNames.get(8));
        Assert.assertEquals("TICKER", headerNames.get(9));
        Assert.assertEquals("POS_FACE", headerNames.get(10));
        Assert.assertEquals("POS_CUR_PAR", headerNames.get(11));
        Assert.assertEquals("CURRENCY", headerNames.get(12));
        Assert.assertEquals("TRD_PRINCIPAL", headerNames.get(13));
        Assert.assertEquals("TRD_COUNTERPARTY", headerNames.get(14));
        Assert.assertEquals("DESC_INSTMT", headerNames.get(15));
        Assert.assertEquals("NDF_TYPE", headerNames.get(16));
        Assert.assertEquals("TRD_CURRENCY", headerNames.get(17));
        Assert.assertEquals("ANNOUNCE_DT", headerNames.get(18));
    }


    @Test(expected = IllegalStateException.class)
    public void testExtractHeaderMetadataFromFileH_neg_emptyHeaderRow() throws Exception {
        String filename = fileDirUtil.getTestResourcesPath(getClass(),"/excel/PositionHeaders002_emptyHeaderRow.xls");
        excelUtil.extractHeaderMetadataFromFileH(filename);
    }


    @Test
    public void testExtractHeaderMetadataFromFileX_successfulNineteenColsHeaders() throws Exception {
        String filename = fileDirUtil.getTestResourcesPath(getClass(),"/excel/PositionHeadersX001.xlsx");
        HeaderMetadata headerMetadata = excelUtil.extractHeaderMetadataFromFileX(filename);

        Assert.assertNotNull(headerMetadata);
        Assert.assertTrue(headerMetadata.isHasHeaderRow());
        Assert.assertEquals(19, headerMetadata.getHeaderCount());
        List<String> headerNames = headerMetadata.getHeaderNames();
        Assert.assertNotNull(headerNames);
        Assert.assertEquals("CLIENT_ID", headerNames.get(0));
        Assert.assertEquals("TRADE_ID", headerNames.get(1));
        Assert.assertEquals("PORTFOLIO", headerNames.get(2));
        Assert.assertEquals("SM_SEC_GROUP", headerNames.get(3));
        Assert.assertEquals("SM_SEC_TYPE", headerNames.get(4));
        Assert.assertEquals("POS_DATE", headerNames.get(5));
        Assert.assertEquals("TRD_TRADE_DATE", headerNames.get(6));
        Assert.assertEquals("TRD_SETTLE_DATE", headerNames.get(7));
        Assert.assertEquals("MATURITY", headerNames.get(8));
        Assert.assertEquals("TICKER", headerNames.get(9));
        Assert.assertEquals("POS_FACE", headerNames.get(10));
        Assert.assertEquals("POS_CUR_PAR", headerNames.get(11));
        Assert.assertEquals("CURRENCY", headerNames.get(12));
        Assert.assertEquals("TRD_PRINCIPAL", headerNames.get(13));
        Assert.assertEquals("TRD_COUNTERPARTY", headerNames.get(14));
        Assert.assertEquals("DESC_INSTMT", headerNames.get(15));
        Assert.assertEquals("NDF_TYPE", headerNames.get(16));
        Assert.assertEquals("TRD_CURRENCY", headerNames.get(17));
        Assert.assertEquals("ANNOUNCE_DT", headerNames.get(18));
        String toStringResult = headerMetadata.toString();
        Assert.assertEquals("{hasHeaderRow:true,[CLIENT_ID, TRADE_ID, PORTFOLIO, SM_SEC_GROUP, SM_SEC_TYPE, POS_DATE, TRD_TRADE_DATE, TRD_SETTLE_DATE, MATURITY, TICKER, POS_FACE, POS_CUR_PAR, CURRENCY, TRD_PRINCIPAL, TRD_COUNTERPARTY, DESC_INSTMT, NDF_TYPE, TRD_CURRENCY, ANNOUNCE_DT]}", toStringResult);
        System.out.println(toStringResult);
    }


    @Test(expected = IllegalStateException.class)
    public void testExtractHeaderMetadataFromFileX_neg_emptyHeaderRow() throws Exception {
        String filename = fileDirUtil.getTestResourcesPath(getClass(),"/excel/PositionHeadersX002_emptyHeaderRow.xlsx");
        excelUtil.extractHeaderMetadataFromFileX(filename);
    }

}
