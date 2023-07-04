#https://jira.pruconnect.net/browse/EISDEV-6717
#Functional Specification: https://collaborate.pruconnect.net/display/EISTT/TFUND%7COn+Market+Transaction%28FI%2CDS%28Zero+Cpn%29%7CHiport+ID+Automation
#Technical Specification : https://collaborate.pruconnect.net/pages/viewpage.action?pageId=63471461

# EISDEV-6720 Changes --START--
# Scenario 1 changed to lookup THAIID and added translation table for Taxable & NonTaxable
# API functionality to fetch identifiers from BRS and reprocess trades to derive HiPortID
# EISDEV-6720 Changes --END--

# EISDEV-6830 Changes --START--
# TFUND logic change to BRS Issuer ID
# EISDEV-6830 Changes --END--

# EISDEV-6841 Changes --START--
# Look up for ID ending with ZX for Non Taxable
# EISDEV-6841 Changes --END--

@gc_interface_portfolios @gc_interface_securities @gc_interface_transactions @gc_interface_strategy @gc_interface_trades
@dmp_regression_integrationtest
@eisdev_6717 @eisdev_6717_tfund_fi @002_tfund_hiportId_derivation @dmp_thailand_hiport @dmp_thailand
@eisdev_6720 @eisdev_6830 @eisdev_6841 @eisdev_7036

