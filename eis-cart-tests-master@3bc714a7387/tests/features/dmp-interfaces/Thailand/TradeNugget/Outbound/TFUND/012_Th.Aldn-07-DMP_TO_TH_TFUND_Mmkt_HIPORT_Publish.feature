#https://jira.pruconnect.net/browse/EISDEV-6817
#Functional Specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=IDX+Money+Market+Transaction+%7CPublish+DMP+to+TMBAM%2CTFUND
#Technical Specification :
# Purpose : The purpose of this file to publish MMkt transactions from DMP to TFUND hiport.

@gc_interface_trades @gc_interface_portfolios @gc_interface_transactions @gc_interface_securities
@dmp_regression_integrationtest
@eisdev_6817 @tfund_mmkt @012_tfund_onmarket_publish @dmp_thailand_hiport @dmp_thailand
Feature: Publish the TFund Mmkt trade in Hiport format

  This feature will test the below scenarios
  1. Load Portfolio files to create portfolios
  2. Load the security file received as part of the trade nugget
  3. Load the transaction file received as part of the trade nugget
  4. Publish the MMkt HiPort file

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/TradeNugget/Outbound/TFUND" to variable "testdata.path"
    And I assign "/dmp/out/thailand/intraday" to variable "PUBLISHING_DIRECTORY"

    #Portfolio Files
    And I assign "Th.Aldn-07-DMP_TO_TH_TFUND_portfolio_uploader.xlsx" to variable "PORTFOLIO_UPLOADER_FILE"
    And I assign "001_Th.Aldn-07-DMP_TO_TH_F54_portfolio.xml" to variable "PORTFOLIO_F54_FILE"
    And I assign "Th.Aldn-07-DMP_TO_TH_TFUND_BRS_port_group.xml" to variable "INPUT_PORTGROUP"

    #Security Files
    And I assign "012_Th.Aldn-07-DMP_TO_TH_BRS_Mmkt_Security_F10_Template.xml" to variable "SECURITY_TEMPLATE"
    And I assign "012_Th.Aldn-07-DMP_TO_TH_BRS_Mmkt_Security_F10" to variable "SECURITY_FILE"

    #Transaction Files
    And I assign "012_Th.Aldn-07-DMP_TO_TH_BRS_Mmkt_Transaction_F11_Template.xml" to variable "TRANSACTION_TEMPLATE"
    And I assign "012_Th.Aldn-07-DMP_TO_TH_BRS_Mmkt_Transaction_F11" to variable "TRANSACTION_FILE"

    #Publish files and directory
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM01_Template.qqq" to variable "PUBLISH_FILE_01_TEMPLATE"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM01_Expected" to variable "PUBLISH_FILE_01_EXPECTED"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM01_Actual" to variable "PUBLISH_FILE_01_ACTUAL"

    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM02_Template.qqq" to variable "PUBLISH_FILE_02_TEMPLATE"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM02_Expected" to variable "PUBLISH_FILE_02_EXPECTED"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM02_Actual" to variable "PUBLISH_FILE_02_ACTUAL"

    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM03_Template.qqq" to variable "PUBLISH_FILE_03_TEMPLATE"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM03_Expected" to variable "PUBLISH_FILE_03_EXPECTED"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM03_Actual" to variable "PUBLISH_FILE_03_ACTUAL"

    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM05_Template.qqq" to variable "PUBLISH_FILE_05_TEMPLATE"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM05_Expected" to variable "PUBLISH_FILE_05_EXPECTED"
    And I assign "012_Th_Aldn-07-DMP_TO_TH_TFTXNMM05_Actual" to variable "PUBLISH_FILE_05_ACTUAL"

    And I execute below query and extract values of "CURR_DATE_1;CURR_DATE_2;CURR_DATE_3;CURR_DATE_4" into same variables
     """
     select TO_CHAR(sysdate, 'MM/DD/YYYY') AS CURR_DATE_1, TO_CHAR(sysdate+1, 'MM/DD/YYYY') AS CURR_DATE_2,
     TO_CHAR(sysdate, 'YYMMDD') AS CURR_DATE_3,TO_CHAR(sysdate+1, 'YYMMDD') AS CURR_DATE_4 from dual
     """

    And I execute below query and extract values of "TRD_VAR_NUM_1" into same variables
     """
     SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS TRD_VAR_NUM_1 FROM DUAL
     """

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I execute below query to "clear transactions being loaded in subsequent steps"
     """
     ${testdata.path}/sql/012_Th.Aldn-07-DMP_TO_TH_BRS_Mmkt_Clear_Trades.sql
     """

  Scenario:TC3: Load the portfolio uploader file, F54 and port group file to create portfolios required for transaction load

    When I process "${testdata.path}/inputfiles/template/${PORTFOLIO_UPLOADER_FILE}" file with below parameters
      | FILE_PATTERN  | ${PORTFOLIO_UPLOADER_FILE}           |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with success record count as "5"

    When I process "${testdata.path}/inputfiles/template/${PORTFOLIO_F54_FILE}" file with below parameters
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${PORTFOLIO_F54_FILE} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO  |

    Then I expect workflow is processed in DMP with success record count as "4"

    When I process "${testdata.path}/inputfiles/template/${INPUT_PORTGROUP}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_PORTGROUP}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |

    Then I expect workflow is processed in DMP with success record count as "8"

  Scenario:TC4: Load the security file, it is prerequisite file for OnMarket Publish

    Given I create input file "${SECURITY_FILE}_${VAR_SYSDATE}.xml" using template "${SECURITY_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${SECURITY_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${SECURITY_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW             |
      | BUSINESS_FEED |                                     |

    Then I expect workflow is processed in DMP with total record count as "4"

  Scenario: TC5: Check if TFUND Transfer Account Number is updated on the security

    Then I expect value of column "TFTACT_1" in the below SQL query equals to "0110102":
    """
	SELECT iss_id AS TFTACT_1
	FROM   ft_t_isid
	WHERE  end_tms IS NULL
		AND id_ctxt_typ = 'TFTACT'
		AND instr_id IN (SELECT instr_id
							FROM   ft_t_isid
							WHERE  id_ctxt_typ = 'BCUSIP'
								AND iss_id = 'BES3FGYT1'
								AND end_tms IS NULL)
    """

  Scenario:TC5: Load the Transaction file, it is prerequisite file for Mmkt Publish

    Given I create input file "${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" using template "${TRANSACTION_TEMPLATE}" from location "${testdata.path}/inputfiles"

    When I process "${testdata.path}/inputfiles/testdata/${TRANSACTION_FILE}_${VAR_SYSDATE}.xml" file with below parameters
      | FILE_PATTERN  | ${TRANSACTION_FILE}_${VAR_SYSDATE}.xml |
      | MESSAGE_TYPE  | EIS_MT_BRS_TH_INTRADAY_TRANSACTION     |
      | BUSINESS_FEED |                                        |

    Then I expect workflow is processed in DMP with success record count as "8"

  Scenario:TC6: Publish Mmkt 01 transaction in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_01_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_01_ACTUAL}.qqq            |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_MKT01_SUB |
      | FOOTER_COUNT                | 1                                        |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_01_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_01_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_01_ACTUAL}*.qqq |

  Scenario: TC7: Recon Mmkt 01 published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_01_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_01_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_01_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_01_ACTUAL}_${VAR_SYSDATE}_1.qqq   |

  Scenario:TC8: Publish Mmkt 02 transaction in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_02_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_02_ACTUAL}.qqq            |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_MKT02_SUB |
      | FOOTER_COUNT                | 1                                        |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_02_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_02_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_02_ACTUAL}*.qqq |

  Scenario: TC9: Recon Mmkt 02 published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_02_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_02_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_02_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_02_ACTUAL}_${VAR_SYSDATE}_1.qqq   |

  Scenario:TC10: Publish Mmkt 03 transaction in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_03_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_03_ACTUAL}.qqq            |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_MKT03_SUB |
      | FOOTER_COUNT                | 1                                        |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_03_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_03_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_03_ACTUAL}*.qqq |

  Scenario: TC11: Recon Mmkt 03 published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_03_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_03_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_03_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_03_ACTUAL}_${VAR_SYSDATE}_1.qqq   |

  Scenario:TC12: Publish Mmkt 05 transaction in Hiport format

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_05_ACTUAL}_*.qqq |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME        | ${PUBLISH_FILE_05_ACTUAL}.qqq            |
      | SUBSCRIPTION_NAME           | EITH_DMP_TO_TFUND_HIPORT_TRADE_MKT05_SUB |
      | FOOTER_COUNT                | 1                                        |
      | EXTRACT_STREETREF_TO_SUBMIT | true                                     |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_05_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_05_ACTUAL}_${VAR_SYSDATE}_1.qqq |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_05_ACTUAL}*.qqq |

  Scenario: TC11: Recon Mmkt 05 published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_05_EXPECTED}_${VAR_SYSDATE}.qqq" using template "${PUBLISH_FILE_05_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type QQQ exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_05_EXPECTED}_${VAR_SYSDATE}.qqq |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_05_ACTUAL}_${VAR_SYSDATE}_1.qqq   |