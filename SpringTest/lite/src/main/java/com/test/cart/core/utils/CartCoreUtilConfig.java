package com.eastspring.qa.cart.core.utils;

import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import com.eastspring.qa.cart.core.utils.core.WorkspaceUtil;
import com.eastspring.qa.cart.core.utils.file.CsvUtil;
import com.eastspring.qa.cart.core.utils.file.FileDirUtil;
import com.eastspring.qa.cart.core.utils.file.JsonUtil;
import com.eastspring.qa.cart.core.utils.file.XmlUtil;
import com.eastspring.qa.cart.core.utils.datetime.DateTimeUtil;
import com.eastspring.qa.cart.core.utils.secret.SecretUtil;
import com.eastspring.qa.cart.core.utils.sync.ThreadUtil;
import com.eastspring.qa.cart.core.utils.testData.TestDataFileUtil;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartCoreUtilConfig {

    @Bean
    public JsonUtil jsonUtil() {
        return new JsonUtil();
    }

    @Bean
    public XmlMapper mapper() {
        return new XmlMapper();
    }

    @Bean
    public SecretUtil secretUtil() {
        return new SecretUtil();
    }

    @Bean
    public CsvUtil csvUtil() {
        return new CsvUtil();
    }

    @Bean
    public DateTimeUtil dateTimeUtil() {
        return new DateTimeUtil();
    }

    @Bean
    public FileDirUtil fileDirUtil() {
        return new FileDirUtil();
    }

    @Bean
    public WorkspaceUtil workspaceUtil() {
        return new WorkspaceUtil();
    }

    @Bean
    public XmlUtil xmlUtil() {
        return new XmlUtil();
    }

    @Bean
    public TestDataFileUtil testDataFileUtil() {
        return new TestDataFileUtil();
    }

    @Bean
    public ThreadUtil threadUtil() {
        return new ThreadUtil();
    }
}