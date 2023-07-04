# https://jira.pruconnect.net/browse/EISDEV-5512: Test the EISELC1 Config Publishing entry created over UI

@web @gs_ui_regression @eisdev_5512
@gc_ui_group_treasury_config @gc_ui_worklist @eisdev_7450

Feature: Group Treasury EMIR UI screen
  As a user, I should be able to publish EMIR entry from Group Treasury configuration UI,
  and I expect entry has updated with the given institution name in Database successfully.

  Scenario: Assign test data variables and delete open records for EMIR reporting

    Given I assign "STCFX" to variable "OTHER_COUNTER_PARTY"
    And I assign "EMIR" to variable "DATA_SOURCE_ID"
    And I assign "FX_FWRD" to variable "SEC_TYP"
    And I assign "FW" to variable "CONTRACT_TYP"

    And  I execute below query to "delete if any open records/entities exists for EMIR and MAS config"
    """
       DELETE FT_WF_UIWA
       WHERE MAIN_ENTITY_NME='${CONTRACT_TYP}'
       AND USR_TASK_ID='SIMPLE_MAKER_CHECKER'
    """


  Scenario: Create New entry for EISELC1 Config Publishing with data Source Id as "EMIR" for EMIR reporting
  Verify EMIR entry created successfully.

    Given I login to golden source UI with "task_assignee" role
    When I add below Group treasury configuration details
      | Portfolio Name                 | PRU ASS LIFE FD                     |
      | Data Source ID                 | ${DATA_SOURCE_ID}                   |
      | Security Type                  | ${SEC_TYP}                          |
      | Other Counterparty             | ${OTHER_COUNTER_PARTY}              |
      | Reporting Counterparty         | PRUDENTIAL CORPORATION HOLDINGS LTD |
      | Contract Type                  | ${CONTRACT_TYP}                     |
      | Instrument Classification Type | C                                   |
      | Instrument Classification      | JFRXCC                              |
      | COTOC                          | HK                                  |

    And I save the valid data

    Then I expect a record in My WorkList with entity id "${SEC_TYP}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "${SEC_TYP}"

    Then I expect value of column "INST_NME_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS INST_NME_COUNT
       FROM FT_T_ELC1
       WHERE OC_INST_MNEM IN
           (
            SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='${OTHER_COUNTER_PARTY}'
           )
      AND DATA_SRC_ID='${DATA_SOURCE_ID}'
      AND CNT_TYP='FW'
      AND INSTRUMENT_CLASSIFICATION_TYPE='C'
      AND CONTRACT_TYPE='${SEC_TYP}'
      AND INSTRUMENT_CLASSIFICATION='JFRXCC'
      AND COTOC='HK'
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
      AND END_TMS IS NULL
      """

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: Create New entry for EISELC1 Config Publishing with data Source Id as "MAS" for MAS reporting
  Verify MAS entry created successfully.

    Given I assign "EASTSPRING ASIAN LOCAL BOND FUND" to variable "OTHER_COUNTER_PARTY"
    And I assign "MAS" to variable "DATA_SOURCE_ID"
    And I assign "FX_FWRD_N" to variable "SEC_TYP"

    And  I execute below query to "delete any existing data"
  """
    DELETE FT_T_ELC1
    WHERE OC_INST_MNEM IN
      (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='${OTHER_COUNTER_PARTY}')
    AND DATA_SRC_ID='${DATA_SOURCE_ID}'
    AND CNT_TYP='${CONTRACT_TYP}'
    AND CONTRACT_TYPE='${SEC_TYP}'
    AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
    AND END_TMS IS NULL
  """

    And I login to golden source UI with "task_assignee" role

    When I add below Group treasury configuration details
      | Portfolio Name         | PRU ASS LIFE FD        |
      | Reporting Counterparty | OCEANA GROUP LTD       |
      | Data Source ID         | ${DATA_SOURCE_ID}      |
      | Contract Type          | ${CONTRACT_TYP}        |
      | Security Type          | ${SEC_TYP}             |
      | Other Counterparty     | ${OTHER_COUNTER_PARTY} |

    And I save the valid data

    Then I expect a record in My WorkList with entity id "${SEC_TYP}"
    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity id "${SEC_TYP}"

    Then I expect value of column "INST_NME_COUNT" in the below SQL query equals to "1":
      """
       SELECT COUNT(*) AS INST_NME_COUNT
       FROM FT_T_ELC1
       WHERE OC_INST_MNEM IN
           (
            SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME='${OTHER_COUNTER_PARTY}'
           )
      AND DATA_SRC_ID='${DATA_SOURCE_ID}'
      AND CNT_TYP='${CONTRACT_TYP}'
      AND CONTRACT_TYPE='${SEC_TYP}'
      AND TRUNC(LAST_CHG_TMS)=TRUNC(SYSDATE)
      AND END_TMS IS NULL
      """

  Scenario: Close browsers
    Then I close all opened web browsers
