package com.eastspring.tom.cart.dmp.svc;

import com.eastspring.tom.cart.constant.BrsApiConstants;
import com.eastspring.tom.cart.core.CartException;
import com.eastspring.tom.cart.core.CartExceptionType;
import com.eastspring.tom.cart.core.svc.RestApiSvc;
import com.eastspring.tom.cart.core.svc.StateSvc;
import com.eastspring.tom.cart.core.utl.FileDirUtil;
import com.eastspring.tom.cart.core.utl.FormatterUtil;
import com.eastspring.tom.cart.core.utl.JsonUtil;
import com.eastspring.tom.cart.core.utl.WorkspaceUtil;
import com.eastspring.tom.cart.dmp.utl.BrsApiUtl;
import io.restassured.response.Response;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.CloseableHttpClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.*;

import static com.eastspring.tom.cart.constant.BrsApiConstants.*;

public class ResearchReportBrsApiSvc {

    private static final Logger LOGGER = LoggerFactory.getLogger(ResearchReportBrsApiSvc.class);

    @Autowired
    private BrsApiUtl brsApiUtl;

    @Autowired
    private JsonUtil jsonUtil;

    @Autowired
    private StateSvc stateSvc;

    @Autowired
    private FileDirUtil fileDirUtil;

    @Autowired
    private WorkspaceUtil workspaceUtil;

    @Autowired
    private RestApiSvc restApiSvc;

    @Autowired
    private FormatterUtil formatterUtil;


    public String generateAPIBodyParameters(String apiBodyTemplatesDir, String apiBodyDir, Map<String, String> apiParamsMap) {
        constructEmailTemplateParamsFromMap(apiParamsMap);
        String apibodyFileName = apiBodyDir + File.separator + BrsApiConstants.BRS_API_FILE;
        String apiTemplate = apiBodyTemplatesDir + File.separator + BrsApiConstants.BRS_ORDER_API_TEMPLATE_FILE;
        String fullapiFilePath = fileDirUtil.addPrefixIfNotAbsolute(apibodyFileName, workspaceUtil.getBaseDir());
        LOGGER.debug("API body File Full Path [{}]", fullapiFilePath);
        fileDirUtil.writeStringToFile(fullapiFilePath, stateSvc.expandVar(fileDirUtil.readFileToString(apiTemplate)));
        String brsApiParameters = fileDirUtil.readFileToString(fullapiFilePath);
        return brsApiParameters;
    }


    public void constructEmailTemplateParamsFromMap(Map<String, String> templateParamsMap) {
        Set<String> keys = templateParamsMap.keySet();
        for (String key : keys) {
            String paramValueExpanded = stateSvc.expandVar(templateParamsMap.get(key));
            stateSvc.setStringVar(key, paramValueExpanded);
        }
    }

