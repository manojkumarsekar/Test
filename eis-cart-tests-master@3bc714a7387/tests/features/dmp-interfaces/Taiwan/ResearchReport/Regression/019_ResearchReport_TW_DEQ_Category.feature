#https://jira.intranet.asia/browse/TOM-4737

@tom_4737 @researchreport_deq @researchreport_tagging @eisdev_5350 @eisdev_5363

Feature: Loading ResearchReport file to throw error for TW DEQ Buy Sell category.

  Scenario:TC_1: Load file to throw error for TW DEQ BUY SELL category(SELL)

    Given I assign "TW_DEQ_Sell.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"

    And I execute below query
      """
      DELETE FT_T_RSP1 WHERE RSR1_OID IN
      (SELECT RSR1_OID FROM FT_T_RSR1 WHERE EXT_RSRSH_ID = 'https://ppmg.blackrock.com/aladdinresearch/index.html#/link/22919');
      DELETE FT_T_RSR1 WHERE EXT_RSRSH_ID = 'https://ppmg.blackrock.com/aladdinresearch/index.html#/link/22919'
      """

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EITW_MT_RESEARCH_REPORT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Checking NTEL
    Then I expect value of column "ID_COUNT_NTEL" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_NTEL FROM FT_T_NTEL
      WHERE NOTFCN_ID='60001'
      AND NOTFCN_STAT_TYP='OPEN'
      AND PARM_VAL_TXT='User defined Error thrown! . Cannot process file as required field, PortfolioCode is not present in the input record.'
      AND LAST_CHG_TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

    # Checking RSR1
    Then I expect value of column "RSR1_COUNT" in the below SQL query equals to "0":
      """
      SELECT COUNT(1) AS RSR1_COUNT  FROM FT_T_RSR1 WHERE EXT_RSRSH_ID = 'https://ppmg.blackrock.com/aladdinresearch/index.html#/link/22919'
      """

  Scenario:TC_2: Load file for TW DEQ BUY SELL category(BUY)

    Given I assign "TW_DEQ_Buy.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EITW_MT_RESEARCH_REPORT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Checking NTEL
    Then I expect value of column "ID_COUNT_TRID" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_TRID FROM FT_T_TRID
      WHERE CRRNT_SEVERITY_CDE='10'
      AND INPUT_MSG_TYP='EITW_MT_RESEARCH_REPORT'
      AND TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

  Scenario:TC_3: Load file for TW DEQ BUY SELL category(BOTH)

    Given I assign "TW_DEQ_Both.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EITW_MT_RESEARCH_REPORT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Checking NTEL
    Then I expect value of column "ID_COUNT_TRID" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_TRID FROM FT_T_TRID
      WHERE CRRNT_SEVERITY_CDE='10'
      AND INPUT_MSG_TYP='EITW_MT_RESEARCH_REPORT'
      AND TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """

  Scenario:TC_4: Load file for TW OEQ BUY SELL category(SELL)

    Given I assign "TW_OEQ_Sell.xml" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EITW_MT_RESEARCH_REPORT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Checking NTEL
    Then I expect value of column "ID_COUNT_TRID" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS ID_COUNT_TRID FROM FT_T_TRID
      WHERE CRRNT_SEVERITY_CDE='10'
      AND INPUT_MSG_TYP='EITW_MT_RESEARCH_REPORT'
      AND TRN_ID IN ( SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
      """