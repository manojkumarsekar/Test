package com.eastspring.tom.cart.core.utl;

import org.apache.http.HttpHeaders;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

/**
 *
 * @author Daniel Baktiar
 * @since 2017-09
 */
public class WsClientUtil {
    private static final Logger LOGGER = LoggerFactory.getLogger(WsClientUtil.class);

    /**
     *
     * @param endpointUrl
     * @param cp
     * @param soapRawRequest
     * @return
     * @throws Exception
     */
    public String submitRawSoapRequest(String endpointUrl, CredentialsProvider cp, String soapRawRequest) throws IOException {
        CloseableHttpClient client = HttpClients.custom().setDefaultCredentialsProvider(cp).build();
        HttpPost httpPost = createHttpPost(endpointUrl, soapRawRequest);
        CloseableHttpResponse response = client.execute(httpPost);
        String body;
        try {
            LOGGER.debug("result status: {}", response.getStatusLine());
            body = EntityUtils.toString(response.getEntity());
            LOGGER.debug("response body:\n{}", body);
        } finally {
            response.close();
        }

        return body;
    }

    /**
     *
     * @param endpointUrl
     * @param soapRawRequest
     * @return
     * @throws Exception
     */
    protected HttpPost createHttpPost(String endpointUrl, String soapRawRequest) throws UnsupportedEncodingException {
        HttpPost httpPost = new HttpPost(endpointUrl);
        httpPost.addHeader(HttpHeaders.CONTENT_TYPE, "text/xml; charset=utf-8");
        httpPost.setEntity(new StringEntity(soapRawRequest));

        return httpPost;
    }
}
