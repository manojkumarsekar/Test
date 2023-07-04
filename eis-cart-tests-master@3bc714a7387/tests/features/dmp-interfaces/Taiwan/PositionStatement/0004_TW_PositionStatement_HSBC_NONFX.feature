#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TOMTN&title=Taiwan+Position+Recon+with+Fund+Admin
#https://jira.intranet.asia/browse/TOM-3587
#https://jira.intranet.asia/browse/TOM-4692 Modified mapping of SITCA to portfolio for equity and fixed income splits

@gc_interface_positions
@dmp_regression_unittest
@dmp_taiwan
@tom_3587 @taiwan_position_statement @tom_4615 @tom_4692
Feature: This feature tests the translations performed by DMP on HSBC's non-FX position file prior to forwarding to BRS

  PORTFOLIO         | POS_CUR_PAR | SEC_CURRENCY  | TEST CASE and EXPECTATION
  SITCA-TWTST1      | 56001       | TWD           | Portfolio with split and USD hedge; TWD position; ; map to TWTST1
  SITCA-TWTST1      | 56002       | USD           | Portfolio with split and USD hedge; USD position; ; map to TWTST1_S
  SITCA-TWTST2      | 56003       | TWD           | Portfolio with split but no hedge; TWD position; ; map to TWTST2
  SITCA-TWTST2      | 56004       | USD           | Portfolio with split but no hedgee; USD position; ; map to TWTST2_S
  SITCA-TWTST3      | 56005       | USD           | Portfolio with no split or hedge; USD position; ; map to TWTST3
  SITCA-TWTSTX      | 56006       | USD           | Portfolio doesn't exist in DMP; raise exception
  SITCA-SITCATWTST4 | 56007       | TWD           | Portfolio with split and equity/fixed-income splits; TWD position; neither STOCK nor BOND; map to TWTST4
  SITCA-SITCATWTST4 | 56008       | USD           | Portfolio with split and equity/fixed-income splits; USD position; neither STOCK nor BOND; map to TWTST4_S
  SITCA-SITCATWTST4 | 56009       | USD           | Portfolio with split and equity/fixed-income splits; USD position; STOCK position; map to TWTST4_EQ_S
  SITCA-SITCATWTST4 | 56010       | USD           | Portfolio with split and equity/fixed-income splits; USD position; BOND position; map to TWTST4_FI_S

  Scenario: TC1: Setup test data

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/PositionStatement" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "ESI_BRS_POSITION_NONFX_HSBC.csv" to variable "INPUT_FILENAME"
    And I assign "ESI_BRS_POSITION_HSBC_NONFX_B_${VAR_SYSDATE}.csv" to variable "OUTPUT_FILENAME"

    Then I execute below query
    """
    ${testdata.path}/sql/setup_test_portfolio_data.sql
    """

  Scenario: TC2: Run HSBC non-FX position file transformation

    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}/hsbc":
      | ${INPUT_FILENAME} |

    And I remove below files in the host "dmp.ssh.outbound" from folder "${dmp.ssh.outbound.path}/brs" if exists:
      | ESI_BRS_POSITION_HSBC_NONFX_B*.csv |

    And I set the workflow template parameter "FILE" to "${dmp.ssh.inbound.path}/hsbc/${INPUT_FILENAME}"
    And I set the workflow template parameter "MESSAGE_TYPE" to "EITW_MT_HSBC_NONFX_POSITION_TO_BRS"
    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_StandardFileLoadTransformation/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 300 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

  Scenario: TC3: Check logs for expected error message from HSBC FX position file transformation

    Given I execute below query and extract values of "JOB_ID" into same variables
    """
    SELECT job_id FROM ft_t_jblg jblg WHERE jblg.job_input_txt = '/dmp/in/hsbc/${INPUT_FILENAME}' AND jblg.job_stat_typ = 'CLOSED' AND jblg.job_start_tms = (SELECT MAX(job_start_tms) FROM ft_t_jblg WHERE job_input_txt = jblg.job_input_txt AND job_stat_typ = 'CLOSED')
    """

    Then I expect value of column "SUCCESS_COUNT" in the below SQL query equals to "9":
    """
    SELECT task_success_cnt AS SUCCESS_COUNT FROM ft_t_jblg WHERE job_id = '${JOB_ID}'
    """

    And I expect value of column "PARTIAL_COUNT" in the below SQL query equals to "1":
    """
    SELECT task_partial_cnt AS PARTIAL_COUNT FROM ft_t_jblg WHERE job_id = '${JOB_ID}'
    """

    And I expect value of column "NOTIFICATION_MESSAGE" in the below SQL query equals to "Missing Data Exception:- User defined Error thrown! . Unable to map SITCA code TWTSTX to BRS portfolio code for SEC_CURRENCY  USD":
    """
    SELECT char_val_txt AS NOTIFICATION_MESSAGE FROM ft_t_trid trid, ft_t_ntel ntel WHERE trid.job_id = '${JOB_ID}' AND trid.crrnt_severity_cde = 40 AND ntel.last_chg_trn_id = trid.trn_id
    """

  Scenario: TC4: Compare transformed HSBC FX position file with expected file

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "ESI_BRS_POSITION_HSBC_NONFX_B_${VAR_SYSDATE}.csv" to variable "OUTPUT_FILENAME"

    And I expect below files to be present in the host "dmp.ssh.outbound" into folder "${dmp.ssh.outbound.path}/brs" after processing:
      | ${OUTPUT_FILENAME} |

    And I copy files below from remote folder "/dmp/out/brs" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/PositionStatement/outfiles/runtime":
      | ${OUTPUT_FILENAME} |

    And I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${testdata.path}/outfiles/runtime/${OUTPUT_FILENAME}" and reference CSV file "${testdata.path}/outfiles/expected/${INPUT_FILENAME}" should be successful and exceptions to be written to "${testdata.path}/outfiles/runtime/exceptions_${recon.timestamp}.csv" file

  Scenario: TC5: Teardown test data

    And I execute below query
    """
    DELETE ft_t_acid WHERE acct_id IN (SELECT acct_id FROM ft_t_acct WHERE acct_nme LIKE 'TWTST%');
    DELETE ft_t_acct WHERE acct_nme LIKE 'TWTST%';
    """