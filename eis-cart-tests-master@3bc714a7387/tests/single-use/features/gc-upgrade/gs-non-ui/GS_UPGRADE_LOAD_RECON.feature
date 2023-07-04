#Pre requisite: Map network folder (\\Kc2napns304_ei\eisg_dmp\dmp\archive\in) to P drive in local
@gs_upgrade_load_recon @ignore_hooks
Feature: To verify DMP all Inbound message types as part of GC Upgrade

  Scenario: Assign data

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/gc-upgrade/gs-non-ui/inbound" to variable "TESTDATA_BASE_PATH"
    And I assign "3600" to variable "workflow.max.polling.time"

  Scenario Outline: Copy latest instrument file <filename_prefix> from Network folder <network_path> to test data path

    Given I assign "<network_path>" to variable "NETWORK_PATH"
    And I assign "${TESTDATA_BASE_PATH}/<testdata_path>" to variable "testdata.path"
    And I copy latest file from "<network_path>" with pattern "<filename_prefix>" to "${testdata.path}" and assign file name to variable "<dest_filename_var>"

    Examples:
      | filename_prefix                                 | network_path               | testdata_path         | dest_filename_var                                  |
      | esi_sc_positionnonfx                            | P:\\china\\transform       | china/transform       | DEST_INFILE_VAR_RCR_POSITIONS                      |
      | esi_sc_security                                 | P:\\china\\transform       | china/transform       | DEST_INFILE_VAR_RCR_SECURITY                       |
      | esi_sc_transactions                             | P:\\china\\transform       | china/transform       | DEST_INFILE_VAR_RCR_TRANSACTIONS                   |
      | F2-UT_MYCRNAV                                   | P:\\db\\nav                | db/nav                | DEST_INFILE_VAR_DB_NAV_ABOR                        |
      | L1-INS_MYCRNAV                                  | P:\\mfund\\nav             | mfund/nav             | DEST_INFILE_VAR_MFUND_NAV_ABOR                     |
      | PAMB_Daily_T0                                   | P:\\scb\\nav               | scb/nav               | DEST_INFILE_VAR_SCB_DMP_NAV                        |
      | ESISODP_EXR_1_                                  | P:\\bnp\\sod               | bnp/sod               | DEST_INFILE_VAR_BNP_EOD_EXCHANGE_RATE              |
      | ESIINTRADAY_TRN_5_                              | P:\\bnp\\intraday          | bnp/intraday          | DEST_INFILE_VAR_BNP_INTRADAY_CASH_TRANSACTION      |
      | ESI_FE_ESIL1ALLOct19-                           | P:\\bnp\\irp               | bnp/irp               | DEST_INFILE_VAR_BNP_PERFORMANCE_RETURNS            |
      | ESIINTRADAY_PTF_5_                              | P:\\bnp\\intraday          | bnp/intraday          | DEST_INFILE_VAR_BNP_PORTFOLIO                      |
      | ESIINTRADAY_SEC_6_                              | P:\\bnp\\intraday          | bnp/intraday          | DEST_INFILE_VAR_BNP_SECURITY_INTRADAY              |
      | ESISODP_SEC_1_                                  | P:\\bnp\\sod               | bnp/sod               | DEST_INFILE_VAR_BNP_SECURITY_SOD                   |
      | ESISODP_POS_3_                                  | P:\\bnp\\sod               | bnp/sod               | DEST_INFILE_VAR_BNP_SOD_POSITIONFX_LATAM           |
      | ESISODP_POS_1_                                  | P:\\bnp\\sod               | bnp/sod               | DEST_INFILE_VAR_BNP_SOD_POSITIONFX_NONLATAM        |
      | ESISODP_SDP_3_                                  | P:\\bnp\\sod               | bnp/sod               | DEST_INFILE_VAR_BNP_SOD_POSITIONNONFX_LATAM        |
      | ESISODP_SDP_1_                                  | P:\\bnp\\sod               | bnp/sod               | DEST_INFILE_VAR_BNP_SOD_POSITIONNONFX_NONLATAM     |
      | BOCIEISLFUNDLE                                  | P:\\ssdr\\boci             | ssdr/boci             | DEST_INFILE_VAR_BOCI_DMP_FUND                      |
      | BOCIEISLPOSITN                                  | P:\\ssdr\\boci             | ssdr/boci             | DEST_INFILE_VAR_BOCI_DMP_POSITION                  |
      | BOCIEISLINSTMT                                  | P:\\ssdr\\boci             | ssdr/boci             | DEST_INFILE_VAR_BOCI_DMP_SECURITY                  |
      | BOCIEISLTRANSN                                  | P:\\ssdr\\boci             | ssdr/boci             | DEST_INFILE_VAR_BOCI_DMP_TXN                       |
      | esi_itap_asia_                                  | P:\\brs\\intraday          | brs/intraday          | DEST_INFILE_VAR_BRS_CASHALLOC_FILE11               |
      | esi_newcash_                                    | P:\\brs\\intraday          | brs/intraday          | DEST_INFILE_VAR_BRS_CASHALLOC_FILE96               |
      | esi_EOD_PITL_*broker                            | P:\\brs                    | brs                   | DEST_INFILE_VAR_BRS_COUNTERPARTY                   |
      | esi_ADX_EOD_ASIA_*coupon                        | P:\\brs\\eod               | brs/eod               | DEST_INFILE_VAR_BRS_COUPONS                        |
      | esi_ADX_EOD_ASIA_*pos                           | P:\\brs\\eod               | brs/eod               | DEST_INFILE_VAR_BRS_EOD_POSITION_NON_LATAM         |
      | esi_ADX_EOD_NP_*pos                             | P:\\ssdr\\npp              | ssdr/npp              | DEST_INFILE_VAR_BRS_EOD_POSITION_NPP               |
      | esi_EOD_PITL_*pos                               | P:\\brs                    | brs                   | DEST_INFILE_VAR_BRS_EOD_POSITION_TREASURY          |
      | esi_ADX_EOD_ASIA_2*.transaction                 | P:\\brs\\eod               | brs/eod               | DEST_INFILE_VAR_BRS_EOD_TRANSACTION_NON_LATAM      |
      | esi_EOD_PITL_2*.transaction                     | P:\\brs                    | brs                   | DEST_INFILE_VAR_BRS_EOD_TRANSACTION_TREASURY       |
      | esi_TW_ADX_I.2*.transaction                     | P:\\taiwan                 | taiwan                | DEST_INFILE_VAR_BRS_INTRADAY_TRANSACTION           |
      | esi_ADX_EOD_ASIA_2*.issuer                      | P:\\brs\\eod               | brs/eod               | DEST_INFILE_VAR_BRS_ISSUER                         |
      | esi_FOLE_ADX2*.order                            | P:\\brs\\eod               | brs/eod               | DEST_INFILE_VAR_BRS_ORDERS                         |
      | esi_portfolio_2*                                | P:\\brs\\6y_portfolio      | brs/6y_portfolio      | DEST_INFILE_VAR_BRS_PORTFOLIO                      |
      | esi_port_group_owned_                           | P:\\brs\\qsg               | brs/qsg               | DEST_INFILE_VAR_BRS_PORTFOLIO_GROUP                |
      | esi_security_analytics_apac_                    | P:\\brs\\7a_risk_analytics | brs/7a_risk_analytics | DEST_INFILE_VAR_BRS_RISK_ANALYTICS                 |
      | esi_security_analytics_global_                  | P:\\brs\\7a_risk_analytics | brs/7a_risk_analytics | DEST_INFILE_VAR_BRS_SEC_ANALYTICS_GLOBAL           |
      | esi_TW_ADX_I.*.sm                               | P:\\taiwan                 | taiwan                | DEST_INFILE_VAR_BRS_SECURITY_NEW                   |
      | esi_ADX_EOD_ASIA_*.shares_outstanding           | P:\\brs\\eod               | brs/eod               | DEST_INFILE_VAR_BRS_SHARES_OUTSTANDING             |
      | esi_users_groups_                               | P:\\brs\\eod               | brs/eod               | DEST_INFILE_VAR_BRS_USER_GROUP                     |
      | EODSBLPOSITIONS                                 | P:\\ssdr\\citi             | ssdr/citi             | DEST_INFILE_VAR_CITI_DMP_SBL_POSITION              |
      | esisg_dmp_hsbc_broker_price_                    | P:\\edm\\price             | edm/price             | DEST_INFILE_VAR_DMP_HSBC_BROKER_PRICE              |
      | esisg_dmp_price_                                | P:\\edm\\price             | edm/price             | DEST_INFILE_VAR_EDM_INT_PRICE_MASTER_TEMPLATE      |
      | esisg_dmp_price_                                | P:\\edm\\price             | edm/price             | DEST_INFILE_VAR_EDM_PRICE_MASTER_TEMPLATE          |
      | esisg_dmp_scb_broker_price_                     | P:\\edm\\price             | edm/price             | DEST_INFILE_VAR_EDM_SCB_BROKER_PRICE               |
      | EIMKEISLFUNDLE                                  | P:\\ssdr\\korea            | ssdr/korea            | DEST_INFILE_VAR_EIMK_DMP_FUND                      |
      | EIMKEISLPOSITN                                  | P:\\ssdr\\korea            | ssdr/korea            | DEST_INFILE_VAR_EIMK_DMP_POSITION                  |
      | EIMKEISLINSTMT                                  | P:\\ssdr\\korea            | ssdr/korea            | DEST_INFILE_VAR_EIMK_DMP_SECURITY                  |
      | EIMKEISLTRANSN                                  | P:\\ssdr\\korea            | ssdr/korea            | DEST_INFILE_VAR_EIMK_DMP_TXN                       |
      | ESGAEISLFUNDLE                                  | P:\\ssdr\\esga             | ssdr/esga             | DEST_INFILE_VAR_ESGA_DMP_FUND                      |
      | ESGAEISLPOSITN                                  | P:\\ssdr\\esga             | ssdr/esga             | DEST_INFILE_VAR_ESGA_DMP_POSITION                  |
      | ESGAEISLINSTMT                                  | P:\\ssdr\\esga             | ssdr/esga             | DEST_INFILE_VAR_ESGA_DMP_SECURITY                  |
      | ESGAEISLTRANSN                                  | P:\\ssdr\\esga             | ssdr/esga             | DEST_INFILE_VAR_ESGA_DMP_TXN                       |
      | ESJPEISLFUNDLE                                  | P:\\ssdr\\japan            | ssdr/japan            | DEST_INFILE_VAR_ESJP_DMP_FUND                      |
      | ESJPEISLPOSITN                                  | P:\\ssdr\\japan            | ssdr/japan            | DEST_INFILE_VAR_ESJP_DMP_POSITION                  |
      | ESJPEISLINSTMT                                  | P:\\ssdr\\japan            | ssdr/japan            | DEST_INFILE_VAR_ESJP_DMP_SECURITY                  |
      | ESJPEISLTRANSN                                  | P:\\ssdr\\japan            | ssdr/japan            | DEST_INFILE_VAR_ESJP_DMP_TXN                       |
      | EASTSPRING INVESTMENTS FUND PRICE VARIANCE -    | P:\\hsbc                   | hsbc                  | DEST_INFILE_VAR_HSBC_BROKER_PRICE                  |
      | VietEvals                                       | P:\\idc\\price             | idc/price             | DEST_INFILE_VAR_IDC_PRICE                          |
      | PPMAEISLFUNDLE                                  | P:\\ssdr\\ppma             | ssdr/ppma             | DEST_INFILE_VAR_JNAM_DMP_FUND                      |
      | PPMAEISLPOSITN                                  | P:\\ssdr\\ppma             | ssdr/ppma             | DEST_INFILE_VAR_JNAM_DMP_POSITION                  |
      | PPMAEISLINSTMT                                  | P:\\ssdr\\ppma             | ssdr/ppma             | DEST_INFILE_VAR_JNAM_DMP_SECURITY                  |
      | PPMAEISLTRANSN                                  | P:\\ssdr\\ppma             | ssdr/ppma             | DEST_INFILE_VAR_JNAM_DMP_TXN                       |
      | MANGEISLSLPOSN                                  | P:\\ssdr\\mng              | ssdr/mng              | DEST_INFILE_VAR_MNG_DMP_SBL_POSITION               |
      | MANGEISLINSTMT                                  | P:\\ssdr\\mng              | ssdr/mng              | DEST_INFILE_VAR_MNG_DMP_SECURITY                   |
      | buylist_                                        | P:\\qsg                    | qsg                   | DEST_INFILE_VAR_PST_TARGET_PRICE                   |
      | VNQ Reuters                                     | P:\\reuters\\price         | reuters/price         | DEST_INFILE_VAR_REUTERS_PRICE                      |
      | *Daily Net Asset Value Internal Funds (ESI).csv | P:\\scb                    | scb                   | DEST_INFILE_VAR_SCB_BROKER_PRICE                   |
      | PH - Daily Net Asset Value                      | P:\\scb                    | scb                   | DEST_INFILE_VAR_SCB_BROKER_PRICE                   |
      | TBAMEISLFUNDLE                                  | P:\\ssdr\\tbam             | ssdr/tbam             | DEST_INFILE_VAR_TMBAM_DMP_FUND                     |
      | TBAMEISLPOSITN                                  | P:\\ssdr\\tbam             | ssdr/tbam             | DEST_INFILE_VAR_TMBAM_DMP_POSITION                 |
      | TBAMSBLPOSITIONS                                | P:\\ssdr\\tbam             | ssdr/tbam             | DEST_INFILE_VAR_TMBAM_DMP_SBL_POSITION             |
      | TBAMEISLINSTMT                                  | P:\\ssdr\\tbam             | ssdr/tbam             | DEST_INFILE_VAR_TMBAM_DMP_SECURITY                 |
      | TBAMEISLTRANSN                                  | P:\\ssdr\\tbam             | ssdr/tbam             | DEST_INFILE_VAR_TMBAM_DMP_TXN                      |
      | esi_TW_newcash_                                 | P:\\taiwan                 | taiwan                | DEST_INFILE_VAR_TW_FAS_NEW_CASH                    |
      | esi_TW_EODCash_*CashStmt_CATHAY_*               | P:\\taiwan                 | taiwan                | DEST_INFILE_VAR_TW_OCR_CASH_STATEMENT              |
      | WFOEEISLPOSITN                                  | P:\\ssdr\\wfoe             | ssdr/wfoe             | DEST_INFILE_VAR_WFOE_DMP_POSITION                  |
      | WFOEEISLINSTMT                                  | P:\\ssdr\\wfoe             | ssdr/wfoe             | DEST_INFILE_VAR_WFOE_DMP_SECURITY                  |
      | WFOEEISLTRANSN                                  | P:\\ssdr\\wfoe             | ssdr/wfoe             | DEST_INFILE_VAR_WFOE_DMP_TXN                       |
      | esi_brs_TW_CM_SMF_                              | P:\\cmoney                 | cmoney                | DEST_INFILE_VAR_CMONEY_DMP_SECURITY                |
      | ESI_BRS_POSITION_FX_B1_*_combined               | P:\\hsbc                   | hsbc                  | DEST_INFILE_VAR_HSBC_FX_POSITION_TO_BRS            |
      | ESI_BRS_NAV_PRICE_A0007DDM01_B1_                | P:\\hsbc                   | hsbc                  | DEST_INFILE_VAR_HSBC_NAV_PRICE                     |
      | ESI_BRS_POSITION_NONFX_B1*_combined.csv         | P:\\hsbc                   | hsbc                  | DEST_INFILE_VAR_HSBC_NONFX_POSITION_TO_BRS         |
      | ESI_BRS_POSITION_NONFX_A0007DDM01_B1_           | P:\\hsbc                   | hsbc                  | DEST_INFILE_VAR_HSBC_PRICE                         |
      | ESI_BRS_POSITION_FX_B1_*_combined.csv           | P:\\ssb                    | ssb                   | DEST_INFILE_VAR_SSB_FX_POSITION_TO_BRS             |
      | ESI_BRS_POSITION_NONFX_B1_*_combined.csv        | P:\\ssb                    | ssb                   | DEST_INFILE_VAR_SSB_NONFX_POSITION_TO_BRS          |
      | ESI_BRS_POSITION_NONFX_TD00099_B2_              | P:\\ssb                    | ssb                   | DEST_INFILE_VAR_SSB_PRICE                          |
      | PRUESID_CITI_NAV_PRICE                          | P:\\citi\\nav              | citi/nav              | DEST_INFILE_VAR_CITI_DMP_NAV                       |
      | Adhoc_Q_east_price_C_                           | P:\\ibpa\\price            | ibpa/price            | DEST_INFILE_VAR_IBPA_DMP_PRICE                     |
      | SCB_ID_NAV_PRICE                                | P:\\scb\\nav               | scb/nav               | DEST_INFILE_VAR_SCB_DMP_NAV                        |
      | PLA_MGMTFEES                                    | P:\\esid\\intraday         | esid/intraday         | DEST_INFILE_VAR_TAC_INTRADAY_MISC_TRANSACTION      |
      | PLA_FUNDALLOC                                   | P:\\esid\\intraday         | esid/intraday         | DEST_INFILE_VAR_TAC_PLAI_INTRADAY_CASH_TRANSACTION |
      | subs_redm_report                                | P:\\esid\\intraday         | esid/intraday         | DEST_INFILE_VAR_TAC_SCB_INTRADAY_CASH_TRANSACTION  |
