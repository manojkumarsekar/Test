#TOM:4534 : Initial Version : #https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=TPSD&title=Requirements
#TOM:4705: Modified the template as CUSIP was added to the security
#TOM:4709: As part of regression, other feature file are loading T date position due to which the max date changes.
# Added Scenario to Delete BALH for T-2 days to load T-1 and recon.
#TOM-4713: Added Feature History
#TOM-4636 : Added the Check for SOD and BNPNPSOD Requester Id

@gc_interface_positions @gc_interface_npp
@dmp_regression_integrationtest
@tom_4534 @esi_npp_positionnonfx @tom_4705 @tom_4709 @tom_4713 @tom_4636
Feature: 001 | NPP | BNP - DMP | Verify MOPK Data for Positions NON FX is segreagated into RECON and GP

  As per Non-Processing Portfolio(NPP) project design, we would be receiving the Positions data for Non-Processing Portfolios
  along with existing Processing Portfolios in SOD NON LATAM MOPK. The MOPK data needs to be to segregated into
  Recon File to BRS for Processing Portfolios
  GP File to BRS for Non-Processing Portfolios
  This feature file covers NON-FX file segregation

  Scenario: Assign Variables and Create Input Files with T-1 Data

    Given I assign "tests/test-data/dmp-interfaces/NPP/BNP_SOD" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/sod" to variable "PUBLISHING_DIRECTORY"
    And I assign "300" to variable "workflow.max.polling.time"
    And I assign "posnonfx_recon" to variable "PUBLISHING_FILE_NAME_RECON"
    And I assign "posnonfx_gp" to variable "PUBLISHING_FILE_NAME_GP"
    And I assign "ESISODP_SDP_1.out" to variable "INPUTFILE_NAME"

    And I execute below query and extract values of "T_1_YYYYMONDD" into same variables
     """
     select TO_CHAR(sysdate-1, 'YYYY-MON-DD') AS T_1_YYYYMONDD from dual
     """
    And I create input file "${INPUTFILE_NAME}" using template "ESISODP_SDP_1_template.out" from location "${TESTDATA_PATH}/inputfiles"

  Scenario: Set NPP Flag for 16SUNE, ABTHMF to Y
   #Based on NPP Flag, the data is segragated into Recon and GP file. Setting NPP Flag for 16SUNE, ABTHMF to Y for testing purposes.
   #The flag is removed post publishing as part of the feature file

    Given I execute below query
	"""
    update ft_t_acst set  STAT_CHAR_VAL_TXT = 'Y' where acct_id in (select acct_id from ft_t_acid where acct_alt_id in ('16SUNE','ABTHMF')) and STAT_DEF_ID = 'NPP';
    COMMIT
	"""

  Scenario: DELETE T-2 BALH
    # As part of regression, other feature file are loading T date position due to which the max date changes.
    # Added Scenario to Delete BALH for T-2 days to load T-1 and recon.

    Given I execute below query
	"""
    DELETE FT_T_BHST WHERE BALH_OID IN (SELECT BALH_OID FROM FT_T_BALH WHERE AS_OF_TMS > SYSDATE -2);
    DELETE FT_T_BALH WHERE AS_OF_TMS > SYSDATE-2;
    COMMIT
	"""

  Scenario: Load SDP File

    When I copy files below from local folder "${TESTDATA_PATH}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUTFILE_NAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUTFILE_NAME}                     |
      | MESSAGE_TYPE  | EIS_MT_BNP_SOD_POSITIONNONFX_NONLATAM |
      | BUSINESS_FEED |                                       |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
    SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
    AND JOB_STAT_TYP ='CLOSED'
    """

  Scenario: Verify Positions for Processing Portfolio are loaded with Requester Id SOD

    Given I expect value of column "SOD_POS_COUNT" in the below SQL query equals to "4":
    """
    select count(*) as SOD_POS_COUNT from ft_t_balh where RQSTR_ID = 'SOD'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id in ('18STAR','ADDMFI'))
    and as_of_tms = to_date('${T_1_YYYYMONDD}','YYYY-MON-DD')
    """

  Scenario: Verify Positions for Non Processing Portfolio are loaded with Requester Id BNPNPSOD

    Given I expect value of column "BNPNPSOD_POS_COUNT" in the below SQL query equals to "6":
    """
    select count(*) as BNPNPSOD_POS_COUNT from ft_t_balh where RQSTR_ID = 'BNPNPSOD'
    and acct_id in (select acct_id from ft_t_acid where acct_alt_id in ('16SUNE','ABTHMF'))
    and as_of_tms = to_date('${T_1_YYYYMONDD}','YYYY-MON-DD')
    """

  Scenario: Publish NON FX Recon File

  #Extract Data
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_RECON}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_RECON}.csv     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SOD_POSITION_NONFX_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv |

  Scenario: Reconcile NON FX Recon File

    Given I execute below query and extract values of "T_1_YYYYMMDD" into same variables
     """
     select TO_CHAR(sysdate-1, 'YYYYMMDD') AS T_1_YYYYMMDD from dual
     """

    Then I create input file "posnonfx_recon.csv" using template "posnonfx_recon_template.csv" from location "${TESTDATA_PATH}/outfiles"

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_RECON}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/posnonfx_recon.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/001_exceptions_${recon.timestamp}.csv" file

  Scenario: Publish NON FX GP File

  #Extract Data
    Given I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_GP}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_GP}.csv        |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_SOD_NPP_POSN_NONFX_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv |

  Scenario: Reconcile NON FX GP File

    Given I create input file "posnonfx_gp.csv" using template "posnonfx_gp_template.csv" from location "${TESTDATA_PATH}/outfiles"

    When I capture current time stamp into variable "recon.timestamp"

    Then I expect reconciliation between generated CSV file "${TESTDATA_PATH}/outfiles/runtime/${PUBLISHING_FILE_NAME_GP}_${VAR_SYSDATE}_1.csv" and reference CSV file "${TESTDATA_PATH}/outfiles/testdata/posnonfx_gp.csv" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/002_2_1_exceptions_${recon.timestamp}.csv" file

  Scenario: Set NPP Flag for 16SUNE, ABTHMF to N

    Given I execute below query
	"""
    update ft_t_acst set  STAT_CHAR_VAL_TXT = 'N' where acct_id in (select acct_id from ft_t_acid where acct_alt_id in ('16SUNE','ABTHMF')) and STAT_DEF_ID = 'NPP';
    COMMIT
	"""