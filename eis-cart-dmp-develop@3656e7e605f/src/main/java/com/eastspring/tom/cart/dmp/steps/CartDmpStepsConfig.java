package com.eastspring.tom.cart.dmp.steps;

import com.eastspring.tom.cart.dmp.mdl.GSUISpec;
import com.eastspring.tom.cart.dmp.steps.websteps.LockFieldsAndEntitySteps;
import com.eastspring.tom.cart.dmp.steps.websteps.benchmark.master.BenchmarkSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.AcctGrpDetailSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.AcctMasterShareclassSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.AcctMasterSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.customer.master.ExternalAccountSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.exception.management.TransactionAndExceptionsSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.generic.setup.*;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.InstitutionSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.InstrumentGroupSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.IssueSteps;
import com.eastspring.tom.cart.dmp.steps.websteps.security.master.MktGrpDetailSteps;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CartDmpStepsConfig {

    @Bean
    public DmpGsPortalSteps dmpGsPortalSteps() {
        return new DmpGsPortalSteps();
    }

    @Bean
    public DmpGsWorkflowSteps dmpWorkflowSteps() {
        return new DmpGsWorkflowSteps();
    }

    @Bean
    public DmpTradeLifeCycleSteps dmpTradeLifeCycleSteps() {
        return new DmpTradeLifeCycleSteps();
    }

    @Bean
    public GSUISpec benchMarkSpec() {
        return new GSUISpec();
    }

    @Bean
    public AcctMasterSteps acctMasterSteps() {
        return new AcctMasterSteps();
    }

    @Bean
    public MktGrpDetailSteps mktGrpDetailSteps() {
        return new MktGrpDetailSteps();
    }

    @Bean
    public AcctGrpDetailSteps acctGrpDetailSteps() {
        return new AcctGrpDetailSteps();
    }

    @Bean
    public RequestTypeConfigSteps requestTypeConfigSteps() {
        return new RequestTypeConfigSteps();
    }

    @Bean
    public CentralCrossRefGrpSteps centralCrossRefGrpSteps() {
        return new CentralCrossRefGrpSteps();
    }

    @Bean
    public InstrumentGroupSteps instrumentGroupSteps() {
        return new InstrumentGroupSteps();
    }

    @Bean
    public BenchmarkSteps benchmarkSteps() {
        return new BenchmarkSteps();
    }

    @Bean
    public TransactionAndExceptionsSteps transactionAndExceptionsSteps() {
        return new TransactionAndExceptionsSteps();
    }

    @Bean
    public TaiwanBrokerSteps taiwanBrokerSteps() {
        return new TaiwanBrokerSteps();
    }

    @Bean
    public InstitutionSteps institutionSteps() {
        return new InstitutionSteps();
    }

    @Bean
    public IndustryClassificationSteps industryClassificationSteps() {
        return new IndustryClassificationSteps();
    }

    @Bean
    public IssueSteps issueSteps() {
        return new IssueSteps();
    }

    @Bean
    public ExternalAccountSteps externalAccountSteps(){ return new ExternalAccountSteps();}
    @Bean
    public GroupTreasuryConfigSteps groupTreasuryConfigSteps() { return new GroupTreasuryConfigSteps(); }

    @Bean
    public LockFieldsAndEntitySteps lockFieldsAndEntitySteps() { return new LockFieldsAndEntitySteps(); }

    @Bean
    public MappingSteps mappingSteps(){
        return new MappingSteps();
    }

    @Bean
    public AcctMasterShareclassSteps shareclassSteps(){
        return new AcctMasterShareclassSteps();
    }

    @Bean
    public ControlMServiceSteps controlMServiceSteps(){
        return new ControlMServiceSteps();
    }



}
