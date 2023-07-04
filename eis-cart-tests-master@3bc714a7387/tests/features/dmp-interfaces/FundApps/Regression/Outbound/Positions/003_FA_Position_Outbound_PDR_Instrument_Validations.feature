#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=01.+Outbound+FundApps+Position+File#MainDeck--1455554384
# Dev Ticket    : https://jira.intranet.asia/browse/TOM-4123
#Testing Ticket  : https://jira.intranet.asia/browse/TOM-4492

#EISDEV-5365: Changes for Additional PDR Handling. For instrument with RDMSCTYP=PDR, the DRTYPE will be PDR
  #and additional attribute ClassPDRsOutstanding will be shown. As currently there is no system to set up a
  #PDR instrument, setting up a test instrument and sending an update script for it and keeping
  #ClassPDRsOutstanding as default value 1.

#EISDEV-6930: Load test funds; use PDR test instrument for assertions
@gc_interface_securities @gc_interface_positions
@dmp_regression_integrationtest
@fa_outbound @fa_outbound_positions @dmp_fundapps_regression @dmp_gs_upgrade
@eisdev_5365 @eisdev_6306 @eisdev_6913 @eisdev_7158
Feature: FundApps_Positions_Outbound : Verify fund apps Outbound Positions published with TotalVotingRights and TotalVotingShares as per Exchange country code
  As a user I should able to publish fundapps positions with TotalVotingRights and TotalVotingShares as per Exchange country code
  and I should able to load all TBAM inbound and Reuters files successfully.

  Scenario: Prerequisite - Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/Positions" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "600" to variable "workflow.max.polling.time"
    And I assign "outbound_positions_pdr" to variable "PUBLISHING_FILE_NAME"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MM-dd" and assign to "SNAPSHOT_DATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "BRS_AS_OF_DATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"

  Scenario: Prerequisite - End dating Instruments to reload the same set of records
  This scenario set END_TMS as SYSDATE in FT_T_ISID table for all TBAM instruments

    When I extract below values from the xml file "${TESTDATA_PATH}/infiles/Instruments/TMBAM_sm_PDR.xml"  with xpath or tagName at index 0 and assign to variables:
      | CUSIP                                              | RCR_CUSIP |
      | //CUSIP_ALIAS_set/CUSIP_ALIAS_record[1]/IDENTIFIER | RCR_ISIN  |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${RCR_CUSIP}','${RCR_ISIN}','${RCR_SEDOL}'"

  Scenario: Load Instruments file for TBAM

    When I process "${TESTDATA_PATH}/infiles/Instruments/TMBAM_sm_PDR.xml" file with below parameters
      | FILE_PATTERN  | TMBAM_sm_PDR.xml        |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Load TBAM Fund File

    When I process "${TESTDATA_PATH}/infiles/Funds/TBAMEISLFUNDLE.csv" file with below parameters
      | FILE_PATTERN  | TBAMEISLFUNDLE*       |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_FUND |
      | BUSINESS_FEED |                       |

    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: Load Positions data for TBAM
    Given I create input file "TMBAMPOSITN.xml" using template "TMBAMPOSITN_PDR_Template.xml" from location "${TESTDATA_PATH}/infiles/Positions"
    When I process "${TESTDATA_PATH}/infiles/Positions/testdata/TMBAMPOSITN.xml" file with below parameters
      | FILE_PATTERN  | TMBAMPOSITN.xml                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: Create dummy data for PDR
    Given I execute below query to "Update and set up dummy PDR instrument RDMSecType"
    """
    UPDATE FT_T_ISCL set CL_VALUE='PDR', clsf_oid = (select CLSF_OID from ft_t_incl where indus_cl_set_id='RDMSCTYP' and cl_value='PDR')
    where indus_cl_set_id='RDMSCTYP' and instr_id in (select instr_Id from ft_t_isid where iss_id='TESTPDR' and end_tms is null);
    """

  Scenario: Refresh FT_V_LPD2

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "STORED_PROCEDURE"

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_refresh_ft_v_lpd2 |

  Scenario: Publish outbound position File
    Given I assign "outbound_positions_expected.xml" to variable "REFERENCE_POSITIONS_FILE_NAME"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml" to variable "ACTUAL_POSTIONS_FILE_NAME"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.xml      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_POSITION_SUB |
      | XML_MERGE_LEVEL      | 2                                |
      | PUBLISHING_BULK_SIZE | 50                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.xml |

  Scenario: Extract ISS_ID (ID_CTXT_TYP='EISLSTID') and Instrument name (ISS_NME) from dmp for TBAM Instruments

    Given I extract below values from the xml file "${TESTDATA_PATH}/infiles/Instruments/TMBAM_sm_PDR.xml"  with xpath or tagName at index 0 and assign to variables:
      | //CUSIP_ALIAS_set/CUSIP_ALIAS_record[1]/IDENTIFIER | ISIN_TBAM1 |

    And I assign "${ISIN_TBAM1}" to variable "RCR_ISIN"
    When I execute below query and extract values of "ISS_ID;ISS_NME" into same variables
    """
    ${TESTDATA_PATH}/sql/Iss_Id_And_Iss_Nme_Extraction.sql
    """

    Then  I assign "${ISS_ID}" to variable "ISS_ID_TBAM1"
    And   I assign "${ISS_NME}" to variable "ISE_NME_TBAM1"

  Scenario: Verify all PDR Attributes related to PDR instrument
  Extract Instrument outbound field values from actual outbound positions file and verify fields are published as expected

    When I extract attribute values from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and assign to variables:
      | xpath                                               | attributeName        | variableName   |
      | //Instruments//ADR[@InstrumentId='${ISS_ID_TBAM1}'] | DRType               | DR_TYPE        |
      | //Instruments//ADR[@InstrumentId='${ISS_ID_TBAM1}'] | ClassPDRsOutstanding | CLASS_PDR_OUTS |

    And I expect the value of var "${DR_TYPE}" equals to "PDR"
    And I expect the value of var "${CLASS_PDR_OUTS}" equals to "1"

