#https://jira.pruconnect.net/browse/EISDEV-3743
#https://collaborate.pruconnect.net/display/EISTOM/Portfolio+Average+Rating
#https://jira.pruconnect.net/browse/EISDEV-6111 - publishing filter query fix for missing parantheis
#https://jira.pruconnect.net/browse/EISDEV-6758: Adding BCUSP to main_entity_id_ctxt_typ due to change in MDX
#EISDEV_6273 : Handling of Null Identifiers
#EISDEV_7176 : Rating Effective Tms is mapped from AS_OF_TMS instead of PXS_DATE. Updating data file with AS_OF_TMS = PXS_DATE
#EISDEV_7353 : Load and publish PHKL_IP_RATING for Portfolio Average rating

@gc_interface_ratings @gc_interface_risk_analytics @ignore @to_be_fixed_eisdev_7462
@dmp_regression_integrationtest
@eisdev_3743 @eisdev_6111 @eisdev_6758 @eisdev_6273 @eisdev_7176 @eisdev_7353
Feature: Test BRS custom ratings load from risk analytics file and publish to BRS for aggregation of ratings at portfolio level

  This feature tests the load of six new ratings from risk analytics file for insert, update and error scenario and then publish the same.

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-3743" to variable "testdata.path"
    And I assign "portfolio_avgrating_allvalid.xml" to variable "INPUT_FILENAME1"
    And I assign "portfolio_avgrating_update.xml" to variable "INPUT_FILENAME2"
    And I assign "portfolio_avgrating_allnullidentifiers.xml" to variable "INPUT_FILENAME3"
    And I assign "portfolio_avgrating_allerros.xml" to variable "INPUT_FILENAME4"
    And I assign "/dmp/out/brs/8b_ratings" to variable "PUBLISHING_DIRECTORY"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: Read Instrument identifiers and clear the Ratings for the selected instrument
  Read ISIN, BCUSIP, SEDOL and EISLSTID from FT_T_ISID table at runtime.

    And  I execute below query and extract values of "BCUSIPVAL;ISINVAL;SEDOLVAL;EISLSTIDVAL" into same variables
    """
    SELECT isid.iss_id AS ISINVAL,
    (SELECT iss_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND isid.instr_id = instr_id AND end_tms IS NULL) as BCUSIPVAL,
    (SELECT iss_id FROM ft_t_isid WHERE id_ctxt_typ = 'SEDOL' AND isid.instr_id = instr_id AND end_tms IS NULL) as SEDOLVAL,
    (SELECT iss_id FROM ft_t_isid WHERE id_ctxt_typ = 'EISLSTID' AND isid.instr_id = instr_id AND end_tms IS NULL) as EISLSTIDVAL
    FROM ft_t_isid isid, ft_t_balh balh, ft_t_acgp acgp, ft_t_acgr acgr
    WHERE isid.instr_id = balh.instr_id
    AND isid.id_ctxt_typ = 'ISIN'
    AND balh.acct_id = acgp.acct_id
    AND acgp.prnt_acct_grp_oid = acgr.acct_grp_oid
    AND acgr.acct_grp_id  = 'SGBFI'
    AND (SELECT count(1) FROM ft_t_isid WHERE id_ctxt_typ = 'SEDOL' AND isid.instr_id = instr_id AND end_tms IS NULL) = 1
    AND (SELECT count(1) FROM ft_t_isid WHERE id_ctxt_typ = 'EISLSTID' AND isid.instr_id = instr_id AND end_tms IS NULL) = 1
    AND (SELECT count(1) FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND isid.instr_id = instr_id AND end_tms IS NULL) = 1
    AND rownum=1
    """

    #Reading instr_id into variable for further validation purpose
    And I execute below query and extract values of "INSTRID" into same variables
    """
    SELECT instr_id as INSTRID FROM ft_t_isid
    WHERE id_ctxt_typ = 'BCUSIP'
    AND iss_id ='${BCUSIPVAL}'
    AND end_tms IS NULL
    """

    And I execute below query to "Clear data for the given instruments from FT_T_ISRT"
    """
    DELETE FROM ft_t_isrt
    WHERE instr_id = '${INSTRID}'
    """

  Scenario: Load Risk Analytics files and verify data is successfully processed

    Given I create input file "${INPUT_FILENAME1}" using template "portfolio_avgrating_allvalid_template.xml" from location "${testdata.path}/inputfiles"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME1}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario Outline: Verify Rating code for Rating set <RatingSet> is successfully Inserted

    Then I expect value of column "rtng_cde" in the below SQL query equals to "<Expected_RatingCode>":
    """
    select rtng_cde FROM ft_t_isrt
    WHERE instr_id IN ('${INSTRID}')
    AND end_tms IS NULL
    AND rtng_set_oid = '<RatingSet>'
    """
    Examples: Data Verifications having value not zero
      | RatingSet  | Expected_RatingCode |
      | ESICOMPHK  | BBB                 |
      | ESCMPWRSTI | BB+                 |
      | ESCMPSECND | B                   |
      | ESCMPBSTAO | A+                  |
      | ESICOMPTCR | A                   |
      | ESWARFRATS | CC                  |
      | PHKLIPRTNG | CCC+                |

  Scenario: Publish BRS file for ratings after loading the data

    Given I assign "portfolio_avgrating_allvalid" to variable "PUBLISHING_FILE_NAME"
    And I assign "portfolio_avgrating_allvalid_template.csv" to variable "OUTPUT_TEMPLATENAME"
    And I assign "portfolio_avgrating_allvalid_expected" to variable "OUTPUT_EXPECTED"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PORTFAVG_RATING_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I create input file "${OUTPUT_EXPECTED}_${VAR_SYSDATE}.csv" using template "${OUTPUT_TEMPLATENAME}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${OUTPUT_EXPECTED}_${VAR_SYSDATE}.csv       |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Load Risk Analytics files to update the existing Ratings

    Given I create input file "${INPUT_FILENAME2}" using template "portfolio_avgrating_update_template.xml" from location "${testdata.path}/inputfiles"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME2}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario Outline: Verify Rating code for Rating set <RatingSet> is successfully Updated

    Then I expect value of column "rtng_cde" in the below SQL query equals to "<Expected_RatingCode>":
    """
    select rtng_cde FROM ft_t_isrt
    WHERE instr_id IN ('${INSTRID}')
    AND end_tms IS NULL
    AND rtng_set_oid = '<RatingSet>'
    """
    Examples: Data Verifications having value not zero
      | RatingSet  | Expected_RatingCode |
      | ESICOMPHK  | D                   |
      | ESCMPWRSTI | C                   |
      | ESCMPSECND | NR                  |
      | ESCMPBSTAO | B+                  |
      | ESICOMPTCR | A                   |
      | ESWARFRATS | CCC+                |
      | PHKLIPRTNG | AAA                 |

  Scenario: Publish BRS file for ratings after Updating Ratings

    Given I assign "portfolio_avgrating_update" to variable "PUBLISHING_FILE_NAME"
    And I assign "portfolio_avgrating_update_expected" to variable "OUTPUT_EXPECTED"
    And I assign "portfolio_avgrating_update_template.csv" to variable "OUTPUT_TEMPLATENAME"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PORTFAVG_RATING_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I create input file "${OUTPUT_EXPECTED}_${VAR_SYSDATE}.csv" using template "${OUTPUT_TEMPLATENAME}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${OUTPUT_EXPECTED}_${VAR_SYSDATE}.csv       |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Load Risk Analytics files - All rating values are to be ignored as per logic - null identifiers scenario

    And I create input file "${INPUT_FILENAME3}" using template "portfolio_avgrating_allnullidentifiers_template.xml" from location "${testdata.path}/inputfiles"
    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME3} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME3}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario Outline: Verify Rating code for <RatingSet> is successfully Updated for Null Identifiers

    Then I expect value of column "rtng_cde" in the below SQL query equals to "<Expected_RatingCode>":
    """
    select rtng_cde FROM ft_t_isrt
    WHERE instr_id IN ('${INSTRID}')
    AND end_tms IS NULL
    AND rtng_set_oid = '<RatingSet>'
    """
    Examples: Data Verifications having value not zero
      | RatingSet  | Expected_RatingCode     |
      | ESICOMPHK  | N/A Composite HK Rating |
      | ESCMPWRSTI | Fund                    |
      | ESCMPSECND | Null                    |
      | ESCMPBSTAO | N/A Composite Best      |
      | ESICOMPTCR | No Rating               |
      | ESWARFRATS | Cash                    |
      | PHKLIPRTNG | N/A PHKL_IP_RATING      |

  Scenario: Publish BRS file for ratings after Updating Ratings to null identifier

    Given I assign "portfolio_avgrating_nullidentifiers" to variable "PUBLISHING_FILE_NAME"
    And I assign "portfolio_avgrating_nullidentifiers_expected" to variable "OUTPUT_EXPECTED"
    And I assign "portfolio_avgrating_nullidentifier_template.csv" to variable "OUTPUT_TEMPLATENAME"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PORTFAVG_RATING_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I create input file "${OUTPUT_EXPECTED}_${VAR_SYSDATE}.csv" using template "${OUTPUT_TEMPLATENAME}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${OUTPUT_EXPECTED}_${VAR_SYSDATE}.csv       |
      | File2 | ${testdata.path}/outfiles/runtime/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: Load Risk Analytics files - All invalid rating values - error scenario

    And I create input file "${INPUT_FILENAME4}" using template "portfolio_avgrating_allerrors_template.xml" from location "${testdata.path}/inputfiles"
    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME4} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME4}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I extract new job id from jblg table into a variable "JOB_ID"

  Scenario Outline: Verify Exceptions are captured for each Rating set <RatingSet> variation

    Then I expect value of column "<RatingSet>" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) As <RatingSet> FROM ft_t_ntel
    WHERE NOTFCN_STAT_TYP = 'OPEN'
    AND NOTFCN_ID = '12'
    AND APPL_ID = 'CONCTNS'
    AND PART_ID = 'NESTED'
    AND MSG_SEVERITY_CDE = 40
    AND MAIN_ENTITY_ID = '${BCUSIPVAL}-AHP5WB'
    AND MAIN_ENTITY_ID_CTXT_TYP = 'BCUSIP-CRTSID'
    AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    AND PARM_VAL_TXT = '<Expected_Text>'
    """
      #Throw Error verification
    Examples: Data Verifications having value not zero
      | RatingSet  | Expected_Text                   |
      | ESICOMPHK  | ESCMPHK BBB+- BRS RatingValue   |
      | CMPWRSTI   | CMPWRSTI AAHYA BRS RatingValue  |
      | CMPSECND   | CMPSECND BB-*-- BRS RatingValue |
      | CMPBSTAO   | CMPBSTAO TC BRS RatingValue     |
      | ESCMPTCR   | ESCMPTCR A-+ BRS RatingValue    |
      | WARFRATS   | WARFRATS NRA BRS RatingValue    |
      | PHKLIPRTNG | PHKLIPRT AAA+- BRS RatingValue  |

