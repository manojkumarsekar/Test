#https://jira.pruconnect.net/browse/EISDEV-6097
#Architectue Requirement: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOM&title=Th.Aldn-24+Th.TMBAM.Positions+Restricted_Holdings+BRS+-%3E+ESI_DMP
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TMBAM-SSDR%7CUpload+Restricted+Holdings%7CBRS+To+DMP
#EISDEV-6234: RQSTR_ID changed to BRSTMSBL
#EISDEV-6377: Modify the portfolio group from TMBAM to THB-AG

@gc_interface_portfolios @gc_interface_positions
@dmp_regression_integrationtest
@eisdev_6097 @001_file211_sbl_holding @dmp_thailand_fundapps @dmp_thailand
@eisdev_6234 @eisdev_6377 @eisdev_6603
Feature: BRS File211 (i.e Restricted holding) load for TMBAM

  The purpose of this interface is to get restricted holdings data from BRS to DMP and published to FundApps using the existing interface created as part of SSDR.
  We are loading only Security Borrowing and Lending (SBL) position for TMBAM.

  We tests the following Scenario with this feature file.

  1.Scenario TC2: Create portfolios(LF1, LF6, E01 and RF3), it is prerequisite for File54 load.
  2.Scenario TC3: Create ContextType=BRSFundId in ACCID table for these portfolios(LF1, LF6, E01 and RF3),  it is prerequisite for Portfolio group load
  3.Scenario TC4: Create Portfolio group as TMBAM and it is participants,  it is prerequisite for File211 load
  4.Scenario TC5: Load the Normal Position(F14),  it is prerequisite for File211 load
  5.Scenario TC6: Load the Normal Position(F211)
  6.Scenario TC7: BCUSIP - 11: CRTS ID - RF3 Normal position not present in database. - Exception 60027 is thrown and record not loaded, Verify in NTEL Table
  7.Scenerio TC8: BCUSIP - S69108249, CRTS ID - LF1 Normal position present in database but value is less than lend position value. - Exception 60028 is thrown and record not loaded, Verify in NTEL Table
  8.Scenerio TC9: BCUSIP - S69108249, CRTS ID - LF1 Normal position is present in database and value is greater than/equal to lend position value - Record successfully loaded. Verify BALH AND BHST tables
  9.Scenerio TC10: BCUSIP - SB05MGY66, CRTS ID - E01 2 SBL positions being loaded with same Account-Instrument combination with appropriate normal position in database:
  10.Both should be set up in database. First position should have STRATEGY_ID 1 and Second position should have strategy ID 2.
  11.Scenerio TC11: BCUSIP - BRSJ3PM97, CRTS ID - RF3, Validate the counterparty mandatory check.

  Scenario: TC1: Initialize variables and Deactivate Existing test maintain clean state before executing tests

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Positions/File211/Inbound" to variable "TESTDATA_PATH_INBOUND"

    # Portfolio Uploader variable
    And I assign "001_Th.Aldn-24_BRS_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "INPUT_PROTFOLIO_FILENAME"

    # Portfolio File54 variable
    And I assign "001_Th.Aldn-24_BRS_DMP_F54_esi_portfolio.xml" to variable "INPUT_F54_FILENAME"
    And I assign "001_Th.Aldn-24_BRS_DMP_F54_esi_portfolio_Template.xml" to variable "INPUT_F54_TEMPLATENAME"

    # Portfolio group variable
    And I assign "001_Th.Aldn-24_BRS_DMP_esi_port_group.xml" to variable "INPUT_PROTGROUP_FILENAME"
    And I assign "001_Th.Aldn-24_BRS_DMP_esi_port_group_Template.xml" to variable "INPUT_PORTGROUP_TEMPLATENAME"

    # File 14 Variable
    And I assign "001_Th.Aldn-24_BRS_DMP_F14_Position.xml" to variable "INPUT_F14_FILENAME"
    And I assign "001_Th.Aldn-24_BRS_DMP_F14_Position_Template.xml" to variable "INPUT_F14_TEMPLATENAME"

    # File 14 Variable
    And I assign "001_Th.Aldn-24_BRS_DMP_F211_RestrictedPosition" to variable "INPUT_F211_FILENAME"
    And I assign "001_Th.Aldn-24_BRS_DMP_F211_RestrictedPosition_Template.xml" to variable "INPUT_F211_TEMPLATENAME"

    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'MM/dd/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE < trunc(sysdate) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I modify date "${DYNAMIC_DATE}" with "+0d" from source format "MM/dd/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"

    And I execute below query to "Delete existing positions for ${DYNAMIC_DATE}"
    """
    DELETE FT_T_BHST WHERE BALH_OID IN (SELECT BALH_OID FROM FT_T_BALH WHERE RQSTR_ID LIKE '%BRSTMSBL%' AND LAST_CHG_USR_ID='EIS_BRS_DMP_EOD_RESTRICTED_HOLDINGS_TMBAM_211' AND to_char(AS_OF_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}');
    DELETE FT_T_BALH WHERE RQSTR_ID LIKE '%BRSTMSBL%' AND LAST_CHG_USR_ID='EIS_BRS_DMP_EOD_RESTRICTED_HOLDINGS_TMBAM_211' AND to_char(AS_OF_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}';
    """

    And I execute below query to "set up FPRO"
	"""
    update ft_t_fpro set FINS_PRO_ID = 'TestAutomation@eastspring.com', PRO_DESIGNATION_TXT = 'PM' where fpro_oid = 'Ec6Q58Mj81';
    commit
    """

  Scenario:TC2: Create portfolios using uploader

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PROTFOLIO_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_PROTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"

  Scenario: TC3: Creates BRSFundID as Context type using File54 from BRS

    Given I create input file "${INPUT_F54_FILENAME}" using template "${INPUT_F54_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_F54_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_F54_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with total record count as "8"

  Scenario: TC4: Load portfolio group file from BRS to DMP for create TBMAM group and participants

    Given I create input file "${INPUT_PROTGROUP_FILENAME}" using template "${INPUT_PORTGROUP_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PROTGROUP_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_PROTGROUP_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP  |

    Then I expect workflow is processed in DMP with total record count as "8"

  Scenario: TC5: Load TMBAM Position Data(File 14) from BRS

    Given I create input file "${INPUT_F14_FILENAME}" using template "${INPUT_F14_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_F14_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_F14_FILENAME}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC6: Load TMBAM SBL Position Data(File 211) from BRS

    And I create input file "${INPUT_F211_FILENAME}_${DYNAMIC_FILE_DATE}.xml" using template "${INPUT_F211_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    Given I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_F211_FILENAME}_${DYNAMIC_FILE_DATE}.xml |

    And I process Load files and publish exceptions with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211        |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}                         |
      | EMAIL_TO                | testautomation@eastspring.com                   |
      | EMAIL_SUBJECT           | Restricted Holdings Load(TMBAM - SBL) Status    |
      | PUBLISH_LOAD_SUMMARY    | true                                            |
      | SUCCESS_ACTION          | DELETE                                          |
      | FILE_PATTERN            | ${INPUT_F211_FILENAME}_${DYNAMIC_FILE_DATE}.xml |
      | ATTACHMENT_FILENAME     | Exceptions.xlsx                                 |
      | HEADER                  | Please see the summary of the load below        |
      | FOOTER                  | DMP Team, Please do not reply to this mail.     |
      | FILE_LOAD_EVENT         | StandardFileLoad                                |
      | EXCEPTION_DETAILS_COUNT | 10                                              |
      | NOOFFILESINPARALLEL     | 1                                               |

    Then I expect workflow is processed in DMP with total record count as "8"


  Scenario:TC7: Verification of failures due to missing positions

    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '60027'
      AND ntel.CHAR_VAL_TXT LIKE '%Normal position is not set up in the database for lend position%'
      """

  Scenario:TC8: Verification of failures due normal position is less then the lend position
    Then I expect value of column "EXCEPTION_MSG2_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG2_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '60028'
      AND ntel.CHAR_VAL_TXT LIKE '%Normal position % in the database is less than the lend position%'
      """

  Scenario:TC9: Verification of BALH and BHST table for the S69108249:LF1 single SBL position loaded with required data from file

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BALH_COUNT
        FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
        WHERE  BALH.INSTR_ID = ISID.INSTR_ID
        AND    ISID.ID_CTXT_TYP IN ('BCUSIP')
        AND    ISID.ISS_ID IN ('S69108249')
        AND    ISID.END_TMS IS NULL
        AND    BALH.RQSTR_ID = 'BRSTMSBL'
        AND    BALH.ACCT_ID = ACID.ACCT_ID
        AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
        AND    ACID.END_TMS IS NULL
        AND    ACID.ACCT_ALT_ID IN ('LF1')
        AND    to_char(ADJST_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
        AND    to_char(AS_OF_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
        AND    STRATEGY_ID=1
      """

    Then I expect value of column "BHST_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as BHST_COUNT
        FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID, FT_T_BHST BHST
        WHERE  BALH.BALH_OID = BHST.BALH_OID
        AND    BHST.STAT_DEF_ID = 'CNPFNSBL'
        AND    BHST.DATA_SRC_ID = 'BRS'
        AND    BHST.END_TMS IS NULL
        AND    BALH.INSTR_ID = ISID.INSTR_ID
        AND    ISID.ID_CTXT_TYP IN ('BCUSIP')
        AND    ISID.ISS_ID IN ('S69108249')
        AND    ISID.END_TMS IS NULL
        AND    BALH.RQSTR_ID = 'BRSTMSBL'
        AND    BALH.ACCT_ID = ACID.ACCT_ID
        AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
        AND    ACID.END_TMS IS NULL
        AND    ACID.ACCT_ALT_ID IN ('LF1')
        AND    to_char(ADJST_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
        AND    to_char(AS_OF_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
        AND    STRATEGY_ID=1
      """

  Scenario:TC10: Verification of BALH table for the SB05MGY66:E01 OBCB multiple SBL position loaded with required data from file

    Then I expect value of column "STRATEGY_ID_1_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_1_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('BCUSIP')
         AND    ISID.ISS_ID = 'SB05MGY66'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'BRSTMSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('E01')
         AND    to_char(ADJST_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
         AND    to_char(AS_OF_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
         AND    STRATEGY_ID=1
      """

    Then I expect value of column "STRATEGY_ID_2_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) as STRATEGY_ID_2_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    ISID.ID_CTXT_TYP IN ('BCUSIP')
         AND    ISID.ISS_ID = 'SB05MGY66'
         AND    ISID.END_TMS IS NULL
         AND    BALH.RQSTR_ID = 'BRSTMSBL'
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ACID.ACCT_ID_CTXT_TYP IN ('CRTSID')
         AND    ACID.END_TMS IS NULL
         AND    ACID.ACCT_ALT_ID IN ('E01')
         AND    to_char(ADJST_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
         AND    to_char(AS_OF_TMS,'MM/dd/YYYY') = '${DYNAMIC_DATE}'
         AND    STRATEGY_ID=2
      """

  Scenario:TC11: Counterparty mandatory check in SBL Position File

    Then I expect value of column "EXCEPTION_MSG3_CHECK" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXCEPTION_MSG3_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.notfcn_id = '60001'
      AND ntel.CHAR_VAL_TXT LIKE '%Counter Party is not present in the input record%'
      """

  Scenario:TC_12 Re-set FPRO

    Given I execute below query to "reset FPRO"
	"""
	update ft_t_fpro set FINS_PRO_ID = 'azhar.arayilakath@eastspring.com' where fpro_oid = 'Ec6Q58Mj81';
	commit
    """