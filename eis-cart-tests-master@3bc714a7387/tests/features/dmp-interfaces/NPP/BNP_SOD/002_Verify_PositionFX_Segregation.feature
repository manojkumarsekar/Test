#TOM:4534 : Initial Version : https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TPSD&title=Requirements
#TOM-4713: Added Feature History
#TOM-4636 : Changed test data path

@gc_interface_positions @gc_interface_npp
@dmp_regression_integrationtest
@dmp_npp @tom_4534 @esi_npp_positionfx @tom_4713 @tom_4636
Feature: 002 | NPP | BNP - DMP | Verify MOPK Data for Positions FX is segreagated into RECON and GP

  As per Non-Processing Portfolio(NPP) project design, we would be receiving the Positions data for Non-Processing Portfolios
  along with existing Processing Portfolios in SOD NON LATAM MOPK. The MOPK data needs to be to segregated into
  Recon File to BRS for Processing Portfolios
  GP File to BRS for Non-Processing Portfolios
  This feature file covers FX file segregation

  Scenario: Assign Variables and Create Input Files with T-1 Data

    Given I assign "tests/test-data/dmp-interfaces/NPP/BNP_SOD" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/sod" to variable "PUBLISHING_DIRECTORY"
    And I assign "300" to variable "workflow.max.polling.time"
    And I assign "posfx_recon" to variable "PUBLISHING_FILE_NAME_RECON"
    And I assign "posfx_gp" to variable "PUBLISHING_FILE_NAME_GP"
    And I assign "ESISODP_POS_1.out" to variable "INPUTFILE_NAME"

    #Create Positions File

    And I execute below query and extract values of "T_1_YYYYMONDD" into same variables
     """
     select TO_CHAR(sysdate-1, 'YYYY-MON-DD') AS T_1_YYYYMONDD from dual
     """

    And I create input file "${INPUTFILE_NAME}" using template "ESISODP_POS_1_template.out" with below codes from location "${TESTDATA_PATH}/inputfiles"
      |  |  |

  Scenario: Set NPP Flag for AYATI4 to Y and END-DATE Identifiers

    Given I execute below query
	"""
    update ft_t_acst set  STAT_CHAR_VAL_TXT = 'Y' where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'AYATI4') and STAT_DEF_ID = 'NPP';
    COMMIT
	"""

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'130662','116124'"

  Scenario: Load POS File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME}                  |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONFX_NONLATAM |
      | BUSINESS_FEED |                                    |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Publish FX Recon File

  #Extract Data

    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_RECON}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_RECON}.csv  |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SOD_POSITION_FX_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv |

  Scenario: Reconcile FX RECON File

    Given I execute below query and extract values of "T_1_YYYYMMDD" into same variables
     """
     select TO_CHAR(sysdate-1, 'YYYYMMDD') AS T_1_YYYYMMDD from dual
     """

    Then I create input file "posfx_recon.csv" using template "posfx_recon_template.csv" with below codes from location "${TESTDATA_PATH}/outfiles"
      |  |  |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/posfx_recon.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_2_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Publish FX GP File

  #Extract Data
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_GP}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_GP}.csv     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SOD_NPP_POSN_FX_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv |

  Scenario: Reconcile FX GP File

    Given I create input file "posfx_gp.csv" using template "posfx_gp_template.csv" with below codes from location "${TESTDATA_PATH}/outfiles"
      |  |  |

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/posfx_gp.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_2_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Set NPP Flag for 16SUNE, ABTHMF to N

    Given I execute below query
	"""
    update ft_t_acst set  STAT_CHAR_VAL_TXT = 'N' where acct_id in (select acct_id from ft_t_acid where acct_alt_id = 'AYATI4') and STAT_DEF_ID = 'NPP';
    COMMIT
	"""