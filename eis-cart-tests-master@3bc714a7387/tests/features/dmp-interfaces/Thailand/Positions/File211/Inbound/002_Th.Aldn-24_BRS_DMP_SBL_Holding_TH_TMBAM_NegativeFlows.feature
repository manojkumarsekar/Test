#https://jira.pruconnect.net/browse/6230
#Technical Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR4&title=Th.Aldn-24+Th.TMBAM.Positions+Restricted_Holdings%28SBL%29+BRS+-%3E+ESI_DMP
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=TMBAM-SSDR%7CUpload+Restricted+Holdings%7CBRS+To+DMP
#EISDEV-6377: Modify the portfolio group from TMBAM to THB-AG

@gc_interface_portfolios @gc_interface_positions
@dmp_regression_integrationtest
@eisdev_6230 @002_file211_sbl_holding @dmp_thailand_fundapps @dmp_thailand @eisdev_6377 @eisdev_6603
Feature: BRS File211 (i.e Restricted holding) load for TMBAM - Negative Flows

  The purpose of this interface is to test he negative flows of TMBAM-SBL loading

  We tests the following Scenario with this feature file.

  1.Loading a record with purpose other than Z - Record is filtered
  2.Loading a record for a portfolio not present in TMBAM port group - Record is filtered
  3.Loading a record for a portfolio not present in DMP - Record is filtered
  4.Load 5 records with each record missing one mandatory tag - The record loading fails

  Scenario: TC1: Initialize variables and Deactivate Existing test

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Positions/File211/Inbound" to variable "TESTDATA_PATH_INBOUND"

    # Portfolio Uploader variable
    And I assign "002_Th.Aldn-24_BRS_DMP_PortfolioCreation_PreRequisite.xlsx" to variable "INPUT_PORTFOLIO_FILENAME"

    # Portfolio File54 variable
    And I assign "002_Th.Aldn-24_BRS_DMP_F54_esi_portfolio_PreRequisite.xml" to variable "INPUT_F54_FILENAME"
    And I assign "002_Th.Aldn-24_BRS_DMP_F54_esi_portfolio_PreRequisite_Template.xml" to variable "INPUT_F54_TEMPLATENAME"

    # Portfolio group variable
    And I assign "002_Th.Aldn-24_BRS_DMP_esi_port_group_PreRequisite.xml" to variable "INPUT_PORTGROUP_FILENAME"
    And I assign "002_Th.Aldn-24_BRS_DMP_esi_port_group_PreRequisite_Template.xml" to variable "INPUT_PORTGROUP_TEMPLATENAME"

    # File 14 Variable
    And I assign "002_Th.Aldn-24_BRS_DMP_F14_Position_PreRequisite.xml" to variable "INPUT_F14_FILENAME"
    And I assign "002_Th.Aldn-24_BRS_DMP_F14_Position_PreRequisite_Template.xml" to variable "INPUT_F14_TEMPLATENAME"

    # File 211 Variable
    And I assign "002_Th.Aldn-24_BRS_DMP_F211_RestrictedPosition.xml" to variable "INPUT_F211_FILENAME"
    And I assign "002_Th.Aldn-24_BRS_DMP_F211_RestrictedPosition_Template.xml" to variable "INPUT_F211_TEMPLATENAME"

    # File 211 As of date Validation Variable
    And I assign "002_2_Th.Aldn-24_BRS_DMP_F211_Restricted_AsofDate.xml" to variable "INPUT_F211_ASOFDATE_FILENAME"
    And I assign "002_2_Th.Aldn-24_BRS_DMP_F211_Restricted_AsofDate_Template.xml" to variable "INPUT_F211_ASOFDATE_TEMPLATENAME"

    And I generate value with date format "M/dd/YYYY" and assign to variable "VAR_SYSDATE"

    And I execute below query to "set up FPRO"
	"""
    update ft_t_fpro set FINS_PRO_ID = 'testautomation@eastspring.com', PRO_DESIGNATION_TXT = 'PM' where fpro_oid = 'Ec6Q58Mj81';
    commit
    """

  Scenario:TC2: Create portfolios using uploader

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PORTFOLIO_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_PORTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: TC3: Creates BRSFundID as Context type using File54 from BRS

    Given I create input file "${INPUT_F54_FILENAME}" using template "${INPUT_F54_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_F54_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${INPUT_F54_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC4: Load portfolio group file from BRS to DMP to create TBMAM group and participants

    Given I create input file "${INPUT_PORTGROUP_FILENAME}" using template "${INPUT_PORTGROUP_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PORTGROUP_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_PORTGROUP_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP  |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: TC5: Load TMBAM Position Data(File 14) from BRS

    Given I create input file "${INPUT_F14_FILENAME}" using template "${INPUT_F14_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_F14_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_F14_FILENAME}             |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario:TC6: Load TMBAM SBL Position Data(File 211) from BRS

    Given I create input file "${INPUT_F211_FILENAME}" using template "${INPUT_F211_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I copy files below from local folder "${TESTDATA_PATH_INBOUND}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_F211_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_F211_FILENAME}                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211 |
      | BUSINESS_FEED |                                          |

    Then I expect workflow is processed in DMP with total record count as "14"

  Scenario: TC7: Verify the records filtered and failure count

    Then I expect workflow is processed in DMP with completed record count as "14"
    And filtered record count as "10"
    And fail record count as "1"
    And partial record count as "2"

  Scenario: TC8: Verify the exception message when an Invalid CUSIP is used

    Then I expect value of column "INVALID_CUSIP_EXCEPTION_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS INVALID_CUSIP_EXCEPTION_COUNT
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID
     FROM FT_T_TRID
     WHERE JOB_ID = '${JOB_ID}')
     AND CHAR_VAL_TXT LIKE 'The Issue for % provided by BRS is not present in the IssueIdentifier.'
    """

  Scenario: TC9: Verify the exception message when Security is missing

    Then I expect value of column "SECURITY_ID_MISSING_EXCEPTION_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS SECURITY_ID_MISSING_EXCEPTION_COUNT
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID
     FROM FT_T_TRID
     WHERE JOB_ID = '${JOB_ID}')
     AND CHAR_VAL_TXT LIKE '%Cannot process record as required fields, Security ID is not present in the input record.'
    """

  Scenario: TC10: Verify the exception message when Quantity is missing

    Then I expect value of column "QUANTITY_MISSING_EXCEPTION_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS QUANTITY_MISSING_EXCEPTION_COUNT
    FROM FT_T_NTEL
    WHERE NOTFCN_STAT_TYP='OPEN' AND LAST_CHG_TRN_ID IN
    (SELECT TRN_ID
     FROM FT_T_TRID
     WHERE JOB_ID = '${JOB_ID}')
     AND CHAR_VAL_TXT LIKE '%Cannot process record as required fields, Quantity is not present in the input record.'
    """

  Scenario: TC11: Verify the exception message when Position Date is missing

    Given I create input file "${INPUT_F211_ASOFDATE_FILENAME}" using template "${INPUT_F211_ASOFDATE_TEMPLATENAME}" from location "${TESTDATA_PATH_INBOUND}/inputfiles"

    When I process "${TESTDATA_PATH_INBOUND}/inputfiles/testdata/${INPUT_F211_ASOFDATE_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_F211_ASOFDATE_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211 |
      | BUSINESS_FEED |                                          |

    Then I expect workflow is processed in DMP with total record count as "1"

    Then I expect value of column "POSITION_DATE_MISSING_EXCEPTION_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS POSITION_DATE_MISSING_EXCEPTION_COUNT
    FROM FT_T_NTEL
    WHERE LAST_CHG_TRN_ID IN
    (SELECT TRN_ID
     FROM FT_T_TRID
     WHERE JOB_ID = '${JOB_ID}')
     AND CHAR_VAL_TXT LIKE '%Cannot process record as required fields Position Date is not present in the input record.'
    """

  Scenario:TC12: Re-set FPRO

    Given I execute below query to "reset FPRO"
	"""
	update ft_t_fpro set FINS_PRO_ID = 'azhar.arayilakath@eastspring.com' where fpro_oid = 'Ec6Q58Mj81';
	commit
    """