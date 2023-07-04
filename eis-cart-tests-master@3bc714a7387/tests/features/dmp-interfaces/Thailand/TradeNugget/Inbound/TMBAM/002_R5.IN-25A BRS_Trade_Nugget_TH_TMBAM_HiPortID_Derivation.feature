#https://jira.pruconnect.net/browse/EISDEV-6720
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TMBAM%7COn+Market+Transaction%28FI%2CDS%28Zero+Cpn%29%2CABS%28FI+00%29%2CTBILL%28DS+00%29%7CHiport+ID+Automation#businessRequirements-goals
#Technical Specification : https://collaborate.pruconnect.net/pages/viewpage.action?pageId=63471461

# EISDEV-6815 Changes --START--
# Removed Es-PVDF
# EISDEV-6815 Changes --END--

# EISDEV-6814 Changes --START--
# This publish logic should be changed based on portfolio grp where portgrp in ('ES-MUT')
# EISDEV-6814 Changes --END--

# EISDEV-6845 Changes --START--
# On market publish logic for FI where secgrp ='BND', then FI 00
# EISDEV-6845 Changes --END--

# EISDEV-6879 Changes --START--
# Exclude ID ending with TT for Non Taxable
# EISDEV-6879 Changes --END--

# EISDEV-6880 Changes --START--
# Add ES-MUT-PVD in the derivation logic
# EISDEV-6880 Changes --END--

# EISDEV-7418 Changes --START--
# Added TB9 in the port group. Green Test
# EISDEV-7418 Changes --END--

@gc_interface_portfolios @gc_interface_securities @gc_interface_transactions @gc_interface_strategy
@dmp_regression_integrationtest
@eisdev_6720 @eisdev_6720_tmbam_fi @002_tmbam_hiportId_derivation @dmp_thailand_hiport @dmp_thailand
@eisdev_6815 @eisdev_6814 @eisdev_6845 @eisdev_6879 @eisdev_6880 @eisdev_7418

