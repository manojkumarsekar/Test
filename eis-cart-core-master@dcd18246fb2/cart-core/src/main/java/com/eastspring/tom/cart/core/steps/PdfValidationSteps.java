package com.eastspring.tom.cart.core.steps;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.PdfValidationSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.WorkspaceDirSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.google.common.base.Strings;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.*;
import java.util.stream.Collectors;

public class PdfValidationSteps {

    private static final Logger LOGGER = LoggerFactory.getLogger(PdfValidationSteps.class);

    public static final String PDF_COMPARE_MODE_VAR = "pdf.compare.mode";
    public static final String TEXT = "Text";

    @Autowired
    private PdfValidationSvc pdfValidationSvc;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private WorkspaceDirSvc workspaceDirSvc;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private FileDirUtil fileDirUtil;

    private ThreadLocal<File> pdfFile = new ThreadLocal<>();

    public File getPdfFile() {
        return pdfFile.get();
    }

    public synchronized void processPdfFile(final String filepath) {
        final String expandFilePath = stateSvc.expandVar(filepath);
        final String normalizedPath = workspaceDirSvc.normalize(expandFilePath);
        pdfFile.set(new File(normalizedPath));
    }

    public void configureExclusions(final List<String> list) {
        pdfValidationSvc.setExclusionList(list.stream().map(s -> stateSvc.expandVar(s)).collect(Collectors.toList()));
    }

    public void assignPdfTextToVar(final Integer pageNumber, final String targetVar) {
        File file = getPdfFile();
        if (file == null) {
            LOGGER.error("Pdf file object is not set");
            throw new CartException(CartExceptionType.UNDEFINED, "Pdf file object is set");
        }
        final String text = pdfValidationSvc.getPdfTextByPage(file, pageNumber);
        scenarioUtil.write(text);
        stateSvc.setStringVar(targetVar, text);
    }


    public void verifyValuesInPdf(final List<String> valuesList) {
        File file = this.getPdfFile();
        if (file == null) {
            LOGGER.error("Pdf file object is not set");
            throw new CartException(CartExceptionType.UNDEFINED, "Pdf file object is set");
        }

        final String pdfText = pdfValidationSvc.getPdfText(file);
        LOGGER.debug("Pdf Text [{}]", pdfText);
        Map<String, String> errors = new HashMap<>();

        String expandValue;
        for (String value : valuesList) {
            expandValue = stateSvc.expandVar(value);
            if (!pdfText.contains(expandValue)) {
                errors.put(expandValue, formatterUtil.format("%s is not available in Pdf Text", expandValue));
            }
        }
        if (errors.size() > 0) {
            String failed = errors.keySet().stream().collect(Collectors.joining(","));
            LOGGER.error("Verify PDF Text is failed for values [{}]", failed);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verify PDF Text is failed for values [{}]", failed);
        }
    }

    public void verifyValueOccurrencesInPdf(final Map<String, String> valueCntMap) {
        File file = this.getPdfFile();
        if (file == null) {
            LOGGER.error("Pdf file object is not set");
            throw new CartException(CartExceptionType.UNDEFINED, "Pdf file object is set");
        }

        final String pdfText = pdfValidationSvc.getPdfText(file);
        LOGGER.debug("Pdf Text [{}]", pdfText);

        List<Map<String, String>> errors = new ArrayList<>();

        Set<String> keys = valueCntMap.keySet();
        for (String key : keys) {
            String expandKey = stateSvc.expandVar(key);
            int expectedCount = Integer.valueOf(stateSvc.expandVar(valueCntMap.get(key)));
            int actualCount = StringUtils.countMatches(pdfText, expandKey);
            if (expectedCount != actualCount) {
                errors.add(new HashMap<String, String>() {{
                    put(expandKey, formatterUtil.format("%s Occurrences in file are %s, but expected %s", expandKey, actualCount, expectedCount));
                }});
            }
        }

        if (errors.size() > 0) {
            String fails = errors.stream().map(Map::values).collect(Collectors.toList()).toString();
            LOGGER.error("Verify Occurrences of Text is failed with errors [{}]", fails);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verify Occurrences of Text is failed with errors [{}]", fails);
        }
    }


