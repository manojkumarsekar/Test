#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMID&title=INDONESIA+Consolidated+Requirements#businessRequirements-Change
#https://jira.intranet.asia/browse/TOM-3532
#TOM-3664 TOM ID - SCB Unit NAV prices to Aladdin
#TOM-3709 DB NAV publishing zero records
#TOM-3805 : Move domains from fld_id to fld_data_cl_id
#TOM-5224 : As per the new changes, SCB splitting the NAV file into two files one with Unit NAV price and another with Total NAV.
#           Unit NAV price need to be stored in DMP (as per IDM team all the price should be stored in DMP) and send to BRS as like old process.
#           In the case of Total NAV, SCB providing the file in BRS format. So this file should be a pass-through.

@gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@tom_3532 @scb_nav_to_dmp @tom_3805 @tom_5224
Feature: 001 | Price | ID SCB Price | Verify Price Load/Publish

  Scenario: Clear the data as a Prerequisite

    Given I assign "NAV_SCB.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Prices/ID_SCB_Price" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "CURR_DATE"

    And I create input file "NAV_SCB.csv" using template "NAV_SCB_Template.csv" from location "${testdata.path}/infiles"

    Given I execute below query to "Clear ISPC and ISGP data"
    """
    ${testdata.path}/sql/ClearData_NAV_SCB_ISPC.sql;
    ${testdata.path}/sql/ClearData_NAV_SCB_ISGP.sql
    """

  Scenario: Load NAV File

    Given I assign "NAV_SCB.csv" to variable "SCB_NAV_FILE"

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | ESII_MT_SCB_DMP_NAV |

    Given I extract new job id from jblg table into a variable "JOB_ID"

  Scenario: Data Verifications - ISPC

    # Validation 1: SCB NAV - Total Successfully Processed ISPC Records => 12 records should be created in ISPC
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
      """
      ${testdata.path}/sql/SCB_NAV_ISPC_Processed_Row_Count.sql
      """

  Scenario: Data Verifications - ISGP
    # Validation 2: SCB NAV - Total Successfully Processed ISGP Records => 12 records should be created in ISGP
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
      """
      ${testdata.path}/sql/SCB_NAV_ISGP_Processed_Row_Count.sql
      """

  Scenario: Data Verifications - ISPC UNIT PRICE

    # Validation 3: SCB NAV - NAV per unit for the account EII01DFCNDICEF00 should be 1116.87
    Then I expect value of column "NAV_PER_UNIT" in the below SQL query equals to "1998.46":
      """
      ${testdata.path}/sql/SCB_NAV_ISPC_NAV_PER_UNIT_MAX.sql
      """

  Scenario: Data Verifications - EXCEPTIONS
    # Validation 5: SCB NAV - Mandatory Field Missing Records => 1 record should be created in NTEL
    Then I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/SCB_NAV_Missing_Fields_Data_Exception.sql
      """

  Scenario: Publish price

    Given I assign "esi_price_ibpa" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I create input file "SCB_PRICE_INDONESIA_MASTER.csv" using template "SCB_PRICE_INDONESIA_MASTER_TEMPLATE.csv" from location "${testdata.path}/outfiles/reference"
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                   |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the attributes in the outbound file for Indonesia SCB Price

    Given I assign "SCB_PRICE_INDONESIA_MASTER.csv" to variable "SCB_PRICE_MASTER"

    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "SCB_PRICE_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect each record in file "${testdata.path}/outfiles/reference/testdata/${SCB_PRICE_MASTER}" should exist in file "${testdata.path}/outfiles/runtime/${SCB_PRICE_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file
