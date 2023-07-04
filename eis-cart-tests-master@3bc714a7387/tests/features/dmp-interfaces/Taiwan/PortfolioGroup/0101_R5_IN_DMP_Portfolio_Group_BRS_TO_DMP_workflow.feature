#https://jira.intranet.asia/browse/TOM-4034
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=50472988
#TOM-4132 : Updated workflow parameter for Load and Publish Exception Job
#TOM-4293 : Use the INPUT_FILENAME variable in NTEL ROW count sql instead of INPUT_FILENAME1
#https://jira.intranet.asia/browse/TOM-4410 - Portfolio Group Load | Relations not getting end_dated | SGLUKLNP already existing

@tom_4293 @dmp_portfolio_group @tom_4034 @tom_4132 @tom_4410 @dmp_gs_upgrade
Feature: Inbound Portfolio Group Interface Testing (R5.IN.DMP Portfolio Group BRS to DMP)

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_1: Clear the BRS Portfolio Group Data as a Prerequisite

    Given I assign "esi_portfolio_group_test_file_for_verification.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/PortfolioGroup" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/ClearData_BRSPortfolioGroup.sql
    """

  Scenario: TC_2: Process BRS User Group Data to DMP : Data Loading

    Given I assign "esi_portfolio_group_test_file_for_verification_template.xml" to variable "INPUT_TEMPLATENAME"
    And I assign "esi_portfolio_group_test_file_for_verification.xml" to variable "INPUT_FILENAME"
    Given I assign "esi_portfolio_group_test_file_for_port_inactivation_verification_template.xml" to variable "INPUT_RELOAD_TEMPLATENAME"
    And I assign "esi_portfolio_group_test_file_for_port_inactivation_verification.xml" to variable "INPUT_RELOAD_FILENAME"

    And I execute below query and extract values of "PORTFOLIO_BRS_FUND_ID_1;PORTFOLIO_BRS_FUND_ID_2;PORTFOLIO_BRS_FUND_ID_3;PORTFOLIO_BRS_FUND_ID_4" into same variables
     """
     ${testdata.path}/sql/fetch_portfolio_codes.sql
     """

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | | |

    And I create input file "${INPUT_RELOAD_FILENAME}" using template "${INPUT_RELOAD_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | | |



    Given I assign "esi_portfolio_group_test_file_for_verification.xml" to variable "INPUT_FILENAME"
    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_PORTFOLIO_GROUP"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "gomathi.sankar.ramakrishnan@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Errors found in DMP load of Portfolio Group"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "POST_EVENT_NAME" to "EIS_UpdateACGPInactivePortfolio"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

  Scenario: TC_3: Data Verifications

   # Validation 1: Portfolio Group - Total Successfully Processed ACGR Records => 3 records should be created in ACGR
      Then I expect value of column "ACGR_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
        """
    ${testdata.path}/sql/ACGR_Processed_Row_Count.sql
    """
   # Validation 2: Portfolio Group - Total Successfully Processed ACGP Records => 6 records should be created in ACGP
      Then I expect value of column "ACGP_PROCESSED_ROW_COUNT" in the below SQL query equals to "4":
        """
    ${testdata.path}/sql/ACGP_Processed_Row_Count.sql
    """
   # Validation 3: Exception Verification in NTEL for Fund which is not there in DMP and Fund and Portfolio Group Name is Blank
      Then I expect value of column "NTEL_EXCEPTION_COUNT" in the below SQL query equals to "2":
        """
    ${testdata.path}/sql/NTEL_Exception_Count.sql
        """

  Scenario: TC_4: Process BRS User Group Data to DMP : To verify portfolio which are not part of BRS Portfolio Group file should be inactivated

    Given I assign "esi_portfolio_group_test_file_for_port_inactivation_verification.xml" to variable "INPUT_FILENAME"
    Given I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_PORTFOLIO_GROUP"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "gomathi.sankar.ramakrishnan@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "Errors found in DMP load of Portfolio Group"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "POST_EVENT_NAME" to "EIS_UpdateACGPInactivePortfolio"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """


    Scenario: TC_5: Data Verifications for Portfolio Inactivation

   # Validation 1: Portfolio Group - Total Successfully Processed ACGR Records => 3 records should be created in ACGR
      Then I expect value of column "ACGR_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
        """
        ${testdata.path}/sql/ACGR_Processed_Row_Count.sql
        """
   # Validation 2: Portfolio Group - Total Successfully Processed ACGP Records => 6 records should be created in ACGP
      Then I expect value of column "ACGP_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
        """
        ${testdata.path}/sql/ACGP_Processed_Row_Count.sql
        """
