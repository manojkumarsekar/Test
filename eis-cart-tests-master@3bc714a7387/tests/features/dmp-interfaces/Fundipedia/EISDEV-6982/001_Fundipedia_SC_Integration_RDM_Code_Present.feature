#https://jira.pruconnect.net/browse/EISDEV-6982
#https://collaborate.pruconnect.net/display/EISPRM/Share+class+Integration
#https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=ShareClass+Integration

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 14/12/2020      EISDEV-6982    Shareclass Integration
# ===================================================================================================================================================================================


@dmp_regression_integrationtest @gc_interface_shareclass @gc_interface_fundipedia
@eisdev_6982 @eisdev_6982_rdmcode_present @eisdev_7283

Feature: Load shareclass for RDM code already present in GS

  This feature tests the below scenarios
  1. The RDM Code received is present in GS. Entity status type = Active.
  2. The RDM Code received is present in GS. Entity status type = Archived.
  3. The RDM Code received is present in GS. Entity status type = Deleted.
  4. The RDM Code received is present in GS. Entity status type = Created.


  Scenario: Initialize all the variables and setup data

    Given I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-6982" to variable "testdata.path"
    And I assign "Shareclass_RDM_Code_Present.xml" to variable "INPUT_FILE_NAME"

    And I execute below query to "Activate any shareclass that might have been inactivated"
    """
    ${testdata.path}/sql/ActivateInactiveShareclass.sql
    """

  Scenario: Load the share class file

    When I process "${testdata.path}/testdata/${INPUT_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                    |
      | MESSAGE_TYPE  | EIS_MT_FUNDIPEDIA_DMP_SHARECLASS_INTG |
      | BUSINESS_FEED |                                       |

    Then I expect workflow is processed in DMP with total record count as "4"
    And I expect workflow is processed in DMP with success record count as "3"
    And I expect workflow is processed in DMP with filtered record count as "1"


  Scenario Outline: Verify the account status for each of the record

    Then I expect value of column "ACCOUNT_STATUS" in the below SQL query equals to "<Acct_Status>":

    """
    SELECT ACCT_STAT_TYP AS ACCOUNT_STATUS
    FROM FT_T_ACCT
    WHERE ACCT_ID IN
      (SELECT ACCT_ID FROM FT_T_ACID
       WHERE ACCT_ALT_ID = '<RDMCode>')
    """

    Examples:
      | Acct_Status | RDMCode  |
      | OPEN        | ALDAEFE  |
      | INACTIVE    | ALDAEEDY |
      | INACTIVE    | ALEMAFE  |

  Scenario Outline: Verify the values saved in ACID table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":

  """
  SELECT ACCT_ALT_ID AS <Column> FROM FT_T_ACID
  WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = 'ALDAEFE')
   AND ACCT_ID_CTXT_TYP = '<ID_Ctxt_Type>'
  """

    Examples:
      | Column       | ID_Ctxt_Type | Value   |
      | RDMCode      | RDMID        | ALDAEFE |
      | ShareclassID | FSHRCLSID    | 291     |

  Scenario Outline: Verify the values saved in ACCT table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":

  """
  SELECT <DBColumnName> AS <Column> FROM FT_T_ACCT
  WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = 'ALDAEFE')
  """

    Examples:
      | Column               | DBColumnName  | Value                                                                        |
      | FullShareClassName   | ACCT_NME      | Eastspring Investments - Developed and Emerging Asia Equity Fund Class E USD |
      | FullShareClassName   | ACCT_DESC     | Eastspring Investments - Developed and Emerging Asia Equity Fund Class E USD |
      | AccountStatus        | ACCT_STAT_TYP | OPEN                                                                         |
      | BKID                 | BK_ID         | EIS                                                                          |
      | OrgID                | ORG_ID        | EIS                                                                          |
      | AccountType          | ACTP_ACCT_TYP | SHRCLASS                                                                     |
      | ACTPOrgID            | ACTP_ORG_ID   | EIS                                                                          |
      | DataStatType         | DATA_STAT_TYP | ACTIVE                                                                       |
      | DataSrcID            | DATA_SRC_ID   | FPEDIA                                                                       |
      | ShareClassLaunchDate | ACCT_OPEN_DTE | 2016-05-19 00:00:00                                                          |


  Scenario: Verify the values saved in INCL table

    Then I expect value of column "ShareClassExtension" in the below SQL query equals to "E":

  """
  SELECT CL_NME AS ShareClassExtension FROM FT_T_INCL
  WHERE CLSF_OID IN
    (SELECT CLSF_OID FROM FT_T_ACCL
    WHERE ACCT_ID IN
      (SELECT ACCT_ID FROM FT_T_ACID
       WHERE ACCT_ALT_ID = 'ALDAEFE')
     AND INDUS_CL_SET_ID='PORTSHRCLS'
     AND CL_VALUE = 'E')
   AND CL_VALUE = 'E'
   AND INDUS_CL_SET_ID='PORTSHRCLS'
  """

  Scenario Outline: Verify the values saved in FNCH table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":

  """
  SELECT <DBColumnName> AS <Column> FROM FT_T_FNCH
  WHERE ACCT_ID IN
     (SELECT ACCT_ID FROM FT_T_ACID
      WHERE ACCT_ALT_ID = 'ALDAEFE')
  """

    Examples:
      | Column               | DBColumnName       | Value               |
      | ShareClassCurrency   | FUND_CURR_CDE      | USD                 |
      | ShareClassLaunchDate | FUND_INCEPTION_DTE | 2016-05-19 00:00:00 |

  Scenario Outline: Verify the values saved in <Tablename> table

    Then I expect value of column "<Column>" in the below SQL query equals to "1":

  """
  <Query>
  """

    Examples:
      | Tablename | Column                  | Query                                                                                                                                                                                                                                                                            |
      | ABMR      | ShareClassBenchmarkCode | SELECT COUNT(*) AS ShareClassBenchmarkCode FROM FT_T_ABMR WHERE BNCH_OID IN (SELECT BNCH_OID FROM FT_T_BNID WHERE BNCHMRK_ID = 'BM_00224'AND BNCHMRK_ID_CTXT_TYP = 'RDMCODE') AND RL_TYP = 'PRIMARY' AND ACCT_ID IN(SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ALDAEFE') |
      | AISR      | ISINCode                | SELECT COUNT(*) AS ISINCode FROM FT_T_AISR WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'LU1410579525') AND ACCT_ISSU_RL_TYP = 'SECSHRECLS'                                                                                                                  |

  Scenario Outline: Verify the values saved in ACST table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":

  """
  SELECT STAT_CHAR_VAL_TXT AS <Column> FROM FT_T_ACST
  WHERE ACCT_ID IN
     (SELECT ACCT_ID FROM FT_T_ACID
      WHERE ACCT_ALT_ID = 'ALDAEFE')
   AND STAT_DEF_ID = '<StatDefID>'
  """

    Examples:
      | Column      | Value | StatDefID |
      | FundId      | 1     | FFUNDID   |
      | BNPPerfFlag | N     | PORTFLAG  |

  Scenario Outline: Verify the values saved in ACGU table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":

  """
  SELECT GU_ID AS <Column> FROM FT_T_ACGU
  WHERE ACCT_ID IN
     (SELECT ACCT_ID FROM FT_T_ACID
      WHERE ACCT_ALT_ID = 'ALDAEFE')
   AND ACCT_GU_PURP_TYP = '<Purptype>'
   AND GU_TYP = 'COUNTRY'
   AND GU_CNT = '1'
  """

    Examples:
      | Column                  | Value | Purptype |
      | Domicile                | LU    | DOMICILE |
      | ShareClassExtensionGUID | SG    | INVLOCTN |