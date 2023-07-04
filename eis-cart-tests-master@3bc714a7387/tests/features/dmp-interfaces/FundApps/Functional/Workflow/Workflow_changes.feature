#https://jira.intranet.asia/browse/TOM-4426
#https://collaborate.intranet.asia/display/FUNDAPPS/SSDR-RCRLBU-POSITION-file

@tom_4426 @dmp_rcrlbu_mng_positions  @dmp_fund_apps @fund_apps_positions @tom_4170
Feature: TOM-4426: Positions RCRLBU MANDG file load (Golden Source)

  1) Positions creation on security and fund combination in DMP through any feed file load from RCRLBU.
  2) As the security and fund data is not set up in the database yet, we are temporarily setting up the required identifiers through inserts. These will be replaced by file load steps once security and fund are completed.

  Scenario: TC_1: Load pre-requisite ORG Chart Data before file

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Workflow" to variable "testdata.path"
    And I assign "300" to variable "workflow.max.polling.time"
    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MNG_ORG_CHART.xlsx |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNG_ORG_CHART.xlsx     |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL |
      | BUSINESS_FEED |                        |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_2: Load pre-requisite Fund Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MNGFUND.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNGFUND*            |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_FUND |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: TC_3: Load pre-requisite Security Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MNGEISINST.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNGEISINST*             |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SECURITY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario:TC_4:Load pre-requisite Reuters Data before file

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | gs_com00003742.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | gs_com00003742*          |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario:TC_5: clear data

    Given I execute below query
    """
    ${testdata.path}/sql/Clear_balh.sql
    """

  Scenario: TC_6: Create Position file with Position_Date as SYSDATE and Load into DMP
    Given I assign "MNGPOSITION.csv" to variable "INPUT_FILENAME"
    And I assign "MNGPosition_template.csv" to variable "INPUT_TEMPLATENAME"

    And I assign "MERGE_DATA" to variable "PUBLISHING_FILE_NAME"
    And I assign "MERGE_DATA_template.csv" to variable "PUBLISHING_TEMPLATENAME"


    And I generate value with date format "ddMMYYYY" and assign to variable "VAR_SYSDATE"
    #And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE2"
    And I assign "${PUBLISHING_FILE_NAME}*_1.xml" to variable "PUBLISHING_FILE_FULL_NAME"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIR"
    And I assign "MERGE_DATA.xml" to variable "MASTER_FILE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_FULL_NAME} |


  Scenario:TC_7: Generate input data from template

    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "ddMMYYYY" to destination format "dd/MM/YYYY" and assign to "DYNAMIC_DATE"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/inputfiles"
      |  |  |


  Scenario: TC_8: Load positon file

    When I copy files below from local folder "${testdata.path}/inputfiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_POSITION |


  Scenario: TC_9: Triggering Publishing Wrapper Event for XML file


    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_POSITION_SUB |
      | XML_MERGE_LEVEL      | 2                                |

#  Scenario: TC_10: I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_PublishingWrapper/request.xmlt" and save the response to file "testout/evidence/gswf/resp/response1.xml"
#    Then I extract value from the XML file "testout\evidence\gswf\request1.xml" with xpath "//*[local-name() = 'flowResultId']" to variable "flowResultId"
#
#    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
#    """
#    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
#    """
