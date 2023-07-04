#https://jira.pruconnect.net/browse/EISDEV-6711
#https://collaborate.pruconnect.net/pages/viewpage.action?pageId=37309918#businessRequirements--2066775069
# Requirement no: RQ_FR_EDM.SEC_CDR_29

# To download Bloomberg data mneumonics (DY894 | DEAL_CUR_TOTAL_BOND_AMT) and send value under Aladdin Token (ESI_ISS_SEC_DEBT).
# This is for cases where Aladdin security group = MBS, ABS, CMBS, ARM, CMO)
# under portfolios (ALAHYB ALAIGB ALALBF ALAREB ALASBF ALATRF ALESGB ALGEMB ALGMHY ALCBDF).
#  Technical Details : New portfolio group created as GRP_ISS_SEC_DEBT

@dmp_regression_integrationtest @eisdev_6711
@bbpersecurity @dmp_interfaces
@gc_interface_portfolios @gc_interface_positions @gc_interface_cdf @gc_interface_request_reply @gc_interface_securities
@dmp_regression_integrationtest

Feature: Request reply feature to get DY894 | DEAL_CUR_TOTAL_BOND_AMT | CDF Value from Bloomberg

  This testcase validate the BB Request and Reply.
  Account group : GRP_ISS_SEC_DEBT
  RDMSecType : MBS, ABAC
  SecGroup : MBS, ABS, CMBS, ARM, CMO

  Below Steps are followed to validate this testing

  1. Create Portfolio participants for ALAHYB,ALAIGB,ALALBF,ALAREB,ALASBF,ALATRF,ALESGB,ALGEMB,ALGMHY and ALCBDF Portfolios
  2. Load positions using the "EIS_MT_BRS_EOD_POSITION_NON_LATAM" Messagetype
  3. Generate the request file it should contains newly loaded positions
  4. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time
  5. Publish CDF file and perform recon

      BCUSIP          ISIN         RDMSecType     Portfolio   Description
    BRT8PZQS8    TH7647031B04       MBS           ALAHYB       Request file should have this identifier
    BRTAPS2X4    XS1622391552       ABAC          ALAIGB       Request file should have this identifier
    61765DAU2    US61765DAU28       MBS           ALALBF       Request file should have this identifier
    81748HAA7    US81748HAA77       MBS           ALAREB       Request file should have this identifier
    BES3DV4Q9    US01F0306948       MBS           ALASBF       Request file should have this identifier

    Z91CLFMT3    MYBPY0500310      ABAC           D22          Request file should not have this identifier because D22 is not part of GRP_ISS_SEC_DEBT account group
    S68083617    CNE000000DH5      COM            ALATRF       Request file should not have this identifier because RDMSECTYPE should be MBS and ABAC
    SBYV76H60    TH6999010015      COM            NFPLUS       Request file should not have this identifier because RDMSECTYPE should be MBS and ABAC and NFPLUS is not part of GRP_ISS_SEC_DEBT account group

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/RequestReply/Bloomberg/SecMaster" to variable "testdata.path"

    #Position
    And I assign "001_DY894_Position_F14_Template.xml" to variable "INPUT_POSITION_TEMPLATENAME"
    And I assign "001_Th.001_DY894_Position_F14.xml" to variable "INPUT_POSITION_FILENAME"

    #Publishing
    And I assign "esi_brs_sec_cdf_iss_sec_debt" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "001_DY894_ESI_ISS_SEC_DEBT_CDF_out_template.csv" to variable "CDF_MASTER_REFERENCE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CDF_CURR_FILE"


  Scenario:TC2: Create Portfolio participants for GRP_ISS_SEC_DEBT

    Given I execute below query to create paticipants for GRP_ISS_SEC_DEBT
    """
    ${testdata.path}/sql/001_DY894_Insert_ACGP_GRP_ISS_SEC_DEBT.sql
    """

  Scenario:TC3: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I create input file "${INPUT_POSITION_FILENAME}" using template "${INPUT_POSITION_TEMPLATENAME}" with below codes from location "${testdata.path}"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    # Ensure there are no future dated positions (created by other feature files, so rows should be small in number)
    And I execute below query to "clear future dated positions"
     """
     ${testdata.path}/sql/001_DY894_Clean_Future_Dated_BALH.sql
     """

    When I process "${testdata.path}/testdata/${INPUT_POSITION_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_POSITION_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with total record count as "8"

    #This check to verify BALH table MAX(AS_OF_TMS) rowcount with PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "8":
     """
     ${testdata.path}/sql/001_DY894_Check_Positions_Loaded.sql
     """

  Scenario: TC4: Check the BB Request Reply for EIS_Secmaster

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "001_DY894_gs_secmaster_response_template.out" to variable "RESPONSE_TEMPLATENAME"

    #This step is to clear ISMC
    And I execute below query to "clear ISMC"
	"""
	DELETE FROM FT_T_LMST WHERE INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID IN ('TH7647031B04','XS1622391552','US61765DAU28','US81748HAA77','US01F0306948') AND END_TMS IS NULL)
    AND LOAN_OUTST_CQTY IS NOT NULL
	"""

    # Clear VREQ
    And I execute below query to "clear VREQ for re-runs"
	"""
	UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Secmaster' AND
	VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND VND_RQST_XREF_ID IN ('TH7647031B04','XS1622391552','US61765DAU28','US81748HAA77','US01F0306948')
	"""

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EIS_Secmaster                                                            |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/RequestReply/Bloomberg/SecMaster/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                                 |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                       |

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR}             |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}               |
      | FIRM_NAME       | dl790188                       |
      | GROUP_NAME      | Portfolio and Security Group 8 |
      | REQUEST_TYPE    | EIS_Secmaster                  |
      | SN              | 191305                         |
      | USER_NUMBER     | 3650834                        |
      | WORK_STATION    | 0                              |

     #This check to verify if 4 securities which satisfied condition for EISSecmaster were requested and response was loaded.
    Then I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 5   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EIS_Secmaster' AND   VND_RQST_XREF_ID_CTXT_TYP = 'ISIN' AND   VND_RQST_XREF_ID IN (
         'TH7647031B04','XS1622391552','US61765DAU28','US81748HAA77','US01F0306948'
      ) AND   (
          VND_RQST_STAT_TYP = 'CLOSED' OR    (
              VND_RQST_STAT_TYP = 'FAILED' AND VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'
          )
      )
     """

    #This check to verify if ISMC requested and response was loaded.
    Then I expect value of column "LMST_CHECK" in the below SQL query equals to "PASS":
     """
     SELECT
	 CASE
		WHEN COUNT (1) = 2 THEN 'PASS'
		ELSE 'FAIL'
	 END
      AS LMST_CHECK
      FROM FT_T_LMST
      WHERE INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('TH7647031B04','XS1622391552','US61765DAU28','US81748HAA77','US01F0306948'
        ) AND   END_TMS IS NULL
        ) AND LOAN_OUTST_CQTY IS NOT NULL
      """

  Scenario: TC5: Triggering Publishing Wrapper Event for CSV file into directory for CDF

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB      |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC6: Check if published file contains all the records which were loaded for Shares outstanding

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/expected/${CDF_MASTER_REFERENCE} |
      | File2 | ${testdata.path}/outfiles/actual/${CDF_CURR_FILE}          |
