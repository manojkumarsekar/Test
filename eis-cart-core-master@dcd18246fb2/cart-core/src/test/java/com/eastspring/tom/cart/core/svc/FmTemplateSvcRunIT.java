package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartCoreTestConfig;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import freemarker.template.Template;
import org.apache.commons.io.FileUtils;
import org.junit.*;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.builder.Input;
import org.xmlunit.diff.Diff;

import javax.xml.transform.Source;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.util.HashMap;
import java.util.Map;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {CartCoreSvcUtlTestConfig.class})
public class FmTemplateSvcRunIT {
    public static final String TEMPLATE_LOCATION = "../../src/test/resources/ws";
    public static final String TEMPLATE_FILENAME = "request-template-01.xml";

    @Rule
    public TemporaryFolder temporaryFolder = new TemporaryFolder();

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FmTemplateSvc fmTemplateSvc;

    private static String temporaryFileFullpath;

    @BeforeClass
    public static void setUpClass() {
        CartCoreTestConfig.configureLogging(FmTemplateSvcRunIT.class);
    }

    @AfterClass
    public static void afterClass() throws Exception {
        try {
            FileUtils.forceDelete(new File(temporaryFileFullpath));
        } catch (FileNotFoundException e) {
            // intentionally ignoring this exception
        }
    }


    @Test
    public void processTemplate() throws Exception {
        String templateDir = fileDirUtil.getAbsolutePath(FmTemplateSvcRunIT.class);
        String templateLocation = templateDir + TEMPLATE_LOCATION;
        System.out.println("templateLocation: " + templateLocation);
        fmTemplateSvc.setTemplateLocation(templateLocation);
        Map<String, String> dataMap = new HashMap<>();

        dataMap.put("flow_result_id", "ABF392348FBR");
        Template template = fmTemplateSvc.getTemplate(TEMPLATE_FILENAME);

        File file = temporaryFolder.newFile();
        temporaryFileFullpath = file.getAbsolutePath();
        System.out.println("tempFile: " + temporaryFileFullpath);


        try (FileWriter fw = new FileWriter(temporaryFileFullpath)) {
            try (BufferedWriter bw = new BufferedWriter(fw)) {
                template.process(dataMap, bw);
            }
        }

        Source control = Input.fromFile(templateLocation + "/request-generated-01.xml").build();
        Source target = Input.fromFile(temporaryFileFullpath).build();
        Diff myDiff = DiffBuilder.compare(control).withTest(target).build();
        Assert.assertFalse(myDiff.toString(), myDiff.hasDifferences());
    }
}
