#https://jira.pruconnect.net/browse/EISDEV-6963
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements-KORPER

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 02/09/2020      EISDEV-6963    Korea Performance LBU
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_6963_XLS @eisdev_6963 @peer_ranking_dwh @eisdev_7414
Feature: Load and Update KOR PER XLS report and verify details

  This is to test if KOR PER Peer Ranking XLS files are getting converted to CSV format and getting loaded in DWH
  And verify if various columns are populated as per expectation

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-6963" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_Load_Fund_performance_as_of_202008_Report.csv" to variable "OUTPUT_FILENAME_KORPER"
    And I assign "Processed_Update_Fund_performance_as_of_202008_Report.csv" to variable "OUTPUT_FILENAME_UPDATE_KORPER"
    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
         UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSKORPER' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655');
         UPDATE FT_T_WACT set INTRNL_ID11='QSLU51346655' WHERE acct_sok in (select acct_sok from FT_T_WAIR where iss_sok in (select iss_sok from ft_t_wisu where isin_id ='QSLU51346655'  and dw_Status_num =1 and PREF_ID_CTXT_TYP='EISSECID') and dw_Status_num =1 and ACCT_ISSU_RL_TYP='AUT') and dw_Status_num=1 and ACCT_STAT_TYP='OPEN';
    """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Load Fund performance as of 202008.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_KOR_PER                                        |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                 |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties              |
      | FILEPATTERN             | *.xls                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Fund_performance_as_of*.csv                                   |
      | PARALLELISM             | 1                                                                        |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                   |
      | PARAMETERSURI           | db://resource/propertyfiles                                              |
      | SUCCESS_ACTION          | LEAVE                                                                    |
      | LIST_SHEET_NAME         | Report                                                                   |
      | REPROCESSPROCESSEDFILES | true                                                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_KORPER} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking load scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSKORPER' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                        | Query                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
      | AsOfDate                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AsOfDate from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and trunc(w.as_of_tms)=to_date('31-08-2020','DD-MM-YYYY')                                                                                                                                    |
      | MainFundCode                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS MainFundCode from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_1='95001'                                                                                                                                                         |
      | KRCode                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS KRCode from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_8='QSLU51346655'                                                                                                                                                        |
      | Fund                          | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Fund from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_2='NACF Active Equity 1'                                                                                                                                                  |
      | BenchPrim                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BenchPrim from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.ACCT_SOK_2 in (SELECT rep_acct_sok fROM FT_T_WACR  WHERE rl_typ ='PRIMARY' AND acct_sok IN (SELECT w.acct_sok FROM ft_T_wact w WHERE INTRNL_ID11='QSLU51346655' AND DW_STATUS_NUM=1)) |

      | BM1Name                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BM1Name from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_9='KOSPI 100%'                                                                                                                                                         |
      | BM2Name                       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS BM2Name from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_10='KOSPI 150%'                                                                                                                                                        |
      | FundHouse                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FundHouse from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_11='ES Korea'                                                                                                                                                        |
      | AssetClass                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AssetClass from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_3='Equity'                                                                                                                                                          |
      | InvestmentTeam                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS InvestmentTeam from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_5='Equity'                                                                                                                                                      |
      | TypeofFund                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS TypeofFund from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_14='Non Life - Institutional'                                                                                                                                       |
      | Currency                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Currency from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.BASE_CURR_CDE='KRW'                                                                                                                                                                    |

      | FUMinbase                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FUMinbase from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_VAL_CAMT_1='20046.3726'                                                                                                                                                           |
      | FUMinUSD                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FUMinUSD from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_VAL_CAMT_3='16.88'                                                                                                                                                                 |
      | FUMinGBP                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FUMinGBP from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_VAL_CAMT_4='12.65'                                                                                                                                                                 |

      | Return_Source                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Return_Source from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.DATA_BASIS_ID='Shinhan Aitas'                                                                                                                                                     |
      | Return_Type                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Return_Type from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RETURN_TYP='Net of FEE'                                                                                                                                                             |
      | ABORIBOR                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ABORIBOR from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_4='ABOR'                                                                                                                                                              |
      | FundManager                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS FundManager from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_12='Angela Ko'                                                                                                                                                     |
      | ClientName                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ClientName from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_6='EISDEV6963'                                                                                                                                                      |
      | ShareType                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS ShareType from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.USR_CHAR_VAL_TXT_7='EISDEV6963TYPE'                                                                                                                                                   |

      | YTDFundGrossAbsoluteReturn    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDFundGrossAbsoluteReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.YTD_RETURN_CAMT='1.2'                                                                                                                                                |
      | YTDFundPriBenchmarkReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDFundPriBenchmarkReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.YTD_ACCT_2_RETURN_CAMT='2.3'                                                                                                                                          |
      | YTDFundGrossRelativeReturn    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDFundGrossRelativeReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.YTD_RELV_RETURN_CAMT='3.4'                                                                                                                                           |
      | YTDptl                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS YTDptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.YTD_RET_PGRP_PCTL_NUM='1'                                                                                                                                                                |

      | Y1FundGrossAbsoluteReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y1FundGrossAbsoluteReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.CUM_1YR_RETURN_CAMT='4.4'                                                                                                                                             |
      | Y1FundPriBenchmarkReturn      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y1FundPriBenchmarkReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.CUM_1YR_ACCT_2_RET_CAMT='5.5'                                                                                                                                          |
      | Y1FundGrossRelativeReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y1FundGrossRelativeReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.CUM_1YR_RELV_RETURN_CAMT='6.6'                                                                                                                                        |
      | Y1ptl                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y1ptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.CUM_1Y_RET_PGRP_PCTL_NUM='2'                                                                                                                                                              |

      | Y3FundGrossAbsoluteReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundGrossAbsoluteReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_3YR_RETURN_CAMT='7.6'                                                                                                                                           |
      | Y3FundPriBenchmarkReturnAnn   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundPriBenchmarkReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_3YR_ACCT_2_RET_CAMT='8.7'                                                                                                                                        |
      | Y3FundGrossRelativeReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3FundGrossRelativeReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_3YR_RELV_RETURN_CAMT='9.8'                                                                                                                                      |
      | Y3ptl                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y3ptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_3Y_RET_PGRP_PCTL_NUM='3'                                                                                                                                                               |

      | Y5FundGrossAbsoluteReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundGrossAbsoluteReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_5YR_RETURN_CAMT='10.8'                                                                                                                                          |
      | Y5FundPriBenchmarkReturnAnn   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundPriBenchmarkReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_5YR_ACCT_2_RET_CAMT='11.9'                                                                                                                                       |
      | Y5FundGrossRelativeReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5FundGrossRelativeReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_5YR_RELV_RETURN_CAMT='13.1'                                                                                                                                     |
      | Y5ptl                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y5ptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_5Y_RET_PGRP_PCTL_NUM='4'                                                                                                                                                               |

      | Y10FundGrossAbsoluteReturnAnn | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundGrossAbsoluteReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_10YR_RETURN_CAMT='14.1'                                                                                                                                        |
      | Y10FundPriBenchmarkReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundPriBenchmarkReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_10YR_ACCT_2_RET_CAMT='15.2'                                                                                                                                     |
      | Y10FundGrossRelativeReturnAnn | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10FundGrossRelativeReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_10YR_RELV_RETURN_CAMT='16.4'                                                                                                                                   |
      | Y10ptl                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Y10ptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_10Y_RET_PGRP_PCTL_NUM='5'                                                                                                                                                             |

      | SIFundGrossAbsoluteReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundGrossAbsoluteReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_SI_RETURN_CAMT='17.4'                                                                                                                                           |
      | SIFundPriBenchmarkReturnAnn   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundPriBenchmarkReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_SI_ACCT_2_RET_CAMT='18.5'                                                                                                                                        |
      | SIFundGrossRelativeReturnAnn  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundGrossRelativeReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_SI_RELV_RETURN_CAMT='19.7'                                                                                                                                      |
      | SIptl                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_SI_RET_PGRP_PCTL_NUM='6'                                                                                                                                                               |

      | M1FundGrossAbsoluteReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M1FundGrossAbsoluteReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RETURN_1M_CAMT='20.7'                                                                                                                                                 |
      | M1FundPriBenchmarkReturn      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M1FundPriBenchmarkReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.ACCT_2_RETURN_1M_CAMT='21.8'                                                                                                                                           |
      | M1FundGrossRelativeReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M1FundGrossRelativeReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RELV_RETURN_1M_CAMT='23.1'                                                                                                                                            |
      | M1ptl                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M1ptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_1M_PGRP_PCTL_NUM='7'                                                                                                                                                                  |

      | M3FundGrossAbsoluteReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M3FundGrossAbsoluteReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RETURN_3M_CAMT='21.7'                                                                                                                                                 |
      | M3FundPriBenchmarkReturn      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M3FundPriBenchmarkReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.ACCT_2_RETURN_3M_CAMT='22.8'                                                                                                                                           |
      | M3FundGrossRelativeReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M3FundGrossRelativeReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RELV_RETURN_3M_CAMT='24.1'                                                                                                                                            |
      | M3ptl                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M3ptl from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.RET_3M_PGRP_PCTL_NUM='8'                                                                                                                                                                  |


  Scenario: Remove files already present in directory before running update scenario

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Run Excel to CSV Peer Ranking workflow for update file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | Update Fund performance as of 202008.xls |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLS.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_KOR_PER                                        |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                 |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties              |
      | FILEPATTERN             | *.xls                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Fund_performance_as_of*.csv                                   |
      | PARALLELISM             | 1                                                                        |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                   |
      | PARAMETERSURI           | db://resource/propertyfiles                                              |
      | SUCCESS_ACTION          | LEAVE                                                                    |
      | LIST_SHEET_NAME         | Report                                                                   |
      | REPROCESSPROCESSEDFILES | true                                                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_UPDATE_KORPER} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking update scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSKORPER' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                       | Query                                                                                                                                                                                                                                                                                                                                                     |
      | M1FundPriBenchmarkReturn     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS M1FundPriBenchmarkReturn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.ACCT_2_RETURN_1M_CAMT='27.7' |
      | SIFundGrossAbsoluteReturnAnn | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS SIFundGrossAbsoluteReturnAnn from ft_w_wcri w where data_src_id = 'MSKORPER' and return_typ ='Net of FEE' and dw_Status_num =1 and acct_sok in ((select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id11= 'QSLU51346655')) and dw_status_num =1 and w.AN_SI_RETURN_CAMT='55.5' |
