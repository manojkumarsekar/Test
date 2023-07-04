#https://jira.intranet.asia/browse/TOM-2166

@gc_interface_securities
@dmp_smoke
@tom_2166 @tom_4070
Feature: Loading Standard File Load and verify Data

  Translator throws warning whenever input is xml and it doesn't match with the input xml fed to MDX.
  These warnings can be ignored and hence should not be written in NTEL.
  Filter TRANS WARNING's with NOTFCN_ID=16

  Scenario: Load BRS Xml and Verify no Warnings in FT_T_NTEL table

    Given I assign "FileLoad.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-2166" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
      WHERE NOTFCN_STAT_TYP = 'OPEN'
      AND NOTFCN_ID = '16'
      AND APPL_ID = 'TPS'
      AND PART_ID = 'TRANS'
      AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """





