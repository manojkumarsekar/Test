# ===================================================================================================================
# Date            JIRA        Comments                  Jira
# ============    ========    ========                  ========
# 02/11/2018      TOM-3619    First Version             https://jira.intranet.asia/browse/TOM-3619
# 09/11/2018      TOM-3853    Second Version            https://jira.intranet.asia/browse/TOM-3853
# 13/11/2018      TOM-3869    Third Version             https://jira.intranet.asia/browse/TOM-3869
# 28/11/2018      TOM-3955    Fourth Version            https://jira.intranet.asia/browse/TOM-3955
# ====================================================================================================================

@eisdev_6945 @gc_interface_excel2csv
@gc_interface_nav @gc_interface_reds @gc_interface_dividend
@dmp_regression_integrationtest @eisdev_7374
@tom_3869 @tom_3853 @tom_3838 @tom_3619 @db_nav_hist @db_nav_pm @db_dividend_ut @db_reds_pm
Feature: Loading NAV files from DB into DMP

  Parent Issue Description: To load DB NAV files to DMP and generate consolidated files to BNP, as there are multiple files coming from DB and the data is not in BNP format, we need an interface to generate a single file
  Solution: Load all the input files into DMP, do necessary conversion while generating publishing file, generate the consolidated output file.
  Please refer the above jira links to review the ticket.

  This Feature file is ti test the Load data functionality of DB nav data into DMP and check if SHARE PRICE value is correctly stored as it was wrongly stored.
  Please refer the above jira links to review the ticket.

  This Feature file is to test the Fund Name in the publish file as it was mapped to Fund Description, it should be mapped to Fund Name as all the Shared class funds are not having fund description.
  Please refer the above jira links to review the ticket.

  Issue During green tests: This Feature file is modified to validate the correct number of records in EIB_NAVHist_01102018.xls file, please refer the above jira links to review the ticket.

  Scenario: TC_1: Assign Variables
     # Assigning input file names and paths

    Given I assign "tests/test-data/DevTest/TOM-3619" to variable "testdata.path"
    And I assign "EIB_NAVHist_01102018.xls" to variable "INPUT_FILENAME_1"
    And I assign "EIB_NAVHist_01102018.csv" to variable "INPUT_FILENAME_1_CSV"
    And I assign "FundNAV_PM_Oct2018.csv" to variable "INPUT_FILENAME_2"
    And I assign "Subs_Reds_PM_Oct2018.csv" to variable "INPUT_FILENAME_3"
    And I assign "Dividend_UT_Oct2018.csv" to variable "INPUT_FILENAME_4"
    And I assign "/dmp/out/bnp/eom" to variable "PUBLISHING_DIR"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "-1M" from source format "YYYYMMdd" to destination format "MM/YYYY" and assign to "VALUATION_MONTH"
    And I modify date "${VAR_SYSDATE}" with "-1M" from source format "YYYYMMdd" to destination format "YYYYMM" and assign to "VALUATION_CHECK"


  Scenario: TC_2: Cleardown any existing data

    When I execute below query to "Clear data for the given NAV for FT_T_ACCV and FT_T_PRFH Tables"
    """
    ${testdata.path}/sql/ClearData_NAV_DB.sql
    """

  Scenario: TC_3: Executing the MDXs

    Given I create input file "${INPUT_FILENAME_1}" using template "EIB_NAVHist_01102018_Template.xls" from location "${testdata.path}/inputfiles"
    And I create input file "${INPUT_FILENAME_2}" using template "FundNAV_PM_Oct2018_Template.csv" from location "${testdata.path}/inputfiles"

    When I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |
      | ${INPUT_FILENAME_2} |
      | ${INPUT_FILENAME_3} |
      | ${INPUT_FILENAME_4} |

    Given I set the workflow template parameter "BUSINESS_FEED" to "EIM_BF_DB_NAV_HIST"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EIM_MT_DB_NAV_HIST"
    And I set the workflow template parameter "INPUT_DATA_DIR" to "${dmp.ssh.inbound.path}"
    And I set the workflow template parameter "FILEPATTERN" to "${INPUT_FILENAME_1}"
    And I set the workflow template parameter "PARALLELISM" to "1"
    And I set the workflow template parameter "OUTPUT_DATA_DIR" to "${dmp.ssh.archive.path}"
    And I set the workflow template parameter "SUCCESS_ACTION" to "MOVE"
    And I set the workflow template parameter "LOAD_FILE_PATTERN" to "${INPUT_FILENAME_1_CSV}"
    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 120 seconds and expect the result of the SQL query below equals to "DONE":
      """
      SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
      """

