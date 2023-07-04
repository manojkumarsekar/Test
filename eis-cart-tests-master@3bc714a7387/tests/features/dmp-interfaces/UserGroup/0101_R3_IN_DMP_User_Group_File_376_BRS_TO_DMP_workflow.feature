#https://jira.intranet.asia/browse/TOM-3781
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48892138

@dmp_user_group @tom_3781
Feature: Inbound User Group Interface Testing (R3.IN.DMP User Group BRS to DMP)

  Data Management Platform (DMP) Workflow Regression Suite
  The Data Management Platform (DMP) which is implemented using Golden Source solutions, exposes workflow for inbound/outbound

  Scenario: TC_1: Clear the User Group Data as a Prerequisite

    Given I assign "esi_users_groups_test_file_for_verification.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/UserGroup" to variable "testdata.path"

    And I execute below query
    """
    ${testdata.path}/sql/ClearData_UserGroup.sql
    """

  Scenario: TC_2: Process BRS User Group Data to DMP : Data Loading

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
     | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
    | BUSINESS_FEED |                       |
    | FILE_PATTERN  | ${INPUT_FILENAME}     |
    | MESSAGE_TYPE  | EIS_MT_BRS_USER_GROUP |

  Scenario: TC_3: Data Verifications

 # Validation 1: User Group - Total Successfully Processed FPRO Records => 3 records should be created in FPRO
    Then I expect value of column "FPRO_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
      """
      ${testdata.path}/sql/FPRO_Processed_Row_Count.sql
      """
# Validation 2: User Group - Total Successfully Processed FPID Records => 6 records should be created in FPID. 3 for Login and 3 for Initials
    Then I expect value of column "FPID_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
      """
      ${testdata.path}/sql/FPID_Processed_Row_Count.sql
      """

# Validation 3: User Group - Total Successfully Processed FPGU Records => 3 records should be created in FPGU
    Then I expect value of column "FPGU_PROCESSED_ROW_COUNT" in the below SQL query equals to "3":
      """
      ${testdata.path}/sql/FPGU_Processed_Row_Count.sql
      """
# Validation 4: User Group - Total Successfully Processed ADTP Records => 2 records should be created in ADTP
    Then I expect value of column "ADTP_PROCESSED_ROW_COUNT" in the below SQL query equals to "2":
      """
      ${testdata.path}/sql/ADTP_Processed_Row_Count.sql
      """

