#As part of EISDEV-6907, Look up on Instrument Group screen has changed from Instrument Name to Preferred Identifier Value
#  eisdev_7369 - Allows multiple same issue name and issue type can be added to the new instrument group

@web @gs_ui_regression @eisdev_7007 @eisdev_7369
@gc_ui_instrument_group  @gc_ui_worklist

Feature: Create Instrument Group
  This feature file can be used to check the Instrument Group create functionality over UI with multiple same issue name.
  This handles both the maker checker event require to create Instrument Group.

  Scenario: Create New Instrument Group with multiple same issue name and issue type
    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "MSs" and assign to variable "VAR_RANDOM"

    Given I execute below query and extract values of "ISIN" column into incremental variables
    """
    SELECT ISIN FROM (
    select PREF_ISS_DESC,iss_id ISIN,row_number() over (partition by PREF_ISS_DESC order by PREF_ISS_DESC) RN from (
    select distinct a.PREF_ISS_ID,a.PREF_ISS_DESC,b.iss_id from ft_t_issu a
    inner join ft_t_isid b on a.instr_id=b.instr_id where a.iss_typ = 'BOND' AND b.id_ctxt_typ='ISIN'
    and a.END_TMS IS NULL AND a.PREF_ISS_DESC is not null and b.END_TMS IS NULL
    GROUP BY a.PREF_ISS_DESC,a.PREF_ISS_ID,b.iss_id)c
    GROUP BY PREF_ISS_DESC,iss_id
    ) where RN >=2 AND ROWNUM<=2
    """

    When I create Instrument Group with following details
      | Group ID               | TST_GRPID_${VAR_RANDOM}   |
      | Group Name             | TST_INS_GRP_${VAR_RANDOM} |
      | Group Purpose          | Account Download          |
      | Group Description      | TST_GROUPDESC             |
      | Subscriber/Down Stream | BNP_CASHALLOC_ITAP        |
      | Enterprise             | EIS                       |
      | Asset Subdivision Name |                           |
      | Group Created On       | T                         |
      | Group Effective Until  |                           |

    When I add Instrument Group Participant with following details
      | Preferred Identifier Value  | ${ISIN1}              |
      | Participant Purpose         | Acceleration Clause   |
      | Participant Description     | Test_Participant_DESC |
      | Participant Amount          | 500                   |
      | Participant Percent         | 5                     |
      | Participant Currency        | 10  - Old Krona (old) |
      | Participation Type          | Amount                |
      | Participant Created On      | T                     |
      | Participant Effective Until |                       |

    When I add Instrument Group Participant with following details
      | Preferred Identifier Value  | ${ISIN2}              |
      | Participant Purpose         | Acceleration Clause   |
      | Participant Description     | Test_Participant_DESC |
      | Participant Amount          | 500                   |
      | Participant Percent         | 5                     |
      | Participant Currency        | 10  - Old Krona (old) |
      | Participation Type          | Amount                |
      | Participant Created On      | T                     |
      | Participant Effective Until |                       |


    And I save the valid data

    Then I expect a record in My WorkList with entity name "TST_INS_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_authorizer" role
    Then I approve a record from My WorkList with entity name "TST_INS_GRP_${VAR_RANDOM}"

    When I relogin to golden source UI with "task_assignee" role

    Then I expect the Instrument Group "TST_INS_GRP_${VAR_RANDOM}" is updated as below
      | Group Purpose     | Account Download |
      | Group Description | TST_GROUPDESC    |

    Then I expect the Instrument Group Participant is updated as below
      | Preferred Identifier Value  | ${ISIN2}              |
      | Participant Purpose         | Acceleration Clause   |
      | Participant Description     | Test_Participant_DESC |
      | Participant Amount          | 500                   |
      | Participant Percent         | 5                     |
      | Participant Currency        | 10  - Old Krona (old) |
      | Participation Type          | Amount                |
      | Participant Created On      | T                     |
      | Participant Effective Until |                       |

    Then I expect the Instrument Group Participant is updated as below
      | Preferred Identifier Value  | ${ISIN1}              |
      | Participant Purpose         | Acceleration Clause   |
      | Participant Description     | Test_Participant_DESC |
      | Participant Amount          | 500                   |
      | Participant Percent         | 5                     |
      | Participant Currency        | 10  - Old Krona (old) |
      | Participation Type          | Amount                |
      | Participant Created On      | T                     |
      | Participant Effective Until |                       |

