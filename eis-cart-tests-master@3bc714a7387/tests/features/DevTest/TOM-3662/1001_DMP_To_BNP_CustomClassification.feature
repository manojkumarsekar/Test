#https://jira.intranet.asia/browse/TOM-3662
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45862291
#TOM-4351 - remove future dated positions prior to position load; possibly loaded by previous feature file (e.g. tom_3604).
#TOM-4357 - remove future dated positions' statistics prior to the positions themselves (avoid FK constraint exception)
# https://jira.pruconnect.net/browse/EISDEV-6171 :Excluding "INTERNAL_RATING" column from recon to avoid recon failures, since ratings changes frequently

@dmp_regression_unittest
@tom_3954 @tom_3662 @tom_3783 @dmp_interfaces @tom_4351 @tom_4357
Feature: Load the Security, Positions, Risk Analytics and generate the BNP Custom Classifications and validate the below condition

  GAA_SECTOR_ASSET_CLASS Column logic:
  If portfolio codes is a group of MY Fund (as specified in filtration criteria) AND SM_SEC_GROUP = "BND" then
  populate this field as "Fixed Income"
  else
  Follow the existing logic

  GAA_SECTOR_REGION column logic:
  If portfolio codes is a group of MY Fund (as specified in filtration criteria)  AND ESI_MY_UPC = "Govt of Msia" then
  populate this field as "Government"
  else If portfolio codes is a group of MY Fund (as specified in filtration criteria)  AND ESI_MY_UPC is not equal to "Govt of Msia" then
  populate this field as "Corporate"
  else
  Follow the existing logic

  New Addition on 25/10/2018 : (Changes done as part of TOM-3783 - https://jira.intranet.asia/browse/TOM-3783)
  IF Investment Team = 'MAS' then use ESI_MAS_SECTOR tag to populate classification
  ELSE
  Follow the existing logic

  Below Steps are followed to validate this testing
  1. Load the BRS Security
  2. Load the BRS Position
  3. Load the BRS Risk Analytics for APAC
  4. Publish the BNP Custom Classifications
  5. Compare the publish file with expected file

  Scenario: TC1: Create Security F10 file with AS_OF_DATE as SYSDATE and Load into DMP

    Given I assign "Asia_Security_F10_Template.xml" to variable "SECURITY_INPUT_TEMPLATENAME"
    And I assign "Asia_Security_F10.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3662" to variable "testdata.path"

    And I create input file "${SECURITY_INPUT_FILENAME}" using template "${SECURITY_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE | DateTimeFormat:YYYY-MM-dd |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND JOB_STAT_TYP ='CLOSED'
      """

    Then I pause for 5 seconds

    #This check to verify FT_T_ISST table rowcount equal to 3 for loaded ISIN with and STAT_CHAR_VAL_TXT equal to "Govt of Msia"
    Then I expect value of column "ISST_COUNT" in the below SQL query equals to "3":
    """
      SELECT COUNT (*) AS ISST_COUNT
      FROM  FT_T_ISST
      WHERE END_TMS IS NULL
      AND   STAT_DEF_ID = 'BRSSUBMY'
      AND   STAT_CHAR_VAL_TXT = 'Govt of Msia'
      AND   INSTR_ID IN ( SELECT INSTR_ID FROM  FT_T_ISID
                                          WHERE ISS_ID IN ('MYBGT1300016', 'MYBPN1400265', 'MYBVX1603212')
                                          AND   ID_CTXT_TYP = 'ISIN'
                                          AND   END_TMS IS NULL
                         )
      """

  Scenario: TC_2: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I assign "Asia_Position_14_Template.xml" to variable "POSITION_INPUT_TEMPLATENAME"
    And I assign "Asia_Position_14.xml" to variable "POSITION_INPUT_FILENAME"

    # Clear any future data positions (from previous feature files)
    And I execute below query
    """
    DELETE ft_t_bhst WHERE balh_oid IN (SELECT balh_oid FROM ft_t_balh WHERE as_of_tms > SYSDATE);
    DELETE ft_t_balh WHERE as_of_tms > SYSDATE;
    """

    And I create input file "${POSITION_INPUT_FILENAME}" using template "${POSITION_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${POSITION_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${POSITION_INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND JOB_STAT_TYP ='CLOSED'
      """

    Then I pause for 5 seconds

     #This check to verify BALH table rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "5":
    """
    SELECT count(distinct ISID.ISS_ID) AS BALH_COUNT
    FROM   FT_T_BALH BALH, FT_T_ISID ISID
    WHERE  BALH.INSTR_ID = ISID.INSTR_ID
    AND    ISID.ID_CTXT_TYP = 'ISIN'
    AND    ISID.ISS_ID IN ('MYBGT1300016','MYBPN1400265','MYBGO1500046','MYBVX1603212','MYBVN1401535')
    AND    ISID.END_TMS IS NULL
    AND    ISID.ISS_ID IS NOT NULL
    AND    BALH.RQSTR_ID = 'BRSEOD'
	AND    BALH.AS_OF_TMS IN (SELECT  MAX(AS_OF_TMS) FROM FT_T_BALH WHERE RQSTR_ID = 'BRSEOD')
    """

  Scenario: TC_3:Create APAC Risk Analytics file with RISK_ASOF_DATE as SYSDATE and Load into DMP

    Given I assign "Asia_Security_Analytics_APAC_Template.xml" to variable "RISK_ANALYTICS_INPUT_TEMPLATENAME"
    And I assign "Asia_Security_Analytics_APAC.xml" to variable "RISK_ANALYTICS_INPUT_FILENAME"

    And I create input file "${RISK_ANALYTICS_INPUT_FILENAME}" using template "${RISK_ANALYTICS_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | RISK_ASOF_DATE | DateTimeFormat:M/dd/YYYY |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RISK_ANALYTICS_INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${RISK_ANALYTICS_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS        |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' AND JOB_STAT_TYP ='CLOSED'
      """

    Then I pause for 5 seconds

  Scenario: TC_4: Publish the BNP Custom Classifications

    Given I assign "bnp_custom_classification" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "PUBLISING_FILE_FULL_NAME"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISING_FILE_FULL_NAME} |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME   | ${PUBLISHING_FILE_NAME}.csv     |
      | SUBSCRIPTION_NAME      | EIS_DMP_TO_BNP_REF_SECURITY_SUB |
      | PUBLISHING_DESTINATION | directory                       |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISING_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISING_FILE_FULL_NAME} |


  Scenario: TC_5: Check the file format
    Then I expect file "${testdata.path}/outfiles/actual/${PUBLISING_FILE_FULL_NAME}" should have below columns
      | "SECURITY_IDENTIFIER","PORTFOLIO_IDENTIFIER","AS_OF","COUNTRY","CURRENCY","CUSIP","GAA_SECTOR_ASSET_CLASS","GAA_SECTOR_REGION","GAA_COUNTRY","GAA_TYPE","INTERNAL_RATING","RISK_COUNTRY","SM_SEC_GROUP","SM_SEC_TYPE","SEC_DESC2","ESJE1" |

  Scenario: TC_6: Compare the publish file with expected file
    Given I assign "bnp_custom_classification_template.csv" to variable "PUBLISH_EXPECTED_TEMPLATENAME"
    And I assign "bnp_custom_classification.csv" to variable "PUBLISH_EXPECTED"

    And I create input file "${PUBLISH_EXPECTED}" using template "${PUBLISH_EXPECTED_TEMPLATENAME}" with below codes from location "${testdata.path}/outfiles/expected"
      | PUB_AS_OF_DATE | DateTimeFormat:dd-MM-YYYY |

    When I capture current time stamp into variable "recon.timestamp"
    And I exclude below columns from CSV file while doing reconciliations
      | INTERNAL_RATING |
    Then I expect each record in file "${testdata.path}/outfiles/expected/testdata/bnp_custom_classification.csv" should exist in file "${testdata.path}/outfiles/actual/${PUBLISING_FILE_FULL_NAME}" and exceptions to be written to "${testdata.path}/outfiles/actual/exceptions_${recon.timestamp}.csv" file
