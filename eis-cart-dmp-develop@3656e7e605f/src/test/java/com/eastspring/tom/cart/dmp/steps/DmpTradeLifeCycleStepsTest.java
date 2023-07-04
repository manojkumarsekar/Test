package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.constant.Source;
import com.eastspring.tom.cart.core.steps.HostSteps;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.dmp.svc.TradeLifeCycleSvc;
import com.eastspring.tom.cart.dmp.utl.BulkUploadUtl;
import com.eastspring.tom.cart.dmp.utl.DmpGsWorkflowUtl;
import com.eastspring.tom.cart.dmp.utl.TradeLifeCycleUtl;
import com.eastspring.tom.cart.dmp.utl.mdl.TrdNuggetsSpec;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

import java.io.File;
import java.nio.file.Path;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.ARCHIVE_FILE_PATH;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.CONFIG_SOURCE;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.DESTINATION_HOST;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.FILE_PATH;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.FILE_PATTERN;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.SLEEP_SEC;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.TLC_BNP_ARCHIVE_PATH;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.TLC_BNP_CONFIG;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.TLC_BNP_INBOUND_PATH;
import static com.eastspring.tom.cart.dmp.steps.DmpTradeLifeCycleSteps.TLC_TEMPLATES_PATH;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static tomcart.glue.DmpGsWorkflowStepsDef.ASYNC_RESPONSE_FILE_PATH;
import static tomcart.glue.DmpGsWorkflowStepsDef.FILE_TRANSFER_TEMPLATE_PATH;
import static tomcart.glue.DmpGsWorkflowStepsDef.MAX_POLL_TIME_SECONDS_SMALL;

public class DmpTradeLifeCycleStepsTest {

    @Spy
    @InjectMocks
    private DmpTradeLifeCycleSteps steps;

    @Mock
    private StateSvc stateSvc;

    @Mock
    private DmpGsWorkflowUtl dmpGsWorkflowUtl;

    @Mock
    private TradeLifeCycleSvc tradeLifeCycleSvc;

    @Mock
    private TradeLifeCycleUtl tradeLifeCycleUtl;

    @Mock
    private HostSteps hostSteps;

    @Mock
    private ThreadSvc threadSvc;

    @Mock
    private TrdNuggetsSpec trdNuggetsSpec;

    @Mock
    private BulkUploadUtl bulkUploadUtl;


    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Before
    public void initMocks() {
        MockitoAnnotations.initMocks(this);
    }

    @Test
    public void testInitiateTLCFileTransferJob_DisconnectedMode() {
        when(tradeLifeCycleSvc.isTlcInConnectedMode()).thenReturn(false);
        when(stateSvc.getStringVar(TLC_BNP_CONFIG)).thenReturn("BNP");
        when(stateSvc.getStringVar(TLC_BNP_ARCHIVE_PATH)).thenReturn("mock_archive");
        when(stateSvc.getStringVar(TLC_BNP_INBOUND_PATH)).thenReturn("mock_inbound");
        when(steps.getTradeAckXmlPath()).thenReturn(new File("target/test-classes/tlc/esi_brs_tmsack_template.xml").toPath());

        final Map<String, String> templateParams = new HashMap<>();
        templateParams.put(CONFIG_SOURCE, "BNP");
        templateParams.put(ARCHIVE_FILE_PATH, "mock_archive");
        templateParams.put(FILE_PATH, "mock_inbound");
        templateParams.put(FILE_PATTERN, "esi_brs_tmsack_template.xml");

        steps.initiateTLCFileTransferJob(Source.BNP);

        verify(dmpGsWorkflowUtl, times(1)).processWorkFlowRequestAndWaitTillCompletion(FILE_TRANSFER_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_SMALL);
    }

    @Test
    public void testInitiateTLCFileTransferJob_ConnectedMode() {
        when(tradeLifeCycleSvc.isTlcInConnectedMode()).thenReturn(true);
        final Map<String, String> templateParams = new HashMap<>();
        steps.initiateTLCFileTransferJob(Source.BNP);
        verify(stateSvc, times(0)).getStringVar(TLC_BNP_CONFIG);
        verify(stateSvc, times(0)).getStringVar(TLC_BNP_ARCHIVE_PATH);
        verify(stateSvc, times(0)).getStringVar(TLC_BNP_INBOUND_PATH);
        verify(dmpGsWorkflowUtl, times(0)).processWorkFlowRequestAndWaitTillCompletion(FILE_TRANSFER_TEMPLATE_PATH, ASYNC_RESPONSE_FILE_PATH, templateParams, MAX_POLL_TIME_SECONDS_SMALL);
    }

    @Test
    public void testGenerateTradeAckXml_DisconnectedMode() {
        final Path testPath = new File("target/test-classes/tlc/esi_brs_tmsack_template.xml").toPath();

        when(tradeLifeCycleSvc.isTlcInConnectedMode()).thenReturn(false);
        when(tradeLifeCycleSvc.generateTradeAckXml(testPath)).thenReturn(testPath);

        when(steps.getTradeNuggetTarPath()).thenReturn(testPath);
        when(steps.getTradeAckXmlPath()).thenReturn(testPath);

        when(stateSvc.getStringVar(TLC_BNP_INBOUND_PATH)).thenReturn("mock_inbound");
        doNothing().when(threadSvc).sleepSeconds(SLEEP_SEC);

        steps.generateTradeAckXml();

        verify(tradeLifeCycleSvc, times(1)).generateTradeAckXml(testPath);
        verify(hostSteps, times(1)).copyLocalFilesToRemote(testPath.getParent().toString(), Collections.singletonList(testPath.getFileName().toString()), DESTINATION_HOST, stateSvc.getStringVar(TLC_BNP_INBOUND_PATH));
        verify(threadSvc, times(1)).sleepSeconds(SLEEP_SEC);
    }

