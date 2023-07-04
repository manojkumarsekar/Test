#https://jira.intranet.asia/browse/TOM-2487
#https://jira.pruconnect.net/browse/EISDEV-5404: Changes in input data format for CDF (From XML (File10) to CSV - new file from BRS)
#https://jira.pruconnect.net/browse/EISDEV-6080: Changes in date format and storing Tag/Value Full Name instead of Tag/Value
#https://jira.pruconnect.net/browse/EISDEV-7052: Changes in view to only pick up records from loaded files

@gc_interface_cdf @gc_interface_user_group
@dmp_regression_integrationtest
@tom_2847 @eisdev_5404 @eisdev_6080 @eisdev_7052
Feature: To test CDF attributes updated by same or different department.

  As a User,
  I expect, I should be able to Load, Modify CDF tags and exceptions to be thrown for missing CDF tags

  We are covering below scenarios as a part of this feature:
  Loading file1 to test
  1. CDF Tags gets loaded successfully and exceptions to be thrown for missing CDF tags
  2. FT_T_IDMV table gets updated with missing CDF tags , so that Users can set up CDF through UI in future
  Loading file2 to test
  1. CDF Tag can be modified to new value
  Loading file3 to test
  1. CDF Tag can be set as NULL and get end-dated
  Verifying email is sent for same and cross-department changes


  Scenario: Assign Variables

    Given I assign "esi_users_groups_20190823.xml" to variable "INPUT_USERGROUP"
    And I assign "sm_2847_TC_1.csv" to variable "INPUT_FILENAME_1"
    And I assign "sm_2847_TC_2.csv" to variable "INPUT_FILENAME_2"
    And I assign "sm_2847_TC_3.csv" to variable "INPUT_FILENAME_3"

    And I assign "tests/test-data/dmp-interfaces/UserGroup" to variable "testdata.path"

  Scenario: Clear the User Group Data as a Prerequisite
  Clear data FT_T_FPRO, FT_T_FPGU, FT_T_GNST, FT_T_UDF1 and FT_T_IDMV

    Given I execute below query to "Clear existing data for clean data setup"
    """
    ${testdata.path}/sql/ClearData_2487.sql
    """

  Scenario: Load user group data to setup FT_T_FPRO and FT_T_GNST table and verify data is loaded successfully

    When I process "${testdata.path}/infiles/${INPUT_USERGROUP}" file with below parameters
      | FILE_PATTERN  | ${INPUT_USERGROUP}    |
      | MESSAGE_TYPE  | EIS_MT_BRS_USER_GROUP |
      | BUSINESS_FEED |                       |


    Then I expect value of column "FPRO_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS FPRO_COUNT FROM FT_T_FPRO
      WHERE FINS_PRO_ID IN ('test1@eastspring.com','test2@eastspring.com')
      AND END_TMS IS NULL
      """

    Then I expect value of column "GNST_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS GNST_COUNT FROM FT_T_GNST
      WHERE GNST_TBL_ID ='FPRO'
      AND STAT_DEF_ID = 'PRIMDEPT'
      AND CROSS_REF_ID IN
      (
        SELECT FPRO_OID FROM FT_T_FPRO
        WHERE FINS_PRO_ID IN ('test1@eastspring.com','test2@eastspring.com')
        AND END_TMS IS NULL
      )
      """

  Scenario: Load file1 and Verify records with CDF Tag (2 records) are loaded successfully

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_1}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_1} |
      | MESSAGE_TYPE  | EIS_MT_BRS_CDF      |
      | BUSINESS_FEED |                     |

    Then I expect workflow is processed in DMP with total record count as "4"
    And success record count as "2"
    And completed record count as "4"

  Scenario: Verify FT_T_UDF1 is loaded with 2 records for CDF Tag is available

    Then I expect value of column "UDF1_COUNT_NEW" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS UDF1_COUNT_NEW FROM FT_T_UDF1
      WHERE USER_DEFINED_VALUE IN ('41-1','Y')
      AND FPRO_OID IN
      (
        SELECT FPRO_OID FROM FT_T_FPRO
        WHERE FINS_PRO_ID IN ('test1@eastspring.com','test2@eastspring.com')
        AND END_TMS IS NULL
      )
      """

  Scenario: Verify Exception is captured if CDF Tag is not present or missing
  We are loading 2 records with CDF Tag missing, hence expected to observe 2 exceptions.


    Then I expect value of column "ID_COUNT_NTEL_TEST_CDF_TAG" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_NTEL_TEST_CDF_TAG FROM FT_T_NTEL
    WHERE NOTFCN_ID='60032'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='Test_CDF_TAG e4tarun EISCDFTeamMapping'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """

    Then I expect value of column "ID_COUNT_NTEL_CDF_MISSING" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS ID_COUNT_NTEL_CDF_MISSING FROM FT_T_NTEL
    WHERE NOTFCN_ID='60032'
    AND NOTFCN_STAT_TYP='OPEN'
    AND PARM_VAL_TXT='CDF_MISSING e4tarun EISCDFTeamMapping'
    AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
    """

  Scenario: Verify FT_T_IDMV table is updated with missing CDF Tags that were loading in file1
  Table will be updated with missing CDF Tags (TEST_CDF_TAG','CDF_MISSING)

    Then I expect value of column "IDMV_CDF_CNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS IDMV_CDF_CNT FROM FT_T_IDMV
    WHERE INTRNL_DMN_VAL_NME IN ('TEST_CDF_TAG','CDF_MISSING')
    AND FLD_ID ='CDF1002'
    """

  Scenario: Load file2 to modify existing CDF Tag and Verify records loaded successfully

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_2}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_2} |
      | MESSAGE_TYPE  | EIS_MT_BRS_CDF      |
      | BUSINESS_FEED |                     |

    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

  Scenario: Verify CDF TAG = (41-1,Y) should be modified as (41-2,N)

    Then I expect value of column "UDF1_COUNT_MODIFY" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS UDF1_COUNT_MODIFY FROM FT_T_UDF1
    WHERE USER_DEFINED_VALUE IN ('41-2','N')
    AND FPRO_OID IN
    (
      SELECT FPRO_OID FROM FT_T_FPRO
      WHERE FINS_PRO_ID IN ('test1@eastspring.com','test2@eastspring.com')
      AND END_TMS IS NULL
    )
    """

  Scenario: Load file3 to modify CDF Tag as Null and verify records are loaded successfully

    When I process "${testdata.path}/infiles/${INPUT_FILENAME_3}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_3} |
      | MESSAGE_TYPE  | EIS_MT_BRS_CDF      |
      | BUSINESS_FEED |                     |

    Then I expect workflow is processed in DMP with total record count as "2"
    And success record count as "2"

  Scenario: Verify CDF Tag = (41-2) should be updated as NULL

    Then I expect value of column "UDF1_COUNT_NULL" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS UDF1_COUNT_NULL FROM FT_T_UDF1
        WHERE USER_DEFINED_VALUE IS NULL
        AND FPRO_OID IN
        (
          SELECT FPRO_OID FROM FT_T_FPRO
          WHERE FINS_PRO_ID IN ('test1@eastspring.com')
          AND END_TMS IS NULL
        )
      """

  Scenario: Verify CDF Tag = (Y) should be updated end-dated
    Then I expect value of column "UDF1_COUNT_END_DATE" in the below SQL query equals to "1":
      """
        SELECT COUNT(*) AS UDF1_COUNT_END_DATE FROM FT_T_UDF1
        WHERE USER_DEFINED_VALUE IN ('Y')
        AND FPRO_OID IN
        (
          SELECT FPRO_OID FROM FT_T_FPRO
          WHERE FINS_PRO_ID IN ('test2@eastspring.com')
          AND END_TMS IS NULL
        )
        AND END_TMS IS NOT NULL
      """

  Scenario: Insert extra record which should not be picked up in the email

    Given I execute below query to "Set up dummy data which should not be emailed"
      """
        Insert into FT_T_UDF1
        (UDF1_OID,FPRO_OID,CDF1_OID,INSTR_ID,ISID_OID,DATA_SRC_ID,DATA_STAT_TYP,USER_DEFINED_LABEL,USER_DEFINED_VALUE,
        START_TMS,END_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,MODIFY_TMS)
        values (new_oid,
        (select fpro_oid from ft_t_fpro where fins_pro_id='test3@eastspring.com'),
        'CDF10004  ','~~8%E9mge1','~~8-E9mge1',
        'BRS','ACTIVE','TESTEXTRA','Test Extra',
        SYSDATE,null,SYSDATE,'EIS_BRS_DMP_CDF',SYSDATE);
        COMMIT;
      """

  Scenario: Run the EIS_SendCDFUpdateEmail workflow to send an email(cross department and same department)

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_SendCDFUpdateEmail/request.xmlt" to variable "EMAIL_CDF_WF"

    And I process the workflow template file "${EMAIL_CDF_WF}" with below parameters and wait for the job to be completed
      | CC_EMAIL                | raisa.dsouza@eastspring.com |
      | RECIPIENTS_NOTFCN_EMAIL | raisa.dsouza@eastspring.com |

  Scenario: Verify the required emails have been sent through TRID set up for them (Cross Department and Same department)

    Then I expect value of column "TRID_CROSS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS TRID_CROSS_COUNT FROM FT_T_TRID
      WHERE MAIN_ENTITY_ID='Tarun Trivedi'
      and MAIN_ENTITY_NME='Cross Dept CDF Update'
      and MAIN_ENTITY_ID_CTXT_TYP='CDF Updated User'
      """

    Then I expect value of column "TRID_SAME_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS TRID_SAME_COUNT FROM FT_T_TRID
      WHERE MAIN_ENTITY_ID='Raisa Dsouza'
      and MAIN_ENTITY_NME='Same Dept CDF Update'
      and MAIN_ENTITY_ID_CTXT_TYP='CDF Updated User'
      """

    Then I expect value of column "TRID_SAME_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS TRID_SAME_COUNT FROM FT_T_TRID
      WHERE MAIN_ENTITY_ID='Swapnali Jadhav'
      and MAIN_ENTITY_ID_CTXT_TYP='CDF Updated User'
      """
