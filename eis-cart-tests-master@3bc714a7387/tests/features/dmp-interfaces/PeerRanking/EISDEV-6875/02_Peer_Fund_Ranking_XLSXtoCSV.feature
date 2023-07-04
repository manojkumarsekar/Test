#https://jira.pruconnect.net/browse/EISDEV-6875
#https://jira.pruconnect.net/browse/EISDEV-6848
#https://jira.pruconnect.net/browse/EISDEV-7199
#https://collaborate.pruconnect.net/display/EISPRM/Morningstar+Peer+ranking+reports
#https://collaborate.pruconnect.net/display/EISPRM/Peer+Ranking+Technical+Design

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 07/09/2020      EISDEV-6875    Create GS Workflow to convert MorningStar Peer Fund Ranking XLSX files into readable CSV format
# 02/09/2020      EISDEV-6848    Peer rank data- SG SICAV Morningstar report
# 23/11/2020      EISDEV-7199    Philippines file loading error
# 29/03/2021      EISDEV-7444    Storing percentile columns for ESKR Peer rank data
# ===================================================================================================================================================================================


@dw_interface_peer_ranking @dmp_dw_regression
@eisdev_6875_XLSX1 @eisdev_6875 @peer_ranking_dwh @eisdev_6853_XLSX @eisdev_6853 @eisdev_6848_XLSX
@eisdev_6848 @eisdev_7199 @eisdev_7199_XLSX @eisdev_7444
Feature: Convert MorningStar Peer Fund Ranking XLSX files into readable CSV format

  This is to test if MorningStar Peer Ranking files are getting converted to CSV format which will get loaded in DWH
  And load different excel files with different data to verify if conversion to CSV format is working properly

  Background:

    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    And I set the database connection to configuration "dmp.db.DW"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/PeerRanking/EISDEV-6875" to variable "testdata.path"
    And I assign "Processed_Sing_ILP_Ranking_202008_Summary_PACS_202008.csv" to variable "OUTPUT_FILENAME_SGILP"
    And I assign "Processed_HK_ILP_20200806_Sheet1_20200806.csv" to variable "OUTPUT_FILENAME_HKILP"
    And I assign "Processed_PerformanceComparison_20200813_Local_PR-SG_20200813.csv" to variable "OUTPUT_FILENAME_LOCALPRSG"
    And I assign "Processed_PerformanceComparison_20200813_Local_PR-JP_20200813.csv" to variable "OUTPUT_FILENAME_LOCALPRJP"
    And I assign "Processed_PerformanceComparison_20200813_Local_PR-TW_20200813.csv" to variable "OUTPUT_FILENAME_LOCALPRTW"
    And I assign "Processed_Malaysia_20200808_Msia_UT_Non_Shariah_and_Shariah_20200808.csv" to variable "OUTPUT_FILENAME_MALAYSIA"
    And I assign "Processed_SICAV_20200806_SICAV_M_PR_-_All_Funds1_ES_20200806.csv" to variable "OUTPUT_FILENAME_SICAVFUND1"
    And I assign "Processed_SICAV_20200806_SICAV_M_PR_-_All_Funds2_ES_20200806.csv" to variable "OUTPUT_FILENAME_SICAVFUND2"
    And I assign "Processed_SICAV_20200806_SICAV_M_PR_-_All_Funds3_ES_20200806.csv" to variable "OUTPUT_FILENAME_SICAVFUND3"
    And I assign "Processed_Peer_group_rankingE_20200831_MMF.csv" to variable "OUTPUT_FILENAME_KOR1"
    And I assign "Processed_Peer_group_rankingE_20200831_Equity.csv" to variable "OUTPUT_FILENAME_KOR2"
    And I assign "Processed_Peer_group_rankingE_20200831_Bond_Balanced.csv" to variable "OUTPUT_FILENAME_KOR3"
    And I assign "Processed_Fund_performance_as_of_202008_Report.csv" to variable "OUTPUT_FILENAME_KORPER"
    And I assign "Processed_Peers_Ranking_for_Regional_-_October_2020_Load_File.csv" to variable "OUTPUT_FILENAME_ID"
    And I assign "Processed_Peer_Rank_202008_-_PHP_ILP_ExtFunds_Load_File.csv" to variable "OUTPUT_FILENAME_PHP"
    And I assign "Processed_Malaysia_Peer_Ranking_Insurance_Fund_Load_file.csv" to variable "OUTPUT_FILENAME_MYILP"

    And I assign "/dmp/in/" to variable "PEERRANK_DOWNLOAD_DIR"
    And I assign "/dmp/out/" to variable "PEERRANK_UPLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_UPLOAD_DIR}" if exists:
      | *.csv |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xls |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PEERRANK_DOWNLOAD_DIR}" if exists:
      | *.xlsx |

  Scenario: Run Excel to CSV Peer Ranking workflow

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${PEERRANK_DOWNLOAD_DIR}":
      | PerformanceComparison_20200813.xlsx            |
      | HK ILP_20200806.xlsx                           |
      | Malaysia_20200808.xlsx                         |
      | SICAV_20200806.xlsx                            |
      | Sing ILP Ranking 202008.xlsx                   |
      | Malaysia Peer Ranking Insurance Fund.xlsx      |
      | Peer Rank 202008 - PHP ILP (ExtFunds).xlsx     |
      | Peers Ranking for Regional - October 2020.xlsx |
      | Peer group ranking(E)_20200831.xlsx            |
      | Fund performance as of 202008.xlsx             |

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_PeerFundRanking_ExceltoCSV_DWH/request.xmlt" to variable "PROC_EXCEL"
    And I assign "1000" to variable "workflow.max.polling.time"

    And I process the workflow template file "${PROC_EXCEL}" with below parameters and wait for the job to be completed
      | BEAN_SHELL_EXCEL_URI    | db://resource/EASTSPRING/script/EIS_Process_PeerRank_ExceltoCSV_XLSX.bshi                                                                                                                                                          |
      | MESSAGE_TYPE            | EIS_MT_MS_DWH_PEERRANKING_JP_UT                                                                                                                                                                                                    |
      | INPUT_DATA_DIR          | ${PEERRANK_DOWNLOAD_DIR}                                                                                                                                                                                                           |
      | HEADERURI               | db://resource/propertyfiles/EISPeerRankingHeader.properties                                                                                                                                                                        |
      | FILEPATTERN             | *.xlsx                                                                                                                                                                                                                             |
      | LOAD_FILE_PATTERNS      | Processed_*.csv                                                                                                                                                                                                                    |
      | PARALLELISM             | 1                                                                                                                                                                                                                                  |
      | OUTPUT_DATA_DIR         | ${PEERRANK_UPLOAD_DIR}                                                                                                                                                                                                             |
      | PARAMETERSURI           | db://resource/propertyfiles                                                                                                                                                                                                        |
      | SUCCESS_ACTION          | LEAVE                                                                                                                                                                                                                              |
      | LIST_SHEET_NAME         | Local PR-JP,Local PR-SG,Local PR-TW,Sheet1,Msia_UT_Non_Shariah_and_Shariah,SICAV M PR - All Funds1 (ES),SICAV M PR - All Funds2 (ES),SICAV M PR - All Funds3 (ES),Summary_PACS,Load file,Load File,Equity,Bond_Balanced,MMF,Report |
      | REPROCESSPROCESSEDFILES | true                                                                                                                                                                                                                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PEERRANK_UPLOAD_DIR}" after processing:
      | ${OUTPUT_FILENAME_HKILP}      |
      | ${OUTPUT_FILENAME_LOCALPRSG}  |
      | ${OUTPUT_FILENAME_LOCALPRJP}  |
      | ${OUTPUT_FILENAME_LOCALPRTW}  |
      | ${OUTPUT_FILENAME_MALAYSIA}   |
      | ${OUTPUT_FILENAME_SICAVFUND1} |
      | ${OUTPUT_FILENAME_SICAVFUND2} |
      | ${OUTPUT_FILENAME_SICAVFUND3} |
      | ${OUTPUT_FILENAME_SGILP}      |
      | ${OUTPUT_FILENAME_KOR1}       |
      | ${OUTPUT_FILENAME_KOR2}       |
      | ${OUTPUT_FILENAME_KOR3}       |
      | ${OUTPUT_FILENAME_KORPER}     |
      | ${OUTPUT_FILENAME_ID}         |
      | ${OUTPUT_FILENAME_PHP}        |
      | ${OUTPUT_FILENAME_MYILP}      |

  Scenario: Load CSV generated for different files for recon

    Given I copy files below from remote folder "${PEERRANK_UPLOAD_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outputfiles/xlsx/runtime":
      | ${OUTPUT_FILENAME_HKILP}      |
      | ${OUTPUT_FILENAME_LOCALPRSG}  |
      | ${OUTPUT_FILENAME_LOCALPRJP}  |
      | ${OUTPUT_FILENAME_LOCALPRTW}  |
      | ${OUTPUT_FILENAME_MALAYSIA}   |
      | ${OUTPUT_FILENAME_SICAVFUND1} |
      | ${OUTPUT_FILENAME_SICAVFUND2} |
      | ${OUTPUT_FILENAME_SICAVFUND3} |
      | ${OUTPUT_FILENAME_SGILP}      |
      | ${OUTPUT_FILENAME_KOR1}       |
      | ${OUTPUT_FILENAME_KOR2}       |
      | ${OUTPUT_FILENAME_KOR3}       |
      | ${OUTPUT_FILENAME_KORPER}     |
      | ${OUTPUT_FILENAME_ID}         |
      | ${OUTPUT_FILENAME_PHP}        |
      | ${OUTPUT_FILENAME_MYILP}      |

  Scenario: Verify CSV files generated matches with expected output

    Then I expect each record in file "${testdata.path}/outputfiles/testdata/SICAVAllFunds1_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_SICAVFUND1}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_SICAVFUND1}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/SICAVAllFunds2_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_SICAVFUND2}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_SICAVFUND2}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/SICAVAllFunds3_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_SICAVFUND3}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_SICAVFUND3}." file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/Malaysia_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_MALAYSIA}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_MALAYSIA}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/LocalPRTW_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_LOCALPRTW}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_LOCALPRTW}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/LocalPRSG_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_LOCALPRSG}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_LOCALPRSG}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/LocalPRJP_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_LOCALPRJP}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_LOCALPRJP}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/Sing_ILP_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_SGILP}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_SGILP}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/KOR_LBU_1_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_KOR1}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_KOR1}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/KOR_LBU_2_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_KOR2}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_KOR2}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/KOR_LBU_3_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_KOR3}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_KOR3}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/KORPER_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_KORPER}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_KORPER}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/ID_ILP_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_ID}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_ID}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/PHP_ILP_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_PHP}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_PHP}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/MY_ILP_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_MYILP}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_MYILP}" file
    Then I expect each record in file "${testdata.path}/outputfiles/testdata/HKILP_XLSX_Expected.csv" should exist in file "${testdata.path}/outputfiles/xlsx/runtime/${OUTPUT_FILENAME_HKILP}" and exceptions to be written to "${testdata.path}/outputfiles/xls/runtime/Exceptions_${OUTPUT_FILENAME_HKILP}" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