    public void verifyValueCoordinatesInPdf(final Integer pageNumber, final Map<String, String> valueCoordinatesMap) {
        File file = this.getPdfFile();
        if (file == null) {
            LOGGER.error("Pdf file object is not set");
            throw new CartException(CartExceptionType.UNDEFINED, "Pdf file object is set");
        }

        List<Map<String, String>> errors = new ArrayList<>();
        Set<String> keys = valueCoordinatesMap.keySet();

        for (String key : keys) {
            String expectedText = stateSvc.expandVar(valueCoordinatesMap.get(key));
            String[] rect = key.split(",");
            if (rect.length != 4) {
                LOGGER.error("Coordinates should be defined as x=1,y=1,width=1,height=1");
                throw new CartException(CartExceptionType.INCOMPLETE_PARAMS, "Coordinates should be defined as x=1,y=1,width=1,height=1");
            }
            String actualText = pdfValidationSvc.getPdfTextByCoordinates(file, pageNumber,
                    Integer.valueOf(rect[0].split("=")[1]), Integer.valueOf(rect[1].split("=")[1]), Integer.valueOf(rect[2].split("=")[1]), Integer.valueOf(rect[3].split("=")[1]));

            if (!expectedText.equals(actualText)) {
                errors.add(new HashMap<String, String>() {{
                    put(key, formatterUtil.format("Actual text with coordinates %s is %s, but Expected is %s", key, actualText, expectedText));
                }});
            }
        }

        if (errors.size() > 0) {
            String fails = errors.stream().map(Map::values).collect(Collectors.toList()).toString();
            LOGGER.error("Verify Occurrences of Text is failed with errors [{}]", fails);
            throw new CartException(CartExceptionType.VERIFICATION_FAILED, "Verify Occurrences of Text is failed with errors [{}]", fails);
        }
    }

    public void comparePdf(final String file1, final String file2) {
        final String expandFile1 = stateSvc.expandVar(file1);
        final String expandFile2 = stateSvc.expandVar(file2);
        this.comparePdf(new File(expandFile1), new File(expandFile2));
    }

    public void comparePdf(final File file1, final File file2) {
        String compareMode = stateSvc.getStringVar(PDF_COMPARE_MODE_VAR);
        if (Strings.isNullOrEmpty(compareMode)) {
            compareMode = TEXT;
        }
        if (!pdfValidationSvc.comparePdf(file1, file2, compareMode)) {
            if (compareMode.equals(TEXT)) {
                byte[] bytes = fileDirUtil.readFileToByteArray(file1.getParent() + "/pdfDiff.txt");
                scenarioUtil.embed(bytes, "text/plain");
            } else {
                byte[] bytes = fileDirUtil.readFileToByteArray(file1.getParent() + "/pdfDiff.pdf");
                scenarioUtil.embed(bytes, "application/pdf");
            }
            LOGGER.error("Pdf Comparison failed, please find the attachment for detailed errors");
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Pdf Comparison failed, please find the attachment for detailed errors");
        }
    }

    public void comparePdfByPageByText(final String file1, final String file2, final Integer pageNumber) {
        final String expandFile1 = stateSvc.expandVar(file1);
        final String expandFile2 = stateSvc.expandVar(file2);

        if (!pdfValidationSvc.comparePdfFilesWithTextMode(new File(expandFile1), new File(expandFile2), pageNumber)) {
            byte[] bytes = fileDirUtil.readFileToByteArray(new File(expandFile1).getParent() + "/pdfDiff.txt");
            scenarioUtil.embed(bytes, "text/plain");
            LOGGER.error("Pdf Comparison for page [{}] failed, please find the attachment for detailed errors", pageNumber);
            throw new CartException(CartExceptionType.VALIDATION_FAILED, "Pdf Comparison for page [{}] failed, please find the attachment for detailed errors", pageNumber);
        }
    }

}
