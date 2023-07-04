#history
#tom_5238 : New feature file created
#https://collaborate.intranet.asia/display/TOMR4/FA-IN-SMF-LBURCR-DMP-Security-File

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_fundapps_regression
@tom_5238 @dmp_fundapps_functional
Feature: 001 | FundApps | Security | Verify Listing Matching between TMBAM and BNP with common listing identifier SEDOL

  Run 1 : TMBAM Security is received with SEDOL. Security is set up, Listing is created with Dummy Market. TMBAMCDE and SEDOL is attached to this Listing
  Run 2 : Same security is received from BNP. Existing Listing is updated with actual Market

  Scenario: Clear Data

    Given I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'TH946710TB07'"

  Scenario: Load Data

    Given I assign "TH946710TB07_WithSedol.csv" to variable "ESTBAM_WITHSEDOL_INPUTFILE"

    And I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Instrument" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ESTBAM_WITHSEDOL_INPUTFILE} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${ESTBAM_WITHSEDOL_INPUTFILE} |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_SECURITY     |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: Verify ISID

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_ISID WHERE INSTR_ID IN (
    SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH946710TB07')
    AND END_TMS IS NULL
    """

  Scenario: Verify MKIS

    Then I expect value of column "MKIS_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS MKIS_COUNT FROM FT_T_MKIS WHERE INSTR_ID IN (
    SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH946710TB07' AND END_TMS IS NULL)
    AND END_TMS IS NULL
    """

  Scenario: Verify MIXR

    Then I expect value of column "MIXR_COUNT" in the below SQL query equals to "3":
    """
    SELECT COUNT(*) MIXR_COUNT FROM FT_T_MIXR WHERE
    MKT_ISS_OID IN
    (
    SELECT MKT_ISS_OID FROM FT_T_MKIS
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH946710TB07' AND END_TMS IS NULL)
    AND END_TMS IS NULL
    AND MKT_OID = '=0000000AC'
    )
    """

  Scenario: Verify BNP

    Given I assign "TH946710TB07_BNP.out" to variable "ESTBAM_BNP_INPUTFILE"

    And I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Inbound/Instrument" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ESTBAM_BNP_INPUTFILE} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${ESTBAM_BNP_INPUTFILE} |
      | MESSAGE_TYPE  | EIS_MT_BNP_SECURITY     |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: Verify ISID

    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "8":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_ISID WHERE INSTR_ID IN (
    SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH946710TB07')
    AND END_TMS IS NULL
    """

  Scenario: Verify MKIS

    Then I expect value of column "MKIS_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS MKIS_COUNT FROM FT_T_MKIS WHERE INSTR_ID IN (
    SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH946710TB07' AND END_TMS IS NULL)
    AND END_TMS IS NULL
    """

  Scenario: Verify MIXR for Unknown Market

    Then I expect value of column "MIXR_COUNT" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) MIXR_COUNT FROM FT_T_MIXR WHERE
    MKT_ISS_OID IN
    (
    SELECT MKT_ISS_OID FROM FT_T_MKIS
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH946710TB07' AND END_TMS IS NULL)
    AND END_TMS IS NULL
    AND MKT_OID = '=0000000AC'
    )
    """

  Scenario: Verify MIXR for Actual Market

    Then I expect value of column "MIXR_COUNT" in the below SQL query equals to "5":
    """
    SELECT COUNT(*) MIXR_COUNT FROM FT_T_MIXR WHERE
    MKT_ISS_OID IN
    (
    SELECT MKT_ISS_OID FROM FT_T_MKIS
    WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'TH946710TB07' AND END_TMS IS NULL)
    AND END_TMS IS NULL
    AND MKT_OID = '478m83Lj81'
    )
    """