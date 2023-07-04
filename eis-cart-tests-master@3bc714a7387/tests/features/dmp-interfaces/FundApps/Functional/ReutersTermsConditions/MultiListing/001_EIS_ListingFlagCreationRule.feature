#https://jira.intranet.asia/browse/TOM-4473
#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=20.+Multi-Listing+Security+Creation+Process
#This feature covered as part of @tom_4794, hence removed the regression tags

@tom_4473
Feature: Test the creation of listing flag for EUR, ASIA and US market group

  This feature file is to test the creation of listing flag for EUR, ASIA and US market group
  1. When the MIC list received in the file have at least two MIC that belongs to ASIA market grp
  we set Asia flag = Y , otherwise Asia flag = N
  2. When the MIC list received in the file have at least one MIC that belongs to EUR market grp
  we set EUROPE flag = Y , otherwise EUROPE flag = N
  3. When the MIC list received in the file have at least one MIC that belongs to US market grp
  we set US flag = Y , otherwise US flag = N

  Background:
    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/ReutersTermsConditionsSecurity/MultiListing/infiles" to variable "testdata.path"

  Scenario: TC_1: Load the reuters terms and conditions security file with MICList having 0 MICs from each market
  Listing flag will be created - EURLST=N, USLST=N and ASIALST=N

    Given I assign "ZeroMICsForEachMRKT.csv" to variable "INPUT_FILENAME"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'JP3845400005'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'JP3845400005'"

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

  Scenario: TC_2: Verifications for listing flag creation

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'EURLST'
      AND STAT_CHAR_VAL_TXT = 'N'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_USLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_USLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'USLST'
      AND STAT_CHAR_VAL_TXT = 'N'
       AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_ASIALST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_ASIALST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'ASIALST'
      AND STAT_CHAR_VAL_TXT = 'N'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

  Scenario: TC_3: Load the reuters terms and conditions security file with MICList having 1 MICs from each market
  Listing flag will be created - EURLST=Y, USLST=Y and ASIALST=N

    Given I assign "TwoYOneNFlag.csv" to variable "INPUT_FILENAME"

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

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'EURLST'
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_USLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_USLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'USLST'
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_ASIALST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_ASIALST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'ASIALST'
      AND STAT_CHAR_VAL_TXT = 'N'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

  Scenario: TC_5: Load the reuters terms and conditions security file with MICList having 2 MICs from each market
  Listing flag will be created - EURLST=Y, USLST=Y and ASIALST=Y

    Given I assign "AllYFlag.csv" to variable "INPUT_FILENAME"

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

  Scenario: TC_6: Verifications for listing flag creation

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'EURLST'
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_USLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_USLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'USLST'
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_ASIALST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_ASIALST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'ASIALST'
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

  Scenario: TC_7: Load the reuters terms and conditions security file with MICList having 3 MIC from only ASIA market
  Listing flag will be created - EURLST=N, USLST=N and ASIALST=Y

    Given I assign "TwoNOneYFlag.csv" to variable "INPUT_FILENAME"

    And I execute below query
    """
      DELETE FROM FT_T_IMKR WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL);
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

  Scenario: TC_8: Verifications for listing flag creation

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'EURLST'
      AND STAT_CHAR_VAL_TXT = 'N'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_USLST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_USLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'USLST'
      AND STAT_CHAR_VAL_TXT = 'N'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_ASIALST" in the below SQL query equals to "1":
    """
      SELECT COUNT(*) AS ISST_COUNT_ASIALST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'ASIALST'
      AND STAT_CHAR_VAL_TXT = 'Y'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

  Scenario: TC_9: Load the reuters terms and conditions security file with empty MICList
  No Listing flag will be created as rule will not be triggered

    Given I assign "EmptyMICListField.csv" to variable "INPUT_FILENAME"

    And I execute below query
    """
      DELETE FROM FT_T_IMKR WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL);
      COMMIT
    """

    And I execute below query
    """
      DELETE FROM FT_T_ISST WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL);
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

  Scenario: TC_10: Verifications for listing flag creation

    Then I expect value of column "ISST_COUNT_EURLST" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS ISST_COUNT_EURLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'EURLST'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_USLST" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS ISST_COUNT_USLST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'USLST'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """

    Then I expect value of column "ISST_COUNT_ASIALST" in the below SQL query equals to "0":
    """
      SELECT COUNT(*) AS ISST_COUNT_ASIALST FROM FT_T_ISST
      WHERE STAT_DEF_ID = 'ASIALST'
      AND INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'JP3845400005' AND END_TMS IS NULL)
      AND END_TMS IS NULL
    """
