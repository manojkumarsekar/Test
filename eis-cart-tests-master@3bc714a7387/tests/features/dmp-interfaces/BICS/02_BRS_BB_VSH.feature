#https://jira.pruconnect.net/browse/EISDEV-6163

@gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6163 @eisdev_6163_02
Feature: Load BICS data from BRS and then BB to verify that BB value overwrites the BRS value

  1) Load the BRS file and verify BICS value is created in ISCL
  2) Load the BB file and verify BICS value is updated in ISCL
  3) Load the same BRS file again and verify BICS value not updated

  Scenario: TC_1:Prerequisites before running actual tests and deleting existing BICS ISCL

    Given I assign "tests/test-data/dmp-interfaces/BICS/InputFiles" to variable "testdata.path"
    And I assign "02_BRS_File10.xml" to variable "INPUT_FILENAME_BRS"
    And I assign "02_BB_file.out" to variable "INPUT_FILENAME_BB"

    And I execute below query to "clear ISCL for BICS data setup"
     """
     DELETE FT_T_ISCL
     WHERE INDUS_CL_SET_ID='BICSSECT'
     AND END_TMS is NULL
     AND INSTR_ID IN (
       SELECT INSTR_ID FROM FT_T_ISID
       WHERE ISS_ID='BPM0C6UC4'
       AND END_TMS IS NULL);
      COMMIT
      """

  Scenario: TC_2: BICS creation from BRS File

    When I process "${testdata.path}/${INPUT_FILENAME_BRS}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    And I expect value of column "BICS_COUNT_BRS" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS BICS_COUNT_BRS FROM FT_T_ISCL
     WHERE CL_VALUE='3010'
     AND INDUS_CL_SET_ID='BICSSECT'
     AND END_TMS is NULL
     AND INSTR_ID IN (
       SELECT INSTR_ID FROM FT_T_ISID
       WHERE ISS_ID='BPM0C6UC4'
       AND END_TMS IS NULL)
    """

  Scenario: TC_3: BICS update from BB File

    When I process "${testdata.path}/${INPUT_FILENAME_BB}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_BB}             |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |
      | BUSINESS_FEED |                                  |

    And I expect value of column "BICS_COUNT_BB" in the below SQL query equals to "1":
    """
     Select COUNT(*) AS BICS_COUNT_BB FROM FT_T_ISCL
     WHERE CL_VALUE='3910'
     AND INDUS_CL_SET_ID='BICSSECT'
     AND END_TMS is NULL
     AND INSTR_ID IN (
       SELECT INSTR_ID FROM FT_T_ISID
       WHERE ISS_ID='BPM0C6UC4'
       AND END_TMS IS NULL)
    """

  Scenario: TC_4: Rerun BRS File 10. BICS should not update

    When I process "${testdata.path}/${INPUT_FILENAME_BRS}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    And I expect value of column "BICS_COUNT_BRS" in the below SQL query equals to "0":
    """
     Select COUNT(*) AS BICS_COUNT_BRS FROM FT_T_ISCL
     WHERE CL_VALUE='3010'
     AND INDUS_CL_SET_ID='BICSSECT'
     AND END_TMS is NULL
     AND INSTR_ID IN (
       SELECT INSTR_ID FROM FT_T_ISID
       WHERE ISS_ID='BPM0C6UC4'
       AND END_TMS IS NULL)
    """