#    Given I process ConvertXlsxToCsvLoad workflow with below parameters and wait for the job to be completed
#      | BUSINESS_FEED     |                         |
#      | FILEPATTERN       | ${INPUT_FILENAME_1}     |
#      | MESSAGE_TYPE      | EIM_MT_DB_NAV_HIST      |
#      | PARALLELISM       | 1                       |
#      | SUCCESS_ACTION    | MOVE                    |
#      | INPUT_DATA_DIR    | ${dmp.ssh.inbound.path} |
#      | OUTPUT_DATA_DIR   | ${dmp.ssh.archive.path} |
#      | LOAD_FILE_PATTERN | ${INPUT_FILENAME_1_CSV} |
#    Then I expect workflow is processed in DMP with total record count as "32"
#    And success record count as "32"

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME_2} |
      | MESSAGE_TYPE  | EIM_MT_DB_NAV_PM    |
    Then I expect workflow is processed in DMP with total record count as "279"
    And success record count as "279"

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME_3} |
      | MESSAGE_TYPE  | EIM_MT_DB_REDS_PM   |
    Then I expect workflow is processed in DMP with total record count as "1"
    And success record count as "1"

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_4}   |
      | MESSAGE_TYPE  | EIM_MT_DB_DIVIDEND_UT |
    Then I expect workflow is processed in DMP with total record count as "5"
    And success record count as "4"

  Scenario: TC_4: Validating the records

  # Checking NAV hist records from EIB_NAVHist_01102018.xls file
    Then I expect value of column "ID_COUNT_NAV" in the below SQL query equals to "32":
     """
     SELECT COUNT(*) AS ID_COUNT_NAV
     FROM FT_T_ACCV
     WHERE DATA_SRC_ID  ='DB'
	 AND VALU_TYP = 'HIST'
	 AND LAST_CHG_USR_ID = 'EIM_DB_DMP_NAV_HIST'
	 """

   # Checking SHARE_PRICE FROM ft_t_accv table for the portfolio MYAE005
    Then I expect value of column "SHARE_PRICE" in the below SQL query equals to ".7022":
    """
     SELECT NAV_CRTE AS SHARE_PRICE
     FROM FT_T_ACCV
     WHERE DATA_SRC_ID  ='DB'
	 AND VALU_TYP = 'HIST'
     AND ACCT_ID = (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'MYAE005')
	 """
    # Checking NET_ASSET_VALUE FROM ft_t_accv table for the portfolio MYAE005
    Then I expect value of column "NET_ASSET_VALUE" in the below SQL query equals to "521640458.48":
     """
     SELECT VALU_VAL_CAMT AS NET_ASSET_VALUE
     FROM FT_T_ACCV
     WHERE DATA_SRC_ID  ='DB'
	 AND VALU_TYP = 'HIST'
     AND ACCT_ID = (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'MYAE005')
     """

  Scenario: TC_5: Publish DB NAV file

    Given I assign "EIB_NAVHist" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/bnp/eom" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}* |

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIM_DMP_TO_BNP_DB_NAV_SUB   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_6: Check the values in outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if PORTFOLIO MMPRU17 has value 0.5758 in the outbound
    Then I expect column "Share Price" value to be "0.5758" where columns values are as below in CSV file "${CSV_FILE}"
      | Portfolio Code | MYUDEF               |
      | Valuation date | ${VALUATION_CHECK}01 |

  Scenario: TC_6: Check the fund description for a shared fund

     #Check if PORTFOLIO MYUAHYAH has value EASTSPRING INVESTMENTS ASIAN HY BOND MY CLASS AUD (HEDGED) in the outbound
    Given I expect column "Fund Description" value to be "Eastspring Investments Asian High Yield Bond My Fund AUD" where columns values are as below in CSV file "${CSV_FILE}"
      | Portfolio Code | MYUAHYAH             |
      | Valuation date | ${VALUATION_CHECK}01 |


