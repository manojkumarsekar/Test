#https://jira.pruconnect.net/browse/EISDEV-6982
#https://collaborate.pruconnect.net/display/EISPRM/Share+class+Integration
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=ShareClass+Integration

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 14/12/2020      EISDEV-6982    Shareclass Integration
# ===================================================================================================================================================================================


@dmp_regression_integrationtest @gc_interface_shareclass @gc_interface_fundipedia
@eisdev_6982 @eisdev_6982_sc_pfl_rl

Feature: Load shareclass and portfolio code relationship file

  This feature tests the below scenarios
  1. No TWHedgePortfolioCode received in the file. Only shareclass-portfolio relationship created
  2. TWHedgePortfolioCode received in the file. Both shareclass and hedgeportfolio relationship created


  Scenario: Initialize all the variables and setup data

    Given I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-6982" to variable "testdata.path"
    And I assign "Shareclass_Portfolio_RelationShip_Prerequisite.xml" to variable "PREREQUISITE_FILE_NAME"
    And I assign "Shareclass_Portfolio_RelationShip.xml" to variable "INPUT_FILE_NAME"

  Scenario: Load the share class file as prerequisite

    When I process "${testdata.path}/testdata/${PREREQUISITE_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${PREREQUISITE_FILE_NAME}             |
      | MESSAGE_TYPE  | EIS_MT_FUNDIPEDIA_DMP_SHARECLASS_INTG |
      | BUSINESS_FEED |                                       |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Load the share class file as prerequisite

    When I process "${testdata.path}/testdata/${INPUT_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                   |
      | MESSAGE_TYPE  | EIS_MT_FUNDIPEDIA_DMP_SHARECLASS_REL |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario Outline: Verify the relationship type shareclass for records created

    Then I expect value of column "RlTypCount" in the below SQL query equals to "1":

    """
    SELECT COUNT(*) AS RlTypCount
    FROM FT_T_ACCR
    WHERE ACCT_ID IN
      (SELECT ACCT_ID FROM FT_T_ACID
       WHERE ACCT_ALT_ID = '<RDMCode>')
     AND REP_ACCT_ID IN
      (SELECT ACCT_ID FROM FT_T_ACID
       WHERE ACCT_ALT_ID = 'ALAEIF')
     AND RL_TYP = 'SHRCLASS'
    """

    Examples:
      | RDMCode |
      | ALAPEFD |
      | ALAPEFA |

  Scenario Outline: Verify the relationship type shareclass for records created

    Then I expect value of column "RlTypCount" in the below SQL query equals to "<Count>":

    """
    SELECT COUNT(*) AS RlTypCount
    FROM FT_T_ACCR
    WHERE ACCT_ID IN
      (SELECT ACCT_ID FROM FT_T_ACID
       WHERE ACCT_ALT_ID = 'ALAEIF')
     AND REP_ACCT_ID IN
      (SELECT ACCT_ID FROM FT_T_ACID
       WHERE ACCT_ALT_ID = '<RDMCode>')
     AND RL_TYP = 'HEDGE'
    """

    Examples:
      | RDMCode | Count |
      | ALAPEFD | 0     |
      | ALAPEFA | 1     |