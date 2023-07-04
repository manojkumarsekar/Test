#https://jira.pruconnect.net/browse/EISDEV-6982
#https://collaborate.pruconnect.net/display/EISPRM/Share+class+Integration
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=ShareClass+Integration

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 14/12/2020      EISDEV-6982    Shareclass Integration
# ===================================================================================================================================================================================


@dmp_regression_integrationtest @gc_interface_shareclass @gc_interface_fundipedia
@eisdev_6982 @eisdev_6982_rdmcode_not_present

Feature: Load shareclass for RDM code not present in GS

  This feature tests the below scenarios
  1. The RDM Code received is not present in GS. Entity status type = Active.
  2. The RDM Code received is not present in GS. Entity status type = Archived.
  3. The RDM Code received is not present in GS. Entity status type = Deleted.
  4. The RDM Code received is not present in GS. Entity status type = Created.


  Scenario: Initialize all the variables and setup data

    Given I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-6982" to variable "testdata.path"
    And I assign "Shareclass_RDM_Code_Not_Present.xml" to variable "INPUT_FILE_NAME"

  Scenario: Load the share class file

    When I process "${testdata.path}/testdata/${INPUT_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                    |
      | MESSAGE_TYPE  | EIS_MT_FUNDIPEDIA_DMP_SHARECLASS_INTG |
      | BUSINESS_FEED |                                       |

    Then I expect workflow is processed in DMP with total record count as "4"
    And I expect workflow is processed in DMP with success record count as "3"
    And I expect workflow is processed in DMP with filtered record count as "1"
    
  Scenario Outline: Verify the values saved in ACST table

    Then I expect value of column "RDMCodeCount" in the below SQL query equals to "<Value>":

    """
 SELECT COUNT(*) AS RDMCodeCount FROM FT_T_ACID
  WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = '<RDMCode>')
   AND ACCT_ID_CTXT_TYP = 'RDMID'
  """

  Examples:
    | RDMCode     | Value |
    | AUTOTEST001 | 1     |
    | AUTOTEST002 | 0     |
    | AUTOTEST003 | 0     |
    | AUTOTEST004 | 0     |
