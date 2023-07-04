@fund_apps_positions @tom_4453 @tom_4482 @tom_4493 @tom_4562 @tom_4640 @tom_4452 @tom_4862
Feature: 001 | FundApps | Verify Outbound Positions for FundApps

  Scenario: Assign Variables
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Positions" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "300" to variable "workflow.max.polling.time"
    And I assign "fa" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    #Create Positions File

    And I execute below query and extract values of "T_1" into same variables
        """
        select TO_CHAR(sysdate-1, 'DD/MM/YYYY') AS T_1 from dual
        """

    And I create input file "MANGEISLPOSITN.csv" using template "MANGEISLPOSITN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles/Outbound"
      | CURR_DATE_1 | ${T_1} |

    And I create input file "TBAMEISLPOSITN.csv" using template "TBAMEISLPOSITN_Template.csv" with below codes from location "${TESTDATA_PATH}/inputfiles/Outbound"
      | CURR_DATE | DateTimeFormat:dd/MM/YYYY |

  Scenario: Load MNG Org Chart

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MNG_ORG_Chart.xlsx |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MNG_ORG_Chart.xlsx     |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL |
      | BUSINESS_FEED |                        |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load TMBAM Org Chart

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TMBAM_ORG_Chart.xlsx |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TMBAM_ORG_Chart.xlsx   |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL |
      | BUSINESS_FEED |                        |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Load MNG Fund File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MANGEISLFUNDLE.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MANGEISLFUNDLE*     |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_FUND |
      | BUSINESS_FEED |                     |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load MNG Security File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MANGEISLINSTMT.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MANGEISLINSTMT*         |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_SECURITY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  #Verification of successful File load
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load MNG Positions File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | MANGEISLPOSITN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | MANGEISLPOSITN*         |
      | MESSAGE_TYPE  | EIS_MT_MNG_DMP_POSITION |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load TBAM Fund File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TBAMEISLFUNDLE.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TBAMEISLFUNDLE*       |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_FUND |
      | BUSINESS_FEED |                       |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load TBAM Security File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TBAMEISLINSTMT.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TBAMEISLINSTMT*           |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_SECURITY |
      | BUSINESS_FEED |                           |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load TBAM Positions File


    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TBAMEISLPOSITN.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TBAMEISLPOSITN*           |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_POSITION |
      | BUSINESS_FEED |                           |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Data Verification

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "4":
      """
         SELECT COUNT(*) as BALH_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ISID.END_TMS IS NULL
         AND    ACID.END_TMS IS NULL
         AND    ISID.ISS_ID IN ('BLLHKZ1','6773812','2569286','BP9DZJ8')
         AND    BALH.RQSTR_ID IN ('MNGEOD')
         AND    ACID.ACCT_ALT_ID IN ('PPLIA','GLEM','OBCB')
         AND    ISID.ID_CTXT_TYP in ('MNGCODE')
         AND    ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
         AND    AS_OF_TMS = TO_DATE('${T_1}','DD/MM/YYYY')
      """

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "5":
      """
         SELECT COUNT(*) as BALH_COUNT
         FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
         WHERE  BALH.INSTR_ID = ISID.INSTR_ID
         AND    BALH.ACCT_ID = ACID.ACCT_ID
         AND    ISID.END_TMS IS NULL
         AND    ACID.END_TMS IS NULL
         AND    ISID.ISS_ID IN ('LU0333811072','TH3740052909','DE000C2Q0XZ9','DE000P8FWV63','FR0013404126')
         AND    BALH.RQSTR_ID IN ('MNGEOD','TMBAMEOD')
         AND    ACID.ACCT_ALT_ID IN ('I26','T09')
         AND    ISID.ID_CTXT_TYP in ('TMBAMCDE')
         AND    ACID.ACCT_ID_CTXT_TYP = 'CRTSID'
         AND    AS_OF_TMS = TO_DATE('${VAR_SYSDATE}','YYYYMMDD')
      """

  Scenario: Load TR DSS TNC

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | gs_tnc.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | gs_tnc*                       |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Load TR DSS COMP

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/Outbound" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | gs_comp.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | gs_comp*                 |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      """

  Scenario: Publish File

  #Extract Data
    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_POSITION_SUB |
      | XML_MERGE_LEVEL      | 2                                |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |