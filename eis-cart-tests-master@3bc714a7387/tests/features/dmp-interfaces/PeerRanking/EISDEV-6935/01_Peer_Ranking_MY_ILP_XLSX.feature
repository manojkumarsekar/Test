#https://jira.pruconnect.net/browse/EISDEV-6935
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISTOMR4/Peer+Ranking+Inbound+Logical+Mapping#businessRequirements-MYILP

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 02/09/2020      EISDEV-6935    Peer rank data- MY ILP Morningstar report
# 23/02/2021      EISDEV-7414    DATA_SRC_ID change
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_6935_XLSX @eisdev_6935 @peer_ranking_dwh @eisdev_7414
Feature: Load and Update MY ILP Morningstar XLSX report and verify details

  This is to test if MY ILP MorningStar Peer Ranking XLSX files are getting converted to CSV format and getting loaded in DWH
  And verify if various columns are populated as per expectation

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-6935" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd-HHmmss" and assign to variable "VAR_SYSDATE"
    And I assign "Processed_202009_Malaysia_Peer_Ranking_Insurance_Fund_Load_Load_file.csv" to variable "OUTPUT_FILENAME_MYILP"
    And I assign "Processed_202009_Malaysia_Peer_Ranking_Insurance_Fund_Update_Load_file.csv" to variable "OUTPUT_FILENAME_UPDATE_MYILP"
    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xlsx |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Clear old test data and setup variables

    And I execute below query
    """
      UPDATE ft_t_wcri SET DW_STATUS_NUM=0,VERSION_END_TMSMP = TO_DATE('${VAR_SYSDATE}','YYYYMMDD-HH24MISS') WHERE DATA_SRC_ID = 'MSMYILP' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2');
     """

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | 202009 Malaysia Peer Ranking Insurance Fund Load.xlsx |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLSX.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_MY_ILP                                          |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties               |
      | FILEPATTERN             | *.xlsx                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Malaysia_Peer_Ranking_Insurance_Fund*.csv                      |
      | PARALLELISM             | 1                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                               |
      | SUCCESS_ACTION          | LEAVE                                                                     |
      | LIST_SHEET_NAME         | Load file                                                                 |
      | REPROCESSPROCESSEDFILES | true                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_MYILP} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking load scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSMYILP' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column                                   | Query                                                                                                                                                                                                                                                                                                                                                                   |
      | GroupInvestment                          | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS GroupInvestment  from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.USR_CHAR_VAL_TXT_2='PRUlink Golden Equity II'      |
      | AsOfDate                                 | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS AsOfDate from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and trunc(w.as_of_tms)=to_date('31-08-2020','DD-MM-YYYY')        |
      | EagleCode                                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS EagleCode from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.USR_CHAR_VAL_TXT_3='MYGEQF2'                              |

      | PeerGroupRank1Month                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_1M_PGRP_RNK_NUM='1'                         |
      | PeerGroupQuartile1Month                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_1M_PGRP_QRTL_NUM='2'                    |
      | Noofinvestmentsrankedinpeergroup1Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup1Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_1M_PGRP_PART_NUM='3'     |
      | PeerGroupPercentile1Month                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile1Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_1M_PGRP_PCTL_NUM='41'                 |

      | PeerGroupRank3Month                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank3Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_3M_PGRP_RNK_NUM='4'                         |
      | PeerGroupQuartile3Month                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile3Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_3M_PGRP_QRTL_NUM='5'                    |
      | Noofinvestmentsrankedinpeergroup3Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup3Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_3M_PGRP_PART_NUM='6'     |
      | PeerGroupPercentile3Month                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile3Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_3M_PGRP_PCTL_NUM='42'                 |

      | PeerGroupRank6Month                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank6Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_6M_PGRP_RNK_NUM='7'                         |
      | PeerGroupQuartile6Month                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile6Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_6M_PGRP_QRTL_NUM='8'                    |
      | Noofinvestmentsrankedinpeergroup6Month   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup6Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_6M_PGRP_PART_NUM='9'     |
      | PeerGroupPercentile6Month                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile6Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_6M_PGRP_PCTL_NUM='43'                 |

      | PeerGroupRankYTDMonth                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRankYTDMonth from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.YTD_RET_PGRP_RNK_NUM='10'                     |
      | PeerGroupQuartileYTDMonth                | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartileYTDMonth from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.YTD_RET_PGRP_QRTL_NUM='11'                |
      | NoofinvestmentsrankedinpeergroupYTDMonth | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NoofinvestmentsrankedinpeergroupYTDMonth from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.YTD_RET_PGRP_PART_NUM='12' |
      | PeerGroupPercentileYTD                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentileYTD from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.YTD_RET_PGRP_PCTL_NUM='44'                   |

      | PeerGroupRank1Yr                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_RNK_NUM='13'                       |
      | PeerGroupQuartile1Yr                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile1Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_QRTL_NUM='14'                  |
      | Noofinvestmentsrankedinpeergroup1Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup1Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_PART_NUM='15'   |
      | PeerGroupPercentile1Yr                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile1Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_PCTL_NUM='45'                |

      | PeerGroupRank3Yr                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank3Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_3Y_RET_PGRP_RNK_NUM='16'                        |
      | PeerGroupQuartile3Yr                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile3Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_3Y_RET_PGRP_QRTL_NUM='17'                   |
      | Noofinvestmentsrankedinpeergroup3Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup3Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_3Y_RET_PGRP_PART_NUM='18'    |
      | PeerGroupPercentile3Yr                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile3Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_3Y_RET_PGRP_PCTL_NUM='49'                 |

      | PeerGroupRank5Yr                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank5Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_5Y_RET_PGRP_RNK_NUM='19'                        |
      | PeerGroupQuartile5Yr                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile5Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_5Y_RET_PGRP_QRTL_NUM='20'                   |
      | Noofinvestmentsrankedinpeergroup5Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup5Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_5Y_RET_PGRP_PART_NUM='21'    |
      | PeerGroupPercentile5Yr                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile5Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_5Y_RET_PGRP_PCTL_NUM='50'                 |

      | PeerGroupRank2Yr                         | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank2Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_2Y_RET_PGRP_RNK_NUM='61'                        |
      | PeerGroupQuartile2Yr                     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile2Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_2Y_RET_PGRP_QRTL_NUM='62'                   |
      | Noofinvestmentsrankedinpeergroup2Yr      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup2Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_2Y_RET_PGRP_PART_NUM='63'    |
      | PeerGroupPercentile2Yr                   | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile2Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_2Y_RET_PGRP_PCTL_NUM='48'                 |

      | PeerGroupRank10Yr                        | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank10Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_10Y_RET_PGRP_RNK_NUM='22'                      |
      | PeerGroupQuartile10Yr                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartile10Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_10Y_RET_PGRP_QRTL_NUM='23'                 |
      | Noofinvestmentsrankedinpeergroup10Yr     | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS Noofinvestmentsrankedinpeergroup10Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_10Y_RET_PGRP_PART_NUM='24'  |
      | PeerGroupPercentile10Yr                  | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentile10Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.AN_10Y_RET_PGRP_PCTL_NUM='51'               |

      | PeerGroupRankSI                          | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRankSI from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_SI_RET_PGRP_RNK_NUM='26'                        |
      | PeerGroupQuartileSI                      | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupQuartileSI from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_SI_RET_PGRP_QRTL_NUM='27'                   |
      | NoofinvestmentsrankedinpeergroupSI       | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS NoofinvestmentsrankedinpeergroupSI from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_SI_RET_PGRP_PART_NUM='28'    |
      | PeerGroupPercentileSI                    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupPercentileSI from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_SI_RET_PGRP_PCTL_NUM='52'                 |


  Scenario: Remove files already present in directory before running update scenario

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xlsx |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

  Scenario: Run Excel to CSV Peer Ranking workflow for update file

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | 202009 Malaysia Peer Ranking Insurance Fund Update.xlsx |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLSX.bshi |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_MY_ILP                                          |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                  |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties               |
      | FILEPATTERN             | *.xlsx                                                                    |
      | LOAD_FILE_PATTERNS      | Processed_*Malaysia_Peer_Ranking_Insurance_Fund*.csv                      |
      | PARALLELISM             | 1                                                                         |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                    |
      | PARAMETERSURI           | db://resource/propertyfiles                                               |
      | SUCCESS_ACTION          | LEAVE                                                                     |
      | LIST_SHEET_NAME         | Load file                                                                 |
      | REPROCESSPROCESSEDFILES | true                                                                      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_UPDATE_MYILP} |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(1) AS JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND TASK_SUCCESS_CNT ='1'
    """

  Scenario: Perform checks in WCRI for checking update scenario

    Then I expect value of column "WCRI_COUNT" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS WCRI_COUNT FROM FT_T_WCRI
      WHERE DATA_SRC_ID = 'MSMYILP' AND DW_STATUS_NUM =1 and ACCT_SOK = (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2')
    """

  Scenario Outline: Verify the data uploaded in column <Column>

    Then I expect value of column "<Column>" in the below SQL query equals to "PASS":
    """
      <Query>
    """

    Examples: Data Verifications having value not zero
      | Column              | Query                                                                                                                                                                                                                                                                                                                                             |
      | PeerGroupRank1Month | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Month from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.RET_1M_PGRP_RNK_NUM='5'   |
      | PeerGroupRank1Yr    | select CASE WHEN COUNT(*) = 1 THEN 'PASS' ELSE 'FAIL' END AS PeerGroupRank1Yr from ft_w_wcri w where data_src_id = 'MSMYILP' and return_typ ='NetNAVGrossMgtFees' and dw_Status_num =1 and acct_sok in (select acct_sok from ft_t_wact where dw_status_num =1 and intrnl_id10= 'MYGEQF2') and dw_status_num =1 and w.CUM_1Y_RET_PGRP_RNK_NUM='77' |