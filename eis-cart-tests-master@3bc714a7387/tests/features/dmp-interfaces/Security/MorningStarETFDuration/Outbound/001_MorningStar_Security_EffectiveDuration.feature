#https://jira.pruconnect.net/browse/EISDEV-7127
#Functional specification: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOM&title=3rd+Party+ETF+Duration+for+GAA#businessRequirements-goals
#EISDEV-7169:Bugfix for picking up only weekly SM file loaded securities
#EISDEV-7191: Changing CUSIP to ISIN

@gc_interface_mstar_publish @gc_interface_morningstar @gc_interface_risk_analytics
@dmp_regression_integrationtest
@eisdev_7127 @001_mstar_outbound @eisdev_7169 @eisdev_7191

Feature: Publish morning star Security Eff Duration file

  The purpose of this interface is to publish Security Eff Duration file
  To extract the scope of ETF to be sent to Morningstar weekly / monthly via CLASS type in security master (sec_desc2 in F10) and send to Morning star.
  Morning star will consume this file and generate duration numbers in File 315 for Aladdin to consume and populate the duration numbers for these 3rd party ETFs.

  Scenario: TC1: Initialize variables

    Given I assign "tests/test-data/dmp-interfaces/Security/MorningStarETFDuration/Outbound" to variable "testdata.path"
    And I assign "001_esi_ADX_WEEKLY_MorningStar_Security_EffectiveDuration_sm.xml" to variable "INPUT_F10_FILENAME"
    And I assign "001_MorningStar_Security_EffectiveDuration_f29.xml" to variable "INPUT_F29_FILENAME"

    #Publish files and directory
    And I assign "001_MorningStar_Security_EffectiveDuration_Template.csv" to variable "PUBLISH_FILE_TEMPLATE"
    And I assign "001_MorningStar_Security_EffectiveDuration_Expected" to variable "PUBLISH_FILE_EXPECTED"
    And I assign "001_MorningStar_Security_EffectiveDuration_Actual" to variable "PUBLISH_FILE_ACTUAL"
    And I assign "/dmp/out/mstar/eod" to variable "PUBLISHING_DIRECTORY"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario:TC2: Load Security file

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_F10_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_F10_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario:TC3: Load Risk analytics file

    Given I process "${testdata.path}/inputfiles/testdata/${INPUT_F29_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_F29_FILENAME}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |
      | BUSINESS_FEED |                           |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario:TC4: Publish the Morning Star file

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}_*.csv |

    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISH_FILE_ACTUAL}.csv            |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_MSTAR_EFF_DUR_SECURITY_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.csv |

    Then I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISH_FILE_ACTUAL}*.csv |

  Scenario: TC5: Recon the FixedIncome published file against the expected file

    Given I capture current time stamp into variable "recon.timestamp"

    And I create input file "${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.csv" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.csv |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISH_FILE_ACTUAL}_${VAR_SYSDATE}_1.csv   |