    @Test
    public void testGenerateTradeAckXml_ConnectedMode() {
        final Path testPath = new File("target/test-classes/tlc/esi_brs_tmsack_template.xml").toPath();

        when(tradeLifeCycleSvc.isTlcInConnectedMode()).thenReturn(true);
        when(tradeLifeCycleSvc.generateTradeAckXml(testPath)).thenReturn(testPath);

        when(steps.getTradeNuggetTarPath()).thenReturn(testPath);
        when(steps.getTradeAckXmlPath()).thenReturn(testPath);

        when(stateSvc.getStringVar(TLC_BNP_INBOUND_PATH)).thenReturn("mock_inbound");

        steps.generateTradeAckXml();

        verify(tradeLifeCycleSvc, times(1)).generateTradeAckXml(testPath);
        verify(hostSteps, times(0)).copyLocalFilesToRemote(testPath.getParent().toString(), Collections.singletonList(testPath.getFileName().toString()), DESTINATION_HOST, stateSvc.getStringVar(TLC_BNP_INBOUND_PATH));
        verify(threadSvc, times(0)).sleepSeconds(SLEEP_SEC);
    }

    @Test
    public void testGenerateTradeNuggets_DisconnectedMode() {
        when(tradeLifeCycleSvc.isTlcInConnectedMode()).thenReturn(false);

        final File tempDir = new File("target/test-classes/tlc");
        final Path nuggetsPath = new File("target/test-classes/tlc/nuggets/test.tar.gz").toPath();

        Map<String, String> tradeMap = new HashMap<>();

        doNothing().when(trdNuggetsSpec).setTrdNuggetsTemplatePath("template_test_path");
        doNothing().when(tradeLifeCycleUtl).setTempDir(tempDir);
        doNothing().when(trdNuggetsSpec).setTrdNuggetsGenerationPath(tempDir.getAbsolutePath());

        when(tradeLifeCycleUtl.getTempDirPath("TLC")).thenReturn(tempDir);
        when(tradeLifeCycleUtl.getTempDir()).thenReturn(tempDir);
        when(stateSvc.getStringVar(TLC_TEMPLATES_PATH)).thenReturn("template_test_path");
        when(tradeLifeCycleSvc.generateTradeNuggetsTar(tradeMap)).thenReturn(tempDir.toPath());
        when(bulkUploadUtl.createBulkUploadFile(tradeMap)).thenReturn(tempDir.toPath());
        when(steps.getTradeNuggetTarPath()).thenReturn(nuggetsPath);

        steps.generateTradeNuggets(tradeMap);

        verify(bulkUploadUtl, times(1)).createBulkUploadFile(tradeMap);
        verify(tradeLifeCycleSvc, times(1)).generateTradeNuggetsTar(tradeMap);
        verify(hostSteps, times(1)).copyLocalFilesToRemote(nuggetsPath.getParent().toString(),
                Collections.singletonList(nuggetsPath.getFileName().toString()),
                DESTINATION_HOST, stateSvc.getStringVar(TLC_BNP_INBOUND_PATH));
        verify(threadSvc, times(1)).sleepSeconds(SLEEP_SEC);
    }

    @Test
    public void testGenerateTradeNuggets_ConnectedMode() {
        when(tradeLifeCycleSvc.isTlcInConnectedMode()).thenReturn(true);

        final File tempDir = new File("target/test-classes/tlc");
        final Path nuggetsPath = new File("target/test-classes/tlc/nuggets/test.tar.gz").toPath();

        Map<String, String> tradeMap = new HashMap<>();

        doNothing().when(trdNuggetsSpec).setTrdNuggetsTemplatePath("template_test_path");
        doNothing().when(tradeLifeCycleUtl).setTempDir(tempDir);
        doNothing().when(trdNuggetsSpec).setTrdNuggetsGenerationPath(tempDir.getAbsolutePath());

        when(tradeLifeCycleUtl.getTempDirPath("TLC")).thenReturn(tempDir);
        when(tradeLifeCycleUtl.getTempDir()).thenReturn(tempDir);
        when(stateSvc.getStringVar(TLC_TEMPLATES_PATH)).thenReturn("template_test_path");
        when(tradeLifeCycleSvc.generateTradeNuggetsTar(tradeMap)).thenReturn(tempDir.toPath());
        when(bulkUploadUtl.createBulkUploadFile(tradeMap)).thenReturn(tempDir.toPath());
        when(steps.getTradeNuggetTarPath()).thenReturn(nuggetsPath);

        steps.generateTradeNuggets(tradeMap);

        verify(bulkUploadUtl, times(1)).createBulkUploadFile(tradeMap);
        verify(tradeLifeCycleSvc, times(1)).generateTradeNuggetsTar(tradeMap);
        verify(hostSteps, times(0)).copyLocalFilesToRemote(nuggetsPath.getParent().toString(),
                Collections.singletonList(nuggetsPath.getFileName().toString()),
                DESTINATION_HOST, stateSvc.getStringVar(TLC_BNP_INBOUND_PATH));
        verify(threadSvc, times(0)).sleepSeconds(SLEEP_SEC);
    }


}
