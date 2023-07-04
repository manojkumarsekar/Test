#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=20.+Multi-Listing+Security+Creation+Process
#https://jira.intranet.asia/browse/TOM-4473 - Dev ticket
#https://jira.intranet.asia/browse/TOM-4794- QA Ticket

@gc_interface_reuters
@dmp_regression_integrationtest
@dmp_fundapps_regression @tom_4794 @04_multlisting_negative
Feature: Test the creation of listing flag for EUR, ASIA and US market group : Empty Mics, Zero Markets (ALL flags as N),Another type of file

  This feature file is to test the creation of listing flag for EUR, ASIA and US market group
  1. When the MIC list received in the file have at least two MIC that belongs to ASIA market grp
  we set Asia flag = Y , otherwise Asia flag = N
  2. When the MIC list received in the file have at least one MIC that belongs to EUR market grp
  we set EUROPE flag = Y , otherwise EUROPE flag = N
  3. When the MIC list received in the file have at least one MIC that belongs to US market grp
  we set US flag = Y , otherwise US flag = N

  Scenario: Assign variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/ReutersTermsConditionsSecurity/MultiListing/infiles" to variable "testdata.path"
    And I assign "ZeroMICsForEachMRKT.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "User Defined Identifier" column and assign to variables:
      | ISIN | ISIN_CODE |
    And  I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${ISIN_CODE}'"

  Scenario: TC_1: Load the reuters terms and conditions security file with MICList having 0 MICs from each market


    Given I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}             |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	  SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_2: Verifications for listing flag creation
  Listing flag should be created as - EURLST=N, USLST=N and ASIALST=N

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "3":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID IN ('EURLST','USLST','ASIALST')
      AND STAT_CHAR_VAL_TXT = 'N'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

  Scenario: TC_3: Load the reuters terms and conditions security file with empty MICList

    Given I assign "EmptyMICListField.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "User Defined Identifier" column and assign to variables:
      | ISIN | ISIN_CODE |

    And I execute below query
    """
      DELETE FROM FT_T_IMKR WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL);
      COMMIT
    """

    And I execute below query
    """
      DELETE FROM FT_T_ISST WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL);
      COMMIT
    """

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}             |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	  SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_4: Verifications for listing flag creation
  No Listing flag should be created as rule not triggered

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID IN ('EURLST','USLST','ASIALST')
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """


  Scenario: TC_5: Load the reuters Composite security file

    Given I assign "AllYFlag.csv" to variable "INPUT_FILENAME"
    And I extract below values for row 2 from CSV file "${INPUT_FILENAME}" in local folder "${testdata.path}" with reference to "User Defined Identifier" column and assign to variables:
      | ISIN | ISIN_CODE |

    And I execute below query
    """
      DELETE FROM FT_T_IMKR WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL);
      COMMIT
    """

    And I execute below query
    """
      DELETE FROM FT_T_ISST WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL);
      COMMIT
    """

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	  SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_6: Verifications for listing flag creation
  No Listing flag should be created as rule not triggered

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID IN ('EURLST','USLST','ASIALST')
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${ISIN_CODE}' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

