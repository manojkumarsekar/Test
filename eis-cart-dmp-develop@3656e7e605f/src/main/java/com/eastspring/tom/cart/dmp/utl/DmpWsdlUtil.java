package com.eastspring.tom.cart.dmp.utl;

import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.dmp.utl.mdl.RowInfo;
import org.apache.commons.io.FileUtils;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

/**
 * <p>This class encapsulates extraction of information from Golden Source Workflow Event Raiser web services
 * by providing parsing services the web service interface specification (WSDL files).</p>
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class DmpWsdlUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(DmpWsdlUtil.class);

    public static final String SEPARATOR1 = "<tr><td>";
    public static final String SEPARATOR2 = "</td><td>";
    public static final String SEPARATOR3 = "</td><td><a href=\"";
    public static final String SEPARATOR4 = "\">WSDL...</a></td></tr>";

    /**
     * @param wsdlRows
     * @return
     */
    public List<RowInfo> parseWsdlRows(List<String> wsdlRows) {
        List<RowInfo> result = new ArrayList<>();
        for (String gsWsdlRow : wsdlRows) {
            LOGGER.debug("{}", gsWsdlRow);
            int start1 = gsWsdlRow.indexOf(SEPARATOR1) + SEPARATOR1.length();
            int end1 = gsWsdlRow.indexOf(SEPARATOR2);
            int start2 = end1 + SEPARATOR2.length();
            int end2 = gsWsdlRow.indexOf(SEPARATOR3);
            int start3 = end2 + SEPARATOR3.length();
            int end3 = gsWsdlRow.indexOf(SEPARATOR4, start3);
            RowInfo row = new RowInfo();
            row.setEventName(gsWsdlRow.substring(start1, end1));
            row.setEventType(gsWsdlRow.substring(start2, end2));
            row.setWsdlUrl(gsWsdlRow.substring(start3, end3));
            result.add(row);
        }
        return result;
    }


    /**
     * @param sourceUrl
     * @param cp        a {@link CredentialsProvider} object for authentication
     * @return body of the response as {@link String}
     * @throws Exception
     */
    public String downloadBodyAsString(String sourceUrl, CredentialsProvider cp) {
        CloseableHttpClient client = HttpClients.custom().setDefaultCredentialsProvider(cp).build();
        HttpGet httpGet = new HttpGet(sourceUrl);
        String body = null;
        try (CloseableHttpResponse response = client.execute(httpGet)) {
            body = EntityUtils.toString(response.getEntity());
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed downloading body as string");
        }

        return body;
    }


    /**
     * <p>
     * Download a single WSDL from given URL.
     * </p>
     *
     * @param row     a @{@link RowInfo} object describing a WSDL entry
     * @param destDir destination directory/folder which will contain the downloaded WSDL file
     * @param cp      a {@link CredentialsProvider} object for authentication
     * @throws Exception
     */
    public void downloadWsdl(RowInfo row, String destDir, CredentialsProvider cp) throws IOException {
        CloseableHttpClient client = HttpClients.custom().setDefaultCredentialsProvider(cp).build();
        HttpGet httpGet = new HttpGet(row.getWsdlUrl());
        CloseableHttpResponse response = client.execute(httpGet);
        try {
            String body = EntityUtils.toString(response.getEntity());
            FileUtils.writeStringToFile(new File(destDir + File.separator + row.getEventName()), body, Charset.defaultCharset(), false);
        } finally {
            response.close();
        }
    }


    /**
     * <p>
     * Download all WSDL files from GoldenSource workflow Events WSDL.
     * </p>
     *
     * @param rows    a {@link List} of @{@link RowInfo} objects, the WSDL entries
     * @param destDir destination directory/folder which will contain the downloaded WSDL file
     * @param cp      a {@link CredentialsProvider} object for authentication
     */
    public void downloadAllWsdl(List<RowInfo> rows, String destDir, CredentialsProvider cp) {
        try {
            FileUtils.forceMkdir(new File(destDir));
            for (RowInfo row : rows) {
                downloadWsdl(row, destDir, cp);
            }
        } catch (IOException e) {
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "failed downloading body as string");
        }
    }
}
