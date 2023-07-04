# =================================================================================
# Date            JIRA           Comments
# ============    ===========    ========
# 10/11/2020      EISDEV-6729    Intial Version
# Requirement https://jira.pruconnect.net/browse/EISDEV-6729
# =================================================================================

@gc_interface_shares
@gc_interface_cdf
@dmp_regression_integrationtest
@bony_to_brs_sho @esidev_6729
Feature: 001 | Shares Outstanding | BONY to BRS

  Verify BONY Shares Outstanding File is Loaded and Published to BRS. Since this is an EXCEL TO CSV transformation, Max Date Publishing will be mocked up

  Scenario: Transform BONY Shares Outstanding file to Load into DMP

    Given I assign "tests/test-data/dmp-interfaces/SharesOutstanding/BONY" to variable "testdata.path"
    And I assign "Eastspring_Investments_VARIANCE_14-07-2020.xls" to variable "INPUT_FILENAME"
    And I assign "Eastspring_Investments_VARIANCE_14-07-2020.csv" to variable "TRANSFORMED_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/in/bony" to variable "INPUT_DIRECTORY"

    And I execute below query to "delete data with sho date 14/07/2020"
    """
    delete ft_t_sho1 where EXT_SHO_DATE = to_date ('20200714','YYYYMMDD')
    """

    Then I execute below query and extract values of "MAX_DATE" into same variables
      """
      select to_char(SYSDATE+1,'YYYYMMDD') as MAX_DATE from dual
      """

     Then I remove below files in the host "dmp.ssh.inbound" from folder "${INPUT_DIRECTORY}" if exists:
      | ${INPUT_FILENAME}        |
      | ${TRANSFORMED_FILE_NAME} |

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/bony":
      | ${INPUT_FILENAME} |

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_ConvertXLSXtoCSVandLoad/request.xmlt" to variable "XLSX_TO_CSV_WF"
    And I process the workflow template file "${XLSX_TO_CSV_WF}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE   | EIS_MT_BONY_SHARES_OUTSTANDING |
      | INPUT_DATA_DIR | ${dmp.ssh.inbound.path}/bony   |
      | FILEPATTERN    | ${INPUT_FILENAME}              |
      | PARALLELISM    | 1                              |

  Scenario: Data Verification for Shares Outstanding dated 14-07-2020

    Given I expect value of column "SHO_14072020" in the below SQL query equals to "347":
    """
    select count(*) as SHO_14072020 from ft_t_sho1 where EXT_SHO_DATE = to_date ('20200714','YYYYMMDD')
    """

  Scenario: Publish loaded sho from DMP to BRS for RUNTIMEPUBLISH_TMS = 20200714

    Given I assign "/dmp/out/brs/1a_security" to variable "BRS_PUBLISHING_DIRECTORY"
    And I assign "esi_brs_bony_sec_cdf" to variable "BRS_PUBLISHING_FILE_NAME"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"
    And I assign "esi_brs_bony_sec_cdf_expected_output.csv" to variable "TEMPLATE_FILENAME"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME}_*_1.csv |

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BONY_CDF_SUB                  |
      | RUNTIMEPUBLISH_TMS   | 20200714                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BRS_PUBLISHING_DIRECTORY}" after processing:
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${BRS_PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${BRS_PUBLISHING_FILE_NAME}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/outfiles/template/${TEMPLATE_FILENAME}                                         |

  Scenario: Publish loaded sho from DMP to BRS for MAX DATE = SYSDATE +1

    Given I assign "esi_brs_bony_sec_cdf_maxdate" to variable "BRS_PUBLISHING_FILE_NAME_MAXDATE"
    And I assign "esi_brs_bony_sec_cdf_maxdate_expected_output.csv" to variable "OUTPUT_FILENAME_MAXDATE"

    And I execute below query to "delete data with sho date 14/07/2020"
    """
    update ft_t_sho1 set EXT_SHO_DATE = SYSDATE+1 where EXT_SHO_DATE = to_date ('20200714','YYYYMMDD')
    """

    Given I create input file "${OUTPUT_FILENAME_MAXDATE}" using template "esi_brs_bony_sec_cdf_maxdate_template.csv" from location "${testdata.path}/outfiles"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${BRS_PUBLISHING_DIRECTORY}" if exists:
      | ${BRS_PUBLISHING_FILE_NAME_MAXDATE}_*_1.csv |

    Then I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${BRS_PUBLISHING_FILE_NAME_MAXDATE}_${TIMESTAMP}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BONY_CDF_SUB                          |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BRS_PUBLISHING_DIRECTORY}" after processing:
      | ${BRS_PUBLISHING_FILE_NAME_MAXDATE}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${BRS_PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${BRS_PUBLISHING_FILE_NAME_MAXDATE}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |

    Then I expect reconciliation should be successful between given CSV files
      | ActualFile   | ${testdata.path}/outfiles/runtime/${BRS_PUBLISHING_FILE_NAME_MAXDATE}_${TIMESTAMP}_${VAR_SYSDATE}_1.csv |
      | ExpectedFile | ${testdata.path}/outfiles/testdata/${OUTPUT_FILENAME_MAXDATE}                                           |