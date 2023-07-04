#https://jira.intranet.asia/browse/TOM-4276

@tom_4276
Feature: Verify no duplicate trades present in database and trade update is successful

  Scenario: Load Trade file for duplicate records were present in db for combination of trd_dte, trd_id, trn_cde and different instrument
  Expected Result: 1) File should load sucessfully
  2) Verify there are duplicate records present in db for combination of trd_dte, trd_id, trn_cde and different instrument

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"
    And I assign "duplicate_trdid.xml" to variable "INPUT_FILENAME"

    And I copy files below from local folder "${testdata.path}/infiles/0010" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='1'
      """

    # Check if EXTR is updated successfully without creating duplicate
    And I expect value of column "EXTR_PROCESSED_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS EXTR_PROCESSED_ROW_COUNT
      FROM FT_T_EXTR
      WHERE TRD_ID = '3547-202'
      AND END_TMS IS NULL
      """

    #Check whether there are duplicate records present in db for combination of trd_dte, trd_id, trn_cde and different instrument
    And I expect value of column "DUPLICATE_TRD_COUNT" in the below SQL query equals to "0":
      """
         SELECT COUNT(*) AS DUPLICATE_TRD_COUNT FROM
         (SELECT trd_dte, trd_id, trn_cde
          FROM ft_t_extr
          WHERE end_tms IS NULL
          GROUP BY
          trd_dte, trd_id, trn_cde
          HAVING COUNT(instr_id) > 1)
      """
