package com.eastspring.tom.cart.core.svc;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.ScenarioUtil;
import com.google.common.base.Strings;
import de.redsix.pdfcompare.CompareResult;
import de.redsix.pdfcompare.CompareResultWithPageOverflow;
import de.redsix.pdfcompare.PdfComparator;
import org.apache.commons.lang3.StringUtils;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.pdfbox.text.PDFTextStripperByArea;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class PdfValidationSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(PdfValidationSvc.class);

    public static final String PDF_COMPARE_AUTOIMAGE_TRANSITION = "pdf.compare.autoimage.transition";

    public static final String PDF_COMPARE_TEXT_MODE = "TEXT";
    public static final String PDF_COMPARE_IMAGE_MODE = "IMAGE";

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private FormatterUtil formatterUtil;

    @Autowired
    private ScenarioUtil scenarioUtil;

    @Autowired
    private StateSvc stateSvc;

    private StringBuffer debugLog = new StringBuffer();

    private ThreadLocal<List<String>> exclusionList = ThreadLocal.withInitial(ArrayList::new);

    public List<String> getExclusionList() {
        return exclusionList.get();
    }

    public PDDocument getPdDocument(final File file) {
        try {
            return PDDocument.load(file);
        } catch (IOException e) {
            LOGGER.error("IO Exception while processing file [{}]", file.getAbsolutePath(), e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO Exception while processing file [{}]", file.getAbsolutePath());
        }
    }

    public void setExclusionList(final List<String> exclusions) {
        exclusionList.set(exclusions);
    }

    public PDPage getPdfPageRef(final PDDocument pdDocument, final Integer pageNumber) {
        if (pageNumber <= 0) {
            LOGGER.error("Page Number cannot be less than or equal to 0");
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "Page Number cannot be less than or equal to 0");
        }
        Integer noOfPages = pdDocument.getNumberOfPages();
        if (noOfPages < pageNumber) {
            LOGGER.error("Cannot access page number [{}] as it contains [{}] pages", pageNumber, noOfPages);
            throw new CartException(CartExceptionType.INVALID_INVOCATION_PARAMS, "Cannot access page number [{}] as it contains [{}] pages", pageNumber, noOfPages);
        }
        return pdDocument.getPage(pageNumber - 1);
    }

    public String getPdfText(final File file) {
        try (PDDocument pdDocument = this.getPdDocument(file)) {
            PDFTextStripper pdfTextStripper = new PDFTextStripper();
            return pdfTextStripper.getText(pdDocument);
        } catch (IOException | NullPointerException e) {
            LOGGER.error("Exception while processing pdfTextStripper", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception while processing pdfTextStripper");
        }
    }

    public String getPdfTextByPage(final File file, final Integer pageNumber) {
        try (PDDocument pdDocument = this.getPdDocument(file)) {
            PDFTextStripper pdfTextStripper = new PDFTextStripper();
            pdfTextStripper.setStartPage(pageNumber);
            pdfTextStripper.setEndPage(pageNumber);
            return pdfTextStripper.getText(pdDocument);
        } catch (IOException | NullPointerException e) {
            LOGGER.error("Exception while processing pdfTextStripper", e);
            throw new CartException(CartExceptionType.IO_ERROR, "Exception while processing pdfTextStripper");
        }
    }

    public String getPdfTextByCoordinates(final File file, final Integer pageNumber,
                                          final double x, final double y, final double width, final double height) {
        Rectangle rect = new Rectangle((int) x, (int) y, (int) width, (int) height);

        try (PDDocument pdDocument = this.getPdDocument(file)) {
            PDPage pdPage = getPdfPageRef(pdDocument, pageNumber);
            PDFTextStripperByArea textStripper = new PDFTextStripperByArea();
            textStripper.setSortByPosition(false);
            textStripper.addRegion("region", rect);
            textStripper.extractRegions(pdPage);
            String result = textStripper.getTextForRegion("region").trim();
            LOGGER.debug("Text captured in the area [{}] is [{}]", rect, result);
            return result;
        } catch (Exception e) {
            LOGGER.error("Processing failed while capturing text by area from Pdf file", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Processing failed while capturing text by area from Pdf file");
        }
    }

    public boolean comparePdf(final File file1, final File file2, final String compareMode) {
        return compareMode.equalsIgnoreCase(PDF_COMPARE_TEXT_MODE) ? comparePdfFilesWithTextMode(file1, file2, 0) : comparePdfFilesByImage(file1, file2);
    }

    public boolean comparePdfFilesWithTextMode(final File file1, final File file2, final Integer pageNumber) {
        boolean result = true;
        final String exceptionsFile = file1.getParent() + "/pdfDiff.txt";
        List<String> srcRecords;
        List<String> targetRecords;
        File targetFile = file2;

        if (pageNumber == 0) {
            srcRecords = Stream.of(this.getPdfText(file1).split(System.lineSeparator())).collect(Collectors.toCollection(ArrayList::new));
            targetRecords = Stream.of(this.getPdfText(file2).split(System.lineSeparator())).collect(Collectors.toCollection(ArrayList::new));
        } else {
            srcRecords = Stream.of(this.getPdfTextByPage(file1, pageNumber).split(System.lineSeparator())).collect(Collectors.toCollection(ArrayList::new));
            targetRecords = Stream.of(this.getPdfTextByPage(file2, pageNumber).split(System.lineSeparator())).collect(Collectors.toCollection(ArrayList::new));
        }

        if (srcRecords.size() != targetRecords.size() && pageNumber == 0) {
            final String autoImageTransition = stateSvc.getStringVar(PDF_COMPARE_AUTOIMAGE_TRANSITION);
            if (!Strings.isNullOrEmpty(autoImageTransition) && Boolean.valueOf(autoImageTransition)) {
                LOGGER.error("Row count is mismatch in pdf files, file1 {}, file2 having {} rows", srcRecords.size(), targetRecords.size());
                LOGGER.error("Invoking Pdf Image comparison...");
                return this.comparePdfFilesByImage(file1, file2);
            } else if (srcRecords.size() < targetRecords.size()) {
                targetFile = file1;
                List<String> tempList = srcRecords;
                srcRecords = targetRecords;
                targetRecords = tempList;
            }
        }

        StringBuilder stringBuilder = new StringBuilder("Below data is missing in file: " + targetFile.getName()).append("\n");

        Iterator<String> iterator1 = srcRecords.stream().iterator();
        Iterator<String> iterator2 = targetRecords.stream().iterator();

        while (iterator1.hasNext()) {
            String data1 = StringUtils.normalizeSpace(iterator1.next().replaceAll("\\r\\n|\\r|\\n", "").trim());
            String data2 = StringUtils.normalizeSpace(iterator2.hasNext() ? iterator2.next().replaceAll("\\r\\n|\\r|\\n", "").trim() : "");
            if (!data1.equals(data2)) {
                debugLog.append(formatterUtil.format("Differences found in file1 data [%s] and file 2 data [%s]", data1, data2)).append("\n");
                List<String> missingWords = this.getMissingWords(data1, data2);
                if (!areMissingWordsInExclusionList(missingWords)) {
                    stringBuilder.append(data1)
                            .append("\n");
                    result = false;
                }
            }
        }

        if (!result) {
            fileDirUtil.writeStringToFile(exceptionsFile, stringBuilder.toString());
            scenarioUtil.write(debugLog.toString());
        }
        this.setExclusionList(new ArrayList<>());
        return result;
    }

    @SuppressWarnings("unchecked")
    private boolean comparePdfFilesByImage(final File file1, final File file2) {
        String exceptionsFile = file1.getParent() + "/pdfDiff";
        try {
            final CompareResult result = new PdfComparator(file1, file2, new CompareResultWithPageOverflow())
                    .compare();

            if (result.isNotEqual()) {
                result.writeTo(exceptionsFile);
                return false;
            }
        } catch (IOException e) {
            LOGGER.error("IO Exception while processing comparePdfFilesByImage", e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO Exception while processing comparePdfFilesByImage");
        }
        return true;
    }

    private boolean areMissingWordsInExclusionList(List<String> missingWords) {
        if (getExclusionList().size() > 0) {
            for (String mWord : missingWords) {
                if (!getExclusionList().toString().contains(mWord)) {
                    debugLog.append(formatterUtil.format("Missing string [%s] is not available in exclusion list", mWord)).append("\n");
                    return false;
                } else {
                    debugLog.append(formatterUtil.format("Missing string [%s] is available in exclusion list, ignoring mismatch...", mWord)).append("\n");
                }
            }
        } else {
            return false;
        }
        return true;
    }


    private List<String> getMissingWords(final String actual, final String expected) {
        final Set<String> actualSet = Arrays.stream(actual.split("\\W+")).collect(Collectors.toSet());
        final Set<String> expectedSet = Arrays.stream(expected.split("\\W+")).collect(Collectors.toSet());
        actualSet.removeAll(expectedSet);
        return new ArrayList<>(actualSet);
    }
}