    public void postBRSOrderUsingBodyTemplate(String apiBodyTemplatesDir, String apiBodyDir, Map<String, String> apiParamsMap) {
        CloseableHttpClient httpClient = null;
        try {
            String apiBodyContent = generateAPIBodyParameters(apiBodyTemplatesDir, apiBodyDir, apiParamsMap);
            httpClient = brsApiUtl.createHttpClient();
            HttpPost httpPost = brsApiUtl.createHttpPost(stateSvc.getStringVar(BrsApiConstants.BRS_ORDER_API_URL));
            httpPost = brsApiUtl.setBodyParameters(httpPost, apiBodyContent);
            HttpResponse response = brsApiUtl.getHTTPPostResponse(httpClient, httpPost);
            String getResonseText = brsApiUtl.getResponseBody(response);
            String apiResponseFileName = apiBodyDir + File.separator + BrsApiConstants.BRS_ORDER_API_RESPONSE_FILE;
            String fullapiFilePath = fileDirUtil.addPrefixIfNotAbsolute(apiResponseFileName, workspaceUtil.getBaseDir());
            fileDirUtil.writeStringToFile(fullapiFilePath, getResonseText);
            Map<String, Object> resultMap = jsonUtil.jsonFileToMap(new File(fullapiFilePath));
            if (!resultMap.isEmpty()) {
                ArrayList<Object> orderDetailsList = (ArrayList<Object>) resultMap.get("postOrderResults");
                LinkedHashMap<Object, Object> orderDetails = (LinkedHashMap<Object, Object>) orderDetailsList.get(0);
                String orderNumExpanded = stateSvc.expandVar(orderDetails.get("orderId").toString());
                stateSvc.setStringVar("brs.api.order.number", orderNumExpanded);
                LOGGER.info("Order created from API has order number=[{}],order status=[{}]", orderDetails.get("orderId").toString(), orderDetails.get("orderStatus").toString());
            } else {
                LOGGER.error("Response not received post order placing using BRS Api[{}]", resultMap);
                throw new CartException(CartExceptionType.PROCESSING_FAILED, "Response not received post order placing using BRS Api[{}]", resultMap);
            }
        } catch (Exception e) {
            LOGGER.error("Unable to post order using API", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to post order using API" + e);
        } finally {
            //Important: Close the connect
            brsApiUtl.closeHttpClent(httpClient);
        }
    }


    public void extractOrderDetailsAndResultsToVars(String orderDetailsResponseFile, Map<String, String> orderMap) {
        Map<String, Object> resultMap = jsonUtil.jsonFileToMap(new File(orderDetailsResponseFile));
        LinkedHashMap<Object, Object> orderDetails = null;
        LinkedHashMap<Object, Object> portfolioDetails = null;
        LinkedHashMap<Object, Object> securityDetails = null;
        LinkedHashMap<Object, Object> commentsDetails = null;

        if (!resultMap.isEmpty()) {
            ArrayList<Object> orderDetailsList = (ArrayList<Object>) resultMap.get("orders");
            orderDetails = (LinkedHashMap<Object, Object>) orderDetailsList.get(0);
            if (orderDetails.containsKey("orderDetails")) {
                ArrayList<Object> portfolioDetailsList = (ArrayList<Object>) orderDetails.get("orderDetails");
                if (portfolioDetailsList.size() != 0) {
                    portfolioDetails = (LinkedHashMap<Object, Object>) portfolioDetailsList.get(0);
                }
            }

            if (orderDetails.containsKey("security")) {
                securityDetails = (LinkedHashMap<Object, Object>) orderDetails.get("security");
            }

            if (orderDetails.containsKey("comments")) {
                ArrayList<Object> commentDetailsList = (ArrayList<Object>) orderDetails.get("comments");
                if (commentDetailsList.size() != 0) {
                    commentsDetails = (LinkedHashMap<Object, Object>) commentDetailsList.get(0);
                }
            }

        } else {
            LOGGER.error("Response not received post order placing using BRS Api[{}]", resultMap);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Response not received post order placing using BRS Api[{}]", resultMap);
        }


        for (String columnName : orderMap.keySet()) {
            String fieldName = orderMap.get(columnName);
            String result = "";
            if (!orderDetails.containsKey(fieldName)) {
                if (portfolioDetails != null && portfolioDetails.containsKey(fieldName)) {
                    if (portfolioDetails.get(fieldName) != null) {
                        result = portfolioDetails.get(fieldName).toString();
                    }
                } else if (securityDetails != null && securityDetails.containsKey(fieldName)) {
                    if (securityDetails.get(fieldName) != null) {
                        result = securityDetails.get(fieldName).toString();
                    }
                } else if (commentsDetails != null && commentsDetails.containsKey(fieldName)) {
                    if (commentsDetails.get(fieldName) != null) {
                        result = commentsDetails.get(fieldName).toString();
                    }
                }

            } else {
                if (orderDetails.get(fieldName) != null) {
                    result = orderDetails.get(fieldName).toString();
                }
            }
            stateSvc.setStringVar(columnName, result);
            LOGGER.debug("multi value query setStringVar: {} is {}", columnName, result);
        }
    }

    public void retrieveBRSOrderDetails(String apiBodyDir, String orderNumber, Map<String, String> orderParams) {
        CloseableHttpClient httpClient = null;
        try {
            httpClient = brsApiUtl.createHttpClient();
            String expandedOrderNum = stateSvc.expandVar(orderNumber);
            HttpGet httpGet = brsApiUtl.createHttpGet(stateSvc.getStringVar(BrsApiConstants.BRS_ORDER_API_URL) + expandedOrderNum);
            HttpResponse response = brsApiUtl.getHTTPGetResponse(httpClient, httpGet);
            String getResonseText = brsApiUtl.getResponseBody(response);
            String apiResponseFileName = apiBodyDir + File.separator + BrsApiConstants.BRS_ORDER_API_RESPONSE_FILE;
            String fullapiFilePath = fileDirUtil.addPrefixIfNotAbsolute(apiResponseFileName, workspaceUtil.getBaseDir());
            fileDirUtil.writeStringToFile(fullapiFilePath, getResonseText);
            extractOrderDetailsAndResultsToVars(fullapiFilePath, orderParams);
        } catch (Exception e) {
            LOGGER.error("Unable to retrieve order using API", e);
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to retrieve order using API" + e);
        } finally {
            //Important: Close the connect
            brsApiUtl.closeHttpClent(httpClient);
        }
    }


    @SuppressWarnings("unchecked")
    public Map<String, Object> retrieveBRSTradeDetails(String tradeReference) {
        Map<String, String> queryParams = new HashMap<>();
        queryParams.put("tradeId", tradeReference);

        final String[] tradeId = tradeReference.split(":");
        final String rootJsonKey = formatterUtil.format(TRADE_RECORD_BY_INVNUM_JSON_PATH, tradeId[0], tradeId[1]);
        final Response response = brsApiUtl.getRequest(BRS_TRADES_API_ENDPOINT, queryParams);

        return (HashMap<String, Object>) jsonUtil.readObjectByJsonpath(response.asString(), rootJsonKey);
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> placeBrsTrade(final String jsonBodyContent) {
        final Response response = brsApiUtl.postRequest(BRS_TRADES_API_ENDPOINT, jsonBodyContent);
        String responeMessage = jsonUtil.readObjectByJsonpath(response.asString(), TRADE_RESPONSE_ERROR_JSON_PATH).toString();
        if(!responeMessage.contains("error")){
            return (HashMap<String, Object>) jsonUtil.readObjectByJsonpath(response.asString(), TRADE_RESPONSE_ALLOCATIONS_JSON_PATH);
        }else{
            LOGGER.error("Unable to post trade using the given parameters");
            throw new CartException(CartExceptionType.PROCESSING_FAILED, "Unable to post trade using the given parameters:"
                                    + responeMessage.split(":")[1]);
        }
    }

}
