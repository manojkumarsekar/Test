#https://jira.intranet.asia/browse/TOM-3730  (Initial ticket)
#https://jira.intranet.asia/browse/TOM-4796
#https://jira.intranet.asia/browse/TOM-5299 -  Remove mapping of NUMBER_OF_SHARE_OUTSTANDING and ISIN fields in outbound to publish blank for these fields
#https://jira.intranet.asia/browse/TOM-5351 - Include shareclasses of the portfolio group main portfolio participants in filter query for BP NAV publish
#https://jira.pruconnect.net/browse/EISDEV-6194 : this portfolio is now included in exclusion, Updated script to load the data. Also corrected ff to run on Monday for Friday date
#https://jira.pruconnect.net/browse/EISDEV-6223 : re-write feature file to load T-1 runtime
#https://jira.pruconnect.net/browse/EISDEV-6471 : to fix the recon filure while regression
#https://jira.pruconnect.net/browse/EISDEV-6638 : to fix the recon filure while regression

@gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@dmp_taiwan
@tom_4796 @tom_3730 @tom_4873 @tom_5299 @tom_5351 @eisdev_5571 @hsbc_ssb_nav @eisdev_6194 @eisdev_6223 @eisdev_6638
Feature: Load the data for HSBC and SSB and published data fro BNP

  Load the data for HSBC and SSB for T-1 Date
  Load the data for HSBC and SSB for T Date
  Publish Nav File

  Scenario: set-up pre-requisite and assign variables

    Given I assign "esi_nav_ssb_hsbc" to variable "PUBLISHING_FILE_NAME"
    And I assign "HSBC_NAV_T_1" to variable "HSBC_NAV_T_1"
    And I assign "HSBC_NAV_T" to variable "HSBC_NAV_T"
    And I assign "SSB_NAV_T_1" to variable "SSB_NAV_T_1"
    And I assign "SSB_NAV_T" to variable "SSB_NAV_T"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "OUTPUT_FILE"
    And I assign "001_BNP_OUTBOUND_NAV.csv" to variable "MASTER_FILE"
    And I assign "001_BNP_OUTBOUND_NAV_TEMPLATE.csv" to variable "OUTPUT_TEMPLATENAME"
    And I assign "/dmp/out/bnp" to variable "PUBLISHING_DIR"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/NAV" to variable "testdata.path"

    # Setup Account group participant(ACGP)
    And I execute below query to "setup Account group participant"
    """
     ${testdata.path}/sql/SetupData_NAV_ACGP.sql
    """

    And I execute below query and extract values of "MAXASOFTMS_TEMP" into same variables
    """
    SELECT to_char(max(as_of_tms),'YYYY/MM/DD') as MAXASOFTMS_TEMP
    FROM ft_t_accv accv
    WHERE data_src_id IN ('HSBC','SSB')
    """

    And I execute below query and extract values of "MAXASOFTMSMINUS1_TEMP" into same variables
    """
    select to_char(max(GREG_DTE),'YYYY/MM/DD') as MAXASOFTMSMINUS1_TEMP
    from fT_T_cadp where bus_dte_ind ='Y' and cal_id = 'PRPTUAL'
    and trunc(greg_dte) <
    (select trunc(max(as_of_tms)) from fT_T_accv ACCV where data_src_id in ('HSBC','SSB'))
    """

    And I execute below query to "Delete existing positions for ${MAXASOFTMS_TEMP} and ${MAXASOFTMSMINUS1_TEMP}"
    """
    delete ft_t_accv where as_of_tms = to_date('${MAXASOFTMS_TEMP}','YYYY/MM/DD');
    delete ft_t_accv where as_of_tms = to_date('${MAXASOFTMSMINUS1_TEMP}','YYYY/MM/DD');
    COMMIT
    """

  Scenario: Create Test Data from Template

    Given I create input file "${HSBC_NAV_T_1}.csv" using template "${HSBC_NAV_T_1}_TEMPLATE.csv" from location "${testdata.path}/inputfiles"
    And I create input file "${HSBC_NAV_T}.csv" using template "${HSBC_NAV_T}_TEMPLATE.csv" from location "${testdata.path}/inputfiles"

    And I modify date "${MAXASOFTMS_TEMP}" with "+0d" from source format "YYYY/MM/dd" to destination format "YYYYMMdd" and assign to "MAXASOFTMS"
    And I modify date "${MAXASOFTMSMINUS1_TEMP}" with "+0d" from source format "YYYY/MM/dd" to destination format "YYYYMMdd" and assign to "MAXASOFTMSMINUS1"

    And I create input file "${SSB_NAV_T_1}.csv" using template "${SSB_NAV_T_1}_TEMPLATE.csv" from location "${testdata.path}/inputfiles"
    And I create input file "${SSB_NAV_T}.csv" using template "${SSB_NAV_T}_TEMPLATE.csv" from location "${testdata.path}/inputfiles"

  Scenario: Load HSBC NAV Price for T-1 Date
  Verify HSBC NAV Price for T-1 Date is Successfully Loaded with Success Count 1

    Given I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${HSBC_NAV_T_1}.csv |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${HSBC_NAV_T_1}.csv    |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Load HSBC NAV Price for T Date
  Verify HSBC NAV Price for T Date is Successfully Loaded with Success Count 1

    Given I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${HSBC_NAV_T}.csv |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                        |
      | FILE_PATTERN  | ${HSBC_NAV_T}.csv      |
      | MESSAGE_TYPE  | EITW_MT_HSBC_NAV_PRICE |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Load SSB NAV Price for T-1 Date
  Verify SSB NAV Price for T-1 Date is Successfully Loaded with Success Count 1

    Given I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SSB_NAV_T_1}.csv |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SSB_NAV_T_1}.csv    |
      | MESSAGE_TYPE  | EITW_MT_SSB_NAV_PRICE |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Load SSB NAV Price for T Date
  Verify SSB NAV Price for T Date is Successfully Loaded with Success Count 1

    Given I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SSB_NAV_T}.csv |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                       |
      | FILE_PATTERN  | ${SSB_NAV_T}.csv      |
      | MESSAGE_TYPE  | EITW_MT_SSB_NAV_PRICE |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Generate output data for BNP
  Publish output file for BNP

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    Then I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BNP_PRICE_NAV_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/dmp-interfaces/Taiwan/NAV/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

  Scenario: Recon output file
  Re-con output file for BNP with existing template

    Given I create input file "${MASTER_FILE}" using template "${OUTPUT_TEMPLATENAME}" from location "${testdata.path}/outfiles"
    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/testdata/${MASTER_FILE}" should exist in file "${testdata.path}/outfiles/runtime/${OUTPUT_FILE}" and exceptions to be written to "${testdata.path}/outfiles/runtime/${OUTPUT_FILE}_exceptions_${recon.timestamp}.csv" file
