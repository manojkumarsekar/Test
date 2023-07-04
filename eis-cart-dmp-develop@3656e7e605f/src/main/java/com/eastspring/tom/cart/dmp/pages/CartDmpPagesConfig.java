package com.eastspring.tom.cart.dmp.pages;

import com.eastspring.tom.cart.dmp.pages.benchmark.master.BenchmarkPage;
import com.eastspring.tom.cart.dmp.pages.customer.master.AccountMasterPage;
import com.eastspring.tom.cart.dmp.pages.customer.master.AccountMasterShareClassPage;
import com.eastspring.tom.cart.dmp.pages.customer.master.AcctGrpDetailPage;
import com.eastspring.tom.cart.dmp.pages.customer.master.ExternalAccountPage;
import com.eastspring.tom.cart.dmp.pages.exception.management.TransactionAndExceptionsPage;
import com.eastspring.tom.cart.dmp.pages.generic.setup.CentralCrossRefGrpPage;
import com.eastspring.tom.cart.dmp.pages.generic.setup.GroupTreasuryConfigPage;
import com.eastspring.tom.cart.dmp.pages.generic.setup.RequestTypeConfigPage;
import com.eastspring.tom.cart.dmp.pages.generic.setup.TaiwanBrokerPage;
import com.eastspring.tom.cart.dmp.pages.industryclassif.IndustryClassificationSetPage;
import com.eastspring.tom.cart.dmp.pages.internaldomaindatafeed.InternalDomainDataFeedPage;
import com.eastspring.tom.cart.dmp.pages.internaldomaindatafeedclass.InternalDomainDataFeedClassPage;
import com.eastspring.tom.cart.dmp.pages.issue.IssuePage;
import com.eastspring.tom.cart.dmp.pages.myworklist.MyWorkListPage;
import com.eastspring.tom.cart.dmp.pages.security.master.InstitutionPage;
import com.eastspring.tom.cart.dmp.pages.security.master.InstrumentGroupPage;
import com.eastspring.tom.cart.dmp.pages.security.master.MrktGrpDetailPage;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartDmpPagesConfig {

    @Bean
    public LoginPage loginPage() {
        return new LoginPage();
    }

    @Bean
    public HomePage homePage() {
        return new HomePage();
    }

    @Bean
    public BenchmarkPage benchmarkPage() {
        return new BenchmarkPage();
    }

    @Bean
    public MyWorkListPage myWorkList() {
        return new MyWorkListPage();
    }

    @Bean
    public AccountMasterPage accountMasterPage() {
        return new AccountMasterPage();
    }

    @Bean
    public IndustryClassificationSetPage indstryClassifCreatePage() {
        return new IndustryClassificationSetPage();
    }

    @Bean
    public AuditLogReportPage auditLogReportPage() {
        return new AuditLogReportPage();
    }

    @Bean
    public InternalDomainDataFeedPage internalDomainDataFeed() {
        return new InternalDomainDataFeedPage();
    }

    @Bean
    public InternalDomainDataFeedClassPage internalDomianDataFeedClass() {
        return new InternalDomainDataFeedClassPage();
    }

    @Bean
    public IssuePage issuePage() {
        return new IssuePage();
    }

    @Bean
    public TransactionAndExceptionsPage transactionAndExceptionsPage() {
        return new TransactionAndExceptionsPage();
    }

    @Bean
    public AcctGrpDetailPage acctGrpDetailsPage() {
        return new AcctGrpDetailPage();
    }

    @Bean
    public MrktGrpDetailPage mrktGrpDetailsPage() {
        return new MrktGrpDetailPage();
    }


    @Bean
    public RequestTypeConfigPage requestTypeConfigPage() {
        return new RequestTypeConfigPage();
    }

    @Bean
    public CentralCrossRefGrpPage centralCrossRefGrpPage() {
        return new CentralCrossRefGrpPage();
    }

    @Bean
    public InstrumentGroupPage instrumentGroupPage() {
        return new InstrumentGroupPage();
    }

    @Bean
    public TaiwanBrokerPage taiwanBrokerPage() {
        return new TaiwanBrokerPage();
    }

    @Bean
    public InstitutionPage institutionPage() {
        return new InstitutionPage();
    }

    @Bean
    public ExternalAccountPage externalAccountPage(){ return new ExternalAccountPage();}
    @Bean
    public GroupTreasuryConfigPage groupTreasuryConfigPage() {
        return new GroupTreasuryConfigPage();
    }

    @Bean
    public LockFieldsAndEntityPage lockFieldsAndEntityPage() { return new LockFieldsAndEntityPage(); }

    @Bean
    public AccountMasterShareClassPage AccountMasterShareClassPage() { return new AccountMasterShareClassPage(); }
}
