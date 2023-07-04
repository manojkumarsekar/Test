Feature: BRS to QSG Simple Delivery of Files

		Quantitave Solutions Group (QSG) team needs to receive files from Blackrock Solutions (BRS).
		BRS provides these files in its file repository, which needs to be picked up by MTF (MOVEIT) job.

		@smoke @hare @step05
    Scenario: Copy the BRS incoming files once in preparation of validating the workflows

#				Given I have no files at the host "dmp.ssh.inbound" folder "/dmp/archive/in/brs/qsg"
#				When I copy files below from local folder "testdata/BRS_QSG-regression/files" to the host "dmp.ssh.inbound" folder "/dmp/in/brs/qsg":

				When I copy files below from local folder "tests/test-data/dip-07-brs-qsg/files" to the host "dmp.ssh.inbound" folder "/home/jbossadm/automatedtest/dmp/in/brs/qsg":
				|esi_ADX_EOD_20171005_101010.tar.gz         |
				|esi_analytics_pnl.ESI_CORE_20171005.xml    |
				|esi_attribution.ESI_CORE_20171005.xml      |
				|esi_BRS_CURVES_DAILY_GP_20171005.csv       |
				|esi_BRS_CURVES_MONTHLY_GP_20171005.csv     |
				|esi_BRS_DISCFACTORS_DAILY_GP_20171005.csv  |
				|esi_BRS_DISCFACTORS_MONTHLY_GP_20171005.csv|
				|esi_cash_transaction_20171005.xml          |
				|esi_cash_walkforward.20171005.xml          |
				|esi_economy_20171005.xml                   |
				|esi_FACTOR_SGBEQ_20171005.xml              |
				|esi_FACTOR_SGBQIS_20171005.xml             |
				|esi_FOLE_ADX20171005.tar.gz                |
				|esi_index_weights_20171005.xml             |
				|esi_mortgage_geography_20171005.xml        |
				|esi_nav_20171005.xml                       |
				|esi_port_group_owned_20171005.xml          |
				|esi_portfolio_analytics_20171005.xml       |
				|esi_price.daily.allsources_20171005.xml    |
				|esi_restricted_position_20171005.xml       |
				|esi_SEC_VAR_SGBEQ_20171005.xml             |
				|esi_SEC_VAR_SGBQIS_20171005.xml            |

		@smoke @hare @step05
    Scenario Outline: BRS Simple File delivery for <case-name>
					
				And I set the workflow template parameter "CONFIG_SOURCE" to "BRS"
				And I set the workflow template parameter "FILE_PATTERN" to "<file-pattern>"
				And I set the workflow template parameter "FILE_PATH" to "/home/jbossadm/automatedtest/dmp/in/brs/qsg"
				And I set the workflow template parameter "ARCHIVE_FILE_PATH" to "<archive-file-path>"
				Given I set the DMP workflow web service endpoint to named configuration "dmp.ws.WORKFLOW"
				
				When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_FileTransfer/request.xmlt" and save the response to file "testout/evidence/dip-07-brs-qsg/resp/response-<case-id>.xml"

				Then I extract a value from the XML file "testout/evidence/dip-07-brs-qsg/resp/response-<case-id>.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_FileTransfer/flowResultIdQuery.xpath" to variable "flowResultId"

				Given I set the database connection to configuration "dmp.db.GC"
				Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "DONE":
				"""
				SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
				"""
				
				When I copy files below from remote folder "<archive-file-path>" on host "dmp.ssh.inbound" into local folder "testout/evidence/dip-07-brs-qsg/files/<case-id>/archived":
				|<sample-file1>|
				
		Examples:
				|case-id|case-name                       |file-pattern                       |archive-file-path                                  |sample-file1                               |
				|case001|Portfolio Groups                |esi_port_group_owned_*.xml         |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_port_group_owned_20171005.xml          |
				|case002|Aladdin Prices                  |esi_price.daily.allsources_*.xml   |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_price.daily.allsources_20171005.xml    |
				|case003|Cash Entries                    |esi_cash_transaction_*.xml         |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_cash_transaction_20171005.xml          |
				|case004|Cash Walkforward                |esi_cash_walkforward*.xml          |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_cash_walkforward.20171005.xml          |
				|case005|Daily Discount Factors Curves   |esi_BRS_DISCFACTORS_DAILY_GP*.csv  |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_BRS_DISCFACTORS_DAILY_GP_20171005.csv  |
				|case006|Daily Yield Curves              |esi_BRS_CURVES_DAILY_GP*.csv       |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_BRS_CURVES_DAILY_GP_20171005.csv       |
				|case007|Monthly Discount Factors Curves |esi_BRS_DISCFACTORS_MONTHLY_GP*.csv|/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_BRS_DISCFACTORS_MONTHLY_GP_20171005.csv|
				|case008|Monthly Yield Curves            |esi_BRS_CURVES_MONTHLY_GP*.csv     |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_BRS_CURVES_MONTHLY_GP_20171005.csv     |
				|case009|Economy                         |esi_economy_*.xml                  |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_economy_20171005.xml                   |
				|case010|End Of Day (EOD)                |esi_ADX_EOD_*.tar.gz               |/home/jbossadm/automatedtest/dmp/archive/in/brs/qsg|esi_ADX_EOD_20171005_101010.tar.gz         |


