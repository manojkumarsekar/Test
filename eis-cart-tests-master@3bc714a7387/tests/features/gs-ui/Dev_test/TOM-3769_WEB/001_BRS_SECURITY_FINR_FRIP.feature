#https://jira.intranet.asia/browse/TOM-3769

@tom_3769 @dmp_interfaces @gs_ui_regression @eisdev_6754
Feature: load file tp setup FT_T_FINR and FT_T_FRIP

  Duplicate trustee are shown in the drop down for Institution Roles so we have migrate the data in FT_T_FINR and FT_T_FRIP.
  and delete the duplicate entry.

  Scenario: Load files for EIS_BRS_DMP_SECURITY

    Given I assign "BRS_SEC.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3769" to variable "testdata.path"

    Given I assign "BRS_SEC.xml" to variable "INPUT_FILENAME"

    # Clear data from FINS and its Child table
    And I execute below query
      """
      ${testdata.path}/sql/001_ClearFRIP_FINR.sql
      """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I expect value of column "ID_COUNT_FINR" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FINR
     FROM FT_T_FINR
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FIID WHERE FINS_ID ='G93302')
     AND FINSRL_TYP='GUARNTOR'
      """
    Then I expect value of column "ID_COUNT_FRIP" in the below SQL query equals to "1":
      """
     SELECT COUNT(*) AS ID_COUNT_FRIP
     FROM FT_T_FRIP
     WHERE INST_MNEM IN (SELECT INST_MNEM FROM Ft_t_FIID WHERE FINS_ID ='G93302')
     AND FINSRL_TYP='GUARNTOR'
      """

  @web
  Scenario: Verify 'Trustee' in Institution Role Type values

    Given I login to golden source UI with "task_assignee" role
    When I select from GS menu "Security Master::Institution"
    And I pause for 1 seconds
    And I click the web element "${gs.web.menu.Setup}"
    And I pause for 1 seconds
    And I click the web element "${gs.web.setup.CreateNew}"

    And I click the web element "${gs.web.institution.Role}"
    And I pause for 1 seconds

    And I click the web element "${gs.web.institution.Role.AddDetails}"
    And I pause for 1 seconds

    And I expect dropdown field with property "xpath://div[contains(@id,'InstitutionRoleType')]//input" should contain below values with counts
      | Trustee | 1 |

  @web
  Scenario: Close all browsers
    Then I close all opened web browsers
