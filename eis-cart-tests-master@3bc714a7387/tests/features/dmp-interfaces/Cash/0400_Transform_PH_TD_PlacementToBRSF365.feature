#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOM&title=PH+TD+Automated+loading+to+Aladdin#businessRequirements--430487976
#https://jira.pruconnect.net/browse/EISDEV-7219
#EISDEV-7317: raised exception for broker missing in translation table
#EISDEV-7339: notfcn_id change for broker missing
#EISDEV-7437: added division by 100 for COUPON

@gc_interface_cash
@dmp_regression_unittest
@eisdev_7219 @eisdev_7317 @eisdev_7339 @eisdev_7437

Feature: Transform XLSX file from PH for TD to BRS Cash Transactions (File 365)

  Load CASH/TD transactions from files provided by PLUK PH TD in XLSX format by converting them to CSV
  and tranform it to File 365 format so that it can be loaded in Aladdin for portfolio management, operations, and accounting purposes

  Scenario: TC_1: Assign Variables & Reset Jblg

    Given I assign "tests/test-data/dmp-interfaces/Cash" to variable "testdata.path"
    And I assign "TDPlacement-2020-11-17-Eastspring1.xlsx" to variable "INPUT_FILENAME_LOAD1"
    And I assign "TDPlacement-2020-11-17-Eastspring2.xlsx" to variable "INPUT_FILENAME_LOAD2"
    And I assign "esi_brs_tradein_td" to variable "OUTPUT_FILENAME"
    And I assign "esi_brs_tradein_td_load_2" to variable "OUTPUT_FILENAME_LOAD2"
    And I assign "/dmp/out/brs/intraday" to variable "PUBLISHING_DIR"
    And I assign "esi_brs_tradein_td_load_1_expected" to variable "EXPECTED_FILENAME_LOAD1"
    And I assign "esi_brs_tradein_td_load_2_expected" to variable "EXPECTED_FILENAME_LOAD2"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" to variable "CONVERT_XLS_CSV"

    And I execute below query to "Reset job Log"
	"""
    update ft_t_jblg set job_input_txt = 'RestJobLog' where job_input_txt like '%TDPlacement-2020-11-17-%' and job_msg_typ = 'EIS_PH_TD_BRS_PLACEMENT' and job_stat_typ = 'CLOSED';
    commit
    """

  Scenario: TC_2: Transform the new Excel file to BRS F365

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}*.csv |

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_LOAD1} |

    And I process the workflow template file "${CONVERT_XLS_CSV}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE    | EIS_PH_TD_BRS_PLACEMENT        |
      | INPUT_DATA_DIR  | ${dmp.ssh.inbound.path}        |
      | FILEPATTERN     | ${INPUT_FILENAME_LOAD1}        |
      | PARALLELISM     | 1                              |
      | OUTPUT_DATA_DIR | ${dmp.ssh.archive.path}        |
      | SUCCESS_ACTION  | MOVE                           |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation |

    And I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | %EX_DESK_TYPE%                             |
      | NOTFCN_ID               | 60040                                      |
      | SOURCE_ID               | TRANSLATION                                |
      | MSG_TYP                 | EIS_PH_TD_BRS_PLACEMENT                    |
      | NOTFCN_STAT_TYP         | OPEN                                       |
      | MAIN_ENTITY_ID_CTXT_TYP | EXT_ID1                                    |
      | MAIN_ENTITY_ID          | 20201117-APPHBF-PHP-PDSCB_DUMMY-20201118-1 |
      | MSG_SEVERITY_CDE        | 40                                         |

    Then I expect 1 exceptions are captured with the following criteria
      | PARM_VAL_TXT            | %EX_BROKER%                                |
      | NOTFCN_ID               | 60040                                      |
      | SOURCE_ID               | TRANSLATION                                |
      | MSG_TYP                 | EIS_PH_TD_BRS_PLACEMENT                    |
      | NOTFCN_STAT_TYP         | OPEN                                       |
      | MAIN_ENTITY_ID_CTXT_TYP | EXT_ID1                                    |
      | MAIN_ENTITY_ID          | 20201117-APPHBF-PHP-PDSCB_DUMMY-20201118-1 |
      | MSG_SEVERITY_CDE        | 40                                         |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}*.csv |

    And I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${OUTPUT_FILENAME}*.csv |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}*.csv |

  Scenario:TC_3: Recon the transformed F365 against the expected file for new file

    Given I execute below query and extract values of "OUTPUT_FILENAME_LOAD1" into same variables
    """
      select substr(pub_out_txt,instr(pub_out_txt,'/',-1)+1) as OUTPUT_FILENAME_LOAD1 from
      (select row_number() over (partition by subscription_nme order by start_tms desc) r, pub_out_txt
      from ft_v_pub1 where subscription_nme = 'EIS_PH_TO_BRS_CASHTRAN_FILE365_SUB' and pub_status = 'CLOSED') where r=1
    """

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/reference/${EXPECTED_FILENAME_LOAD1}.csv |
      | File2 | ${testdata.path}/outfiles/runtime/${OUTPUT_FILENAME_LOAD1}         |

  Scenario: TC_4: Transform the correction Excel file to BRS F365

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}*.csv |

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_LOAD2} |

    And I process the workflow template file "${CONVERT_XLS_CSV}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE    | EIS_PH_TD_BRS_PLACEMENT        |
      | INPUT_DATA_DIR  | ${dmp.ssh.inbound.path}        |
      | FILEPATTERN     | ${INPUT_FILENAME_LOAD2}        |
      | PARALLELISM     | 1                              |
      | OUTPUT_DATA_DIR | ${dmp.ssh.archive.path}        |
      | SUCCESS_ACTION  | MOVE                           |
      | FILE_LOAD_EVENT | EIS_StandardFileTransformation |

    Then I expect below files to be present in the host "dmp.ssh.outbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${OUTPUT_FILENAME}*.csv |

    And I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.outbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${OUTPUT_FILENAME}*.csv |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${OUTPUT_FILENAME}*.csv |

  Scenario:TC_5: Recon the transformed F365 against the expected file for correction file

    Given I execute below query and extract values of "OUTPUT_FILENAME_LOAD2" into same variables
    """
      select substr(pub_out_txt,instr(pub_out_txt,'/',-1)+1) as OUTPUT_FILENAME_LOAD2 from
      (select row_number() over (partition by subscription_nme order by start_tms desc) r, pub_out_txt
      from ft_v_pub1 where subscription_nme = 'EIS_PH_TO_BRS_CASHTRAN_FILE365_SUB' and pub_status = 'CLOSED') where r=1
    """

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/reference/${EXPECTED_FILENAME_LOAD2}.csv |
      | File2 | ${testdata.path}/outfiles/runtime/${OUTPUT_FILENAME_LOAD2}         |