Feature: Test HiPort ID derivation for TFUND

  This feature will test the below scenarios
  1. Load Portfolio files to create portfolios
  2. Load the FixedIncome security file received as part of the trade nugget
  3. Load strategy file to create strategy id in the domain table
  4. Load the FixedIncome transaction file received as part of the trade nugget
  5. Trigger CallBRSApiReprocessTHTrades workflow

  Scenario 1a: BRS Issuer ID in R86074 (BANK OF THAILAND) or R61053 (THAILAND KINGDOM OF (GOVERNMENT)) portfolio code not equal to DPLUS, Strategy = 334

  Scenario 1b: BRS Issuer ID in R86074 (BANK OF THAILAND) or R61053 (THAILAND KINGDOM OF (GOVERNMENT)) portfolio code not equal to DPLUS, Strategy != 334

  Scenario 2a: BRS Issuer ID not in R86074 (BANK OF THAILAND) or R61053 (THAILAND KINGDOM OF (GOVERNMENT)) portfolio code not equal to DPLUS, Strategy = 334

  Scenario 2b: BRS Issuer ID not in R86074 (BANK OF THAILAND) or R61053 (THAILAND KINGDOM OF (GOVERNMENT)) portfolio code not equal to DPLUS, Strategy != 334.

  Scenario 3: Portfolio equal to DPLUS

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Inbound/TFUND" to variable "testdata.path"

    #Portfolio Files
    And I assign "002_R5.IN-25A-DMP_TO_TH_TFUND_portfolio_uploader.xlsx" to variable "PORTFOLIO_UPLOADER_FILE"
    And I assign "002_R5.IN-25A-DMP_TO_TH_TFUND_F54_portfolio.xml" to variable "PORTFOLIO_F54_FILE"
    And I assign "002_R5.IN-25A-DMP_TO_TH_TFUND_BRS_port_group.xml" to variable "INPUT_PORTGROUP"

    #Security Files
    And I assign "002_R5.IN-25A-DMP_TO_TH_BRS_FixedIncome_Security_F10.xml" to variable "SECURITY_FILE"

    #Transaction Files
    And I assign "002_R5.IN-25A-DMP_TO_TH_BRS_FixedIncome_Strategy_F113.xml" to variable "STRATEGY_FILE"
    And I assign "002_R5.IN-25A-DMP_TO_TH_BRS_FixedIncome_Transaction_F11.xml" to variable "TRANSACTION_FILE"

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BPM29LRM3'"

    And I execute below query to "clear trades"
    """
      update ft_t_extr set end_tms = sysdate, trd_id = new_oid where end_tms is null
      and trd_id in ('6717_RMF-6717_RMF_2','6717_TFPVD-6717_TFPVD_1','6717_RMF-6717_RMF_1','6717_TFMUT-6717_TFMUT_3',
      '6717_TFMUT-6717_TFMUT_2','6717_TFMUT-6717_TFMUT_6','DPLUS-DPLUS_2','6717_TFMUT-6717_TFMUT_1','6717_TFMUT-6717_TFMUT_7',
      '6717_TFPRV-6717_TFPRV_1','DPLUS-DPLUS_4','DPLUS-DPLUS_1','DPLUS-DPLUS_3','DPLUS-DPLUS_5')
    """

  Scenario:TC2: Load the portfolio uploader file, F54 and port group file to create portfolios required for transaction load

    When I process "${testdata.path}/testdata/${PORTFOLIO_UPLOADER_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_UPLOADER_FILE}           |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "5"

    When I process "${testdata.path}/testdata/${PORTFOLIO_F54_FILE}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PORTFOLIO_F54_FILE} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with success record count as "5"

    When I process "${testdata.path}/testdata/${INPUT_PORTGROUP}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_PORTGROUP}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |

    Then I expect workflow is processed in DMP with success record count as "10"

  Scenario:TC3: Load the security file

    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'BRS24G469','BES2Y14N1','BES34WME4','BES39D8D9','BPM20H8L4','BPM29AMV2'"

    When I process "${testdata.path}/testdata/${SECURITY_FILE}" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "8"

    And I execute below query to "update maturity date to greater than 90 days"
    """
      update ft_t_issu set mat_exp_tms = trunc(sysdate+100) where instr_id in
      (select instr_id from ft_t_isid where iss_id ='BES34WME4' and id_ctxt_typ = 'BCUSIP' and end_tms is null)
    """

    And I execute below query to "update maturity date less than 90 days"
    """
      update ft_t_issu set mat_exp_tms = trunc(sysdate+30) where instr_id in
      (select instr_id from ft_t_isid where iss_id ='BES39D8D9' and id_ctxt_typ = 'BCUSIP' and end_tms is null)
    """

  Scenario:TC4: Load the Strategy file

    When I process "${testdata.path}/testdata/${STRATEGY_FILE}" file with below parameters
      | FILE_PATTERN  | ${STRATEGY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_STRATEGY_113 |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "2"

    Then I expect value of column "STRATEGY_334_COUNT" in the below SQL query equals to "2":
    """
      select count(1) as STRATEGY_334_COUNT from ft_t_incl where indus_cl_set_id = 'STRATEGY'
      and cl_value in ('334','333') and end_tms is null
    """

  Scenario:TC5: Load the Transaction file

    When I process "${testdata.path}/testdata/${TRANSACTION_FILE}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "11"
    Then I expect workflow is processed in DMP with total record count as "16"

  Scenario:TC5: Verify HIPORTSECID rows count in ETCM & validate exceptions for Scenario 1

    Given I expect value of column "SC1_TFMUT_HIPORT_ID_1" in the below SQL query equals to "LB213A":
    """
      SELECT etcm.cmnt_txt AS SC1_TFMUT_HIPORT_ID_1 FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_TFMUT-6717_TFMUT_1'
    """

    Then I expect value of column "SC1_TFMUT_HIPORT_ID_2" in the below SQL query equals to "LB213A":
    """
      SELECT etcm.cmnt_txt AS SC1_TFMUT_HIPORT_ID_2 FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_RMF-6717_RMF_1'
    """

    Then I expect value of column "SC1_TFMUT_HIPORT_ID_TABLE" in the below SQL query equals to "LB23DAT":
    """
      SELECT etcm.cmnt_txt AS SC1_TFMUT_HIPORT_ID_TABLE FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_TFMUT-6717_TFMUT_4'
    """

    Then I expect value of column "SC1_TFMUT_HIPORT_ID_2" in the below SQL query equals to "LB386A":
    """
      SELECT etcm.cmnt_txt AS SC1_TFMUT_HIPORT_ID_2 FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_TFMUT-6717_TFMUT_6'
    """

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | TFUND: Scenario 1a: BRS Issuer ID not in [R86074, R61053] portfolio code not equal to DPLUS, Strategy = 334. However, More than 1 TFHIPORTID ending with X is present on the security. TRD_ID = 6717_TFMUT-6717_TFMUT_3 |
      | NOTFCN_ID               | 60036                                                                                                                                                                                                                   |
      | SOURCE_ID               | %_GC%                                                                                                                                                                                                                   |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                                                                                                                                                                                      |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                                                                                                                    |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM                                                                                                                                                                                                    |
      | MAIN_ENTITY_ID          | 6717_TFMUT:-6717_TFMUT_3                                                                                                                                                                                                |
      | MSG_SEVERITY_CDE        | 40                                                                                                                                                                                                                      |

  Scenario:TC6: Verify HIPORTSECID rows count in ETCM & validate exceptions for Scenario 2

    Given I expect value of column "SC2_TFMUT_HIPORT_ID_1" in the below SQL query equals to "LB29DAX":
    """
      SELECT etcm.cmnt_txt AS SC2_TFMUT_HIPORT_ID_1 FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_TFMUT-6717_TFMUT_2'
    """

    Then I expect value of column "SC2_RMF_HIPORT_ID" in the below SQL query equals to "LB29DAX":
    """
      SELECT etcm.cmnt_txt AS SC2_RMF_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_RMF-6717_RMF_2'
    """

    Then I expect value of column "SC2_TFPVD_HIPORT_ID" in the below SQL query equals to "LB29DAX":
    """
      SELECT etcm.cmnt_txt AS SC2_TFPVD_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_TFPVD-6717_TFPVD_1'
    """

    Then I expect value of column "SC2_TFPRV_HIPORT_ID" in the below SQL query equals to "LB29DA":
    """
      SELECT etcm.cmnt_txt AS SC2_TFPRV_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_TFPRV-6717_TFPRV_1'
    """

    Then I expect value of column "SC2_TFMUT_HIPORT_ID_TABLE" in the below SQL query equals to "LB23DA":
    """
      SELECT etcm.cmnt_txt AS SC2_TFMUT_HIPORT_ID_TABLE FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = '6717_TFMUT-6717_TFMUT_5'
    """

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | TFUND: Scenario 3b: Portfolio equal to DPLUS, Strategy != 334. However, TFHIPORTID is not present on the security. TRD_ID = DPLUS-DPLUS_5 |
      | NOTFCN_ID               | 60036                                                                                                                                     |
      | SOURCE_ID               | %_GC%                                                                                                                                     |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                                                                                                        |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                                      |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM                                                                                                                      |
      | MAIN_ENTITY_ID          | DPLUS:-DPLUS_5                                                                                                                            |
      | MSG_SEVERITY_CDE        | 40                                                                                                                                        |

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | TFUND: Scenario 2b: BRS Issuer ID not in [R86074, R61053] portfolio code not equal to DPLUS, Strategy = 334. However, More than 1 TFHIPORTID not ending with X, Z and ZX is present on the security. TRD_ID = 6717_TFMUT-6717_TFMUT_7 |
      | NOTFCN_ID               | 60036                                                                                                                                                                                                                                 |
      | SOURCE_ID               | %_GC%                                                                                                                                                                                                                                 |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                                                                                                                                                                                                    |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                                                                                                                                  |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM                                                                                                                                                                                                                  |
      | MAIN_ENTITY_ID          | 6717_TFMUT:-6717_TFMUT_7                                                                                                                                                                                                              |
      | MSG_SEVERITY_CDE        | 40                                                                                                                                                                                                                                    |

  Scenario:TC7: Verify HIPORTSECID rows count in ETCM & validate exceptions for Scenario 3

    Given I expect value of column "SC4_DPLUS_HIPORT_ID" in the below SQL query equals to "BG208BAZX":
    """
      SELECT etcm.cmnt_txt AS SC4_DPLUS_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = 'DPLUS-DPLUS_2'
    """

    And I expect value of column "SC3_DPLUS_HIPORT_ID" in the below SQL query equals to "TBEV29AZ":
    """
      SELECT etcm.cmnt_txt AS SC3_DPLUS_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = 'DPLUS-DPLUS_1'
    """

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | TFUND: Scenario 3a: Portfolio code equal to DPLUS, Strategy = 334. However, More than 1 TFHIPORTID not ending with Z is present on the security. TRD_ID = DPLUS-DPLUS_3 |
      | NOTFCN_ID               | 60036                                                                                                                                                                   |
      | SOURCE_ID               | %_GC%                                                                                                                                                                   |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                                                                                                                                      |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                                                                    |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM                                                                                                                                                    |
      | MAIN_ENTITY_ID          | DPLUS:-DPLUS_3                                                                                                                                                          |
      | MSG_SEVERITY_CDE        | 40                                                                                                                                                                      |

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | TFUND: Scenario 3b: Portfolio equal to DPLUS, Strategy != 334. However, More than 1 TFHIPORTID ending with Z is present on the security. TRD_ID = DPLUS-DPLUS_4 |
      | NOTFCN_ID               | 60036                                                                                                                                                           |
      | SOURCE_ID               | %_GC%                                                                                                                                                           |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION                                                                                                                              |
      | NOTFCN_STAT_TYP         | OPEN                                                                                                                                                            |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM                                                                                                                                            |
      | MAIN_ENTITY_ID          | DPLUS:-DPLUS_4                                                                                                                                                  |
      | MSG_SEVERITY_CDE        | 40                                                                                                                                                              |

  Scenario:TC8: Call BRS API and Reprocess TH trades

    Given I process Brs Api ReprocessTHTrades workflow with below parameters and wait for the job to be completed
      | BRS_WEBSERVICE_URL        | ${brswebservice.url}                 |
      | MSG_TYP                   | EIS_MT_BRS_SECURITY_NEW              |
      | TRANSLATION_MDX           | ${transalationmdx.validfilelocation} |
      | BRSPROPERTY_FILE_LOCATION | ${brscredentials.validfilelocation}  |
      | TRADE_SOURCE              | TFUND                                |

    Then I expect value of column "DPLUS_HIPORT_ID_2" in the below SQL query equals to "THN212CZ":
    """
      SELECT etcm.cmnt_txt AS DPLUS_HIPORT_ID_2 FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
      etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
      and TRD_ID = 'DPLUS-DPLUS_5'
    """