Feature: Test HiPort ID derivation for TMBAM

  This feature will test the below scenarios
  1. Load Portfolio files to create portfolios
  2. Load the FixedIncome security file received as part of the trade nugget
  3. Load strategy file to create strategy id in the domain table
  4. Load the FixedIncome transaction file received as part of the trade nugget

  Scenario 1: Portfolio is present in ES-PVDF or ES-MUT-RMF portgroup, portfolio code starting with P or R and Hiport Security Type in DS or FI

  Scenario 2a: Portfolio is present in ESMUT and not present in ES-MUT-RMF portgroup portfolio code starting with T or L and Hiport Security Type = DS

  Scenario 2b: Portfolio is present in ESMUT and not present in ES-MUT-RMF portgroup portfolio code starting with T or L, Hiport Security Type = FI & Strategy = null

  Scenario 2c: Portfolio is present in ESMUT and not present in ES-MUT-RMF portgroup portfolio code starting with T or L, Hiport Security Type = FI & Strategy = 334

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Inbound/TMBAM" to variable "testdata.path"

    #Portfolio Files
    And I assign "002_R5.IN-25A-DMP_TO_TH_TMBAM_portfolio_uploader.xlsx" to variable "PORTFOLIO_UPLOADER_FILE"
    And I assign "002_R5.IN-25A-DMP_TO_TH_TMBAM_F54_portfolio.xml" to variable "PORTFOLIO_F54_FILE"
    And I assign "002_R5.IN-25A-DMP_TO_TH_TMBAM_BRS_port_group.xml" to variable "INPUT_PORTGROUP"

    #Security Files
    And I assign "002_R5.IN-25A-DMP_TO_TH_BRS_FixedIncome_Security_F10.xml" to variable "SECURITY_FILE"

    #Transaction Files
    And I assign "002_R5.IN-25A-DMP_TO_TH_BRS_FixedIncome_Strategy_F113.xml" to variable "STRATEGY_FILE"
    And I assign "002_R5.IN-25A-DMP_TO_TH_BRS_FixedIncome_Transaction_F11.xml" to variable "TRANSACTION_FILE"

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

    Then I expect workflow is processed in DMP with success record count as "14"

  Scenario:TC3: Load the security file

    When I process "${testdata.path}/testdata/${SECURITY_FILE}" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "5"

  Scenario:TC4: Load the Strategy file

    When I process "${testdata.path}/testdata/${STRATEGY_FILE}" file with below parameters
      | FILE_PATTERN  | ${STRATEGY_FILE}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_STRATEGY_113 |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

    Then I expect value of column "STRATEGY_334_COUNT" in the below SQL query equals to "1":
    """
    select count(1) as STRATEGY_334_COUNT from ft_t_incl where indus_cl_set_id = 'STRATEGY'
    and cl_value = '334' and end_tms is null
    """

  Scenario:TC5: Load the Transaction file

    When I process "${testdata.path}/testdata/${TRANSACTION_FILE}" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}                |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | BUSINESS_FEED |                                    |

    Then I expect workflow is processed in DMP with success record count as "6"
    Then I expect workflow is processed in DMP with total record count as "8"

  Scenario:TC6: Verify HIPORTSECID rows count in ETCM & validate exceptions for Scenario 1

    Given I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID               | 60036                              |
      | SOURCE_ID               | %_GC%                              |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | NOTFCN_STAT_TYP         | OPEN                               |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM               |
      | MAIN_ENTITY_ID          | PES-PVDF_6720:-6717_RMF_1          |
      | MSG_SEVERITY_CDE        | 40                                 |

    Then I expect value of column "SC1_ESMUTRMF_HIPORT_ID" in the below SQL query equals to "EN219AUT0":
    """
    SELECT etcm.cmnt_txt AS SC1_ESMUTRMF_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
    etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
    and TRD_ID = 'RES-MUT-RMF_6720-RES-MUT-RMF_6720_3'
    """

    Then I expect value of column "SC1_ESMUTPVD_HIPORT_ID" in the below SQL query equals to "CB0806BZF":
    """
    SELECT etcm.cmnt_txt AS SC1_ESMUTPVD_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
    etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
    and TRD_ID = 'PES-PVDF_6720-PES-PVDF_6720_1'
    """

  Scenario:TC7: Verify HIPORTSECID rows count in ETCM for Scenario 2a

    Given I expect value of column "SC2A_ESMUT_HIPORT_ID" in the below SQL query equals to "EN219AUTOT":
    """
    SELECT etcm.cmnt_txt AS SC2A_ESMUT_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
    etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
    and TRD_ID = 'TESMUT_6720-TESMUT_6720_4'
    """

  Scenario:TC8: Verify HIPORTSECID rows count in ETCM for Scenario 2b

    Given I expect value of column "SC2B_ESMUT_HIPORT_ID" in the below SQL query equals to "MBF21NOT":
    """
    SELECT etcm.cmnt_txt AS SC2B_ESMUT_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
    etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
    and TRD_ID = 'TESMUT_6720-TESMUT_6720_5'
    """

  Scenario:TC9: Verify HIPORTSECID rows count in ETCM & validate exceptions for Scenario 2c

    Given I expect value of column "SC2C_ESMUT_HIPORT_ID" in the below SQL query equals to "TLT214AA":
    """
    SELECT etcm.cmnt_txt AS SC2C_ESMUT_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
    etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
    and TRD_ID = 'LESMUT_6720-LESMUT_6720_6'
    """

    And I expect value of column "SC2B_T04_HIPORT_ID" in the below SQL query equals to "BAM226AT":
    """
    SELECT etcm.cmnt_txt AS SC2B_T04_HIPORT_ID FROM FT_T_ETCM etcm, ft_t_extr extr WHERE
    etcm.CMNT_REAS_TYP = 'HIPORTSECID' and etcm.LN_NUM = 1 and etcm.EXEC_TRD_ID = extr.exec_trd_id
    and TRD_ID = '15999-T04_01'
    """


    Then I expect 1 exceptions are captured with the following criteria
      | NOTFCN_ID               | 60036                              |
      | SOURCE_ID               | %_GC%                              |
      | MSG_TYP                 | EIS_MT_BRS_TH_INTRADAY_TRANSACTION |
      | NOTFCN_STAT_TYP         | OPEN                               |
      | MAIN_ENTITY_ID_CTXT_TYP | BRSTRNID-FUND:INVNUM               |
      | MAIN_ENTITY_ID          | LESMUT_RMF_6720:-LESMUT_RMF_6720_7 |
      | MSG_SEVERITY_CDE        | 40                                 |

