#https://jira.intranet.asia/browse/TOM-3354
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=17629498
# https://jira.intranet.asia/browse/TOM-4780: Adding saveDetails and closeTab steps for Industry Classification
# EISDEV-7051: As part of 6461, Industry Classification template is updated which requires date in timestamp format. Updating input data


@tom_3354 @web @gs_ui_regression @eisdev_7051 @gc_ui_industry_classification
Feature: Create and Delete Industry classification set

  This feature file can be used to check the if Cross reference created for the Industry classification set over UI.

  Scenario: TC_1: Create Industry classification set with RDM Sec type
    Given I login to golden source UI with "administrators" role
    And I generate value with date format "DHs" and assign to variable "VAR_RANDOM"

    When I add Industry Classification Details for Classification set "RDMSCTYP" with following details
      | Class Name                     | VIFO                    |
      | Class Description              | VIFO                    |
      | Classification Value           | VIFO_VAL_${VAR_RANDOM}  |
      | Level Number                   |                         |
      | Classification Created On      | 25-Jul-2018 01:01:18 PM |
      | Classification Effective Until |                         |

    And I save the valid data
    And I close active GS tab

    Then I expect value of column "CCRF_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS CCRF_COUNT FROM FT_T_CCRF
      WHERE CL_VALUE = 'VIFO_VAL_${VAR_RANDOM}'
      AND TRUNC(START_TMS) = TRUNC(SYSDATE)
      AND END_TMS IS NULL
      AND CLSF_OID = (SELECT CLSF_OID
      FROM FT_T_INCL
      WHERE CL_NME = 'VIFO'
      AND CL_VALUE = 'VIFO_VAL_${VAR_RANDOM}'
      AND TRIM(INDUS_CL_SET_ID) = 'RDMSCTYP'
      AND TRUNC(START_TMS) = TO_DATE('25-Jul-2018', 'DD-MON-YYYY')
      AND END_TMS IS NULL)
      """

    When I relogin to golden source UI with "administrators" role

    And I delete Industry Classification Details for Classification set "RDMSCTYP" having following details
      | Class Name                | VIFO                   |
      | Classification Value      | VIFO_VAL_${VAR_RANDOM} |

    And I save the valid data

    Then I expect value of column "CCRF_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(1) AS CCRF_COUNT FROM FT_T_CCRF
      WHERE CL_VALUE = 'VIFO_VAL_${VAR_RANDOM}'
      AND TRUNC(END_TMS) = TRUNC(SYSDATE)
      AND CLSF_OID = (SELECT CLSF_OID
      FROM FT_T_INCL
      WHERE CL_NME = 'VIFO'
      AND CL_VALUE = 'VIFO_VAL_${VAR_RANDOM}'
      AND TRIM(INDUS_CL_SET_ID) = 'RDMSCTYP'
      AND TRUNC(START_TMS) = TO_DATE('25-Jul-2018', 'DD-MON-YYYY')
      AND TRUNC(END_TMS) = TRUNC(SYSDATE))
      """

  Scenario: Close browsers
    Then I close all opened web browsers

  Scenario: TC_2: Create Industry classification set with MLIS Sec type

    Given I login to golden source UI with "administrators" role
    And I generate value with date format "DHs" and assign to variable "VAR_RANDOM"

    When I add Industry Classification Details for Classification set "MLIS" with following details
      | Class Name                     | DIFO                   |
      | Class Description              | DIFO                   |
      | Classification Value           | DIFO VAL ${VAR_RANDOM} |
      | Level Number                   |                        |
      | Classification Created On      | 25-Jul-2018            |
      | Classification Effective Until |                        |

    And I save changes
    And I close active GS tab

    Then I expect value of column "CCRF_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(1) AS CCRF_COUNT FROM FT_T_CCRF
      WHERE CL_VALUE = 'DIFO VAL ${VAR_RANDOM}'
      AND TRUNC(START_TMS) = TRUNC(SYSDATE)
      AND END_TMS IS NULL
      AND CLSF_OID = (SELECT CLSF_OID
      FROM FT_T_INCL
      WHERE CL_NME = 'DIFO'
      AND CL_VALUE = 'DIFO VAL ${VAR_RANDOM}'
      AND TRIM(INDUS_CL_SET_ID) = 'MLIS'
      AND TRUNC(START_TMS) = TO_DATE('25-Jul-2018', 'DD-MON-YYYY')
      AND END_TMS IS NULL)
      """

  Scenario: Close browsers
    Then I close all opened web browsers