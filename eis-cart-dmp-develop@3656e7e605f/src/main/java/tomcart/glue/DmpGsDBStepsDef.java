package tomcart.glue;

import com.eastspring.tom.cart.core.CartBootstrap;
import com.eastspring.tom.cart.dmp.steps.DmpGsWorkflowSteps;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;

public class DmpGsDBStepsDef {

    private DmpGsWorkflowSteps wfSteps = (DmpGsWorkflowSteps) CartBootstrap.getBean(DmpGsWorkflowSteps.class);

    @Given( "I set end_tms to SYSDATE in database {string} where iss_id in {string}" )
    public void setEndTmsToSysdate(final String databaseConfig, final String issid) {
        wfSteps.setEndTmsToSYSDATEAsPerDBConfig(databaseConfig, issid);
    }

    @Then( "I ensure all instruments defined in the BB price feed {string} are configured with BBPRICEGRP group" )
    public void addBBInstrumentsToTheBBPriceGroup(final String bbPriceFeedFile) {
        wfSteps.addBBInstrumentsToTheBBPriceGroup(bbPriceFeedFile);
    }

    @Then( "I update PPED_OID column for all instruments defined in the BB price feed {string} with ESIPRPTEOD" )
    public void updateBBInstrumentRecordsWithESIPRPTEODInISPCTable(final String bbPriceFeedFile) {
        wfSteps.updateBBInstrumentRecordsWithESIPRPTEODInISPCTable(bbPriceFeedFile);
    }

    @Then( "I delete price records for all instruments defined in the BB price feed {string}" )
    public void deleteBBInstrumentRecordsFromDMP(final String bbPriceFeedFile) {
        wfSteps.deleteBBInstrumentRecordsFromDMP(bbPriceFeedFile);
    }

    @Then( "I setup instruments defined in the BB price feed with BNP file {string} in the path {string}" )
    public void setupBBPriceInstrumentsWithBNPFeed(final String instrumentFeed, final String feedPath) {
        wfSteps.setupBBPriceInstrumentsWithBNPFeed(instrumentFeed, feedPath);
    }

    @Then( "I extract new job id from jblg table into a variable {string}" )
    public void iExtractJobIdFromJblgTable(final String jobIdVar) {
        wfSteps.iExtractJobIdFromJblgTable(jobIdVar);
    }
}
