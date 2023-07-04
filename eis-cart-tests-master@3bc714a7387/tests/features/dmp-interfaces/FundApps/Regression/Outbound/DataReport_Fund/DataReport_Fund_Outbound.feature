#https://jira.intranet.asia/browse/TOM-4697
#https://collaborate.intranet.asia/display/FUNDAPPS/23.+Outbound+FundApps+Portfolio+File
#EISDEV-5511 : Removed M&G Flag from the template

@gc_interface_funds
@dmp_regression_integrationtest
@tom_4697 @dmp_fundapps_regression @fund_apps_fund_outbound  @tom_4848 @tom_4988 @tom_5000 @eisdev_5511
Feature: TOM-4697: Outbound Portfolio datareports file for Fundapps (Golden Source)

  Scenario: Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/DataReport_Fund" to variable "testdata.path"
    And I assign "/dmp/out/eis/datareports" to variable "PUBLISHING_DIRECTORY"
    And I assign "300" to variable "workflow.max.polling.time"
    And I assign "Fund_dataReport" to variable "PUBLISHING_FILE_NAME"
    And I assign "Fund_DataReport_expected" to variable "MASTER_FILE"
    And I assign "EIMKEISLFUNDLE_DATAREPORT" to variable "INPUTFILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: TC_1: Load pre-requisite Fund(EIMK)Data file

    When I copy files below from local folder "${testdata.path}/InputFiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME}.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME}.csv |
      | MESSAGE_TYPE  | EIS_MT_EIMK_DMP_FUND  |
      | BUSINESS_FEED |                       |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_2:Verification data for Account Statistics where SSH flag,MNG flag & PPMA flag ='Y'

    Then I expect value of column "VERIFYFlag" in the below SQL query equals to "3":
    """
	SELECT
	count(*) as VERIFYFlag
	FROM FT_T_ACST
    WHERE END_TMS IS NULL
    AND STAT_CHAR_VAL_TXT ='Y'
    AND STAT_DEF_ID  in ('SSHFLAG','MNGFLAG','PPMFLAG')
     AND ACCT_ID IN
                  (
                    SELECT ACCT_ID
                    FROM FT_T_ACID
                    WHERE ACCT_ALT_ID ='E17822'
                    AND ACCT_ID_CTXT_TYP='CRTSID'
                    AND END_TMS IS NULL
                   )
	"""

  Scenario: TC_3: Check if published file contains all the records which were loaded for DataReport fund

  #Extract Data

    Given I assign "Fund_dataReport" to variable "PUBLISHING_FILE_NAME"

    And I assign "/dmp/out/eis/datareports" to variable "PUBLISHING_DIR"

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_DATAREPORTS_FUND_SUB |
      | COLUMN_SEPARATOR     | ,                                   |
      | COLUMN_TO_SORT       | 3                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_4: Check if published file contains all the records which were loaded for Fundapps SSDR Funddata

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/template/${MASTER_FILE}.csv" should exist in file "${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory
