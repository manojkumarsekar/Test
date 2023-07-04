#https://jira.pruconnect.net/browse/EISDEV-6253 : Bulk closure of exception: Request Response
#https://jira.pruconnect.net/browse/EISDEV-6623 : Performance upgrade
#https://jira.pruconnect.net/browse/EISDEV-7156 : Suppress Exceptions

@gc_interface_securities
@dmp_regression_unittest
@dmp_gs_upgrade @eisdev_6253 @eisdev_6253_cetrel @eisdev_6623 @eisdev_7156
Feature: To load response file from Cetrel and check if VREQ is updated as failed and no exception is raised for missing records in response file

  Scenario: Verify Execution of Workflow with all parameters

    Given I assign "tests/test-data/dmp-interfaces/RequestReply/Cetrel/ExceptionBulkClosure" to variable "testdata.path"

    And I execute below query to "inactivate account classification to reduce the securities count"
     """
     ${testdata.path}/sql/SetupData.sql
     """

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "UCIO.EODS_RESPONSE_TEMPLATE.CETSECPROD.PAMPROD" to variable "RESPONSE_TEMPLATENAME"
    And I assign "UCII.EOD_20100714_140536226.PAMPROD.CETSECPROD" to variable "request.file"

    And I assign "/dmp/out/cetrel" to variable "CET_DOWNLOAD_DIR"
    And I assign "/dmp/in/cetrel" to variable "CET_UPLOAD_DIR"

    When I copy files below from local folder "${testdata.path}/response" to the host "dmp.ssh.inbound" folder "${CET_DOWNLOAD_DIR}":
      | ${RESPONSE_TEMPLATENAME} |

    And I rename file "${CET_DOWNLOAD_DIR}/${RESPONSE_TEMPLATENAME}" as "${CET_DOWNLOAD_DIR}/UCIO.EODS_${VAR_SYSDATE}_161011691.CETSECPROD.PAMPROD" in the named host "dmp.ssh.inbound"

    And I set the workflow template parameter "CETREL_DOWNLOAD_DIRECTORY" to "${CET_DOWNLOAD_DIR}"
    And I set the workflow template parameter "CETREL_UPLOAD_DIRECTORY" to "${CET_UPLOAD_DIR}"
    And I set the workflow template parameter "CETREL_TIMEOUT" to "3000"
    And I set the workflow template parameter "FIRM_NAME" to "EIS"
    And I set the workflow template parameter "REQUEST_TYPE" to "EIS_Cetrel"
    And I set the workflow template parameter "FILEON_LOCAL" to "false"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_CetrelPerSecurity/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_CetrelPerSecurity/flowResultIdQuery.xpath" to variable "flowResultId"

    #Workflow Verifications
    Then I poll for maximum 600 seconds and expect the result of the SQL query below equals to "DONE":
    """
    SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
    """

    And I expect below files to be present in the host "dmp.ssh.inbound" into folder "${CET_UPLOAD_DIR}" after processing:
      | ${request.file} |

    And I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect 0 exceptions are captured with the following criteria
      | NOTFCN_ID        | 6        |
      | NOTFCN_STAT_TYP  | OPEN     |
      | MSG_SEVERITY_CDE | 40       |
      | APPL_ID          | VENDOR   |
      | PART_ID          | REQREPLY |

  Scenario: Re-activating account classification

    Given I execute below query to "re-activate account classification"
     """
     ${testdata.path}/sql/ResetSetupData.sql
     """