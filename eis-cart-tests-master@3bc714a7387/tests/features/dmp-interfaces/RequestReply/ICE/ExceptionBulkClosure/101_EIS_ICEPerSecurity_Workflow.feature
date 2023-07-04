#https://jira.pruconnect.net/browse/EISDEV-6253 : Bulk closure of exception: Request Response

@gc_interface_securities @gc_interface_ice
@dmp_regression_unittest
@dmp_smoke @eisdev_6253 @eisdev_6253_ice
Feature: To load response file from ICE BPAM and check if message severity code updated as 30 for missing records in response file

  Scenario: Assign Variables

    Given I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I generate value with date format "hhmmss" and assign to variable "TIMESTAMP"
    And I assign "tests/test-data/dmp-interfaces/RequestReply/ICE/ExceptionBulkClosure" to variable "testdata.path"
    And I assign "ICEBPAM_ESI_PRICE_REF_TEMPLATE.csv" to variable "RESPONSE_INPUT_TEMPLATENAME"
    And I assign "ESI_ICEBPAM_REQUEST_${VAR_SYSDATE}.csv" to variable "request.file"
    And I assign "ICEBPAM_ESI_PRICE_REF.csv" to variable "response.file"
    And I assign "/dmp/out/icebpam" to variable "ICE_DOWNLOAD_DIR"
    And I assign "/dmp/in/icebpam" to variable "ICE_UPLOAD_DIR"

  Scenario: Verify Execution of Workflow with all parameters

    Given I create input file "${response.file}" using template "${RESPONSE_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | POS_DATE | DateTimeFormat:YYYYMMdd |

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to ICE for testing this is to simulate the process of request reply
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${ICE_DOWNLOAD_DIR}":
      | ${response.file} |

    And I rename file "${ICE_DOWNLOAD_DIR}/${response.file}" as "${ICE_DOWNLOAD_DIR}/ICEBPAM_ESI_PRICE_REF_${VAR_SYSDATE}.csv" in the named host "dmp.ssh.inbound"

    And I process ICEPerSecurity workflow with below parameters and wait for the job to be completed
      | ICE_DOWNLOAD_DIRECTORY          | ${ICE_DOWNLOAD_DIR} |
      | ICE_TIMEOUT                     | 300                 |
      | ICE_UPLOAD_DIRECTORY            | ${ICE_UPLOAD_DIR}   |
      | MAX_REQUESTS_PER_FILE           | 100000              |
      | PRICE_POINT_EVENT_DEFINITION_ID | ESIPRPTEOD          |
      | REQUEST_TYPE                    | EIM_ICERefdata      |
      | REQUESTOR_ID                    | EIM                 |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${ICE_UPLOAD_DIR}" after processing:
      | ESI_ICEBPAM_REQUEST_${VAR_SYSDATE}.csv |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    #This check to verify no entries with Severity Code 40.
    Then I expect value of column "VREQ_STATUS_CHECK_40" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 0   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK_40
      FROM   ft_t_ntel
      WHERE  last_chg_trn_id IN (SELECT trn_id
                                 FROM   ft_t_trid
                                 WHERE  job_id = (SELECT prnt_job_id
                                                  FROM   gs_gc.ft_t_jblg
                                                  WHERE  job_id = '${JOB_ID}'))
             AND appl_id = 'VENDOR'
             AND part_id = 'REQREPLY'
             AND notfcn_id = 6
             AND msg_severity_cde = 40
     """

    #This check to verify entries with Severity Code 30.
    Then I expect value of column "VREQ_STATUS_CHECK_30" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) >= 1   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK_30
      FROM   ft_t_ntel
      WHERE  last_chg_trn_id IN (SELECT trn_id
                                 FROM   ft_t_trid
                                 WHERE  job_id = (SELECT prnt_job_id
                                                  FROM   gs_gc.ft_t_jblg
                                                  WHERE  job_id = '${JOB_ID}'))
             AND appl_id = 'VENDOR'
             AND part_id = 'REQREPLY'
             AND notfcn_id = 6
             AND msg_severity_cde = 30
     """
