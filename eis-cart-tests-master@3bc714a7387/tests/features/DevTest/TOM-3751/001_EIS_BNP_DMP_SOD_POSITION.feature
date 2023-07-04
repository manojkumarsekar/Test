#https://jira.intranet.asia/browse/TOM-3751

@gc_interface_positions
@dmp_regression_integrationtest
@tom_3751
Feature: Receive leg expected from BNP

  Earlier,leg which comes first in MOPK feed file has been sent to BRS.
  for Example, if both legs are in MOPK file and Pay leg position comes first then Receive leg then Pay leg has been sent to BRS.
  Now, only RECEIVE leg is should be publish to BRS

  Scenario: Providing filename and output directory

    Given I assign "tests/test-data/DevTest/TOM-3751" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+1d" from source format "YYYYMMdd" to destination format "YYYY-MMM-dd" and assign to "AS_OF_TMS"
    And I assign "RP_Case" to variable "PUBLISHING_FILE_NAME_1"
    And I assign "PR_Case" to variable "PUBLISHING_FILE_NAME_2"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/sod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    And I execute below query to "Delete BALH and BHST table"
      """
      ${testdata.path}/sql/delete_BALH.sql
      """

    And I create input file "PR_Diff_leg.out" using template "PR_Diff_leg.out" from location "${testdata.path}"
    And I create input file "RP_diff_leg.out" using template "RP_diff_leg.out" from location "${testdata.path}"

  Scenario: Load files for EIS_BNP_DMP_SOD_EOD_POSITION

    Given I assign "RP_diff_leg.out" to variable "INPUT_FILENAME_1"
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}                   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

     # Checking BALH
    Then I expect value of column "ID_COUNT_BALH_1" in the below SQL query equals to "1":
        """
       SELECT COUNT(*) AS ID_COUNT_BALH_1
       FROM FT_T_BALH
       where instr_id in (select instr_id from ft_t_isid where iss_id='MD_499047'
       and id_ctxt_typ='BNPLSTID'
       and end_tms is null)
       and acct_id in (select acct_id from fT_t_acid where acct_alt_id='ARBRUF'
       and end_tms is null)
       and as_of_tms = trunc(sysdate+1)
       and ldgr_id='0020'
       and rqstr_id='SOD'
        """

  Scenario: Publish RP case file

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_1}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SOD_POSITION_NONFX_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the value for PORTFOLIO in outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if PORTFOLIO ARBRUF has value 10 in the outbound

    Given I expect column "POS_CUR_PAR" value to be "10" where columns values are as below in CSV file "${CSV_FILE}"
      | PORTFOLIO     | ARBRUF    |
      | POS_CUR_PAR   | 10        |
      | SEC_CURRENCY  | INR       |
      | BRS_SEC_ID    | BRTD8M988 |
      | POS_FACE      | 1000000   |
      | BASE_CURRENCY | SGD       |


    And I execute below query to "Delete BALH and BHST table"
    """
    ${testdata.path}/sql/delete_BALH.sql
    """

  Scenario: Load files for EIS_BNP_DMP_SOD_EOD_POSITION

    Given I assign "PR_Diff_leg.out" to variable "INPUT_FILENAME_2"
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                       |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}                   |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |

     # Checking BALH
    Then I expect value of column "ID_COUNT_BALH_2" in the below SQL query equals to "1":
        """
       SELECT COUNT(*) AS ID_COUNT_BALH_2
       FROM FT_T_BALH
       where instr_id in (select instr_id from ft_t_isid where iss_id='MD_499047'
       and id_ctxt_typ='BNPLSTID'
       and end_tms is null)
       and acct_id in (select acct_id from fT_t_acid where acct_alt_id='ARBRUF'
       and end_tms is null)
       and as_of_tms = trunc(sysdate+1)
       and ldgr_id='0020'
       and rqstr_id='SOD'
        """

  Scenario: Publish PR case file

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}.csv         |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SOD_POSITION_NONFX_SUB |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the value for PORTFOLIO in outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

      #Check if PORTFOLIO ARBRUF has value 10 in the outbound

    Given I expect column "POS_CUR_PAR" value to be "10" where columns values are as below in CSV file "${CSV_FILE}"
      | PORTFOLIO     | ARBRUF    |
      | POS_CUR_PAR   | 10        |
      | SEC_CURRENCY  | INR       |
      | BRS_SEC_ID    | BRTD8M988 |
      | POS_FACE      | 1000000   |
      | BASE_CURRENCY | SGD       |