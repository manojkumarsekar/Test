Feature: Performance L3 Attribution Pocket Level Historical Data Reconciliation: Legacy vs BNP DNA Platform
				
	
	Background:
		Given I prepare the reconciliation engine
#		When I list down missing DNA Breakdown from file "c:/tomwork/performance-l3/01-config/Request.csv"

	@reconciliation @performance @performance_l3 @performance_l3_pocket_reconciliation
    Scenario Outline: Generate the Performance L3 reconciliation report with highlighted mismatch

		Then I generate the Performance L3 Pocket Level report with end date "<end-date>" and DNA Breakdown file "c:/tomwork/performance-l3/01-config/Request.csv"
		Then I generate the Performance L3 Pocket Level reconciliation reports at location "c:/tomwork/performance-l3/04-result/pocket" for result name "<result-name>" with report end date "<end-date>"
		
	Examples:
        |result-name|end-date  |table-ext-name|
        |2016-08    |2016-08-31|201608        |
        |2016-09    |2016-09-30|201609        |
        |2016-10    |2016-10-31|201610        |
        |2016-11    |2016-11-30|201611        |
        |2016-12    |2016-12-31|201612        |
        |2017-01    |2017-01-31|201701        |
        |2017-02    |2017-02-28|201702        |
        |2017-03    |2017-03-31|201703        |
        |2017-04    |2017-04-30|201704        |
        |2017-05    |2017-05-31|201705        |
        |2017-06    |2017-06-30|201706        |
        |2017-07    |2017-07-31|201707        |
		|2017-12    |2017-12-31|201712        |
		

                                        