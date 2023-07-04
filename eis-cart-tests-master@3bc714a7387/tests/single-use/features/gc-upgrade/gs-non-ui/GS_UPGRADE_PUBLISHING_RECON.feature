@gs_upgrade_publishing_recon @ignore_hooks
Feature: To verify that publishing files on both regular and upgraded environments are same

  Scenario: Assign data

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "tests/test-data/gc-upgrade/gs-non-ui/outbound" to variable "testdata.path"
    And I assign "5400" to variable "workflow.max.polling.time"

  Scenario: Connect to GC Upgraded Environment

    Given I set the DMP workflow web service endpoint to named configuration "dmp.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.GC"

  Scenario Outline: publish  file <pub_file_name> with subscription name <subscription_name> on GC Upgraded Environment
    Given I assign "<pub_file_name>_${VAR_SYSDATE}_1.<file_extension>" to variable "PUBLISHING_FILE_NAME"
    And I assign "<dmp_pub_dir>" to variable "PUBLISHING_DIR"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | <pub_file_name>_*_1.csv |
    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | <pub_file_name>.<file_extension> |
      | SUBSCRIPTION_NAME    | <subscription_name>              |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}":
      | ${PUBLISHING_FILE_NAME} |
    Examples:
      | pub_file_name                                | dmp_pub_dir              | subscription_name                        | file_extension |
      | UPG_BRS_CTRN_FILE367_SCB_ID_NEWCASH          | /dmp/out/brs/intraday    | ESII_DMP_TO_BRS_CTRN_FILE367_SCB_SUB     | csv            |
      | UPG_BRS_CTRN_FILE367_PLAI_ID_NEWCASH         | /dmp/out/brs/intraday    | ESII_DMP_TO_BRS_CTRN_FILE367_PLAI_SUB    | csv            |
      | UPG_BRS_CASHTRAN_FILE314_ID_NEWCASH          | /dmp/out/brs/intraday    | ESII_DMP_TO_BRS_CASHTRAN_FILE314_SUB     | csv            |
      | UPG_EITW_SSB_TO_BRS                          | /dmp/out/brs             | EITW_SSB_TO_BRS_SUB                      | csv            |
      | UPG_EITW_HSBC_TO_BRS                         | /dmp/out/brs             | EITW_HSBC_TO_BRS_SUB                     | csv            |
      | UPG_SSB_TRADEFLOW_B2_TRD                     | /dmp/out/ssb             | EITW_DMP_TO_SSB_TRADEFLOW_B2             | csv            |
      | UPG_SSB_TRADEFLOW_B1_TRD                     | /dmp/out/ssb             | EITW_DMP_TO_SSB_TRADEFLOW_B1             | csv            |
      | UPG_SSB_OVERSEAS_PORT                        | /dmp/out/ssb             | EITW_DMP_TO_SSB_OVERSEAS_PORT_SUB        | csv            |
      | UPG_SSB_DOMESTIC_PORT                        | /dmp/out/ssb             | EITW_DMP_TO_SSB_DOMESTIC_PORT_SUB        | csv            |
      | UPG_HSBC_TRADEFLOW_TD_B2                     | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_TD_B2_SUB     | csv            |
      | UPG_HSBC_TRADEFLOW_TD_B1                     | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_TD_B1_SUB     | csv            |
      | UPG_HSBC_TRADEFLOW_FX_FWD_B2                 | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_FX_FWD_B2_SUB | csv            |
      | UPG_HSBC_TRADEFLOW_CP_REP_B2                 | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_CP_REP_B2_SUB | csv            |
      | UPG_HSBC_TRADEFLOW_B1                        | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_B1            | csv            |
      | UPG_HSBC_OVERSEAS_PORT                       | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_OVERSEAS_PORT_SUB       | csv            |
      | UPG_HSBC_DOMESTIC_PORT                       | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_DOMESTIC_PORT_SUB       | csv            |
      | UPG_BRS_TRADE_ACK_NACK                       | /dmp/out/brs/intraday    | EITW_DMP_TO_BRS_TRADE_ACK_NACK_SUB       | xml            |
      | UPG_BRS_HSBC_EOD_NAV_B3                      | /dmp/out/brs/eod         | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B3_SUB      | csv            |
      | UPG_BRS_HSBC_EOD_NAV_B2                      | /dmp/out/brs/eod         | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B2_SUB      | csv            |
      | UPG_BRS_HSBC_EOD_NAV_B1                      | /dmp/out/brs/eod         | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B1_SUB      | csv            |
      | UPG_BRS_CASHTRAN_FILE367                     | /dmp/out/brs/intraday    | EITW_DMP_TO_BRS_CASHTRAN_FILE367_SUB     | csv            |
      | UPG_BNP_SITE_FUND                            | /dmp/out/bnp             | EITW_DMP_TO_BNP_SITE_FUND_SUB            | csv            |
      | UPG_BNP_PRICE_NAV                            | /dmp/out/bnp             | EITW_DMP_TO_BNP_PRICE_NAV_SUB            | csv            |
      | UPG_EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM | /dmp/out/brs/intraday    | EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM | csv            |
      | UPG_EIS_SCB_TO_DMP_BROKER_PRICE              | /dmp/out/eis/edm         | EIS_SCB_TO_DMP_BROKER_PRICE_SUB          | xml            |
      | UPG_EIS_PST_TO_BRS_TARGET_PRICES             | /dmp/out/brs/qsg         | EIS_PST_TO_BRS_TARGET_PRICES             | csv            |
      | UPG_EIS_HSBC_TO_DMP_BROKER_PRICE             | /dmp/out/eis/edm         | EIS_HSBC_TO_DMP_BROKER_PRICE_SUB         | xml            |
      | UPG_UV_TREASURY_TRADE_EMIR                   | /dmp/out/unavista        | EIS_DMP_TO_UV_TREASURY_TRADE_EMIR_SUB    | csv            |
      | UPG_TRANSACTION_DATAREPORT                   | /dmp/out/eis/datareports | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB    | csv            |
      | UPG_STARCOM_TW_POSITION                      | /dmp/out/eis/starcom     | EIS_DMP_TO_STARCOM_TW_POSITION_SUB       | csv            |
      | UPG_RDM_SSDR_TRADE                           | /dmp/out/eis/ssdr        | EIS_DMP_TO_RDM_SSDR_TRADE_SUB            | csv            |
      | UPG_RDM_SSDR_POSITION                        | /dmp/out/eis/ssdr        | EIS_DMP_TO_RDM_SSDR_POSITION_SUB         | csv            |
      | UPG_RDM_SECURITY_CREATION                    | /dmp/out/eis/refdata     | EIS_DMP_TO_RDM_SECURITY_CREATION_SUB     | csv            |
      | UPG_RDM_INTERNAL_RATINGS                     | /dmp/out/eis/refdata     | EIS_DMP_TO_RDM_INTERNAL_RATINGS_SUB      | csv            |
      | UPG_PPM_SECURITY                             | /dmp/out/fundapps        | EIS_DMP_TO_PPM_SECURITY_SUB              | csv            |
      | UPG_PPM_POSITION                             | /dmp/out/fundapps        | EIS_DMP_TO_PPM_POSITION_SUB              | csv            |
      | UPG_PPM_FUND                                 | /dmp/out/fundapps        | EIS_DMP_TO_PPM_FUND_SUB                  | csv            |
      | UPG_FUNDAPPS_TRANSACTION                     | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB      | csv            |
      | UPG_FUNDAPPS_POSITION                        | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_POSITION_SUB         | xml            |
      | UPG_FUNDAPPS_ISSUER                          | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_ISSUER_SUB           | csv            |
      | UPG_FUNDAPPS_FUND                            | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_FUND_SUB             | csv            |
      | UPG_EIS_STARCOM_ORDERS                       | /dmp/out/eis/starcom     | EIS_DMP_TO_EIS_STARCOM_ORDERS_SUB        | csv            |
      | UPG_EIS_STARCOM_EOD_ORDERS                   | /dmp/out/eis/starcom     | EIS_DMP_TO_EIS_STARCOM_EOD_ORDERS_SUB    | csv            |
      | UPG_EIS_SBLPOSN_DATAREPORT                   | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_SBLPOSN_DATAREPORT_SUB    | csv            |
      | UPG_EIS_POSNSUMMARY_REPORTS                  | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_POSNSUMMARY_REPORTS_SUB   | csv            |
      | UPG_EIS_POSITION_DATAREPORTS                 | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_POSITION_DATAREPORTS_SUB  | csv            |
      | UPG_EIS_DATAREPORTS_FUND                     | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_DATAREPORTS_FUND_SUB      | csv            |
      | UPG_BRS_VN_INT_PRICE_VIEW                    | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_VN_INT_PRICE_VIEW_SUB     | csv            |
      | UPG_BRS_SOD_POS_NONFX_LATAM                  | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POS_NONFX_LATAM_SUB   | csv            |
      | UPG_BRS_SOD_POSITION_NONFX                   | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POSITION_NONFX_SUB    | csv            |
      | UPG_BRS_SOD_POSITION_FX                      | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POSITION_FX_SUB       | csv            |
      | UPG_BRS_SOD_POSITION_FX_LATAM                | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POSITION_FX_LATAM_SUB | csv            |
      | UPG_BRS_SOD_NPP_POSN_NONFX                   | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_NPP_POSN_NONFX_SUB    | csv            |
      | UPG_BRS_SOD_NPP_POSN_FX                      | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_NPP_POSN_FX_SUB       | csv            |
      | UPG_BRS_SG_INT_PRICE_VIEW                    | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_SG_INT_PRICE_VIEW_SUB     | csv            |
      | UPG_BRS_SCB_BROKER_PRICE_VIEW                | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_SCB_BROKER_PRICE_VIEW_SUB | csv            |
      #| UPG_BRS_PRICE_VIEW                           | /dmp/out/brs/eod         | EIS_DMP_TO_BRS_PRICE_VIEW_SUB            | csv            |
      | UPG_BRS_ISSUER_RATING_CUSTOM                 | /dmp/out/brs/8b_ratings  | EIS_DMP_TO_BRS_ISSUER_RATING_SUB         | csv            |
      | UPG_BRS_HSBC_BROKER_PRC_VIEW                 | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_HSBC_BROKER_PRC_VIEW_SUB  | csv            |
      | UPG_BRS_CDF_SEC                              | /dmp/out/brs/1a_security | EIS_DMP_TO_BRS_CDF_SUB                   | csv            |
      | UPG_BRS_CASHTRAN_FILE367_NEWCASH             | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE367_SUB      | csv            |
      | UPG_BRS_CASHTRAN_FILE367_CANC                | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE367_CANC_SUB | csv            |
      | UPG_BRS_CASHTRAN_FILE365_FX                  | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE365_FX_SUB   | csv            |
      | UPG_BRS_CASHTRAN_FILE365_FX_C                | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE365_FX_C_SUB | csv            |
      | UPG_BRS_CASHTRAN_FILE365_CC                  | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE365_CC_SUB   | csv            |
      | UPG_BRS_CASHTRAN_FILE314_MISCCASH            | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE314_SUB      | csv            |
      | UPG_BRS_CASHSTMT_FILE313_EODCASH             | /dmp/out/brs             | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB      | csv            |
      | UPG_BRS_P_BBGRATINGS                         | /dmp/out/brs/1a_security | EIS_DMP_TO_BRS_BBGRATINGS_SUB            | csv            |
      | UPG_BNP_REF_SECURITY_CUSTOM_CLASSIFICATION   | /dmp/out/bnp/eod         | EIS_DMP_TO_BNP_REF_SECURITY_SUB          | csv            |
      | UPG_BNP_DRIFTED_BM_WEIGHTS                   | /dmp/out/bnp/eod         | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB    | csv            |
      | UPG_BNP_CASHALLOCATION_ITAP_FIL11            | /dmp/out/bnp/intraday    | EIS_DMP_TO_BNP_CASHALLOCATION_ITAP_SUB   | xml            |
      | UPG_BNP_CASHALLOCATION_FILE96                | /dmp/out/bnp/intraday    | EIS_DMP_TO_BNP_CASHALLOCATION_FILE96_SUB | xml            |
      | UPG_EIS_BRS_TO_DMP_SEC_ANALYTICS_GLOBAL_PNL  | /dmp/out/brs/eod         | EIS_BRS_TO_DMP_SEC_ANALYTICS_GLOBAL_SUB  | csv            |
      | UPG_EIS_BNP_TO_BRS_PERFORMANCE_RETURNS       | /dmp/out/brs/irp         | EIS_BNP_TO_BRS_PERFORMANCE_RETURNS_SUB   | csv            |
      | UPG_EIM_DMP_TO_BRS_MFUND_NAV_ABOR            | /dmp/out/brs/eod         | EIM_DMP_TO_BRS_MFUND_NAV_ABOR_SUB        | csv            |
      | UPG_EIM_DMP_TO_BRS_DB_NAV_ABOR               | /dmp/out/brs/eod         | EIM_DMP_TO_BRS_DB_NAV_ABOR_SUB           | csv            |
      | UPG_EIM_DMP_BRS_SCB_NAV                      | /dmp/out/brs/eod         | EIM_DMP_BRS_SCB_NAV_SUB                  | csv            |
      | UPG_EICN_WFOE_TO_RCR_WFOEEISLINSTMT          | /dmp/out/eis/fundapps    | EICN_WFOE_TO_RCR_SUB                     | csv            |


