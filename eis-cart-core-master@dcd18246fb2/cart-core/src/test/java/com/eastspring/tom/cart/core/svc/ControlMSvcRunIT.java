package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.mdl.ControlMOutputLine;
import com.eastspring.tom.cart.core.mdl.ControlMOutputType;
import com.eastspring.tom.cart.core.mdl.ControlMSegregatedOutputLines;
import com.eastspring.tom.cart.core.mdl.RemoteOutput;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static com.eastspring.tom.cart.core.svc.ControlMSvc.PARSE_FAILED_LINE_MUST_NOT_BE_NULL;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class ControlMSvcRunIT {
    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(ControlMSvcRunIT.class);
    }

    @Autowired
    private ControlMSvc controlMSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private StateSvc stateSvc;

    @Rule
    public ExpectedException thrown = ExpectedException.none();

    @Test
    public void testParseOutputLine_jobLong() {
        ControlMOutputLine result1 = controlMSvc.parseOutputLine("5701 JOB 'EIS-APP-TOM-EOD-GLOBAL-DEV/BNP_TO_EIS_DEV/EOD_FXRT_DEV/UEISATOM_DEV_MOVEIT_DMP_TO_SHARE_DAILY_FX' ordered, file_name = 'Deliver daily FX rate file', orderno='0rrfx'");
        assertNotNull(result1);
        assertEquals(ControlMOutputType.JOB, result1.getType());
        assertEquals("EIS-APP-TOM-EOD-GLOBAL-DEV/BNP_TO_EIS_DEV/EOD_FXRT_DEV", result1.getFolderName());
        assertEquals("UEISATOM_DEV_MOVEIT_DMP_TO_SHARE_DAILY_FX", result1.getJobName());
        assertEquals("0rrfx", result1.getOrderid());
    }

    @Test
    public void testParseOutputLine_jobShort() {
        ControlMOutputLine result2 = controlMSvc.parseOutputLine("5701 JOB 'A/B' ordered, file_name = 'C', orderno='0a'");
        assertNotNull(result2);
        assertEquals(ControlMOutputType.JOB, result2.getType());
        assertEquals("A", result2.getFolderName());
        assertEquals("B", result2.getJobName());
        assertEquals("0a", result2.getOrderid());
    }

    @Test
    public void testParseOutputLine_subfolderLong() {
        ControlMOutputLine result1 = controlMSvc.parseOutputLine("5701 Sub folder 'EIS-APP-TOM-EOD-GLOBAL-DEV/BNP_TO_EIS_DEV/EIS-APP-TOM-QUANT-DEV' ordered, file_name = '', orderno='0rrfy'");
        assertNotNull(result1);
        assertEquals(ControlMOutputType.SUBFOLDER, result1.getType());
        assertEquals("EIS-APP-TOM-EOD-GLOBAL-DEV/BNP_TO_EIS_DEV/EIS-APP-TOM-QUANT-DEV", result1.getFolderName());
        assertNull(result1.getJobName());
        assertEquals("0rrfy", result1.getOrderid());
    }

    @Test
    public void testParseOutputLine_subfolderShort() {
        ControlMOutputLine result2 = controlMSvc.parseOutputLine("5701 Sub folder 'A' ordered, file_name = '', orderno='0b'");
        assertNotNull(result2);
        assertEquals(ControlMOutputType.SUBFOLDER, result2.getType());
        assertEquals("A", result2.getFolderName());
        assertNull(result2.getJobName());
        assertEquals("0b", result2.getOrderid());
    }

    @Test
    public void testParseOutputLine_unknown1() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Parsing failed: Unknown Control-M output line: [5701 Something Else 'EIS-APP-TOM-EOD-GLOBAL-DEV/BNP_TO_EIS_DEV/EIS-APP-TOM-QUANT-DEV' ordered, file_name = '', orderno='0rrfy']");
        controlMSvc.parseOutputLine("5701 Something Else 'EIS-APP-TOM-EOD-GLOBAL-DEV/BNP_TO_EIS_DEV/EIS-APP-TOM-QUANT-DEV' ordered, file_name = '', orderno='0rrfy'");
    }

    @Test
    public void testParseOutputLine_unknown2() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Parsing failed: Unknown Control-M output line: [5701 ]");
        controlMSvc.parseOutputLine("5701 ");
    }

    @Test
    public void testParseOutputLine_nullArg() {
        thrown.expect(CartException.class);
        thrown.expectMessage(PARSE_FAILED_LINE_MUST_NOT_BE_NULL);
        controlMSvc.parseOutputLine(null);
    }

    @Test
    public void testSegregateOutputLinesByFolder() {
        List<ControlMOutputLine> lines = Collections.singletonList(new ControlMOutputLine(ControlMOutputType.SUBFOLDER, "A", null, "0rabc"));
        assertNotNull(controlMSvc.segregateOutputLinesByFolder("A", lines));
    }

    @Test
    public void testSegregateOutputLinesByFolder_multipleLines() {
        List<ControlMOutputLine> lines = Arrays.asList(
                new ControlMOutputLine(ControlMOutputType.SUBFOLDER, "A/B", null, "0rab1"),
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B", "JOB1", "0rab2"),
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B", "JOB2", "0rab3"),
                new ControlMOutputLine(ControlMOutputType.SUBFOLDER, "A/B/C", null, "0rab4"),
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B/C", "JOB3", "0rab5"),
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B/C", "JOB4", "0rab6"),
                new ControlMOutputLine(ControlMOutputType.SUBFOLDER, "C", null, "0rab7"),
                new ControlMOutputLine(ControlMOutputType.JOB, "C", "JOB5", "0rab8"),
                new ControlMOutputLine(ControlMOutputType.SUBFOLDER, "C/D", null, "0rab9"),
                new ControlMOutputLine(ControlMOutputType.JOB, "C/D", "JOB6", "0raba")
        );
        ControlMSegregatedOutputLines segregated = controlMSvc.segregateOutputLinesByFolder("A/B", lines);
        assertNotNull(segregated);

        List<ControlMOutputLine> expectedToRetainList = Arrays.asList(
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B", "JOB1", "0rab2"),
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B", "JOB2", "0rab3"),
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B/C", "JOB3", "0rab5"),
                new ControlMOutputLine(ControlMOutputType.JOB, "A/B/C", "JOB4", "0rab6")
        );
        List<ControlMOutputLine> expectedToKillList = Arrays.asList(
                new ControlMOutputLine(ControlMOutputType.JOB, "C", "JOB5", "0rab8"),
                new ControlMOutputLine(ControlMOutputType.JOB, "C/D", "JOB6", "0raba")
        );
        assertEquals(expectedToRetainList, segregated.getToRetain());
        assertEquals(expectedToKillList, segregated.getToKill());
    }

    @Test
    public void testSegregateSampleString_emptyString() {
        String outputText = "";
        thrown.expect(CartException.class);
        thrown.expectMessage("Parsing failed: Unknown Control-M output line: []");
        controlMSvc.getSegregatedOutputFromString("A/B", outputText);
    }

    @Test
    public void testSegregateSampleString_null() {
        thrown.expect(CartException.class);
        thrown.expectMessage("Parsing failed: Unknown Control-M output line: []");
        controlMSvc.getSegregatedOutputFromString("A/B", null);
    }

    @Test
    public void testSegregateTheSampleInputFile() {
        ControlMSegregatedOutputLines result = controlMSvc.getSegregatedOutputFromString("A/B", getFileWithSkippedFirstFiveRows());
        assertEquals(0, result.getToRetain().size());
        assertEquals(172, result.getToKill().size());

    }

    //@Test
    public void testControlM() {
        stateSvc.useNamedEnvironment("TOM_DEV1");
        RemoteOutput result = controlMSvc.runCliControlM("echo hello");
        assertNotNull(result);
        assertEquals("hello\n", result.getOutput());
        assertEquals("", result.getError());
    }

    @Test
    public void testSegregateTheSampleInputFile_koreaFiles() {
        ControlMSegregatedOutputLines result = controlMSvc.getSegregatedOutputFromString("EIS-APP-TOM-EOD-GLOBAL-DEV/EIS_TO_BRS_DEV/KOREA_HSBC_FILES_DEV", getFileWithSkippedFirstFiveRows());
        assertNotNull(result);
        assertEquals(10, result.getToRetain().size());
        assertEquals(162, result.getToKill().size());
    }

    private String getFileWithSkippedFirstFiveRows() {
        String outputFile = fileDirUtil.getMavenTestResourcesPath("controlm/ctmorder/output01.txt");
        String content = fileDirUtil.readFileToString(outputFile);
        String[] lines = content.split("\\r?\\n");
        StringBuilder sb = new StringBuilder();
        int noOfLines = lines.length;
        int lineNum = 5;
        while (lineNum < noOfLines) {
            sb.append(lines[lineNum]);
            if (lineNum != noOfLines - 1) {
                sb.append("\n");
            }
            lineNum++;
        }
        return sb.toString();
    }
}
