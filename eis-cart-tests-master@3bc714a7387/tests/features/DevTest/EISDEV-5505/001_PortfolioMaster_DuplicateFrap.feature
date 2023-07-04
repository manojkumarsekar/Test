#https://jira.pruconnect.net/browse/EISDEV-5505
#https://jira.pruconnect.net/browse/EISDEV-6173 : Adding PM email id setup in db as part of prerequisite.

@gc_interface_portfolios
@dmp_regression_unittest
@eisdev_5505 @eisdev_6173 @eisdev_7571
Feature: Prevent creation of FT_T_FRAP entry without inst_mnem.

  This is to prevent creation of FT_T_FRAP entry without inst_mnem, when FinancialInstitution segment fails it should not create FT_T_FRAP entry.
  we will be loading 2 record -  1st record will pass successfully and FT_T_FRAP entry will get created with "INVMGR"
  2nd record will fail with partial error and FT_T_FRAP entry will not get created with "ADVISOR" .

  Scenario: TC_1: Load Portfolio Template

    Given I assign "TC-01.xlsx" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/EISDEV-5505" to variable "testdata.path"
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

      # Clear data from FT_T_FRAP
    And I execute below query to "Delete existing FT_T_FRAP entry"
      """
      DELETE FROM FT_T_FRAP
      WHERE INST_MNEM IN (select INST_MNEM from ft_T_fins where inst_nme='EASTSPRING INVESTMENTS LIMITED')
      AND FINSRL_TYP='INVMGR'
      AND ACCT_ID='GS0000012928'
      AND END_TMS IS NULL;
      commit
      """

    #Clear FPRO Data
    And I execute below query to "End Date the FPRO data if exists"
      """
        UPDATE FT_T_FPRO SET END_TMS=SYSDATE-1
        WHERE FINS_PRO_ID='joanna.ong@eastspring.com' AND PRO_DESIGNATION_TXT='PM';
        COMMIT;
      """

    And I execute below query and extract values of "FPRO_OID;FINS_PRO_ID" into same variables
      """
       SELECT FPRO_OID,FINS_PRO_ID FROM FT_T_FPRO where ROWNUM=1 AND END_TMS IS NULL
      """

    And I execute below query to "Update PM mail id"
      """
        UPDATE FT_T_FPRO SET FINS_PRO_ID='joanna.ong@eastspring.com',PRO_DESIGNATION_TXT='PM'
        WHERE FPRO_OID='${FPRO_OID}';
        COMMIT
      """

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME_1}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    #Verification of  successfull File load
    Then I expect workflow is processed in DMP with total record count as "2"
    And completed record count as "2"
    And success record count as "1"

    #Verification of  File load for partial error
    Then I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
     """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
      WHERE JOB_ID = '${JOB_ID}'
      AND JOB_STAT_TYP ='CLOSED'
      AND TASK_PARTIAL_CNT=1
      """

     #Verification of  FT_T_FRAP to check entry got created
    Then I expect value of column "FRAP_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS FRAP_COUNT
    FROM   ft_t_frap
    WHERE  acct_id IN (SELECT acct_id
                   FROM   ft_t_acct
                   WHERE  cross_ref_id IN (SELECT xref_tbl_row_oid
                                           FROM   ft_t_msgp
                                           WHERE  xref_tbl_typ = 'ACCT'
                                                  AND trn_id IN (SELECT trn_id
                                                                 FROM
                                                      ft_t_trid
                                                                 WHERE
                                                      crrnt_severity_cde = '10'
                                                      AND job_id ='${JOB_ID}')))
       AND Trunc(last_chg_tms) = Trunc(sysdate)
    """


  Scenario: Reverting the PM mail changes

    Then I execute below query to "Reverting the PM mail id changes"
      """
        UPDATE FT_T_FPRO SET FINS_PRO_ID='${FINS_PRO_ID}',PRO_DESIGNATION_TXT = NULL
        WHERE FPRO_OID='${FPRO_OID}';
        COMMIT
      """