#
  Scenario: Connect to GC Upgraded Environment

    Given I set the DMP workflow web service endpoint to named configuration "dmp.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.GC"

  Scenario Outline: Load inbound file <file_name> on GC Upgraded Environment

    And I copy files below from local folder "${TESTDATA_BASE_PATH}/<testdata_path>" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${<file_name>} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                |
      | FILE_PATTERN  | ${<file_name>} |
      | MESSAGE_TYPE  | <msg_typ>      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I export below sql query results to CSV file "${TESTDATA_BASE_PATH}/<testdata_path>/<qry_file_name>"
    """
    SELECT JOB_STAT_TYP,JOB_INPUT_TXT,TASK_SUCCESS_CNT,TASK_FAILED_CNT,TASK_PARTIAL_CNT,JOB_MSG_TYP FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
    """
    Examples:
      | file_name                                          | msg_typ                                    | testdata_path    | qry_file_name                                  |
      | DEST_INFILE_VAR_RCR_POSITIONS                      | EICN_MT_RCR_POSITIONS                      | china/transform  | UPG_esi_sc_positionnonfx.csv                   |
      | DEST_INFILE_VAR_RCR_SECURITY                       | EICN_MT_RCR_SECURITY                       | china/transform  | UPG_esi_sc_security.csv                        |
      | DEST_INFILE_VAR_RCR_TRANSACTIONS                   | EICN_MT_RCR_TRANSACTIONS                   | china/transform  | UPG_esi_sc_transactions.csv                    |
      | DEST_INFILE_VAR_DB_NAV_ABOR                        | EIM_MT_DB_NAV_ABOR                         | db/nav           | UPG_F2-UT_MYCRNAV.csv                          |
      | DEST_INFILE_VAR_MFUND_NAV_ABOR                     | EIM_MT_MFUND_NAV_ABOR                      | mfund/nav        | UPG_L1-INS_MYCRNAV.csv                         |
      | DEST_INFILE_VAR_SCB_DMP_NAV                        | EIM_MT_SCB_DMP_NAV                         | scb/nav          | UPG_PAMB_Daily_T0.csv                          |
      | DEST_INFILE_VAR_BNP_EOD_EXCHANGE_RATE              | EIS_MT_BNP_EOD_EXCHANGE_RATE               | bnp/sod          | UPG_ESISODP_EXR_1.csv                          |
      | DEST_INFILE_VAR_BNP_INTRADAY_CASH_TRANSACTION      | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION       | bnp/intraday     | UPG_ESIINTRADAY_TRN_5.csv                      |
      | DEST_INFILE_VAR_BNP_INTRADAY_CASH_TRANSACTION      | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION       | bnp/intraday     | UPG_ESIINTRADAY_TRN_5.csv                      |
      | DEST_INFILE_VAR_BNP_PERFORMANCE_RETURNS            | EIS_MT_BNP_PERFORMANCE_RETURNS             | bnp/irp          | UPG_ESI_FE_ESIL1ALLOct19.csv                   |
      | DEST_INFILE_VAR_BNP_PORTFOLIO                      | EIS_MT_BNP_PORTFOLIO                       | bnp/intraday     | UPG_ESIINTRADAY_PTF_5.csv                      |
      | DEST_INFILE_VAR_BNP_SECURITY_INTRADAY              | EIS_MT_BNP_SECURITY                        | bnp/intraday     | UPG_ESIINTRADAY_SEC_6.csv                      |
      | DEST_INFILE_VAR_BNP_SECURITY_SOD                   | EIS_MT_BNP_SECURITY                        | bnp/sod          | UPG_ESISODP_SEC_1.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONFX_LATAM           | EIS_MT_BNP_SOD_POSITIONFX_LATAM            | bnp/sod          | UPG_ESISODP_POS_3.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONFX_NONLATAM        | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM         | bnp/sod          | UPG_ESISODP_POS_1.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONNONFX_LATAM        | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM         | bnp/sod          | UPG_ESISODP_SDP_3.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONNONFX_NONLATAM     | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM      | bnp/sod          | UPG_ESISODP_SDP_1.csv                          |
      | DEST_INFILE_VAR_BOCI_DMP_FUND                      | EIS_MT_BOCI_DMP_FUND                       | ssdr/boci        | UPG_BOCIEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_BOCI_DMP_POSITION                  | EIS_MT_BOCI_DMP_POSITION                   | ssdr/boci        | UPG_BOCIEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_BOCI_DMP_SECURITY                  | EIS_MT_BOCI_DMP_SECURITY                   | ssdr/boci        | UPG_BOCIEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_BOCI_DMP_TXN                       | EIS_MT_BOCI_DMP_TXN                        | ssdr/boci        | UPG_BOCIEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_BRS_CASHALLOC_FILE11               | EIS_MT_BRS_CASHALLOC_FILE11                | brs/intraday     | UPG_esi_itap_asia.csv                          |
      | DEST_INFILE_VAR_BRS_CASHALLOC_FILE96               | EIS_MT_BRS_CASHALLOC_FILE96                | brs/intraday     | UPG_esi_newcash.csv                            |
      | DEST_INFILE_VAR_BRS_COUNTERPARTY                   | EIS_MT_BRS_COUNTERPARTY                    | brs              | UPG_esi_EOD_PITL_broker.csv                    |
      | DEST_INFILE_VAR_BRS_COUPONS                        | EIS_MT_BRS_COUPONS                         | brs/eod          | UPG_esi_ADX_EOD_ASIA_coupon.csv                |
      | DEST_INFILE_VAR_BRS_EOD_POSITION_NON_LATAM         | EIS_MT_BRS_EOD_POSITION_NON_LATAM          | brs/eod          | UPG_esi_ADX_EOD_ASIA_pos.csv                   |
      | DEST_INFILE_VAR_BRS_EOD_POSITION_NPP               | EIS_MT_BRS_EOD_POSITION_NPP                | ssdr/npp         | UPG_esi_ADX_EOD_NP_pos.csv                     |
      | DEST_INFILE_VAR_BRS_EOD_POSITION_TREASURY          | EIS_MT_BRS_EOD_POSITION_TREASURY           | brs              | UPG_esi_EOD_PITL_pos.csv                       |
      | DEST_INFILE_VAR_BRS_EOD_TRANSACTION_NON_LATAM      | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM       | brs/eod          | UPG_esi_ADX_EOD_ASIA_2.transaction.csv         |
      | DEST_INFILE_VAR_BRS_EOD_TRANSACTION_TREASURY       | EIS_MT_BRS_EOD_TRANSACTION_TREASURY        | brs              | UPG_esi_EOD_PITL_2.transaction.csv             |
      | DEST_INFILE_VAR_BRS_INTRADAY_TRANSACTION           | EIS_MT_BRS_INTRADAY_TRANSACTION            | taiwan           | UPG_esi_TW_ADX_I.2.transaction.csv             |
      | DEST_INFILE_VAR_BRS_ISSUER                         | EIS_MT_BRS_ISSUER                          | brs/eod          | UPG_esi_ADX_EOD_ASIA_2.issuer.csv              |
      | DEST_INFILE_VAR_BRS_ORDERS                         | EIS_MT_BRS_ORDERS                          | brs/eod          | UPG_esi_FOLE_ADX2.order.csv                    |
      | DEST_INFILE_VAR_BRS_PORTFOLIO                      | EIS_MT_BRS_PORTFOLIO                       | brs/6y_portfolio | UPG_esi_portfolio_2.csv                        |
      | DEST_INFILE_VAR_BRS_PORTFOLIO_GROUP                | EIS_MT_BRS_PORTFOLIO_GROUP                 | brs/qsg          | UPG_esi_port_group_owned.csv                   |
     # | DEST_INFILE_VAR_BRS_RISK_ANALYTICS                 | EIS_MT_BRS_RISK_ANALYTICS                  | brs/7a_risk_analytics | UPG_esi_security_analytics_apac.csv            |
     # | DEST_INFILE_VAR_BRS_SEC_ANALYTICS_GLOBAL           | EIS_MT_BRS_SEC_ANALYTICS_GLOBAL            | brs/7a_risk_analytics | UPG_esi_security_analytics_gl"                 |
      | DEST_INFILE_VAR_BRS_SECURITY_NEW                   | EIS_MT_BRS_SECURITY_NEW                    | taiwan           | UPG_esi_TW_ADX_I.sm.csv                        |
      | DEST_INFILE_VAR_BRS_SHARES_OUTSTANDING             | EIS_MT_BRS_SHARES_OUTSTANDING              | brs/eod          | UPG_esi_ADX_EOD_ASIA_.shares_outstanding.csv   |
      | DEST_INFILE_VAR_BRS_USER_GROUP                     | EIS_MT_BRS_USER_GROUP                      | brs/eod          | UPG_esi_users_groups.csv                       |
      | DEST_INFILE_VAR_CITI_DMP_SBL_POSITION              | EIS_MT_CITI_DMP_SBL_POSITION               | ssdr/citi        | UPG_EODSBLPOSITIONS.csv                        |
      | DEST_INFILE_VAR_DMP_HSBC_BROKER_PRICE              | EIS_MT_DMP_HSBC_BROKER_PRICE               | edm/price        | UPG_esisg_dmp_hsbc_broker_price.csv            |
      | DEST_INFILE_VAR_EDM_INT_PRICE_MASTER_TEMPLATE      | EIS_MT_EDM_INT_PRICE_MASTER_TEMPLATE       | edm/price        | UPG_esisg_dmp_price.csv                        |
      | DEST_INFILE_VAR_EDM_PRICE_MASTER_TEMPLATE          | EIS_MT_EDM_PRICE_MASTER_TEMPLATE           | edm/price        | UPG_esisg_dmp_price.csv                        |
      | DEST_INFILE_VAR_EDM_SCB_BROKER_PRICE               | EIS_MT_EDM_SCB_BROKER_PRICE                | edm/price        | UPG_esisg_dmp_scb_broker_price.csv             |
      | DEST_INFILE_VAR_EIMK_DMP_FUND                      | EIS_MT_EIMK_DMP_FUND                       | ssdr/korea       | UPG_EIMKEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_EIMK_DMP_POSITION                  | EIS_MT_EIMK_DMP_POSITION                   | ssdr/korea       | UPG_EIMKEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_EIMK_DMP_SECURITY                  | EIS_MT_EIMK_DMP_SECURITY                   | ssdr/korea       | UPG_EIMKEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_EIMK_DMP_TXN                       | EIS_MT_EIMK_DMP_TXN                        | ssdr/korea       | UPG_EIMKEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_FUND                      | EIS_MT_ESGA_DMP_FUND                       | ssdr/esga        | UPG_ESGAEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_POSITION                  | EIS_MT_ESGA_DMP_POSITION                   | ssdr/esga        | UPG_ESGAEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_SECURITY                  | EIS_MT_ESGA_DMP_SECURITY                   | ssdr/esga        | UPG_ESGAEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_TXN                       | EIS_MT_ESGA_DMP_TXN                        | ssdr/esga        | UPG_ESGAEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_FUND                      | EIS_MT_ESJP_DMP_FUND                       | ssdr/japan       | UPG_ESJPEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_POSITION                  | EIS_MT_ESJP_DMP_POSITION                   | ssdr/japan       | UPG_ESJPEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_SECURITY                  | EIS_MT_ESJP_DMP_SECURITY                   | ssdr/japan       | UPG_ESJPEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_TXN                       | EIS_MT_ESJP_DMP_TXN                        | ssdr/japan       | UPG_ESJPEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_HSBC_BROKER_PRICE                  | EIS_MT_HSBC_BROKER_PRICE                   | hsbc             | UPG_EASTSPRINGINVESTMENTSFUNDPRICEVARIANCE.csv |
      | DEST_INFILE_VAR_IDC_PRICE                          | EIS_MT_IDC_PRICE                           | idc/price        | UPG_VietEvals.csv                              |
      | DEST_INFILE_VAR_JNAM_DMP_FUND                      | EIS_MT_JNAM_DMP_FUND                       | ssdr/ppma        | UPG_PPMAEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_JNAM_DMP_POSITION                  | EIS_MT_JNAM_DMP_POSITION                   | ssdr/ppma        | UPG_PPMAEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_JNAM_DMP_SECURITY                  | EIS_MT_JNAM_DMP_SECURITY                   | ssdr/ppma        | UPG_PPMAEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_JNAM_DMP_TXN                       | EIS_MT_JNAM_DMP_TXN                        | ssdr/ppma        | UPG_PPMAEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_MNG_DMP_SBL_POSITION               | EIS_MT_MNG_DMP_SBL_POSITION                | ssdr/mng         | UPG_MANGEISLSLPOSN.csv                         |
      | DEST_INFILE_VAR_MNG_DMP_SECURITY                   | EIS_MT_MNG_DMP_SECURITY                    | ssdr/mng         | UPG_MANGEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_PST_TARGET_PRICE                   | EIS_MT_PST_TARGET_PRICE                    | qsg              | UPG_buylist.csv                                |
      | DEST_INFILE_VAR_REUTERS_PRICE                      | EIS_MT_REUTERS_PRICE                       | reuters/price    | UPG_VNQReuters.csv                             |
      | DEST_INFILE_VAR_SCB_BROKER_PRICE                   | EIS_MT_SCB_BROKER_PRICE                    | scb              | UPG_DailyNetAssetValueInternalFunds(ESI).csv   |
      | DEST_INFILE_VAR_SCB_BROKER_PRICE                   | EIS_MT_SCB_BROKER_PRICE                    | scb              | UPG_PH-DailyNetAssetValue.csv                  |
      | DEST_INFILE_VAR_TMBAM_DMP_FUND                     | EIS_MT_TMBAM_DMP_FUND                      | ssdr/tbam        | UPG_TBAMEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_TMBAM_DMP_POSITION                 | EIS_MT_TMBAM_DMP_POSITION                  | ssdr/tbam        | UPG_TBAMEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_TMBAM_DMP_SBL_POSITION             | EIS_MT_TMBAM_DMP_SBL_POSITION              | ssdr/tbam        | UPG_TBAMSBLPOSITIONS.csv                       |
      | DEST_INFILE_VAR_TMBAM_DMP_SECURITY                 | EIS_MT_TMBAM_DMP_SECURITY                  | ssdr/tbam        | UPG_TBAMEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_TMBAM_DMP_TXN                      | EIS_MT_TMBAM_DMP_TXN                       | ssdr/tbam        | UPG_TBAMEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_TW_FAS_NEW_CASH                    | EIS_MT_TW_FAS_NEW_CASH                     | taiwan           | UPG_esi_TW_newcash.csv                         |
      | DEST_INFILE_VAR_TW_OCR_CASH_STATEMENT              | EIS_MT_TW_OCR_CASH_STATEMENT               | taiwan           | UPG_esi_TW_EODCash_CashStmt_CATHAY.csv         |
      | DEST_INFILE_VAR_WFOE_DMP_POSITION                  | EIS_MT_WFOE_DMP_POSITION                   | ssdr/wfoe        | UPG_WFOEEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_WFOE_DMP_SECURITY                  | EIS_MT_WFOE_DMP_SECURITY                   | ssdr/wfoe        | UPG_WFOEEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_WFOE_DMP_TXN                       | EIS_MT_WFOE_DMP_TXN                        | ssdr/wfoe        | UPG_WFOEEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_CMONEY_DMP_SECURITY                | EITW_MT_CMONEY_DMP_SECURITY                | cmoney           | UPG_esi_brs_TW_CM_SMF.csv                      |
      | DEST_INFILE_VAR_HSBC_FX_POSITION_TO_BRS            | EITW_MT_HSBC_FX_POSITION_TO_BRS            | hsbc             | UPG_ESI_BRS_POSITION_FX_B1__combined.csv       |
      | DEST_INFILE_VAR_HSBC_NAV_PRICE                     | EITW_MT_HSBC_NAV_PRICE                     | hsbc             | UPG_ESI_BRS_NAV_PRICE_A0007DDM01_B1.csv        |
      | DEST_INFILE_VAR_HSBC_NONFX_POSITION_TO_BRS         | EITW_MT_HSBC_NONFX_POSITION_TO_BRS         | hsbc             | UPG_ESI_BRS_POSITION_NONFX_B1_combined.csv     |
      | DEST_INFILE_VAR_HSBC_PRICE                         | EITW_MT_HSBC_PRICE                         | hsbc             | UPG_ESI_BRS_POSITION_NONFX_A0007DDM01_B1.csv   |
      | DEST_INFILE_VAR_SSB_FX_POSITION_TO_BRS             | EITW_MT_SSB_FX_POSITION_TO_BRS             | ssb              | UPG_ESI_BRS_POSITION_FX_B1__combined.csv       |
      | DEST_INFILE_VAR_SSB_NONFX_POSITION_TO_BRS          | EITW_MT_SSB_NONFX_POSITION_TO_BRS          | ssb              | UPG_ESI_BRS_POSITION_NONFX_B1__combined.csv    |
      | DEST_INFILE_VAR_SSB_PRICE                          | EITW_MT_SSB_PRICE                          | ssb              | UPG_ESI_BRS_POSITION_NONFX_TD00099_B2.csv      |
      | DEST_INFILE_VAR_CITI_DMP_NAV                       | ESII_MT_CITI_DMP_NAV                       | citi/nav         | UPG_PRUESID_CITI_NAV_PRICE.csv                 |
      | DEST_INFILE_VAR_IBPA_DMP_PRICE                     | ESII_MT_IBPA_DMP_PRICE                     | ibpa/price       | UPG_Adhoc_Q_east_price_C.csv                   |
      | DEST_INFILE_VAR_SCB_DMP_NAV                        | ESII_MT_SCB_DMP_NAV                        | scb/nav          | UPG_SCB_ID_NAV_PRICE.csv                       |
      | DEST_INFILE_VAR_TAC_INTRADAY_MISC_TRANSACTION      | ESII_MT_TAC_INTRADAY_MISC_TRANSACTION      | esid/intraday    | UPG_PLA_MGMTFEES.csv                           |
      | DEST_INFILE_VAR_TAC_PLAI_INTRADAY_CASH_TRANSACTION | ESII_MT_TAC_PLAI_INTRADAY_CASH_TRANSACTION | esid/intraday    | UPG_PLA_FUNDALLOC.csv                          |
      | DEST_INFILE_VAR_TAC_SCB_INTRADAY_CASH_TRANSACTION  | ESII_MT_TAC_SCB_INTRADAY_CASH_TRANSACTION  | esid/intraday    | UPG_subs_redm_report.csv                       |

  Scenario: Connect to GC Regular Dev Environment

    Given I set the DMP workflow web service endpoint to named configuration "dmp.ws.WORKFLOW1"
    And I set the database connection to configuration "dmp.db.GC1"

  Scenario Outline: Load inbound file <file_name> on GC Regular Daily Dev  Environment
    And I copy files below from local folder "${TESTDATA_BASE_PATH}/<testdata_path>" to the host "dmp.ssh.inbound1" folder "${dmp.ssh.inbound.path}":
      | ${<file_name>} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                |
      | FILE_PATTERN  | ${<file_name>} |
      | MESSAGE_TYPE  | <msg_typ>      |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I export below sql query results to CSV file "${TESTDATA_BASE_PATH}/<testdata_path>/<qry_file_name>"
      """
      SELECT JOB_STAT_TYP,JOB_INPUT_TXT,TASK_SUCCESS_CNT,TASK_FAILED_CNT,TASK_PARTIAL_CNT,JOB_MSG_TYP FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """
    Examples:
      | file_name                                          | msg_typ                                    | testdata_path    | qry_file_name                                  |
      | DEST_INFILE_VAR_RCR_POSITIONS                      | EICN_MT_RCR_POSITIONS                      | china/transform  | REG_esi_sc_positionnonfx.csv                   |
      | DEST_INFILE_VAR_RCR_SECURITY                       | EICN_MT_RCR_SECURITY                       | china/transform  | REG_esi_sc_security.csv                        |
      | DEST_INFILE_VAR_RCR_TRANSACTIONS                   | EICN_MT_RCR_TRANSACTIONS                   | china/transform  | REG_esi_sc_transactions.csv                    |
      | DEST_INFILE_VAR_DB_NAV_ABOR                        | EIM_MT_DB_NAV_ABOR                         | db/nav           | REG_F2-UT_MYCRNAV.csv                          |
      | DEST_INFILE_VAR_MFUND_NAV_ABOR                     | EIM_MT_MFUND_NAV_ABOR                      | mfund/nav        | REG_L1-INS_MYCRNAV.csv                         |
      | DEST_INFILE_VAR_SCB_DMP_NAV                        | EIM_MT_SCB_DMP_NAV                         | scb/nav          | REG_PAMB_Daily_T0.csv                          |
      | DEST_INFILE_VAR_BNP_EOD_EXCHANGE_RATE              | EIS_MT_BNP_EOD_EXCHANGE_RATE               | bnp/sod          | REG_ESISODP_EXR_1.csv                          |
      | DEST_INFILE_VAR_BNP_INTRADAY_CASH_TRANSACTION      | EIS_MT_BNP_INTRADAY_CASH_TRANSACTION       | bnp/intraday     | REG_ESIINTRADAY_TRN_5.csv                      |
      | DEST_INFILE_VAR_BNP_PERFORMANCE_RETURNS            | EIS_MT_BNP_PERFORMANCE_RETURNS             | bnp/irp          | REG_ESI_FE_ESIL1ALLOct19.csv                   |
      | DEST_INFILE_VAR_BNP_PORTFOLIO                      | EIS_MT_BNP_PORTFOLIO                       | bnp/intraday     | REG_ESIINTRADAY_PTF_5.csv                      |
      | DEST_INFILE_VAR_BNP_SECURITY_INTRADAY              | EIS_MT_BNP_SECURITY                        | bnp/intraday     | REG_ESIINTRADAY_SEC_6.csv                      |
      | DEST_INFILE_VAR_BNP_SECURITY_SOD                   | EIS_MT_BNP_SECURITY                        | bnp/sod          | REG_ESISODP_SEC_1.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONFX_LATAM           | EIS_MT_BNP_SOD_POSITIONFX_LATAM            | bnp/sod          | REG_ESISODP_POS_3.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONFX_NONLATAM        | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM         | bnp/sod          | REG_ESISODP_POS_1.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONNONFX_LATAM        | EIS_MT_BNP_SOD_POSITIONNONFX_LATAM         | bnp/sod          | REG_ESISODP_SDP_3.csv                          |
      | DEST_INFILE_VAR_BNP_SOD_POSITIONNONFX_NONLATAM     | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM      | bnp/sod          | REG_ESISODP_SDP_1.csv                          |
      | DEST_INFILE_VAR_BOCI_DMP_FUND                      | EIS_MT_BOCI_DMP_FUND                       | ssdr/boci        | REG_BOCIEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_BOCI_DMP_POSITION                  | EIS_MT_BOCI_DMP_POSITION                   | ssdr/boci        | REG_BOCIEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_BOCI_DMP_SECURITY                  | EIS_MT_BOCI_DMP_SECURITY                   | ssdr/boci        | REG_BOCIEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_BOCI_DMP_TXN                       | EIS_MT_BOCI_DMP_TXN                        | ssdr/boci        | REG_BOCIEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_BRS_CASHALLOC_FILE11               | EIS_MT_BRS_CASHALLOC_FILE11                | brs/intraday     | REG_esi_itap_asia.csv                          |
      | DEST_INFILE_VAR_BRS_CASHALLOC_FILE96               | EIS_MT_BRS_CASHALLOC_FILE96                | brs/intraday     | REG_esi_newcash.csv                            |
      | DEST_INFILE_VAR_BRS_COUNTERPARTY                   | EIS_MT_BRS_COUNTERPARTY                    | brs              | REG_esi_EOD_PITL_broker.csv                    |
      | DEST_INFILE_VAR_BRS_COUPONS                        | EIS_MT_BRS_COUPONS                         | brs/eod          | REG_esi_ADX_EOD_ASIA_coupon.csv                |
      | DEST_INFILE_VAR_BRS_EOD_POSITION_NON_LATAM         | EIS_MT_BRS_EOD_POSITION_NON_LATAM          | brs/eod          | REG_esi_ADX_EOD_ASIA_pos.csv                   |
      | DEST_INFILE_VAR_BRS_EOD_POSITION_NPP               | EIS_MT_BRS_EOD_POSITION_NPP                | ssdr/npp         | REG_esi_ADX_EOD_NP_pos.csv                     |
      | DEST_INFILE_VAR_BRS_EOD_POSITION_TREASURY          | EIS_MT_BRS_EOD_POSITION_TREASURY           | brs              | REG_esi_EOD_PITL_pos.csv                       |
      | DEST_INFILE_VAR_BRS_EOD_TRANSACTION_NON_LATAM      | EIS_MT_BRS_EOD_TRANSACTION_NON_LATAM       | brs/eod          | REG_esi_ADX_EOD_ASIA_2.transaction.csv         |
      | DEST_INFILE_VAR_BRS_EOD_TRANSACTION_TREASURY       | EIS_MT_BRS_EOD_TRANSACTION_TREASURY        | brs              | REG_esi_EOD_PITL_2.transaction.csv             |
      | DEST_INFILE_VAR_BRS_INTRADAY_TRANSACTION           | EIS_MT_BRS_INTRADAY_TRANSACTION            | taiwan           | REG_esi_TW_ADX_I.2.transaction.csv             |
      | DEST_INFILE_VAR_BRS_ISSUER                         | EIS_MT_BRS_ISSUER                          | brs/eod          | REG_esi_ADX_EOD_ASIA_2.issuer.csv              |
      | DEST_INFILE_VAR_BRS_ORDERS                         | EIS_MT_BRS_ORDERS                          | brs/eod          | REG_esi_FOLE_ADX2.order.csv                    |
      | DEST_INFILE_VAR_BRS_PORTFOLIO                      | EIS_MT_BRS_PORTFOLIO                       | brs/6y_portfolio | REG_esi_portfolio_2.csv                        |
      | DEST_INFILE_VAR_BRS_PORTFOLIO_GROUP                | EIS_MT_BRS_PORTFOLIO_GROUP                 | brs/qsg          | REG_esi_port_group_owned.csv                   |
    #  | DEST_INFILE_VAR_BRS_RISK_ANALYTICS                 | EIS_MT_BRS_RISK_ANALYTICS                  | brs/7a_risk_analytics | REG_esi_security_analytics_apac.csv            |
    #  | DEST_INFILE_VAR_BRS_SEC_ANALYTICS_GLOBAL           | EIS_MT_BRS_SEC_ANALYTICS_GLOBAL            | brs/7a_risk_analytics | REG_esi_security_analytics_global.csv          |
      | DEST_INFILE_VAR_BRS_SECURITY_NEW                   | EIS_MT_BRS_SECURITY_NEW                    | taiwan           | REG_esi_TW_ADX_I.sm.csv                        |
      | DEST_INFILE_VAR_BRS_SHARES_OUTSTANDING             | EIS_MT_BRS_SHARES_OUTSTANDING              | brs/eod          | REG_esi_ADX_EOD_ASIA_.shares_outstanding.csv   |
      | DEST_INFILE_VAR_BRS_USER_GROUP                     | EIS_MT_BRS_USER_GROUP                      | brs/eod          | REG_esi_users_groups.csv                       |
      | DEST_INFILE_VAR_CITI_DMP_SBL_POSITION              | EIS_MT_CITI_DMP_SBL_POSITION               | ssdr/citi        | REG_EODSBLPOSITIONS.csv                        |
      | DEST_INFILE_VAR_DMP_HSBC_BROKER_PRICE              | EIS_MT_DMP_HSBC_BROKER_PRICE               | edm/price        | REG_esisg_dmp_hsbc_broker_price.csv            |
      | DEST_INFILE_VAR_EDM_INT_PRICE_MASTER_TEMPLATE      | EIS_MT_EDM_INT_PRICE_MASTER_TEMPLATE       | edm/price        | REG_esisg_dmp_price.csv                        |
      | DEST_INFILE_VAR_EDM_PRICE_MASTER_TEMPLATE          | EIS_MT_EDM_PRICE_MASTER_TEMPLATE           | edm/price        | REG_esisg_dmp_price.csv                        |
      | DEST_INFILE_VAR_EDM_SCB_BROKER_PRICE               | EIS_MT_EDM_SCB_BROKER_PRICE                | edm/price        | REG_esisg_dmp_scb_broker_price.csv             |
      | DEST_INFILE_VAR_EIMK_DMP_FUND                      | EIS_MT_EIMK_DMP_FUND                       | ssdr/korea       | REG_EIMKEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_EIMK_DMP_POSITION                  | EIS_MT_EIMK_DMP_POSITION                   | ssdr/korea       | REG_EIMKEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_EIMK_DMP_SECURITY                  | EIS_MT_EIMK_DMP_SECURITY                   | ssdr/korea       | REG_EIMKEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_EIMK_DMP_TXN                       | EIS_MT_EIMK_DMP_TXN                        | ssdr/korea       | REG_EIMKEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_FUND                      | EIS_MT_ESGA_DMP_FUND                       | ssdr/esga        | REG_ESGAEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_POSITION                  | EIS_MT_ESGA_DMP_POSITION                   | ssdr/esga        | REG_ESGAEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_SECURITY                  | EIS_MT_ESGA_DMP_SECURITY                   | ssdr/esga        | REG_ESGAEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_ESGA_DMP_TXN                       | EIS_MT_ESGA_DMP_TXN                        | ssdr/esga        | REG_ESGAEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_FUND                      | EIS_MT_ESJP_DMP_FUND                       | ssdr/japan       | REG_ESJPEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_POSITION                  | EIS_MT_ESJP_DMP_POSITION                   | ssdr/japan       | REG_ESJPEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_SECURITY                  | EIS_MT_ESJP_DMP_SECURITY                   | ssdr/japan       | REG_ESJPEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_ESJP_DMP_TXN                       | EIS_MT_ESJP_DMP_TXN                        | ssdr/japan       | REG_ESJPEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_HSBC_BROKER_PRICE                  | EIS_MT_HSBC_BROKER_PRICE                   | hsbc             | REG_EASTSPRINGINVESTMENTSFUNDPRICEVARIANCE.csv |
      | DEST_INFILE_VAR_IDC_PRICE                          | EIS_MT_IDC_PRICE                           | idc/price        | REG_VietEvals.csv                              |
      | DEST_INFILE_VAR_JNAM_DMP_FUND                      | EIS_MT_JNAM_DMP_FUND                       | ssdr/ppma        | REG_PPMAEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_JNAM_DMP_POSITION                  | EIS_MT_JNAM_DMP_POSITION                   | ssdr/ppma        | REG_PPMAEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_JNAM_DMP_SECURITY                  | EIS_MT_JNAM_DMP_SECURITY                   | ssdr/ppma        | REG_PPMAEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_JNAM_DMP_TXN                       | EIS_MT_JNAM_DMP_TXN                        | ssdr/ppma        | REG_PPMAEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_MNG_DMP_SBL_POSITION               | EIS_MT_MNG_DMP_SBL_POSITION                | ssdr/mng         | REG_MANGEISLSLPOSN.csv                         |
      | DEST_INFILE_VAR_MNG_DMP_SECURITY                   | EIS_MT_MNG_DMP_SECURITY                    | ssdr/mng         | REG_MANGEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_PST_TARGET_PRICE                   | EIS_MT_PST_TARGET_PRICE                    | qsg              | REG_buylist.csv                                |
      | DEST_INFILE_VAR_REUTERS_PRICE                      | EIS_MT_REUTERS_PRICE                       | reuters/price    | REG_VNQReuters.csv                             |
      | DEST_INFILE_VAR_SCB_BROKER_PRICE                   | EIS_MT_SCB_BROKER_PRICE                    | scb              | REG_DailyNetAssetValueInternalFunds(ESI).csv   |
      | DEST_INFILE_VAR_SCB_BROKER_PRICE                   | EIS_MT_SCB_BROKER_PRICE                    | scb              | REG_PH-DailyNetAssetValue.csv                  |
      | DEST_INFILE_VAR_TMBAM_DMP_FUND                     | EIS_MT_TMBAM_DMP_FUND                      | ssdr/tbam        | REG_TBAMEISLFUNDLE.csv                         |
      | DEST_INFILE_VAR_TMBAM_DMP_POSITION                 | EIS_MT_TMBAM_DMP_POSITION                  | ssdr/tbam        | REG_TBAMEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_TMBAM_DMP_SBL_POSITION             | EIS_MT_TMBAM_DMP_SBL_POSITION              | ssdr/tbam        | REG_TBAMSBLPOSITIONS.csv                       |
      | DEST_INFILE_VAR_TMBAM_DMP_SECURITY                 | EIS_MT_TMBAM_DMP_SECURITY                  | ssdr/tbam        | REG_TBAMEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_TMBAM_DMP_TXN                      | EIS_MT_TMBAM_DMP_TXN                       | ssdr/tbam        | REG_TBAMEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_TW_FAS_NEW_CASH                    | EIS_MT_TW_FAS_NEW_CASH                     | taiwan           | REG_esi_TW_newcash.csv                         |
      | DEST_INFILE_VAR_TW_OCR_CASH_STATEMENT              | EIS_MT_TW_OCR_CASH_STATEMENT               | taiwan           | REG_esi_TW_EODCash_CashStmt_CATHAY.csv         |
      | DEST_INFILE_VAR_WFOE_DMP_POSITION                  | EIS_MT_WFOE_DMP_POSITION                   | ssdr/wfoe        | REG_WFOEEISLPOSITN.csv                         |
      | DEST_INFILE_VAR_WFOE_DMP_SECURITY                  | EIS_MT_WFOE_DMP_SECURITY                   | ssdr/wfoe        | REG_WFOEEISLINSTMT.csv                         |
      | DEST_INFILE_VAR_WFOE_DMP_TXN                       | EIS_MT_WFOE_DMP_TXN                        | ssdr/wfoe        | REG_WFOEEISLTRANSN.csv                         |
      | DEST_INFILE_VAR_CMONEY_DMP_SECURITY                | EITW_MT_CMONEY_DMP_SECURITY                | cmoney           | REG_esi_brs_TW_CM_SMF.csv                      |
      | DEST_INFILE_VAR_HSBC_FX_POSITION_TO_BRS            | EITW_MT_HSBC_FX_POSITION_TO_BRS            | hsbc             | REG_ESI_BRS_POSITION_FX_B1__combined.csv       |
      | DEST_INFILE_VAR_HSBC_NAV_PRICE                     | EITW_MT_HSBC_NAV_PRICE                     | hsbc             | REG_ESI_BRS_NAV_PRICE_A0007DDM01_B1.csv        |
      | DEST_INFILE_VAR_HSBC_NONFX_POSITION_TO_BRS         | EITW_MT_HSBC_NONFX_POSITION_TO_BRS         | hsbc             | REG_ESI_BRS_POSITION_NONFX_B1_combined.csv     |
      | DEST_INFILE_VAR_HSBC_PRICE                         | EITW_MT_HSBC_PRICE                         | hsbc             | REG_ESI_BRS_POSITION_NONFX_A0007DDM01_B1.csv   |
      | DEST_INFILE_VAR_SSB_FX_POSITION_TO_BRS             | EITW_MT_SSB_FX_POSITION_TO_BRS             | ssb              | REG_ESI_BRS_POSITION_FX_B1__combined.csv       |
      | DEST_INFILE_VAR_SSB_NONFX_POSITION_TO_BRS          | EITW_MT_SSB_NONFX_POSITION_TO_BRS          | ssb              | REG_ESI_BRS_POSITION_NONFX_B1__combined.csv    |
      | DEST_INFILE_VAR_SSB_PRICE                          | EITW_MT_SSB_PRICE                          | ssb              | REG_ESI_BRS_POSITION_NONFX_TD00099_B2.csv      |
      | DEST_INFILE_VAR_CITI_DMP_NAV                       | ESII_MT_CITI_DMP_NAV                       | citi/nav         | REG_PRUESID_CITI_NAV_PRICE.csv                 |
      | DEST_INFILE_VAR_IBPA_DMP_PRICE                     | ESII_MT_IBPA_DMP_PRICE                     | ibpa/price       | REG_Adhoc_Q_east_price_C.csv                   |
      | DEST_INFILE_VAR_SCB_DMP_NAV                        | ESII_MT_SCB_DMP_NAV                        | scb/nav          | REG_SCB_ID_NAV_PRICE.csv                       |
      | DEST_INFILE_VAR_TAC_INTRADAY_MISC_TRANSACTION      | ESII_MT_TAC_INTRADAY_MISC_TRANSACTION      | esid/intraday    | REG_PLA_MGMTFEES.csv                           |
      | DEST_INFILE_VAR_TAC_PLAI_INTRADAY_CASH_TRANSACTION | ESII_MT_TAC_PLAI_INTRADAY_CASH_TRANSACTION | esid/intraday    | REG_PLA_FUNDALLOC.csv                          |
      | DEST_INFILE_VAR_TAC_SCB_INTRADAY_CASH_TRANSACTION  | ESII_MT_TAC_SCB_INTRADAY_CASH_TRANSACTION  | esid/intraday    | REG_subs_redm_report.csv                       |


  Scenario Outline:Reconciliation between generated files in Gs upgraded and not upgraded environments :<testdata_path>

    And I assign "${TESTDATA_BASE_PATH}/<testdata_path>/<upgrade_file>" to variable "GC_UPGRADE_FILE"
    And I assign "${TESTDATA_BASE_PATH}/<testdata_path>/<reg_file>" to variable "GC_DEV_FILE"
    And I assign "${TESTDATA_BASE_PATH}/<testdata_path>/<exception_file>" to variable "EXCEP_FILE"

    Then I expect reconciliation between generated CSV file "${GC_UPGRADE_FILE}" and reference CSV file "${GC_DEV_FILE}" should be successful and exceptions to be written to "${EXCEP_FILE}" file
    Examples:
      | testdata_path    | upgrade_file                                   | reg_file                                       | exception_file                                        |
      | china/transform  | UPG_esi_sc_positionnonfx.csv                   | REG_esi_sc_positionnonfx.csv                   | EXCEPTIONS_esi_sc_positionnonfx.csv                   |
      | china/transform  | UPG_esi_sc_security.csv                        | REG_esi_sc_security.csv                        | EXCEPTIONS_esi_sc_security.csv                        |
      | china/transform  | UPG_esi_sc_transactions.csv                    | REG_esi_sc_transactions.csv                    | EXCEPTIONS_esi_sc_transactions.csv                    |
      | db/nav           | UPG_F2-UT_MYCRNAV.csv                          | REG_F2-UT_MYCRNAV.csv                          | EXCEPTIONS_F2-UT_MYCRNAV.csv                          |
      | mfund/nav        | UPG_L1-INS_MYCRNAV.csv                         | REG_L1-INS_MYCRNAV.csv                         | EXCEPTIONS_L1-INS_MYCRNAV.csv                         |
      | scb/nav          | UPG_PAMB_Daily_T0.csv                          | REG_PAMB_Daily_T0.csv                          | EXCEPTIONS_PAMB_Daily_T0.csv                          |
      | bnp/sod          | UPG_ESISODP_EXR_1.csv                          | REG_ESISODP_EXR_1.csv                          | EXCEPTIONS_ESISODP_EXR_1.csv                          |
      | bnp/intraday     | UPG_ESIINTRADAY_TRN_5.csv                      | REG_ESIINTRADAY_TRN_5.csv                      | EXCEPTIONS_ESIINTRADAY_TRN_5.csv                      |
      | bnp/irp          | UPG_ESI_FE_ESIL1ALLOct19.csv                   | REG_ESI_FE_ESIL1ALLOct19.csv                   | EXCEPTIONS_ESI_FE_ESIL1ALLOct19.csv                   |
      | bnp/intraday     | UPG_ESIINTRADAY_PTF_5.csv                      | REG_ESIINTRADAY_PTF_5.csv                      | EXCEPTIONS_ESIINTRADAY_PTF_5.csv                      |
      | bnp/intraday     | UPG_ESIINTRADAY_SEC_6.csv                      | REG_ESIINTRADAY_SEC_6.csv                      | EXCEPTIONS_ESIINTRADAY_SEC_6.csv                      |
      | bnp/sod          | UPG_ESISODP_SEC_1.csv                          | REG_ESISODP_SEC_1.csv                          | EXCEPTIONS_ESISODP_SEC_1.csv                          |
      | bnp/sod          | UPG_ESISODP_POS_3.csv                          | REG_ESISODP_POS_3.csv                          | EXCEPTIONS_ESISODP_POS_3.csv                          |
      | bnp/sod          | UPG_ESISODP_POS_1.csv                          | REG_ESISODP_POS_1.csv                          | EXCEPTIONS_ESISODP_POS_1.csv                          |
      | bnp/sod          | UPG_ESISODP_SDP_3.csv                          | REG_ESISODP_SDP_3.csv                          | EXCEPTIONS_ESISODP_SDP_3.csv                          |
      | bnp/sod          | UPG_ESISODP_SDP_1.csv                          | REG_ESISODP_SDP_1.csv                          | EXCEPTIONS_ESISODP_SDP_1.csv                          |
      | ssdr/boci        | UPG_BOCIEISLFUNDLE.csv                         | REG_BOCIEISLFUNDLE.csv                         | EXCEPTIONS_BOCIEISLFUNDLE.csv                         |
      | ssdr/boci        | UPG_BOCIEISLPOSITN.csv                         | REG_BOCIEISLPOSITN.csv                         | EXCEPTIONS_BOCIEISLPOSITN.csv                         |
      | ssdr/boci        | UPG_BOCIEISLINSTMT.csv                         | REG_BOCIEISLINSTMT.csv                         | EXCEPTIONS_BOCIEISLINSTMT.csv                         |
      | ssdr/boci        | UPG_BOCIEISLTRANSN.csv                         | REG_BOCIEISLTRANSN.csv                         | EXCEPTIONS_BOCIEISLTRANSN.csv                         |
      | brs/intraday     | UPG_esi_itap_asia.csv                          | REG_esi_itap_asia.csv                          | EXCEPTIONS_esi_itap_asia.csv                          |
      | brs/intraday     | UPG_esi_newcash.csv                            | REG_esi_newcash.csv                            | EXCEPTIONS_esi_newcash.csv                            |
      | brs              | UPG_esi_EOD_PITL_broker.csv                    | REG_esi_EOD_PITL_broker.csv                    | EXCEPTIONS_esi_EOD_PITL_broker.csv                    |
      | brs/eod          | UPG_esi_ADX_EOD_ASIA_coupon.csv                | REG_esi_ADX_EOD_ASIA_coupon.csv                | EXCEPTIONS_esi_ADX_EOD_ASIA_coupon.csv                |
      | brs/eod          | UPG_esi_ADX_EOD_ASIA_pos.csv                   | REG_esi_ADX_EOD_ASIA_pos.csv                   | EXCEPTIONS_esi_ADX_EOD_ASIA_pos.csv                   |
      | ssdr/npp         | UPG_esi_ADX_EOD_NP_pos.csv                     | REG_esi_ADX_EOD_NP_pos.csv                     | EXCEPTIONS_esi_ADX_EOD_NP_pos.csv                     |
      | brs              | UPG_esi_EOD_PITL_pos.csv                       | REG_esi_EOD_PITL_pos.csv                       | EXCEPTIONS_esi_EOD_PITL_pos.csv                       |
      | brs/eod          | UPG_esi_ADX_EOD_ASIA_2.transaction.csv         | REG_esi_ADX_EOD_ASIA_2.transaction.csv         | EXCEPTIONS_esi_ADX_EOD_ASIA_2.transaction.csv         |
      | brs              | UPG_esi_EOD_PITL_2.transaction.csv             | REG_esi_EOD_PITL_2.transaction.csv             | EXCEPTIONS_esi_EOD_PITL_2.transaction.csv             |
      | taiwan           | UPG_esi_TW_ADX_I.2.transaction.csv             | REG_esi_TW_ADX_I.2.transaction.csv             | EXCEPTIONS_esi_TW_ADX_I.2.transaction.csv             |
      | brs/eod          | UPG_esi_ADX_EOD_ASIA_2.issuer.csv              | REG_esi_ADX_EOD_ASIA_2.issuer.csv              | EXCEPTIONS_esi_ADX_EOD_ASIA_2.issuer.csv              |
      | brs/eod          | UPG_esi_FOLE_ADX2.order.csv                    | REG_esi_FOLE_ADX2.order.csv                    | EXCEPTIONS_esi_FOLE_ADX2.order.csv                    |
      | brs/6y_portfolio | UPG_esi_portfolio_2.csv                        | REG_esi_portfolio_2.csv                        | EXCEPTIONS_esi_portfolio_2.csv                        |
      | brs/qsg          | UPG_esi_port_group_owned.csv                   | REG_esi_port_group_owned.csv                   | EXCEPTIONS_esi_port_group_owned.csv                   |
     # | brs/7a_risk_analytics | UPG_esi_security_analytics_apac.csv            | REG_esi_security_analytics_apac.csv            | EXCEPTIONS_esi_security_analytics_apac.csv            |
     #| brs/7a_risk_analytics | UPG_esi_security_analytics_global.csv          | REG_esi_security_analytics_global.csv          | EXCEPTIONS_esi_security_analytics_global.csv          |
      | taiwan           | UPG_esi_TW_ADX_I.sm.csv                        | REG_esi_TW_ADX_I.sm.csv                        | EXCEPTIONS_esi_TW_ADX_I.sm.csv                        |
      | brs/eod          | UPG_esi_ADX_EOD_ASIA_.shares_outstanding.csv   | REG_esi_ADX_EOD_ASIA_.shares_outstanding.csv   | EXCEPTIONS_esi_ADX_EOD_ASIA_.shares_outstanding.csv   |
      | brs/eod          | UPG_esi_users_groups.csv                       | REG_esi_users_groups.csv                       | EXCEPTIONS_esi_users_groups.csv                       |
      | ssdr/citi        | UPG_EODSBLPOSITIONS.csv                        | REG_EODSBLPOSITIONS.csv                        | EXCEPTIONS_EODSBLPOSITIONS.csv                        |
      | edm/price        | UPG_esisg_dmp_hsbc_broker_price.csv            | REG_esisg_dmp_hsbc_broker_price.csv            | EXCEPTIONS_esisg_dmp_hsbc_broker_price.csv            |
      | edm/price        | UPG_esisg_dmp_price.csv                        | REG_esisg_dmp_price.csv                        | EXCEPTIONS_esisg_dmp_price.csv                        |
      | edm/price        | UPG_esisg_dmp_price.csv                        | REG_esisg_dmp_price.csv                        | EXCEPTIONS_esisg_dmp_price.csv                        |
      | edm/price        | UPG_esisg_dmp_scb_broker_price.csv             | REG_esisg_dmp_scb_broker_price.csv             | EXCEPTIONS_esisg_dmp_scb_broker_price.csv             |
      | ssdr/korea       | UPG_EIMKEISLFUNDLE.csv                         | REG_EIMKEISLFUNDLE.csv                         | EXCEPTIONS_EIMKEISLFUNDLE.csv                         |
      | ssdr/korea       | UPG_EIMKEISLPOSITN.csv                         | REG_EIMKEISLPOSITN.csv                         | EXCEPTIONS_EIMKEISLPOSITN.csv                         |
      | ssdr/korea       | UPG_EIMKEISLINSTMT.csv                         | REG_EIMKEISLINSTMT.csv                         | EXCEPTIONS_EIMKEISLINSTMT.csv                         |
      | ssdr/korea       | UPG_EIMKEISLTRANSN.csv                         | REG_EIMKEISLTRANSN.csv                         | EXCEPTIONS_EIMKEISLTRANSN.csv                         |
      | ssdr/esga        | UPG_ESGAEISLFUNDLE.csv                         | REG_ESGAEISLFUNDLE.csv                         | EXCEPTIONS_ESGAEISLFUNDLE.csv                         |
      | ssdr/esga        | UPG_ESGAEISLPOSITN.csv                         | REG_ESGAEISLPOSITN.csv                         | EXCEPTIONS_ESGAEISLPOSITN.csv                         |
      | ssdr/esga        | UPG_ESGAEISLINSTMT.csv                         | REG_ESGAEISLINSTMT.csv                         | EXCEPTIONS_ESGAEISLINSTMT.csv                         |
      | ssdr/esga        | UPG_ESGAEISLTRANSN.csv                         | REG_ESGAEISLTRANSN.csv                         | EXCEPTIONS_ESGAEISLTRANSN.csv                         |
      | ssdr/japan       | UPG_ESJPEISLFUNDLE.csv                         | REG_ESJPEISLFUNDLE.csv                         | EXCEPTIONS_ESJPEISLFUNDLE.csv                         |
      | ssdr/japan       | UPG_ESJPEISLPOSITN.csv                         | REG_ESJPEISLPOSITN.csv                         | EXCEPTIONS_ESJPEISLPOSITN.csv                         |
      | ssdr/japan       | UPG_ESJPEISLINSTMT.csv                         | REG_ESJPEISLINSTMT.csv                         | EXCEPTIONS_ESJPEISLINSTMT.csv                         |
      | ssdr/japan       | UPG_ESJPEISLTRANSN.csv                         | REG_ESJPEISLTRANSN.csv                         | EXCEPTIONS_ESJPEISLTRANSN.csv                         |
      | hsbc             | UPG_EASTSPRINGINVESTMENTSFUNDPRICEVARIANCE.csv | REG_EASTSPRINGINVESTMENTSFUNDPRICEVARIANCE.csv | EXCEPTIONS_EASTSPRINGINVESTMENTSFUNDPRICEVARIANCE.csv |
      | idc/price        | UPG_VietEvals.csv                              | REG_VietEvals.csv                              | EXCEPTIONS_VietEvals.csv                              |
      | ssdr/ppma        | UPG_PPMAEISLFUNDLE.csv                         | REG_PPMAEISLFUNDLE.csv                         | EXCEPTIONS_PPMAEISLFUNDLE.csv                         |
      | ssdr/ppma        | UPG_PPMAEISLPOSITN.csv                         | REG_PPMAEISLPOSITN.csv                         | EXCEPTIONS_PPMAEISLPOSITN.csv                         |
      | ssdr/ppma        | UPG_PPMAEISLINSTMT.csv                         | REG_PPMAEISLINSTMT.csv                         | EXCEPTIONS_PPMAEISLINSTMT.csv                         |
      | ssdr/ppma        | UPG_PPMAEISLTRANSN.csv                         | REG_PPMAEISLTRANSN.csv                         | EXCEPTIONS_PPMAEISLTRANSN.csv                         |
      | ssdr/mng         | UPG_MANGEISLSLPOSN.csv                         | REG_MANGEISLSLPOSN.csv                         | EXCEPTIONS_MANGEISLSLPOSN.csv                         |
      | ssdr/mng         | UPG_MANGEISLINSTMT.csv                         | REG_MANGEISLINSTMT.csv                         | EXCEPTIONS_MANGEISLINSTMT.csv                         |
      | qsg              | UPG_buylist.csv                                | REG_buylist.csv                                | EXCEPTIONS_buylist.csv                                |
      | reuters/price    | UPG_VNQReuters.csv                             | REG_VNQReuters.csv                             | EXCEPTIONS_VNQReuters.csv                             |
      | scb              | UPG_DailyNetAssetValueInternalFunds(ESI).csv   | REG_DailyNetAssetValueInternalFunds(ESI).csv   | EXCEPTIONS_DailyNetAssetValueInternalFunds(ESI).csv   |
      | scb              | UPG_PH-DailyNetAssetValue.csv                  | REG_PH-DailyNetAssetValue.csv                  | EXCEPTIONS_PH-DailyNetAssetValue.csv                  |
      | ssdr/tbam        | UPG_TBAMEISLFUNDLE.csv                         | REG_TBAMEISLFUNDLE.csv                         | EXCEPTIONS_TBAMEISLFUNDLE.csv                         |
      | ssdr/tbam        | UPG_TBAMEISLPOSITN.csv                         | REG_TBAMEISLPOSITN.csv                         | EXCEPTIONS_TBAMEISLPOSITN.csv                         |
      | ssdr/tbam        | UPG_TBAMSBLPOSITIONS.csv                       | REG_TBAMSBLPOSITIONS.csv                       | EXCEPTIONS_TBAMSBLPOSITIONS.csv                       |
      | ssdr/tbam        | UPG_TBAMEISLINSTMT.csv                         | REG_TBAMEISLINSTMT.csv                         | EXCEPTIONS_TBAMEISLINSTMT.csv                         |
      | ssdr/tbam        | UPG_TBAMEISLTRANSN.csv                         | REG_TBAMEISLTRANSN.csv                         | EXCEPTIONS_TBAMEISLTRANSN.csv                         |
      | taiwan           | UPG_esi_TW_newcash.csv                         | REG_esi_TW_newcash.csv                         | EXCEPTIONS_esi_TW_newcash.csv                         |
      | taiwan           | UPG_esi_TW_EODCash_CashStmt_CATHAY.csv         | REG_esi_TW_EODCash_CashStmt_CATHAY.csv         | EXCEPTIONS_esi_TW_EODCash_CashStmt_CATHAY.csv         |
      | ssdr/wfoe        | UPG_WFOEEISLPOSITN.csv                         | REG_WFOEEISLPOSITN.csv                         | EXCEPTIONS_WFOEEISLPOSITN.csv                         |
      | ssdr/wfoe        | UPG_WFOEEISLINSTMT.csv                         | REG_WFOEEISLINSTMT.csv                         | EXCEPTIONS_WFOEEISLINSTMT.csv                         |
      | ssdr/wfoe        | UPG_WFOEEISLTRANSN.csv                         | REG_WFOEEISLTRANSN.csv                         | EXCEPTIONS_WFOEEISLTRANSN.csv                         |
      | cmoney           | UPG_esi_brs_TW_CM_SMF.csv                      | REG_esi_brs_TW_CM_SMF.csv                      | EXCEPTIONS_esi_brs_TW_CM_SMF.csv                      |
      | hsbc             | UPG_ESI_BRS_POSITION_FX_B1__combined.csv       | REG_ESI_BRS_POSITION_FX_B1__combined.csv       | EXCEPTIONS_ESI_BRS_POSITION_FX_B1__combined.csv       |
      | hsbc             | UPG_ESI_BRS_NAV_PRICE_A0007DDM01_B1.csv        | REG_ESI_BRS_NAV_PRICE_A0007DDM01_B1.csv        | EXCEPTIONS_ESI_BRS_NAV_PRICE_A0007DDM01_B1.csv        |
      | hsbc             | UPG_ESI_BRS_POSITION_NONFX_B1_combined.csv     | REG_ESI_BRS_POSITION_NONFX_B1_combined.csv     | EXCEPTIONS_ESI_BRS_POSITION_NONFX_B1_combined.csv     |
      | hsbc             | UPG_ESI_BRS_POSITION_NONFX_A0007DDM01_B1.csv   | REG_ESI_BRS_POSITION_NONFX_A0007DDM01_B1.csv   | EXCEPTIONS_ESI_BRS_POSITION_NONFX_A0007DDM01_B1.csv   |
      | ssb              | UPG_ESI_BRS_POSITION_FX_B1__combined.csv       | REG_ESI_BRS_POSITION_FX_B1__combined.csv       | EXCEPTIONS_ESI_BRS_POSITION_FX_B1__combined.csv       |
      | ssb              | UPG_ESI_BRS_POSITION_NONFX_B1__combined.csv    | REG_ESI_BRS_POSITION_NONFX_B1__combined.csv    | EXCEPTIONS_ESI_BRS_POSITION_NONFX_B1__combined.csv    |
      | ssb              | UPG_ESI_BRS_POSITION_NONFX_TD00099_B2.csv      | REG_ESI_BRS_POSITION_NONFX_TD00099_B2.csv      | EXCEPTIONS_ESI_BRS_POSITION_NONFX_TD00099_B2.csv      |
      | citi/nav         | UPG_PRUESID_CITI_NAV_PRICE.csv                 | REG_PRUESID_CITI_NAV_PRICE.csv                 | EXCEPTIONS_PRUESID_CITI_NAV_PRICE.csv                 |
      | ibpa/price       | UPG_Adhoc_Q_east_price_C.csv                   | REG_Adhoc_Q_east_price_C.csv                   | EXCEPTIONS_Adhoc_Q_east_price_C.csv                   |
      | scb/nav          | UPG_SCB_ID_NAV_PRICE.csv                       | REG_SCB_ID_NAV_PRICE.csv                       | EXCEPTIONS_SCB_ID_NAV_PRICE.csv                       |
      | esid/intraday    | UPG_PLA_MGMTFEES.csv                           | REG_PLA_MGMTFEES.csv                           | EXCEPTIONS_PLA_MGMTFEES.csv                           |
      | esid/intraday    | UPG_PLA_FUNDALLOC.csv                          | REG_PLA_FUNDALLOC.csv                          | EXCEPTIONS_PLA_FUNDALLOC.csv                          |
      | esid/intraday    | UPG_subs_redm_report.csv                       | REG_subs_redm_report.csv                       | EXCEPTIONS_subs_redm_report.csv                       |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory