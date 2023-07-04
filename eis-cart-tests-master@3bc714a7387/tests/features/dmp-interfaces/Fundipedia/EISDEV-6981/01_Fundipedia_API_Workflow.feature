#https://jira.pruconnect.net/browse/EISDEV-6981
#https://collaborate.pruconnect.net/display/EISPRM/Share+class+Integration
#https://collaborate.pruconnect.net/display/EISPRM/Shareclass+portfolio+Relationship
#https://collaborate.pruconnect.net/display/EISTOMR4/ShareClass+Integration
#https://collaborate.pruconnect.net/display/EISTOMR4/ShareClass+Integration+Relationship

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 25/09/2020      EISDEV-6981    Fundipedia API Integration
# ===================================================================================================================================================================================

@gc_interface_fundipedia @dmp_regression_unittest @eisdev_6981 @gc_interface_shareclass @eisdev_7283
Feature: Call Fundipedia API to fetch report and verify details

  This is to test if Fundipedia API is being called and report is fetched in json format and is getting converted to XML

  Background:

#    Given I set the DMP workflow web service endpoint to named configuration "dwh.ws.WORKFLOW"
    Given I set the database connection to configuration "dmp.db.GC"

  Scenario: Assign Variables

    Given  I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-6981" to variable "testdata.path"
    And I assign "/dmp/in/fundipedia/" to variable "FPEDIA_DOWNLOAD_DIR"

  Scenario: Remove files already present in directory

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${FPEDIA_DOWNLOAD_DIR}" if exists:
      | *.xml |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${FPEDIA_DOWNLOAD_DIR}" if exists:
      | *.log |

  Scenario: Run Fundipedia API Process and Load workflow

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_Fundipedia_API_ProcessandLoad/request.xmlt" to variable "PROC_API"
    And I assign "100" to variable "workflow.max.polling.time"

    And I process the workflow template file "${PROC_API}" with below parameters and wait for the job to be completed
      | APIKEY      | 840c3e3b-cc90-420b-a379-67bb73c51666      |
      | APISECRET   | 4953fe2a-ad48-48a4-bfc5-10480b33a6f6      |
      | API_URL     | https://eastspringtest.api.fundipedia.com |
      | MESSAGETYPE | EIS_MT_FUNDIPEDIA_DMP_SHARECLASS_REL      |
      | REPORTID    | 263                                       |
      | REPORTPATH  | ${FPEDIA_DOWNLOAD_DIR}                    |
      | TOKENPATH   | ${FPEDIA_DOWNLOAD_DIR}                    |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${FPEDIA_DOWNLOAD_DIR}" after processing:
      | EISFundipedia_*.xml |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${FPEDIA_DOWNLOAD_DIR}" after processing:
      | reportjson_*.log   |
      | createdtoken_*.log |

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory