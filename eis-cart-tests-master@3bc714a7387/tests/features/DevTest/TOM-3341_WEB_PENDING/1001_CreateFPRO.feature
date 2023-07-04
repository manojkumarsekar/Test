#https://jira.pruconnect.net/browse/EISDEV-6173 : Adding PM email id setup in db as part of prerequisite.
@tom_3341 @dmp_interfaces @eisdev_6173
Feature: Loading different files to populate FT_T_FPRO (FinancialServicesProfessional)

  Scenario: TC_1: Load files for EIS_BRS_DMP_USER_GROUP

    Given I assign "TC-01-UserGroup.xml" to variable "INPUT_FILENAME_1"
    And I assign "tests/test-data/DevTest/TOM-3341" to variable "testdata.path"

     # Clear data from FINS and its Child table
    And I execute below query
    """
    ${testdata.path}/sql/01ClearFPROData.sql
    """

    And I execute below query and extract values of "FPRO_OID;FINS_PRO_ID" into same variables
    """
     SELECT FPRO_OID,FINS_PRO_ID FROM FT_T_FPRO where ROWNUM=1
    """

    And I execute below query to "Update PM mail id"
    """
     UPDATE FT_T_FPRO SET FINS_PRO_ID='Ilene.Chong@eastspring.com',PRO_DESIGNATION_TXT='PM'
     WHERE FPRO_OID='${FPRO_OID}';
     COMMIT
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_USER_GROUP |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # 2 records are getting filtered because: 1) Domain is other than eastspring
    #                                         2) Primary Dept Name contains Testing

    Then I expect value of column "CNT" in the below SQL query equals to "2":
      """
     SELECT TASK_FILTERED_CNT AS CNT
     FROM FT_t_JBLG
     WHERE JOB_ID='${JOB_ID}'
      """

    Then I expect value of column "ID_COUNT_FPRO" in the below SQL query equals to "2":
      """
     SELECT COUNT(*) AS ID_COUNT_FPRO
     FROM FT_T_FPRO
     WHERE FINS_PRO_ID IN ('tarunkumar.trivedi@eastspring.com','nitin.mahajan@eastspring.com')
      """

  Scenario: TC_2: Load files for EIS_RDM_DMP_PORTFOLIO_MASTER

    Given I assign "TC-01-Portfolio_Master.xlsx" to variable "INPUT_FILENAME_2"

     # Clear data from FINS and its Child table
    And I execute below query
      """
      ${testdata.path}/sql/02ClearFPROData.sql
      """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  # If Portfolio Manager present 1 in FPRO and PRO_DESIGNATION_TXT='PM' then FPGU should be created.
    Then I expect value of column "ID_COUNT_ACTA" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_ACTA
     FROM FT_T_ACTA
     WHERE FPRO_OID IN (SELECT FPRO_OID FROM Ft_t_FPRO WHERE fins_pro_id='Ilene.Chong@eastspring.com' and  pro_designation_txt='PM')
      """

  Scenario: TC_3: Load files for EIS_RDM_DMP_PORTFOLIO_MASTER

    Given I assign "TC-02-Portfolio_Master.xlsx" to variable "INPUT_FILENAME_3"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_3} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_3}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

 # If Portfolio Manager 1 present in FPRO and PRO_DESIGNATION_TXT is blank then it should throw error.
    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE CHAR_VAL_TXT LIKE '%The Fins Services Pro Alt Identifier ''INTERNAL - teresa.soh@eastspring.com'' received from RDM  could not be retrieved from the FinancialServicesProfessional%'
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND SOURCE_ID LIKE '%GS_GC%'
      AND MSG_TYP='EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

  Scenario: TC_4: Load files for EIS_RDM_DMP_PORTFOLIO_MASTER

    Given I assign "TC-03-Portfolio_Master.xlsx" to variable "INPUT_FILENAME_4"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_4} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_FILENAME_4}                  |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

  # If wrong email id present in Portfolio Manager 1 then it should throw error.
    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE CHAR_VAL_TXT LIKE '%The Fins Services Pro Alt Identifier ''INTERNAL - abc.def@eastspring.com'' received from RDM  could not be retrieved from the FinancialServicesProfessional%'
      AND NOTFCN_STAT_TYP = 'OPEN'
      AND SOURCE_ID LIKE '%GS_GC%'
      AND MSG_TYP='EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """


  Scenario: Reverting the PM mail changes

    Then I execute below query to "Reverting the PM mail id changes"
    """
     UPDATE FT_T_FPRO SET FINS_PRO_ID='${FINS_PRO_ID}',PRO_DESIGNATION_TXT = NULL
     WHERE FPRO_OID='${FPRO_OID}';
     COMMIT
    """