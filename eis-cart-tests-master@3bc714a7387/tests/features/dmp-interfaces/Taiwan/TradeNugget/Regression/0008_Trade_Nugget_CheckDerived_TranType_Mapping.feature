#https://jira.intranet.asia/browse/TOM-3844
#https://collaborate.intranet.asia/display/TOMR4/R5.IN-TRAN10+Aladdin-%3EDMP+TW+Trades
#EISDEV-6582: as part of this jira, new transaction types have been added. fixing ff to include new codes
#EISDEV-6876: as part of EISDEV-6690, new transaction types have been added. fixing ff to include new codes

@gc_interface_transactions
@dmp_regression_unittest
@dmp_taiwan
@tom_3844 @tom_3385 @tw_derived_trantype @eisdev_6582 @eisdev_6644 @eisdev_6876
Feature: TW Intraday Trades Interface Testing (R5.IN-TRAN10 Trades BRS to DMP) - Verify Different derived TRAN_TYPE store the correct decode value in FT_T_ETCL table

  Scenario: TC1: Clear table data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/TradeNugget" to variable "testdata.path"

    And I execute below query
    """
     UPDATE FT_T_EXTR SET END_TMS = SYSDATE
     WHERE TRD_ID IN ('12627-11','12627-12','12627-13','12627-14','12627-15','12627-16','12627-17','12627-18','12627-19','12627-20','12627-21','12627-22','12627-23','12627-24','12627-25','12627-26')
     AND END_TMS IS NULL;
     COMMIT
    """

    And I execute below query
    """
    UPDATE FT_T_ETID SET END_TMS = SYSDATE
    WHERE EXEC_TRN_ID IN ('12627-11','12627-12','12627-13','12627-14','12627-15','12627-16','12627-17','12627-18','12627-19','12627-20','12627-21','12627-22','12627-23','12627-24','12627-25','12627-26')
    AND EXEC_TRN_ID_CTXT_TYP = 'BRSTRNID' AND END_TMS IS NULL;
    COMMIT
    """

    And I execute below query and extract values of "PORTFOLIO_NAME" into same variables
     """
     SELECT ACCT_ALT_ID AS PORTFOLIO_NAME FROM ft_t_acid where acct_id_ctxt_typ = 'CRTSID' AND ACCT_ALT_ID like 'TT%'  AND end_tms IS NULL  ORDER  BY 1 DESC
     """

#  Needs to be updated if BRS is sending the code and decode value for (REP::-, CMAT::-, COLL::-) once confirmed by Ying
  Scenario: TC2: Load Trades file for new Bond Local security transaction in portfolio TT56
  Expected Result: 1) File should load and make entry in jblg
  2) Verify a new record created for this transaction and all the required fields are mapped properly in DMP

    Given I assign "Derived_TranType_Tem.xml" to variable "INPUT_TEMPLATE_FILENAME"
    And I assign "Derived_TranType.xml" to variable "INPUT_FILENAME"

    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATE_FILENAME}" with below codes from location "${testdata.path}/infiles"
      |  |  |

    And I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                 |
      | FILE_PATTERN  | ${INPUT_FILENAME}               |
      | MESSAGE_TYPE  | EIS_MT_BRS_INTRADAY_TRANSACTION |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}' and TASK_SUCCESS_CNT ='15'
      """

    # Check if ETCL is created with data present in the test file(TRAN_TYPE_DERIV,TRD_FLAGS,TRAN_TYPE)
    And I expect value of column "ETCL_PROCESSED_ROW_COUNT" in the below SQL query equals to "15":
      """
      SELECT COUNT(*) AS ETCL_PROCESSED_ROW_COUNT FROM FT_T_ETCL
      WHERE INDUS_CL_SET_ID IN ('BRSTRTYP')
      AND  EXEC_TRD_ID IN ( SELECT EXEC_TRD_ID FROM FT_T_EXTR
      WHERE TRD_ID IN ('12627-11','12627-12','12627-13','12627-14','12627-15','12627-16','12627-17','12627-18','12627-19','12627-20','12627-21','12627-22','12627-23','12627-24','12627-25','12627-26') AND END_TMS IS NULL
      )
      """

  Scenario: TC3:Verify Trans_Type decode value mapping in DMP with BRS catelog mapping

    Given I export below sql query results to CSV file "${testdata.path}/outfiles/DMP_FT_T_EINC_Data.csv"
    """
    SELECT EXT_CL_VALUE AS CDE,CL_VALUE AS DECDE  FROM FT_T_EINC WHERE indus_cl_set_id='BRSTRTYP'
    """

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/DMP_FT_T_EINC_Data.csv" and reference CSV file "${testdata.path}/infiles/regression/BRS_Tran_Type_Decodes.csv" should be successful and exceptions to be written to "${testdata.path}/outfiles/FT_T_EINC_exceptions_${recon.timestamp}.csv" file