#
  Scenario: Connect to GC Regular Dev Environment

    Given I set the DMP workflow web service endpoint to named configuration "dmp.ws.WORKFLOW1"
    And I set the database connection to configuration "dmp.db.GC1"

  Scenario Outline: publish  file <pub_file_name> with subscription name <subscription_name> on GC regular Environment

    Given I assign "<pub_file_name>_${VAR_SYSDATE}_1.<file_extension>" to variable "PUBLISHING_FILE_NAME"
    And I assign "<dmp_pub_dir>" to variable "PUBLISHING_DIR"
    And I remove below files with pattern in the host "dmp.ssh.inbound1" from folder "${PUBLISHING_DIR}" if exists:
      | <pub_file_name>_*_1.csv |
    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | <pub_file_name>.<file_extension> |
      | SUBSCRIPTION_NAME    | <subscription_name>              |


    Then I expect below files to be present in the host "dmp.ssh.inbound1" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound1" into local folder "${testdata.path}":
      | ${PUBLISHING_FILE_NAME} |
    Examples:
      | pub_file_name                                | dmp_pub_dir              | subscription_name                        | file_extension |
      | REG_BRS_CTRN_FILE367_SCB_ID_NEWCASH          | /dmp/out/brs/intraday    | ESII_DMP_TO_BRS_CTRN_FILE367_SCB_SUB     | csv            |
      | REG_BRS_CTRN_FILE367_PLAI_ID_NEWCASH         | /dmp/out/brs/intraday    | ESII_DMP_TO_BRS_CTRN_FILE367_PLAI_SUB    | csv            |
      | REG_BRS_CASHTRAN_FILE314_ID_NEWCASH          | /dmp/out/brs/intraday    | ESII_DMP_TO_BRS_CASHTRAN_FILE314_SUB     | csv            |
      | REG_EITW_SSB_TO_BRS                          | /dmp/out/brs             | EITW_SSB_TO_BRS_SUB                      | csv            |
      | REG_EITW_HSBC_TO_BRS                         | /dmp/out/brs             | EITW_HSBC_TO_BRS_SUB                     | csv            |
      | REG_SSB_TRADEFLOW_B2_TRD                     | /dmp/out/ssb             | EITW_DMP_TO_SSB_TRADEFLOW_B2             | csv            |
      | REG_SSB_TRADEFLOW_B1_TRD                     | /dmp/out/ssb             | EITW_DMP_TO_SSB_TRADEFLOW_B1             | csv            |
      | REG_SSB_OVERSEAS_PORT                        | /dmp/out/ssb             | EITW_DMP_TO_SSB_OVERSEAS_PORT_SUB        | csv            |
      | REG_SSB_DOMESTIC_PORT                        | /dmp/out/ssb             | EITW_DMP_TO_SSB_DOMESTIC_PORT_SUB        | csv            |
      | REG_HSBC_TRADEFLOW_TD_B2                     | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_TD_B2_SUB     | csv            |
      | REG_HSBC_TRADEFLOW_TD_B1                     | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_TD_B1_SUB     | csv            |
      | REG_HSBC_TRADEFLOW_FX_FWD_B2                 | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_FX_FWD_B2_SUB | csv            |
      | REG_HSBC_TRADEFLOW_CP_REP_B2                 | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_CP_REP_B2_SUB | csv            |
      | REG_HSBC_TRADEFLOW_B1                        | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_TRADEFLOW_B1            | csv            |
      | REG_HSBC_OVERSEAS_PORT                       | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_OVERSEAS_PORT_SUB       | csv            |
      | REG_HSBC_DOMESTIC_PORT                       | /dmp/out/hsbc            | EITW_DMP_TO_HSBC_DOMESTIC_PORT_SUB       | csv            |
      | REG_BRS_TRADE_ACK_NACK                       | /dmp/out/brs/intraday    | EITW_DMP_TO_BRS_TRADE_ACK_NACK_SUB       | xml            |
      | REG_BRS_HSBC_EOD_NAV_B3                      | /dmp/out/brs/eod         | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B3_SUB      | csv            |
      | REG_BRS_HSBC_EOD_NAV_B2                      | /dmp/out/brs/eod         | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B2_SUB      | csv            |
      | REG_BRS_HSBC_EOD_NAV_B1                      | /dmp/out/brs/eod         | EITW_DMP_TO_BRS_HSBC_EOD_NAV_B1_SUB      | csv            |
      | REG_BRS_CASHTRAN_FILE367                     | /dmp/out/brs/intraday    | EITW_DMP_TO_BRS_CASHTRAN_FILE367_SUB     | csv            |
      | REG_BNP_SITE_FUND                            | /dmp/out/bnp             | EITW_DMP_TO_BNP_SITE_FUND_SUB            | csv            |
      | REG_BNP_PRICE_NAV                            | /dmp/out/bnp             | EITW_DMP_TO_BNP_PRICE_NAV_SUB            | csv            |
      | REG_EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM | /dmp/out/brs/intraday    | EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM | csv            |
      | REG_EIS_SCB_TO_DMP_BROKER_PRICE              | /dmp/out/eis/edm         | EIS_SCB_TO_DMP_BROKER_PRICE_SUB          | xml            |
      | REG_EIS_PST_TO_BRS_TARGET_PRICES             | /dmp/out/brs/qsg         | EIS_PST_TO_BRS_TARGET_PRICES             | csv            |
      | REG_EIS_HSBC_TO_DMP_BROKER_PRICE             | /dmp/out/eis/edm         | EIS_HSBC_TO_DMP_BROKER_PRICE_SUB         | xml            |
      | REG_UV_TREASURY_TRADE_EMIR                   | /dmp/out/unavista        | EIS_DMP_TO_UV_TREASURY_TRADE_EMIR_SUB    | csv            |
      | REG_TRANSACTION_DATAREPORT                   | /dmp/out/eis/datareports | EIS_DMP_TO_TRANSACTION_DATAREPORT_SUB    | csv            |
      | REG_STARCOM_TW_POSITION                      | /dmp/out/eis/starcom     | EIS_DMP_TO_STARCOM_TW_POSITION_SUB       | csv            |
      | REG_RDM_SSDR_TRADE                           | /dmp/out/eis/ssdr        | EIS_DMP_TO_RDM_SSDR_TRADE_SUB            | csv            |
      | REG_RDM_SSDR_POSITION                        | /dmp/out/eis/ssdr        | EIS_DMP_TO_RDM_SSDR_POSITION_SUB         | csv            |
      | REG_RDM_SECURITY_CREATION                    | /dmp/out/eis/refdata     | EIS_DMP_TO_RDM_SECURITY_CREATION_SUB     | csv            |
      | REG_RDM_INTERNAL_RATINGS                     | /dmp/out/eis/refdata     | EIS_DMP_TO_RDM_INTERNAL_RATINGS_SUB      | csv            |
      | REG_PPM_SECURITY                             | /dmp/out/fundapps        | EIS_DMP_TO_PPM_SECURITY_SUB              | csv            |
      | REG_PPM_POSITION                             | /dmp/out/fundapps        | EIS_DMP_TO_PPM_POSITION_SUB              | csv            |
      | REG_PPM_FUND                                 | /dmp/out/fundapps        | EIS_DMP_TO_PPM_FUND_SUB                  | csv            |
      | REG_FUNDAPPS_TRANSACTION                     | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_TRANSACTION_SUB      | csv            |
      | REG_FUNDAPPS_POSITION                        | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_POSITION_SUB         | xml            |
      | REG_FUNDAPPS_ISSUER                          | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_ISSUER_SUB           | csv            |
      | REG_FUNDAPPS_FUND                            | /dmp/out/fundapps        | EIS_DMP_TO_FUNDAPPS_FUND_SUB             | csv            |
      | REG_EIS_STARCOM_ORDERS                       | /dmp/out/eis/starcom     | EIS_DMP_TO_EIS_STARCOM_ORDERS_SUB        | csv            |
      | REG_EIS_STARCOM_EOD_ORDERS                   | /dmp/out/eis/starcom     | EIS_DMP_TO_EIS_STARCOM_EOD_ORDERS_SUB    | csv            |
      | REG_EIS_SBLPOSN_DATAREPORT                   | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_SBLPOSN_DATAREPORT_SUB    | csv            |
      | REG_EIS_POSNSUMMARY_REPORTS                  | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_POSNSUMMARY_REPORTS_SUB   | csv            |
      | REG_EIS_POSITION_DATAREPORTS                 | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_POSITION_DATAREPORTS_SUB  | csv            |
      | REG_EIS_DATAREPORTS_FUND                     | /dmp/out/eis/datareports | EIS_DMP_TO_EIS_DATAREPORTS_FUND_SUB      | csv            |
      | REG_BRS_VN_INT_PRICE_VIEW                    | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_VN_INT_PRICE_VIEW_SUB     | csv            |
      | REG_BRS_SOD_POS_NONFX_LATAM                  | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POS_NONFX_LATAM_SUB   | csv            |
      | REG_BRS_SOD_POSITION_NONFX                   | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POSITION_NONFX_SUB    | csv            |
      | REG_BRS_SOD_POSITION_FX                      | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POSITION_FX_SUB       | csv            |
      | REG_BRS_SOD_POSITION_FX_LATAM                | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_POSITION_FX_LATAM_SUB | csv            |
      | REG_BRS_SOD_NPP_POSN_NONFX                   | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_NPP_POSN_NONFX_SUB    | csv            |
      | REG_BRS_SOD_NPP_POSN_FX                      | /dmp/out/brs/sod         | EIS_DMP_TO_BRS_SOD_NPP_POSN_FX_SUB       | csv            |
      | REG_BRS_SG_INT_PRICE_VIEW                    | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_SG_INT_PRICE_VIEW_SUB     | csv            |
      | REG_BRS_SCB_BROKER_PRICE_VIEW                | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_SCB_BROKER_PRICE_VIEW_SUB | csv            |
     # | REG_BRS_PRICE_VIEW                           | /dmp/out/brs/eod         | EIS_DMP_TO_BRS_PRICE_VIEW_SUB            | csv            |
      | REG_BRS_ISSUER_RATING_CUSTOM                 | /dmp/out/brs/8b_ratings  | EIS_DMP_TO_BRS_ISSUER_RATING_SUB         | csv            |
      | REG_BRS_HSBC_BROKER_PRC_VIEW                 | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_HSBC_BROKER_PRC_VIEW_SUB  | csv            |
      | REG_BRS_CDF_SEC                              | /dmp/out/brs/1a_security | EIS_DMP_TO_BRS_CDF_SUB                   | csv            |
      | REG_BRS_CASHTRAN_FILE367_NEWCASH             | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE367_SUB      | csv            |
      | REG_BRS_CASHTRAN_FILE367_CANC                | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE367_CANC_SUB | csv            |
      | REG_BRS_CASHTRAN_FILE365_FX                  | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE365_FX_SUB   | csv            |
      | REG_BRS_CASHTRAN_FILE365_FX_C                | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE365_FX_C_SUB | csv            |
      | REG_BRS_CASHTRAN_FILE365_CC                  | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE365_CC_SUB   | csv            |
      | REG_BRS_CASHTRAN_FILE314_MISCCASH            | /dmp/out/brs/intraday    | EIS_DMP_TO_BRS_CASHTRAN_FILE314_SUB      | csv            |
      | REG_BRS_CASHSTMT_FILE313_EODCASH             | /dmp/out/brs             | EIS_DMP_TO_BRS_CASHSTMT_FILE313_SUB      | csv            |
      | REG_BRS_P_BBGRATINGS                         | /dmp/out/brs/1a_security | EIS_DMP_TO_BRS_BBGRATINGS_SUB            | csv            |
      | REG_BNP_REF_SECURITY_CUSTOM_CLASSIFICATION   | /dmp/out/bnp/eod         | EIS_DMP_TO_BNP_REF_SECURITY_SUB          | csv            |
      | REG_BNP_DRIFTED_BM_WEIGHTS                   | /dmp/out/bnp/eod         | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB    | csv            |
      | REG_BNP_CASHALLOCATION_ITAP_FIL11            | /dmp/out/bnp/intraday    | EIS_DMP_TO_BNP_CASHALLOCATION_ITAP_SUB   | xml            |
      | REG_BNP_CASHALLOCATION_FILE96                | /dmp/out/bnp/intraday    | EIS_DMP_TO_BNP_CASHALLOCATION_FILE96_SUB | xml            |
      | REG_EIS_BRS_TO_DMP_SEC_ANALYTICS_GLOBAL_PNL  | /dmp/out/brs/eod         | EIS_BRS_TO_DMP_SEC_ANALYTICS_GLOBAL_SUB  | csv            |
      | REG_EIS_BNP_TO_BRS_PERFORMANCE_RETURNS       | /dmp/out/brs/irp         | EIS_BNP_TO_BRS_PERFORMANCE_RETURNS_SUB   | csv            |
      | REG_EIM_DMP_TO_BRS_MFUND_NAV_ABOR            | /dmp/out/brs/eod         | EIM_DMP_TO_BRS_MFUND_NAV_ABOR_SUB        | csv            |
      | REG_EIM_DMP_TO_BRS_DB_NAV_ABOR               | /dmp/out/brs/eod         | EIM_DMP_TO_BRS_DB_NAV_ABOR_SUB           | csv            |
      | REG_EIM_DMP_BRS_SCB_NAV                      | /dmp/out/brs/eod         | EIM_DMP_BRS_SCB_NAV_SUB                  | csv            |
      | REG_EICN_WFOE_TO_RCR_WFOEEISLINSTMT          | /dmp/out/eis/fundapps    | EICN_WFOE_TO_RCR_SUB                     | csv            |

  Scenario Outline:Reconciliation between generated files in Gs upgraded<upgrade_file> and not upgraded environments :<reg_file>

    And I assign "${testdata.path}/<upgrade_file>_${VAR_SYSDATE}_1.csv" to variable "GC_UPGRADE_FILE"
    And I assign "${testdata.path}/<reg_file>_${VAR_SYSDATE}_1.csv" to variable "GC_DEV_FILE"
    And I assign "${testdata.path}/<exception_file>_${VAR_SYSDATE}_1.csv " to variable "EXCEP_FILE"

    Then I expect reconciliation between generated CSV file "${GC_UPGRADE_FILE}" and reference CSV file "${GC_DEV_FILE}" should be successful and exceptions to be written to "${EXCEP_FILE}" file
    Examples:
      | upgrade_file                                 | reg_file                                     | exception_file                                     |
      | UPG_BRS_CTRN_FILE367_SCB_ID_NEWCASH          | REG_BRS_CTRN_FILE367_SCB_ID_NEWCASH          | EXCEPTIONSBRS_CTRN_FILE367_SCB_ID_NEWCASH          |
      | UPG_BRS_CTRN_FILE367_SCB_CN                  | REG_BRS_CTRN_FILE367_SCB_CN                  | EXCEPTIONSBRS_CTRN_FILE367_SCB_CN                  |
      | UPG_BRS_CTRN_FILE367_PLAI_ID_NEWCASH         | REG_BRS_CTRN_FILE367_PLAI_ID_NEWCASH         | EXCEPTIONSBRS_CTRN_FILE367_PLAI_ID_NEWCASH         |
      | UPG_BRS_CTRN_FILE367_PLAI_CN                 | REG_BRS_CTRN_FILE367_PLAI_CN                 | EXCEPTIONSBRS_CTRN_FILE367_PLAI_CN                 |
      | UPG_BRS_CASHTRAN_FILE314_ID_NEWCASH          | REG_BRS_CASHTRAN_FILE314_ID_NEWCASH          | EXCEPTIONSBRS_CASHTRAN_FILE314_ID_NEWCASH          |
      | UPG_EITW_SSB_TO_BRS                          | REG_EITW_SSB_TO_BRS                          | EXCEPTIONSEITW_SSB_TO_BRS                          |
      | UPG_EITW_HSBC_TO_BRS                         | REG_EITW_HSBC_TO_BRS                         | EXCEPTIONSEITW_HSBC_TO_BRS                         |
      | UPG_TW_ORDER_PLACE                           | REG_TW_ORDER_PLACE                           | EXCEPTIONSTW_ORDER_PLACE                           |
      | UPG_TW_MAINCUST_SI_AOI                       | REG_TW_MAINCUST_SI_AOI                       | EXCEPTIONSTW_MAINCUST_SI_AOI                       |
      | UPG_SSB_TRADEFLOW_B2_TRD                     | REG_SSB_TRADEFLOW_B2_TRD                     | EXCEPTIONSSSB_TRADEFLOW_B2_TRD                     |
      | UPG_SSB_TRADEFLOW_B1_TRD                     | REG_SSB_TRADEFLOW_B1_TRD                     | EXCEPTIONSSSB_TRADEFLOW_B1_TRD                     |
      | UPG_SSB_OVERSEAS_PORT                        | REG_SSB_OVERSEAS_PORT                        | EXCEPTIONSSSB_OVERSEAS_PORT                        |
      | UPG_SSB_DOMESTIC_PORT                        | REG_SSB_DOMESTIC_PORT                        | EXCEPTIONSSSB_DOMESTIC_PORT                        |
      | UPG_HSBC_TRADEFLOW_TD_B2                     | REG_HSBC_TRADEFLOW_TD_B2                     | EXCEPTIONSHSBC_TRADEFLOW_TD_B2                     |
      | UPG_HSBC_TRADEFLOW_TD_B1                     | REG_HSBC_TRADEFLOW_TD_B1                     | EXCEPTIONSHSBC_TRADEFLOW_TD_B1                     |
      | UPG_HSBC_TRADEFLOW_FX_FWD_B2                 | REG_HSBC_TRADEFLOW_FX_FWD_B2                 | EXCEPTIONSHSBC_TRADEFLOW_FX_FWD_B2                 |
      | UPG_HSBC_TRADEFLOW_FX_FWD_B1                 | REG_HSBC_TRADEFLOW_FX_FWD_B1                 | EXCEPTIONSHSBC_TRADEFLOW_FX_FWD_B1                 |
      | UPG_HSBC_TRADEFLOW_CP_REP_B2                 | REG_HSBC_TRADEFLOW_CP_REP_B2                 | EXCEPTIONSHSBC_TRADEFLOW_CP_REP_B2                 |
      | UPG_HSBC_TRADEFLOW_CP_REP_B1                 | REG_HSBC_TRADEFLOW_CP_REP_B1                 | EXCEPTIONSHSBC_TRADEFLOW_CP_REP_B1                 |
      | UPG_HSBC_TRADEFLOW_B2                        | REG_HSBC_TRADEFLOW_B2                        | EXCEPTIONSHSBC_TRADEFLOW_B2                        |
      | UPG_HSBC_TRADEFLOW_B1                        | REG_HSBC_TRADEFLOW_B1                        | EXCEPTIONSHSBC_TRADEFLOW_B1                        |
      | UPG_HSBC_OVERSEAS_PORT                       | REG_HSBC_OVERSEAS_PORT                       | EXCEPTIONSHSBC_OVERSEAS_PORT                       |
      | UPG_HSBC_DOMESTIC_PORT                       | REG_HSBC_DOMESTIC_PORT                       | EXCEPTIONSHSBC_DOMESTIC_PORT                       |
      | UPG_BRS_TRADE_ACK_NACK                       | REG_BRS_TRADE_ACK_NACK                       | EXCEPTIONSBRS_TRADE_ACK_NACK                       |
      | UPG_BRS_HSBC_EOD_NAV_B3                      | REG_BRS_HSBC_EOD_NAV_B3                      | EXCEPTIONSBRS_HSBC_EOD_NAV_B3                      |
      | UPG_BRS_HSBC_EOD_NAV_B2                      | REG_BRS_HSBC_EOD_NAV_B2                      | EXCEPTIONSBRS_HSBC_EOD_NAV_B2                      |
      | UPG_BRS_HSBC_EOD_NAV_B1                      | REG_BRS_HSBC_EOD_NAV_B1                      | EXCEPTIONSBRS_HSBC_EOD_NAV_B1                      |
      | UPG_BRS_CASHTRAN_FILE367                     | REG_BRS_CASHTRAN_FILE367                     | EXCEPTIONSBRS_CASHTRAN_FILE367                     |
      | UPG_BNP_SITE_FUND                            | REG_BNP_SITE_FUND                            | EXCEPTIONSBNP_SITE_FUND                            |
      | UPG_BNP_PRICE_NAV                            | REG_BNP_PRICE_NAV                            | EXCEPTIONSBNP_PRICE_NAV                            |
      | UPG_EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM    | REG_EITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM    | EXCEPTIONSEITW_DMP_BRS_CASHTRAN_FILE367_FX_NEWM    |
      | UPG_EITW_DMP_BRS_CASHTRAN_FILE367_FX_CANC    | REG_EITW_DMP_BRS_CASHTRAN_FILE367_FX_CANC    | EXCEPTIONSEITW_DMP_BRS_CASHTRAN_FILE367_FX_CANC    |
      | UPG_EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM | REG_EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM | EXCEPTIONSEITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_NEWM |
      | UPG_EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_CANC | REG_EITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_CANC | EXCEPTIONSEITW_DMP_BRS_CASHTRAN_F367_FX_SYNTH_CANC |
      | UPG_EIS_SCB_TO_DMP_BROKER_PRICE              | REG_EIS_SCB_TO_DMP_BROKER_PRICE              | EXCEPTIONSEIS_SCB_TO_DMP_BROKER_PRICE              |
      | UPG_EIS_PST_TO_BRS_TARGET_PRICES             | REG_EIS_PST_TO_BRS_TARGET_PRICES             | EXCEPTIONSEIS_PST_TO_BRS_TARGET_PRICES             |
      | UPG_EIS_HSBC_TO_DMP_BROKER_PRICE             | REG_EIS_HSBC_TO_DMP_BROKER_PRICE             | EXCEPTIONSEIS_HSBC_TO_DMP_BROKER_PRICE             |
      | UPG_UV_TREASURY_TRADE_EMIR                   | REG_UV_TREASURY_TRADE_EMIR                   | EXCEPTIONSUV_TREASURY_TRADE_EMIR                   |
      | UPG_TRANSACTION_DATAREPORT                   | REG_TRANSACTION_DATAREPORT                   | EXCEPTIONSTRANSACTION_DATAREPORT                   |
      | UPG_STARCOM_TW_POSITION                      | REG_STARCOM_TW_POSITION                      | EXCEPTIONSSTARCOM_TW_POSITION                      |
      | UPG_RDM_SSDR_TRADE                           | REG_RDM_SSDR_TRADE                           | EXCEPTIONSRDM_SSDR_TRADE                           |
      | UPG_RDM_SSDR_POSITION                        | REG_RDM_SSDR_POSITION                        | EXCEPTIONSRDM_SSDR_POSITION                        |
      | UPG_RDM_SECURITY_CREATION                    | REG_RDM_SECURITY_CREATION                    | EXCEPTIONSRDM_SECURITY_CREATION                    |
      | UPG_RDM_INTERNAL_RATINGS                     | REG_RDM_INTERNAL_RATINGS                     | EXCEPTIONSRDM_INTERNAL_RATINGS                     |
      | UPG_PPM_SECURITY                             | REG_PPM_SECURITY                             | EXCEPTIONSPPM_SECURITY                             |
      | UPG_PPM_POSITION                             | REG_PPM_POSITION                             | EXCEPTIONSPPM_POSITION                             |
      | UPG_PPM_FUND                                 | REG_PPM_FUND                                 | EXCEPTIONSPPM_FUND                                 |
      | UPG_FUNDAPPS_TRANSACTION                     | REG_FUNDAPPS_TRANSACTION                     | EXCEPTIONSFUNDAPPS_TRANSACTION                     |
      | UPG_FUNDAPPS_POSITION                        | REG_FUNDAPPS_POSITION                        | EXCEPTIONSFUNDAPPS_POSITION                        |
      | UPG_FUNDAPPS_ISSUER                          | REG_FUNDAPPS_ISSUER                          | EXCEPTIONSFUNDAPPS_ISSUER                          |
      | UPG_FUNDAPPS_FUND                            | REG_FUNDAPPS_FUND                            | EXCEPTIONSFUNDAPPS_FUND                            |
      | UPG_EIS_STARCOM_ORDERS                       | REG_EIS_STARCOM_ORDERS                       | EXCEPTIONSEIS_STARCOM_ORDERS                       |
      | UPG_EIS_STARCOM_EOD_ORDERS                   | REG_EIS_STARCOM_EOD_ORDERS                   | EXCEPTIONSEIS_STARCOM_EOD_ORDERS                   |
      | UPG_EIS_SBLPOSN_DATAREPORT                   | REG_EIS_SBLPOSN_DATAREPORT                   | EXCEPTIONSEIS_SBLPOSN_DATAREPORT                   |
      | UPG_EIS_POSNSUMMARY_REPORTS                  | REG_EIS_POSNSUMMARY_REPORTS                  | EXCEPTIONSEIS_POSNSUMMARY_REPORTS                  |
      | UPG_EIS_POSITION_DATAREPORTS                 | REG_EIS_POSITION_DATAREPORTS                 | EXCEPTIONSEIS_POSITION_DATAREPORTS                 |
      | UPG_EIS_DATAREPORTS_FUND                     | REG_EIS_DATAREPORTS_FUND                     | EXCEPTIONSEIS_DATAREPORTS_FUND                     |
      | UPG_BRS_VN_INT_PRICE_VIEW                    | REG_BRS_VN_INT_PRICE_VIEW                    | EXCEPTIONSBRS_VN_INT_PRICE_VIEW                    |
      | UPG_BRS_SOD_POS_NONFX_LATAM                  | REG_BRS_SOD_POS_NONFX_LATAM                  | EXCEPTIONSBRS_SOD_POS_NONFX_LATAM                  |
      | UPG_BRS_SOD_POSITION_NONFX                   | REG_BRS_SOD_POSITION_NONFX                   | EXCEPTIONSBRS_SOD_POSITION_NONFX                   |
      | UPG_BRS_SOD_POSITION_FX                      | REG_BRS_SOD_POSITION_FX                      | EXCEPTIONSBRS_SOD_POSITION_FX                      |
      | UPG_BRS_SOD_POSITION_FX_LATAM                | REG_BRS_SOD_POSITION_FX_LATAM                | EXCEPTIONSBRS_SOD_POSITION_FX_LATAM                |
      | UPG_BRS_SOD_NPP_POSN_NONFX                   | REG_BRS_SOD_NPP_POSN_NONFX                   | EXCEPTIONSBRS_SOD_NPP_POSN_NONFX                   |
      | UPG_BRS_SOD_NPP_POSN_FX                      | REG_BRS_SOD_NPP_POSN_FX                      | EXCEPTIONSBRS_SOD_NPP_POSN_FX                      |
      | UPG_BRS_SG_INT_PRICE_VIEW                    | REG_BRS_SG_INT_PRICE_VIEW                    | EXCEPTIONSBRS_SG_INT_PRICE_VIEW                    |
      | UPG_BRS_SCB_BROKER_PRICE_VIEW                | REG_BRS_SCB_BROKER_PRICE_VIEW                | EXCEPTIONSBRS_SCB_BROKER_PRICE_VIEW                |
     # | UPG_BRS_PRICE_VIEW                           | REG_BRS_PRICE_VIEW                           | EXCEPTIONSBRS_PRICE_VIEW                           |
      | UPG_BRS_ISSUER_RATING_CUSTOM                 | REG_BRS_ISSUER_RATING_CUSTOM                 | EXCEPTIONSBRS_ISSUER_RATING_CUSTOM                 |
      | UPG_BRS_HSBC_BROKER_PRC_VIEW                 | REG_BRS_HSBC_BROKER_PRC_VIEW                 | EXCEPTIONSBRS_HSBC_BROKER_PRC_VIEW                 |
      | UPG_BRS_CDF_SEC                              | REG_BRS_CDF_SEC                              | EXCEPTIONSBRS_CDF_SEC                              |
      | UPG_BRS_CASHTRAN_FILE367_NEWCASH             | REG_BRS_CASHTRAN_FILE367_NEWCASH             | EXCEPTIONSBRS_CASHTRAN_FILE367_NEWCASH             |
      | UPG_BRS_CASHTRAN_FILE367_CANC                | REG_BRS_CASHTRAN_FILE367_CANC                | EXCEPTIONSBRS_CASHTRAN_FILE367_CANC                |
      | UPG_BRS_CASHTRAN_FILE365_VM                  | REG_BRS_CASHTRAN_FILE365_VM                  | EXCEPTIONSBRS_CASHTRAN_FILE365_VM                  |
      | UPG_BRS_CASHTRAN_FILE365_VM_C                | REG_BRS_CASHTRAN_FILE365_VM_C                | EXCEPTIONSBRS_CASHTRAN_FILE365_VM_C                |
      | UPG_BRS_CASHTRAN_FILE365_FX                  | REG_BRS_CASHTRAN_FILE365_FX                  | EXCEPTIONSBRS_CASHTRAN_FILE365_FX                  |
      | UPG_BRS_CASHTRAN_FILE365_FX_C                | REG_BRS_CASHTRAN_FILE365_FX_C                | EXCEPTIONSBRS_CASHTRAN_FILE365_FX_C                |
      | UPG_BRS_CASHTRAN_FILE365_CC                  | REG_BRS_CASHTRAN_FILE365_CC                  | EXCEPTIONSBRS_CASHTRAN_FILE365_CC                  |
      | UPG_BRS_CASHTRAN_FILE365_CC_C                | REG_BRS_CASHTRAN_FILE365_CC_C                | EXCEPTIONSBRS_CASHTRAN_FILE365_CC_C                |
      | UPG_BRS_CASHTRAN_FILE314_MISCCASH            | REG_BRS_CASHTRAN_FILE314_MISCCASH            | EXCEPTIONSBRS_CASHTRAN_FILE314_MISCCASH            |
      | UPG_BRS_CASHSTMT_FILE313_EODCASH             | REG_BRS_CASHSTMT_FILE313_EODCASH             | EXCEPTIONSBRS_CASHSTMT_FILE313_EODCASH             |
      | UPG_BRS_P_BBGRATINGS                         | REG_BRS_P_BBGRATINGS                         | EXCEPTIONSBRS_P_BBGRATINGS                         |
      | UPG_BNP_REF_SECURITY_CUSTOM_CLASSIFICATION   | REG_BNP_REF_SECURITY_CUSTOM_CLASSIFICATION   | EXCEPTIONSBNP_REF_SECURITY_CUSTOM_CLASSIFICATION   |
      | UPG_BNP_DRIFTED_BM_WEIGHTS                   | REG_BNP_DRIFTED_BM_WEIGHTS                   | EXCEPTIONSBNP_DRIFTED_BM_WEIGHTS                   |
      | UPG_BNP_CASHALLOCATION_ITAP_FIL11            | REG_BNP_CASHALLOCATION_ITAP_FIL11            | EXCEPTIONSBNP_CASHALLOCATION_ITAP_FIL11            |
      | UPG_BNP_CASHALLOCATION_FILE96                | REG_BNP_CASHALLOCATION_FILE96                | EXCEPTIONSBNP_CASHALLOCATION_FILE96                |
      | UPG_EIS_BRS_TO_DMP_SEC_ANALYTICS_GLOBAL_PNL  | REG_EIS_BRS_TO_DMP_SEC_ANALYTICS_GLOBAL_PNL  | EXCEPTIONSEIS_BRS_TO_DMP_SEC_ANALYTICS_GLOBAL_PNL  |
      | UPG_EIS_BNP_TO_BRS_PERFORMANCE_RETURNS       | REG_EIS_BNP_TO_BRS_PERFORMANCE_RETURNS       | EXCEPTIONSEIS_BNP_TO_BRS_PERFORMANCE_RETURNS       |
      | UPG_EIM_DMP_TO_BRS_MFUND_NAV_ABOR            | REG_EIM_DMP_TO_BRS_MFUND_NAV_ABOR            | EXCEPTIONSEIM_DMP_TO_BRS_MFUND_NAV_ABOR            |
      | UPG_EIM_DMP_TO_BRS_DB_NAV_ABOR               | REG_EIM_DMP_TO_BRS_DB_NAV_ABOR               | EXCEPTIONSEIM_DMP_TO_BRS_DB_NAV_ABOR               |
      | UPG_EIM_DMP_BRS_SCB_NAV                      | REG_EIM_DMP_BRS_SCB_NAV                      | EXCEPTIONSEIM_DMP_BRS_SCB_NAV                      |
      | UPG_EICN_WFOE_TO_RCR_WFOEEISLINSTMT          | REG_EICN_WFOE_TO_RCR_WFOEEISLINSTMT          | EXCEPTIONSEICN_WFOE_TO_RCR_WFOEEISLINSTMT          |


  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory