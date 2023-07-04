package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.constant.Formats;
import com.eastspring.tom.cart.constant.MapConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.ExcelFileSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.svc.ThreadSvc;
import com.eastspring.tom.cart.core.utl.CsvUtil;
import com.eastspring.tom.cart.core.utl.DateTimeUtil;
import com.eastspring.tom.cart.dmp.svc.BulkUploadFormatSvc;
import com.opencsv.CSVWriter;
import org.apache.commons.collections4.map.ListOrderedMap;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;

import static com.eastspring.tom.cart.constant.Formats.BULK_UPLOAD_FILE_FOR_CANCEL;
import static com.eastspring.tom.cart.constant.Formats.BULK_UPLOAD_FILE_FOR_NEW_AMEND;


/**
 * The type Bulk upload utl.
 */
public class BulkUploadUtl {

    private static final Logger LOGGER = LoggerFactory.getLogger(BulkUploadUtl.class);

    @Autowired
    private ExcelFileSvc excelFileSvc;

    @Autowired
    private BulkUploadFormatSvc bulkUploadFormatSvc;

    @Autowired
    private TradeLifeCycleUtl tradeLifeCycleUtl;

    @Autowired
    private DateTimeUtil dateTimeUtil;

    @Autowired
    private CsvUtil csvUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private ThreadSvc threadSvc;

    private static AtomicLong atomicNanos = new AtomicLong(Long.MIN_VALUE);

    /**
     * Generate bulk upload file name string.
     * Different logic implemented for New/Amend file generation keeping parallel processing in mind.
     * It ensures, unique HHmmss will be created though I run the TLC feature files in parallel.
     *
     * @param txnStatus the txn status
     * @return the string
     */
    public String generateBulkUploadFileName(final String txnStatus) {
        String nanos = String.valueOf(atomicNanos.updateAndGet((v) -> Math.max(v + 1, System.nanoTime())));
        String uniqueSeconds = String.valueOf(nanos).substring(nanos.length() - 4);
        String date = Formats.BRS_TIMESTAMP_FOR_NEW_AMEND_FILE.print(new DateTime());
        if ("Cancel".equalsIgnoreCase(txnStatus)) {
            return String.format(BULK_UPLOAD_FILE_FOR_CANCEL, date + uniqueSeconds);
        }
        return String.format(BULK_UPLOAD_FILE_FOR_NEW_AMEND, date + uniqueSeconds);
    }

    /**
     * Create bulk upload file from the trade parameters map.
     *
     * @param tradeParams the trade params
     * @return the path {@link Path}
     */
    public Path createBulkUploadFile(final Map<String, String> tradeParams) {
        final String txnStatus = tradeParams.get(MapConstants.TXN_STATUS);

        Path tempFolder = tradeLifeCycleUtl.getTempDir().toPath();
        String bulkUploadFileName = generateBulkUploadFileName(txnStatus);
        File csvFile = new File(tempFolder.toString() + File.separator + bulkUploadFileName + ".csv");
        File excelFile = new File(tempFolder.toString() + File.separator + bulkUploadFileName + ".xlsx");

        ListOrderedMap<String, String> content = bulkUploadFormatSvc.getContentMap(tradeParams);
        this.writeToCsv(content, csvFile);
        this.writeToExcelX(content, excelFile);
        return csvFile.toPath();
    }

    private void writeToCsv(final ListOrderedMap<String, String> map, final File file) {
        try {
            List<String> header = map.keyList();
            List<String> data = map.valueList();
            try (CSVWriter csvWriter = csvUtil.getDefaultCSVWriter(file.getAbsolutePath())) {
                csvWriter.writeNext(header.toArray(new String[0]), false);
                csvWriter.writeNext(data.toArray(new String[0]), false);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void writeToExcelX(final ListOrderedMap<String, String> map, final File file) {
        try {
            List<String> header = map.keyList();
            List<String> data = map.valueList();

            try (Workbook workbook = new XSSFWorkbook()) {
                Sheet sheet = workbook.createSheet();
                Row headerRow = sheet.createRow(0);
                for (int i = 0; i <= header.size() - 1; i++) {
                    Cell cell = headerRow.createCell(i);
                    cell.setCellValue(header.get(i));
                }

                Row dataRow = sheet.createRow(sheet.getLastRowNum() + 1);
                for (int i = 0; i <= data.size() - 1; i++) {
                    Cell cell = dataRow.createCell(i);
                    cell.setCellValue(data.get(i));
                }

                try (FileOutputStream outputStream = new FileOutputStream(file)) {
                    workbook.write(outputStream);
                }
            }
        } catch (IOException e) {
            LOGGER.error("IO Exception while writing Header to Bulkupload.xlsx", e);
            throw new CartException(CartExceptionType.IO_ERROR, "IO Exception while writing Header to Bulkupload.xlsx");
        }
    }


}