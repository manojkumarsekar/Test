#https://jira.pruconnect.net/browse/EISDEV-7531
#https://jira.pruconnect.net/browse/EISDEV-5514
#https://jira.pruconnect.net/browse/EISDEV-5284 : Dev ticket feature has been removed from the suite due to redundant.
#Note:
#  DMP received files from LBUs (classified as EIS_RCRLBU_DMP_SECURITY),These files contain LBU identifiers (example is TMBAMCDE)
#  LBU identifiers are stored in DMP but not exposed in GS UI.
#  IDM needs these fields to be exposed so that we can handle exception raised from LBU Identifiers
#  List of LBU Identifiers:
#  BOCI
#  EIMK
#  ESGA
#  ESJP
#  MANDG
#  PPM
#  TMBAM
#  WFOE
#  THANA
#  Exposed all LBU identifiers above in GS UI

@web @gs_ui_regression @eisdev_5514 @eisdev_5284 @eisdev_7217 @eisdev_7531
@gc_ui_instrument

Feature: 003_Issue_with_SSDR_Identifiers: Create New Issue by providing new SSDR Identifiers BOCI,EIMK,ESGA,ESJP,MANDG,PPM,TMBAM,WFOE and THANA CODES fields
  
  As a user I should able to see all new SSDR Identifiers codes under Market level identifiers,
  and user should able to create Issue with new SSDR Identifiers codes.

  Scenario: Create new issue with SSDR Identifiers available under Market Level Identifiers
  Verify new issue has created successfully.

    Given I login to golden source UI with "task_assignee" role
    And I generate value with date format "HMs" and assign to variable "VAR_RANDOM"
    And I assign "TST_INSTNAME_${VAR_RANDOM}" to variable "INTSR_NAME"

    When I enter below Instrument Details for new Issue
      | Instrument Name          | ${INTSR_NAME}           |
      | Instrument Description   | TST_INSTDESC            |
      | Instrument Type          | Equity Share            |
      | Pricing Method           | 100 Pieces              |
      | Instrument System Status | Active                  |
      | Source Currency          | HKD - Hong Kong Dollar  |
      | Target Currency          | AUD - Australian Dollar |

    And I add below Market Listing details
      | Exchange Name             | UBS AG LONDON BRANCH EMEA TRADING |
      | Primary Market Indicator  | Original                          |
      | Market Status             | Acquired                          |
      | Trading Currency          | HKD - Hong Kong Dollar            |
      | Market Listing Created On | T                                 |

    And I add below Market level Identifiers under Market Listing
      | RDM Code          | RDM_${VAR_RANDOM}          |
      | BNP BBGlobal      | BNP BBGlobal_${VAR_RANDOM} |
      | MNG BCUSIP        | MNG BCUSIP_${VAR_RANDOM}   |
      | RCR ESJP CODE     | ESJP_${VAR_RANDOM}         |
      | RCR EIMKOR CODE   | EIMKOR_${VAR_RANDOM}       |
      | RCR PPMJNAM CODE  | PPMJNAM_${VAR_RANDOM}      |
      | RCR WFOE CODE     | WFOE_${VAR_RANDOM}         |
      | RCR WFOECCB CODE  | WFOECCB_${VAR_RANDOM}      |
      | RCR ROBOCOLL CODE | ROBOCOLL_${VAR_RANDOM}     |
      | BNP HIPEXT2ID     | HIPEXT21D_${VAR_RANDOM}    |
      | BNP Listing ID    | Listing ID_${VAR_RANDOM}   |
      | RCR BOCI CODE     | BOCI_${VAR_RANDOM}         |
      | RCR ESGA CODE     | ESGA_${VAR_RANDOM}         |
      | RCR MNG CODE      | MNG_${VAR_RANDOM}          |
      | RCR TMBAM CODE    | TMBAM_${VAR_RANDOM}        |
      | RCR THANA CODE    | THANA_${VAR_RANDOM}        |
      | RCR PAMTC CODE    | PAMTC_${VAR_RANDOM}        |


    And I save the valid data

    Then I expect a record in My WorkList with entity name "${INTSR_NAME}"

    When I relogin to golden source UI with "task_authorizer" role
    And I approve a record from My WorkList with entity name "${INTSR_NAME}"

    And I relogin to golden source UI with "task_assignee" role

    And I expect below Market level Identifiers updated for the Issue "${INTSR_NAME}"

      | RDM Code          | RDM_${VAR_RANDOM}          |
      | BNP BBGlobal      | BNP BBGlobal_${VAR_RANDOM} |
      | MNG BCUSIP        | MNG BCUSIP_${VAR_RANDOM}   |
      | RCR ESJP CODE     | ESJP_${VAR_RANDOM}         |
      | RCR EIMKOR CODE   | EIMKOR_${VAR_RANDOM}       |
      | RCR PPMJNAM CODE  | PPMJNAM_${VAR_RANDOM}      |
      | RCR WFOE CODE     | WFOE_${VAR_RANDOM}         |
      | RCR WFOECCB CODE  | WFOECCB_${VAR_RANDOM}      |
      | RCR ROBOCOLL CODE | ROBOCOLL_${VAR_RANDOM}     |
      | BNP HIPEXT2ID     | HIPEXT21D_${VAR_RANDOM}    |
      | BNP Listing ID    | Listing ID_${VAR_RANDOM}   |
      | RCR BOCI CODE     | BOCI_${VAR_RANDOM}         |
      | RCR ESGA CODE     | ESGA_${VAR_RANDOM}         |
      | RCR MNG CODE      | MNG_${VAR_RANDOM}          |
      | RCR TMBAM CODE    | TMBAM_${VAR_RANDOM}        |
      | RCR THANA CODE    | THANA_${VAR_RANDOM}        |
      | RCR PAMTC CODE    | PAMTC_${VAR_RANDOM}        |



