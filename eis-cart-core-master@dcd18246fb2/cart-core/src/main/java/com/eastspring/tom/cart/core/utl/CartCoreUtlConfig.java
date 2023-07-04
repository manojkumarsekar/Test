package com.eastspring.tom.cart.core.utl;

import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import org.flywaydb.core.Flyway;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartCoreUtlConfig {

    @Bean
    public JsonUtil jsonUtil() {
        return new JsonUtil();
    }

    @Bean
    public AwaitilityUtil awaitilityUtil() {
        return new AwaitilityUtil();
    }

    @Bean
    public ScenarioUtil scenarioUtil() {
        return new ScenarioUtil();
    }

    @Bean
    public XmlMapper mapper() {
        return new XmlMapper();
    }

    @Bean
    public CredentialsUtil credentialsUtil() {
        return new CredentialsUtil();
    }

    @Bean
    public CssUtil cssUtil() {
        return new CssUtil();
    }

    @Bean
    public CsvUtil csvUtil() {
        return new CsvUtil();
    }

    @Bean
    public CukesTagUtil cukesTagUtil() {
        return new CukesTagUtil();
    }

    @Bean
    public DataTableUtil dataTableUtil() {
        return new DataTableUtil();
    }

    @Bean
    public DateTimeUtil dateTimeUtil() {
        return new DateTimeUtil();
    }

    @Bean
    public EncodingUtil encodingUtil() {
        return new EncodingUtil();
    }

    @Bean
    public ExcelFormatUtil excelFormatUtil() {
        return new ExcelFormatUtil();
    }

    @Bean
    public FileDirUtil fileDirUtil() {
        return new FileDirUtil();
    }

    @Bean
    public FileValidatorUtil fileValidatorUtil() {
        return new FileValidatorUtil();
    }

    @Bean
    public FlywayUtil flywayUtil() {
        return new FlywayUtil();
    }

    @Bean
    public FormatterUtil formatterUtil() {
        return new FormatterUtil();
    }

    @Bean
    public LinuxRuntimeUtil linuxRuntimeUtilService() {
        return new LinuxRuntimeUtil();
    }

    @Bean
    public NumericVerificationUtil numericVerificationUtil() {
        return new NumericVerificationUtil();
    }

    @Bean
    public PerformanceExcelUtil performanceExcelUtil() {
        return new PerformanceExcelUtil();
    }

    @Bean
    public SensitivePassAwareDebugLogUtil sensitivePassAwareDebugLogUtil() {
        return new SensitivePassAwareDebugLogUtil();
    }

    @Bean
    public SqlStringUtil stringUtil() {
        return new SqlStringUtil();
    }

    @Bean
    public StringVerifyUtil stringVerifyUtil() {
        return new StringVerifyUtil();
    }

    @Bean
    public SysEnvUtil sysEnvUtil() {
        return new SysEnvUtil();
    }

    @Bean
    public TcpUtil tcpUtil() {
        return new TcpUtil();
    }

    @Bean
    public WindowsRuntimeUtil windowsRuntimeUtil() {
        return new WindowsRuntimeUtil();
    }

    @Bean
    public WorkspaceUtil workspaceUtil() {
        return new WorkspaceUtil();
    }

    @Bean
    public WriterUtil writerUtil() {
        return new WriterUtil();
    }

    @Bean
    public WsClientUtil wsClientUtil() {
        return new WsClientUtil();
    }

    @Bean
    public XmlUtil xmlUtil() {
        return new XmlUtil();
    }

    @Bean
    public XPathUtil xPathUtil() {
        return new XPathUtil();
    }

    @Bean
    public Flyway flyway() {
        return new Flyway();
    }

    @Bean
    public MathUtil mathUtil() {
        return new MathUtil();
    }

    @Bean
    public FtpUtil ftpUtil() {
        return new FtpUtil();
    }

    @Bean
    public HtmlGenUtil htmlGenUtil() {
        return new HtmlGenUtil();
    }

    @Bean
    public ImageUtl imageUtl() {
        return new ImageUtl();
    }
}
