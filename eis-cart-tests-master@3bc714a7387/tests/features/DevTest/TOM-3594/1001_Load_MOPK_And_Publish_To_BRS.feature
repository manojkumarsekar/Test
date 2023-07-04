# https://collaborate.intranet.asia/pages/viewpage.action?pageId=45855649
# https://jira.intranet.asia/browse/TOM-3594

@gc_interface_positions
@dmp_regression_integrationtest
@tom_3594 @dmp_gs_upgrade
Feature: Loading BNP daily MOPK into GC and publishing to BRS

  These testcases are validate the BNP Position Bookprice and Bookvalue in the inbound and outbound

  Below Steps are following to validate this testing

  Prerequisite
  1. Clear old test data and create input and output files from templates

  Testcase
  2. Load the BNP files(ESISODP_POS_*.out - Position without corporate action, ESISODP_SDP_1*.out -Position with corporate action)
  3, Publish the Non-FX
  4. Validate publish file against the database -  Bookcost and Nominal are not null in the BNP input file
  5. Validate publish file against the database -  Bookcost and Nominal are null in the BNP input file

  Scenario: TC_1: Clear old test data and create input and output files from templates

    Given I assign "tests/test-data/DevTest/TOM-3594" to variable "testdata.path"
    And I assign "esi_brs_positionnonfx_recon" to variable "PUBLISHING_FILENAME_NONFX"
    And I assign "${dmp.ssh.outbound.path}/brs/sod" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+1d" from source format "YYYYMMdd" to destination format "yyyy-MMM-dd" and assign to "PUBLISH_DATE_IN"
    And I modify date "${VAR_SYSDATE}" with "+1d" from source format "YYYYMMdd" to destination format "yyyyMMdd" and assign to "PUBLISH_DATE_OUT"

    And I execute below query to "Clear the old data"
    """
    ${testdata.path}/sql/cleardown.sql
    """
    # create a new version of input file from template
    And I create input file "ESISODP_POS_1.out" using template "ESISODP_POS_1_Template.out" from location "${testdata.path}/infiles"
    And I create input file "ESISODP_SDP_1.out" using template "ESISODP_SDP_1_Template.out" from location "${testdata.path}/infiles"

    # create a new version of expected output file from template for reconciliation
    And I create input file "Expected_esi_brs_positionnonfx.csv" using template "Expected_esi_brs_positionnonfx_template.csv" with below codes from location "${testdata.path}/outfiles"
      |  |  |

  Scenario: TC_2: Load BNP files

    Given I assign "ESISODP_POS_1.out" to variable "BNP_POS_FILE"
    And I assign "ESISODP_SDP_1.out" to variable "BNP_SDP_FILE"

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BNP_POS_FILE} |
      | ${BNP_SDP_FILE} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                    |
      | FILE_PATTERN  | ${BNP_POS_FILE}                    |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${BNP_SDP_FILE}                       |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

  Scenario: TC_3: Publish SOD Position Non-FX to BRS

    Given I remove below files in the host "dmp.ssh.outbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILENAME_NONFX}*.* |

     # create a new version of expected output file from template for reconciliation
    And I create input file "Expected_esi_brs_positionnonfx.csv" using template "Expected_esi_brs_positionnonfx_template.csv" from location "${testdata.path}/outfiles"

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILENAME_NONFX}.csv      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SOD_POSITION_NONFX_SUB |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check if published file contains all the records which were loaded
    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/testdata/Expected_esi_brs_positionnonfx.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: TC_5: Validate publish file against the database - Bookcost and Nominal are not null in the BNP input file

    Given I execute below query and extract values of "CLIENT_ID_FROM_DB;BOOKVALUE_FROM_DB;BOOKPRICE_FROM_DB" into same variables
     """
     SELECT ISID.ISS_ID AS CLIENT_ID_FROM_DB, BALH.LOCAL_CURR_BOOK_VAL_CAMT AS BOOKVALUE_FROM_DB, BALH.LOCAL_CURR_BOOK_VAL_CAMT/BALH.NOM_VAL_CAMT AS BOOKPRICE_FROM_DB
     FROM FT_T_BALH BALH, FT_T_ISID ISID
     WHERE BALH.DATA_SRC_ID = 'BNP' AND   TRUNC (AS_OF_TMS) = TRUNC (SYSDATE + 1) AND   BALH.INSTR_ID = ISID.INSTR_ID AND   ISID.END_TMS IS NULL AND   ISID.ID_CTXT_TYP = 'EISLSTID' AND   ISID.ISS_ID = 'ESL7334170'
     """
    #This check to verify Validate Bookvalue is equal to Book_cost where  Bookcost and nominal value is not null
    Then I expect column "BOOK_VALUE" value to be "${BOOKVALUE_FROM_DB}" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

    #This check to verify Validate BOOK_PRICE is equal to "BookPrice/Nominal where  Bookcost and nominal value is not null
    Then I expect column "BOOK_PRICE" value to be "${BOOKPRICE_FROM_DB}" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

    #This check to verify Validate BOOK_TYPE is equal to "GAAP" where  Bookcost and nominal value is not null
    Then I expect column "BOOK_TYPE" value to be "GAAP" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

    #This check to verify Validate BOOK_FX_RATE is equal to "" where  Bookcost and nominal value is not null
    Then I expect column "BOOK_FX_RATE" value to be "" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

  Scenario: TC_6: Validate publish file against the database - Bookcost or nominal values are null in the BNP input file

    Given I execute below query and extract values of "CLIENT_ID_FROM_DB;BOOKVALUE_FROM_DB;BOOKPRICE_FROM_DB" into same variables
     """
     SELECT ISID.ISS_ID AS CLIENT_ID_FROM_DB, BALH.LOCAL_CURR_BOOK_VAL_CAMT AS BOOKVALUE_FROM_DB, BALH.LOCAL_CURR_BOOK_VAL_CAMT/BALH.NOM_VAL_CAMT AS BOOKPRICE_FROM_DB
     FROM FT_T_BALH BALH, FT_T_ISID ISID
     WHERE BALH.DATA_SRC_ID = 'BNP' AND   TRUNC (AS_OF_TMS) = TRUNC (SYSDATE + 1) AND   BALH.INSTR_ID = ISID.INSTR_ID AND   ISID.END_TMS IS NULL AND   ISID.ID_CTXT_TYP = 'EISLSTID' AND   ISID.ISS_ID = 'ESL2389121'
     """

    #This check to verify Validate Bookvalue is null where Bookcost or nominal values are null
    Then I expect column "BOOK_VALUE" value to be "" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

    #This check to verify Validate BOOK_PRICE is null where Bookcost or nominal values are null
    Then I expect column "BOOK_PRICE" value to be "" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

    #This check to verify Validate BOOK_TYPE is null where Bookcost or nominal values are null
    Then I expect column "BOOK_TYPE" value to be "" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

    #This check to verify Validate BOOK_FX_RATE is null where Bookcost or nominal values are null
    Then I expect column "BOOK_FX_RATE" value to be "" where column "CLIENT_ID" value is "${CLIENT_ID_FROM_DB}" in CSV file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILENAME_NONFX}_${VAR_SYSDATE}_1.csv"

