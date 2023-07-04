#https://jira.pruconnect.net/browse/EISDEV-6758
#https://jira.pruconnect.net/browse/EISDEV-6761 : Additional steps for emails

# https://jira.pruconnect.net/browse/EISDEV-7467 :
# Security Analytics global file summation logic(QTY_CQTY, ORIG_FACE_CAMT, LOCAL_CURR_MKT_CAMT and BKPG_CURR_MKT_CAMT) has included
# based on portfolio, Instrument, As_of_tms and Reqstr_id for a file, if it is part of DOP Portfolios

@eisdev_6758 @dmp_regression_integrationtest @gc_interface_risk_analytics @gc_interface_dop @eisdev_6761 @eisdev_6979 @eisdev_7467

Feature: DOP CFE : Verify load and tolerance check for DOP ASORAB and AP ASPRAB

  This feature file covers the load of security analytics data for two portfolios ASPRAB and ASORAB (DOP) and performs reconciliation
  for tolerance check through the publishing of new cash file.

  Scenario: Prerequisite - Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/DOPCFE" to variable "TESTDATA_PATH"
    And I generate value with date format "MM/dd/YYYY" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/intraday/dop" to variable "PUBLISHING_DIRECTORY"
    And I assign "esi_brs_newcash" to variable "PUBLISHING_FILE_NAME"
    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
    """
    select to_char(max(GREG_DTE),'MM/DD/YYYY') as DYNAMIC_DATE from ft_t_cadp
    where cal_id = 'PRPTUAL'
    and GREG_DTE < trunc(sysdate)
    and BUS_DTE_IND = 'Y'
    and END_TMS IS NULL
    """
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "MM/dd/YYYY" to destination format "YYYYMMdd" and assign to "CURR_DATE_OUT"
    And I modify date "${DYNAMIC_DATE}" with "+0d" from source format "MM/dd/YYYY" to destination format "YYYYMMdd" and assign to "BRS_DATE_OUT"
    And I execute below query to "Clear all positions greater than SYSDATE-1"
    """
    ${TESTDATA_PATH}/sql/ClearData.sql;
    """

  Scenario: Prerequisite - Create Positions File for BRS and Security analytics file with T-1 date

    Given I create input file "BRSSECGLOBAL.xml" using template "BRSSECGLOBAL_Template.xml" from location "${TESTDATA_PATH}/infiles"

    Given I process "${TESTDATA_PATH}/infiles/testdata/BRSSECGLOBAL.xml" file with below parameters
      | FILE_PATTERN  | BRSSECGLOBAL.xml          |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |
      | BUSINESS_FEED |                           |

    Then I expect workflow is processed in DMP with total record count as "5"
    And fail record count as "0"


  Scenario Outline: Verify the values saved in BALH table with summation logic for a file

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT <DBColumnName> AS <Column>
    FROM   FT_T_BALH BALH, FT_T_ISID ISID,
            (SELECT DISTINCT ACCT_ID, BK_ID, ORG_ID FROM FT_T_ACID
            WHERE END_TMS IS NULL AND ACCT_ID_CTXT_TYP IN ('ESPORTCDE','ALTCRTSID','CRTSID') AND ACCT_ALT_ID='ASPRAB') ACID
    WHERE  BALH.ORG_ID=ACID.ORG_ID AND BALH.BK_ID=ACID.BK_ID AND BALH.ACCT_ID=ACID.ACCT_ID
    AND    BALH.INSTR_ID= ISID.INSTR_ID AND BALH.ISID_OID = ISID.ISID_OID AND ISID.END_TMS IS NULL AND ISID.ID_CTXT_TYP='BCUSIP'
    AND    ISID.ISS_ID in ('BRSRT6JS5') AND BALH.RQSTR_ID='BRSF29' AND BALH.AS_OF_TMS=TO_DATE('${DYNAMIC_DATE}','MM-dd-yyyy')
    """
    Examples:
      | Column              | DBColumnName               | Value       |
      | QTY_CQTY            | NVL(QTY_CQTY,0)            | 18340023    |
      | ORIG_FACE_CAMT      | NVL(ORIG_FACE_CAMT,0)      | 18340023    |
      | LOCAL_CURR_MKT_CAMT | NVL(LOCAL_CURR_MKT_CAMT,0) | 32935380.57 |
      | BKPG_CURR_MKT_CAMT  | NVL(BKPG_CURR_MKT_CAMT,0)  | 32935380.57 |

  Scenario: Publish outbound position File for PROD publishing profile
    Given I assign "esi_newcash.csv" to variable "REFERENCE_NEWCASH_FILE_NAME"
    And I create input file "${REFERENCE_NEWCASH_FILE_NAME}" using template "esi_newcash_template.csv" from location "${TESTDATA_PATH}/outfiles/reference"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_DOPCFE_FILE367_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${CURR_DATE_OUT}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${CURR_DATE_OUT}_1.csv |

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/reference/testdata/${REFERENCE_NEWCASH_FILE_NAME}      |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${CURR_DATE_OUT}_1.csv |

  Scenario: Generate emails for DOP - email 1 for CFE General Notification

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_EmailsDOPCFE/request.xmlt" to variable "DOPCFE_EMAILS"

    And I process the workflow template file "${DOPCFE_EMAILS}" with below parameters and wait for the job to be completed
      | IS_CONTROL_EMAIL | false                       |
      | RECIPIENTS_EMAIL | raisa.dsouza@eastspring.com |
      | SENDER_EMAIL     | raisa.dsouza@eastspring.com |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_GENNOTIF" in the below SQL query equals to "1":
    """
    Select COUNT(*) AS JBLG_GENNOTIF FROM FT_T_JBLG
    WHERE job_id='${JOB_ID}' and job_config_txt='DOP CFE General Notification Email'
    """

  Scenario: Generate emails for DOP - email 1 for CFE Control Process

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_EmailsDOPCFE/request.xmlt" to variable "DOPCFE_EMAILS"

    And I process the workflow template file "${DOPCFE_EMAILS}" with below parameters and wait for the job to be completed
      | IS_CONTROL_EMAIL | true                        |
      | RECIPIENTS_EMAIL | raisa.dsouza@eastspring.com |
      | SENDER_EMAIL     | raisa.dsouza@eastspring.com |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_GENNOTIF" in the below SQL query equals to "1":
    """
    Select COUNT(*) AS JBLG_GENNOTIF FROM FT_T_JBLG
    WHERE job_id='${JOB_ID}' and job_config_txt='DOP CFE Control Process Email'
    """

  Scenario: Reload the another file again and it should overwrite the value which is uploaded previously

    Given I create input file "BRSSECGLOBAL_Overwrite.xml" using template "BRSSECGLOBAL_Overwrite_Template.xml" from location "${TESTDATA_PATH}/infiles"

    Given I process "${TESTDATA_PATH}/infiles/testdata/BRSSECGLOBAL_Overwrite.xml" file with below parameters
      | FILE_PATTERN  | BRSSECGLOBAL_Overwrite.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS  |
      | BUSINESS_FEED |                            |

    Then I expect workflow is processed in DMP with total record count as "2"
    And fail record count as "0"

  Scenario Outline: Verify the values saved in BALH table and it should overwrite the value which is loaded previously

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT <DBColumnName> AS <Column>
    FROM   FT_T_BALH BALH, FT_T_ISID ISID,
            (SELECT DISTINCT ACCT_ID, BK_ID, ORG_ID FROM FT_T_ACID
            WHERE END_TMS IS NULL AND ACCT_ID_CTXT_TYP IN ('ESPORTCDE','ALTCRTSID','CRTSID') AND ACCT_ALT_ID='ASPRAB') ACID
    WHERE  BALH.ORG_ID=ACID.ORG_ID AND BALH.BK_ID=ACID.BK_ID AND BALH.ACCT_ID=ACID.ACCT_ID
    AND    BALH.INSTR_ID= ISID.INSTR_ID AND BALH.ISID_OID = ISID.ISID_OID AND ISID.END_TMS IS NULL AND ISID.ID_CTXT_TYP='BCUSIP'
    AND    ISID.ISS_ID in ('BRSRT6JS5') AND BALH.RQSTR_ID='BRSF29' AND BALH.AS_OF_TMS=TO_DATE('${DYNAMIC_DATE}','MM-dd-yyyy')
    """

    Examples:
      | Column              | DBColumnName               | Value |
      | QTY_CQTY            | NVL(QTY_CQTY,0)            | 200   |
      | ORIG_FACE_CAMT      | NVL(ORIG_FACE_CAMT,0)      | 200   |
      | LOCAL_CURR_MKT_CAMT | NVL(LOCAL_CURR_MKT_CAMT,0) | 20250 |
      | BKPG_CURR_MKT_CAMT  | NVL(BKPG_CURR_MKT_CAMT,0)  | 20250 |
