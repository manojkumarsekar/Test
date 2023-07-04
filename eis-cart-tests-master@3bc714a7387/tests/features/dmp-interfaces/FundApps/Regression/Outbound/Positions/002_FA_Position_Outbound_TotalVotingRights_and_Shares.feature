#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=01.+Outbound+FundApps+Position+File#MainDeck--1455554384
# Dev Ticket    : https://jira.intranet.asia/browse/TOM-4123
#Testing Ticket  : https://jira.intranet.asia/browse/TOM-4492

#EISDEV-5242: Adding scenario for TotalVotingRights and TotalVotingShares as per Exchange country code
#EISDEV-6929: Load test funds
@gc_interface_securities @gc_interface_positions @gc_interface_reuters
@dmp_regression_integrationtest
@fa_outbound @fa_outbound_positions @dmp_fundapps_regression @dmp_gs_upgrade
@eisdev_5242 @eisdev_6306 @eisdev_6913 @eisdev_7157
Feature: FundApps_Positions_Outbound : Verify fund apps Outbound Positions published with TotalVotingRights and TotalVotingShares as per Exchange country code
  As a user I should able to publish fundapps positions with TotalVotingRights and TotalVotingShares as per Exchange country code
  and I should able to load all TBAM inbound and Reuters files successfully.

  TotalVotingRights and TotalVotingShares as per Exchange country code

  Adding scenario for TotalVotingRights and TotalVotingShares as per Exchange country code"
  Test Case                             | ISIN	      | Exchange Country	| TotalVotingRights	      | TotalVotingShares
  Exchange country out of group:        | TW0002330008|	TW	                | 25930380002	          | 25930380001
  Exhange country Group 1 (not IL)      | FR0000120644|	FR	                | 715398002	              | 686120803
  Exchange country Group 2 (Both values)| FI0009000681|	FI	                | 25930380450+25930380450 | 25930380453+25930380453
  Exchange Country Group 3	            | BRABEVACNOR1|	BR	                | 15733575282	          | 15733575286
  Exchange Country Group 4	            | RU0009024277|	RU	                | 652881001               | 652881002


  Scenario: Prerequisite - Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/Positions" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "600" to variable "workflow.max.polling.time"
    And I assign "outbound_positions_voting_rights" to variable "PUBLISHING_FILE_NAME"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MM-dd" and assign to "SNAPSHOT_DATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I modify date "${VAR_SYSDATE}" with "-0d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "BRS_AS_OF_DATE"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"

  Scenario Outline: Prerequisite - End dating Instruments to reload the same set of records
  This scenario set END_TMS as SYSDATE in FT_T_ISID table for all TBAM instruments

    When I extract below values from the xml file "${TESTDATA_PATH}/infiles/Instruments/TMBAM_sm.xml"  with xpath or tagName at index <INDEX_NUMBER> and assign to variables:
      | CUSIP                                              | RCR_CUSIP |
      | //CUSIP_ALIAS_set/CUSIP_ALIAS_record[4]/IDENTIFIER | RCR_ISIN  |
      | //CUSIP2_set/CUSIP2_record[1]/IDENTIFIER           | RCR_SEDOL |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${RCR_CUSIP}','${RCR_ISIN}','${RCR_SEDOL}'"

    Examples: TBAM Instruments
      | INDEX_NUMBER |
      | 0            |
      | 1            |
      | 2            |
      | 3            |
      | 4            |

  Scenario: Load Instruments file for TBAM

    When I process "${TESTDATA_PATH}/infiles/Instruments/TMBAM_sm.xml" file with below parameters
      | FILE_PATTERN  | TMBAM_sm.xml            |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |
      | BUSINESS_FEED |                         |

    Then I expect workflow is processed in DMP with success record count as "5"

  Scenario: Load TBAM Fund File

    When I process "${TESTDATA_PATH}/infiles/Funds/TBAMEISLFUNDLE.csv" file with below parameters
      | FILE_PATTERN  | TBAMEISLFUNDLE*       |
      | MESSAGE_TYPE  | EIS_MT_TMBAM_DMP_FUND |
      | BUSINESS_FEED |                       |

    Then I expect workflow is processed in DMP with success record count as "3"

  Scenario: Load Positions data for TBAM
    Given I create input file "TMBAMPOSITN.xml" using template "TMBAMPOSITN_Template.xml" from location "${TESTDATA_PATH}/infiles/Positions"
    When I process "${TESTDATA_PATH}/infiles/Positions/testdata/TMBAMPOSITN.xml" file with below parameters
      | FILE_PATTERN  | TMBAMPOSITN.xml                   |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with total record count as "5"

  Scenario: Load Thomson Reuters Terms and conditions files

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles/ThomsonReuters" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TR_TermsAndCondtions3.csv |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | *.csv                         |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

  Scenario: Load Thomson reuters Composite file

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles/ThomsonReuters" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TR_Composite2.csv |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TR_Composite*.csv        |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |

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

  Scenario Outline: Extract ISS_ID (ID_CTXT_TYP='EISLSTID') and Instrument name (ISS_NME) from dmp for EIMK, ESJP, TBAM2 and TBAM Instruments

    Given I extract below values from the xml file "${TESTDATA_PATH}/infiles/Instruments/TMBAM_sm.xml"  with xpath or tagName at index <INDEX_NUMBER> and assign to variables:
      | //CUSIP_ALIAS_set/CUSIP_ALIAS_record[4]/IDENTIFIER | <ISIN_ID> |

    And I assign "${<ISIN_ID>}" to variable "RCR_ISIN"
    When I execute below query and extract values of "ISS_ID;ISS_NME" into same variables
    """
    ${TESTDATA_PATH}/sql/Iss_Id_And_Iss_Nme_Extraction.sql
    """

    Then  I assign "${ISS_ID}" to variable "<INSTRUMENT_ID>"
    And   I assign "${ISS_NME}" to variable "<INSTRUMENT_NAME>"

    Examples:  Instrument Id and Name for TBAM
      | INDEX_NUMBER | INSTRUMENT_ID | INSTRUMENT_NAME | ISIN_ID     |
      | 0            | ISS_ID_TBAM21 | ISE_NME_TBAM21  | ISIN_TBAM21 |
      | 1            | ISS_ID_TBAM22 | ISE_NME_TBAM22  | ISIN_TBAM22 |
      | 2            | ISS_ID_TBAM23 | ISE_NME_TBAM23  | ISIN_TBAM23 |
      | 3            | ISS_ID_TBAM24 | ISE_NME_TBAM24  | ISIN_TBAM24 |
      | 4            | ISS_ID_TBAM25 | ISE_NME_TBAM25  | ISIN_TBAM25 |

  Scenario Outline: Verify all TotalVotingRights and TotalVotingShares details published for TBAM2
  Extract Instrument outbound field values from actual outbound positions file and verify fields are published as expected

    When I extract attribute values from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and assign to variables:
      | xpath                                        | attributeName     | variableName      |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | TotalVotingRights | VAR_TOT_VOT_RGHTS |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | TotalVotingShares | VAR_TOT_VOT_SHRS  |

    Then I expect the value of var "${VAR_TOT_VOT_RGHTS}" equals to "<VAR_TOT_VOT_RGHTS>"
    And I expect the value of var "${VAR_TOT_VOT_SHRS}" equals to "<VAR_TOT_VOT_SHRS>"

    Examples: Instrument Id and Name for TBAM
      | SEC_TYPE | ISIN_ID        | VAR_TOT_VOT_RGHTS | VAR_TOT_VOT_SHRS |
      | Equity   | ${ISIN_TBAM21} | 25930380002       | 25930380001      |
      | Equity   | ${ISIN_TBAM22} | 51860760900       | 51860760906      |
      | Equity   | ${ISIN_TBAM23} | 15733575282       | 15733575286      |
      | Equity   | ${ISIN_TBAM24} | 652881001         | 652881002        |
      | Equity   | ${ISIN_TBAM25} | 715398002         | 686120803        |
