package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.constant.AssetType;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.core.svc.DatabaseSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import org.apache.commons.collections4.map.ListOrderedMap;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.svc.BulkUploadFormatSvc.BCUSIP;
import static com.eastspring.tom.cart.dmp.svc.BulkUploadFormatSvc.ISIN;
import static com.eastspring.tom.cart.dmp.svc.BulkUploadFormatSvc.SEDOL;
import static com.eastspring.tom.cart.dmp.svc.BulkUploadFormatSvc.SQL_TO_GET_IDENTIFIERS;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

public class BulkUploadFormatSvcTest {

    @InjectMocks
    private BulkUploadFormatSvc bulkUploadFormatSvc;

    @Mock
    private DatabaseSvc databaseSvc;

    @Mock
    private StateSvc stateSvc;

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testGetContentMap_EQFI() {
        Map<String, String> testParams = new HashMap<>();
        //Below are mandatory fields for EQFI
        testParams.put(MapConstants.ASSET_TYPE, AssetType.EQUITY);
        testParams.put(MapConstants.IDENTIFIER, "SG1F60858221");
        testParams.put(MapConstants.TXN_TYPE, "Buy");
        testParams.put(MapConstants.TRD_DATE, "2018-06-01");
        testParams.put(MapConstants.SETT_DATE, "2018-06-04");

        ListOrderedMap<String, String> content = bulkUploadFormatSvc.getContentMap(testParams);

        verify(databaseSvc, times(1)).executeSqlQueryAssignResultsToVars(String.format(SQL_TO_GET_IDENTIFIERS, "SG1F60858221"), Arrays.asList(ISIN, SEDOL, BCUSIP));
        verify(stateSvc, times(5)).getStringVar(anyString());

        Assert.assertEquals(17, content.keyList().size());
        Assert.assertEquals(17, content.valueList().size());
    }
}
