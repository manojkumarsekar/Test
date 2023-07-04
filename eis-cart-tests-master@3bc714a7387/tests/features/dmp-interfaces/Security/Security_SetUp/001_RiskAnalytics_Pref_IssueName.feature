#eisdev-7237 : Initial Version. Verify Pref Issue name and description of Security setup from the BRS F10 is not update from Risk Analytic File

@gc_interface_securities
@dmp_regression_integrationtest
@eisdev_7237

Feature: 001 | Security | F10 | Risk Analytics
  Verify Pref Issue name of Security setup from the BRS F10 is not update from Risk Analytic File

  Scenario: End date Instruments in GC and VD DB

    Given I inactivate "BRSRU56B6" instruments in GC database

  Scenario: Loading Securities using BRS F10

    And I assign "tests/test-data/dmp-interfaces/Security/Security_SetUp" to variable "TESTDATA_PATH"
    And I assign "BRSRU56B6_F10.xml" to variable "INPUT_FILENAME_F10"
    And I assign "BRSRU56B6_RA.xml" to variable "INPUT_FILENAME_RA"

    Given I process "${TESTDATA_PATH}/testdata/${INPUT_FILENAME_F10}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_F10}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification in GC for ISSU from F10
  Expect Value of PREF_ISS_NME and PREF_ISS_DESC is inserted from F10 mapping

    Then I expect value of column "PREF_ISS_NME" in the below SQL query equals to "EASTSPRING INV US HI YLD BD D":
    """
    select PREF_ISS_NME from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BRSRU56B6' and end_tms is null)
    and trunc(START_TMS) = trunc(sysdate)
    """

    Then I expect value of column "PREF_ISS_DESC" in the below SQL query equals to "EASTSPRING INV US HI YLD BD D":
    """
    select PREF_ISS_DESC from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BRSRU56B6' and end_tms is null)
    and trunc(START_TMS) = trunc(sysdate)
    """

  Scenario: Loading Securities using Risk Analytics

    Given I process "${TESTDATA_PATH}/testdata/${INPUT_FILENAME_RA}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILENAME_RA}      |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |
      | BUSINESS_FEED |                           |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Data verification in GC for ISSU from Risk Analytics
  Expect Value of PREF_ISS_NME and PREF_ISS_DESC is not updated

    Then I expect value of column "PREF_ISS_NME" in the below SQL query equals to "EASTSPRING INV US HI YLD BD D":
    """
    select PREF_ISS_NME from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BRSRU56B6' and end_tms is null)
    and trunc(START_TMS) = trunc(sysdate)
    """

    Then I expect value of column "PREF_ISS_DESC" in the below SQL query equals to "EASTSPRING INV US HI YLD BD D":
    """
    select PREF_ISS_DESC from ft_t_issu
    where instr_id in (select instr_id from ft_t_isid where iss_id = 'BRSRU56B6' and end_tms is null)
    and trunc(START_TMS) = trunc(sysdate)
    """