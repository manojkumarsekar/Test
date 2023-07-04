#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=01.+Outbound+FundApps+Position+File#MainDeck--1455554384
# Dev Ticket    : https://jira.intranet.asia/browse/TOM-4123
#Testing Ticket  : https://jira.intranet.asia/browse/TOM-4492

###Note: WFOE and JNAM excluded from the coverage
###      Due to JNAM as_of_tms is T-2 and  WFOE is not in scope
#@tom_4639 : we have changed the snapshot date from (T-1) to T(Current) Date due to position date  of other LBUs
#TOM-5148: Removing M&G related loads due to demerger
#EISDEV-5493: Changing values of AUT instrument as per requirement
#EISDEV-5993: As part of eisdev-5993, publishing has been changed based on view ft_v_lpd2. this jira has also fixed the bug to stop publishing EFUT data at positions level.
#EISDEV-6306: Updated the feature to reduce complexity and maintenance efforts
#EISDEV-6234: Publish another file for FundApps UAT environment excluding positions configured for UAT exclusion.
  #Change existing publishing logic to exclude positions configured for PROD exclusion
  #Add BRS loads for security and position as it was not happening
#EISDEV-6414: Verify FA Position publishing for Security type EFUT
#EISDEV-6564: Verify FA Position publishing for Security type TRS
#eisdev_6788: changes for HasAlternateUSSection12Registration=FALSE
#eisdev_7175: addition of MarketValue & MarketValueInInstrumentCurrency
#eisdev_7276: addition of AuthorisedLendingAgreement & TitleOfClass

@gc_interface_portfolios @gc_interface_positions @gc_interface_funds @gc_interface_reuters @gc_interface_securities
#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@dmp_regression_unittest
#@dmp_regression_integrationtest
@tom_4492 @fa_outbound @fa_outbound_positions @tom_4639 @dmp_fundapps_regression @dmp_gs_upgrade
@eisdev_5993 @eisdev_6306 @eisdev_6234 @eisdev_6414 @eisdev_6780 @eisdev_6564 @eisdev_6788 @eisdev_7175 @eisdev_7276
Feature: FundApps_Positions_Outbound : Verify fund apps Outbound Positions for BOCI,TBAM,Eastspring Japan & Korea

  As a user I should able to publish fundapps positions with all instruments data
  and I should able tto load all inbound and Reuters files successfully.

  Scenario: Prerequisite - Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/Positions" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "outbound_positions_prod" to variable "PUBLISHING_FILE_NAME_PROD"
    And I assign "outbound_positions_uat" to variable "PUBLISHING_FILE_NAME_UAT"
    And I assign "600" to variable "workflow.max.polling.time"
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "yyyy-MM-dd" and assign to "SNAPSHOT_DATE"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "MM/dd/YYYY" and assign to "BRS_AS_OF_DATE"
    And I modify date "${VAR_SYSDATE}" with "-1d" from source format "YYYYMMdd" to destination format "YYYY-MMM-dd" and assign to "BNP_AS_OF_DATE"

    And I execute below query to "Clear all positions greater than SYSDATE-1 and only keeping 2 positions"
    """
    ${TESTDATA_PATH}/sql/ClearBALH.sql;
    ${TESTDATA_PATH}/sql/Clear_LBUPositions_balh.sql
    """
    And  I execute below query to "End date All Funds to reload the same set of records"
    """
    ${TESTDATA_PATH}/sql/EndDateFunds.sql
    """
    And I modify date "${VAR_SYSDATE}" with "+0d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"

  Scenario Outline: Prerequisite - End dating Instruments to reload the same set of records
  This scenario set END_TMS as SYSDATE in FT_T_ISID table for all EIMK, Legacy,ESJP and TBAM instruments

    When I extract below values for row <ROW_NUMBER> from PSV file "<FILE_NAME>" in local folder "${TESTDATA_PATH}/infiles/Instruments" with reference to "Security Id" column and assign to variables:
      | CUSIP | RCR_CUSIP |
      | ISIN  | RCR_ISIN  |
      | Sedol | RCR_SEDOL |

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${RCR_CUSIP}','${RCR_ISIN}','${RCR_SEDOL}'"

    Examples: EIMK, Legacy and ESJP Instruments
      | FILE_NAME           | ROW_NUMBER |
      | EIMKEISLINSTMT.csv  | 2          |
      | EIMKEISLINSTMT.csv  | 3          |
      | LEGAEEISLINSTMT.csv | 2          |
      | ESJPEISLINSTMT.csv  | 2          |

#    Examples: TBAM Instruments
#      | FILE_NAME          | ROW_NUMBER |
#      | TBAMEISLINSTMT.csv | 2          |
#      | TBAMEISLINSTMT.csv | 3          |
#      | TBAMEISLINSTMT.csv | 4          |
#      | TBAMEISLINSTMT.csv | 5          |
#      | TBAMEISLINSTMT.csv | 6          |

  Scenario: Prerequisite - End dating Instruments to reload the same set of records
  This scenario set END_TMS as SYSDATE in FT_T_ISID table for all BOCI instruments

    Given  I assign "esi_ADX_EOD_NON-ASIA_2019.sm.xml" to variable "INPUT_FILENAME_BRS"
    And I extract value from the xml file "${TESTDATA_PATH}/infiles/Instruments/${INPUT_FILENAME_BRS}" with tagName "CUSIP" to variable "BCUSIP_VAR"
    And  I assign "BRTD8LY90" to variable "BCUSIP_VAR2"
    And I extract below values for row 2 from PSV file "BOCIEISLINSTMT.csv" in local folder "${TESTDATA_PATH}/infiles/Instruments" with reference to "SECURITY_ID" column and assign to variables:
      | CUSIP | RCR_CUSIP |
      | ISIN  | RCR_ISIN  |
      | SEDOL | RCR_SEDOL |

    And I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP_VAR}','${BCUSIP_VAR2}','${RCR_ISIN}','${RCR_SEDOL}'"

  Scenario: Prerequisite - Loading Portfolio Master & Port group File

    Given I assign "Portfolio_Master.xlsx" to variable "INPUT_PORTFOLIO_FILENAME"
    Given I assign "port_group.xml" to variable "INPUT_PORTGROUP_FILENAME"

    And I copy files below from local folder "${TESTDATA_PATH}/infiles/Portfolios" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PORTFOLIO_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                      |
      | FILE_PATTERN  | ${INPUT_PORTFOLIO_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |

    And I copy files below from local folder "${TESTDATA_PATH}/infiles/Portfolios" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_PORTGROUP_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_PORTGROUP_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP  |

  Scenario Outline: Prerequisite - Create Positions File for all interfaces with T-1 date

    Given I create input file "<FILE_NAME>" using template "<TEMPLATE_FILE_NAME>" from location "${TESTDATA_PATH}/infiles/Positions"
    Examples:
      | INTERFACE_NAME | TEMPLATE_FILE_NAME          | FILE_NAME          |
#      | TBAM           | TBAMEISLPOSITN_Template.csv | TBAMEISLPOSITN.csv |
      | ESJP           | ESJPEISLPOSITN_Template.csv | ESJPEISLPOSITN.csv |
      | ESKR           | EIMKEISLPOSITN_Template.csv | EIMKEISLPOSITN.csv |
      | BOCI           | BOCIEISLPOSITN_Template.csv | BOCIEISLPOSITN.csv |
      | LEGACY         | LEGAEISLPOSITN_Template.csv | LEGAEISLPOSITN.csv |
      | BRS            | BRSPOSITION_Template.xml    | BRSPOSITION.xml    |
      | BNP            | ESISODP_EXR_1_Template.out  | ESISODP_EXR_1.out  |
      | BRS            | BRSTMBAMSBLPOS_Template.xml | BRSTMBAMSBLPOS.xml |

  Scenario Outline: Load Funds for all LBUs

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles/Funds" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | <FILE_NAME> |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | <FILE_NAME>    |
      | MESSAGE_TYPE  | <MESSAGE_TYPE> |
      | BUSINESS_FEED |                |

    Examples:
      | FILE_NAME          | MESSAGE_TYPE         |
#      | TBAMEISLFUNDLE.csv | EIS_MT_TMBAM_DMP_FUND |
      | ESJPEISLFUNDLE.csv | EIS_MT_ESJP_DMP_FUND |
      | BOCIEISLFUNDLE.csv | EIS_MT_BOCI_DMP_FUND |
      | EIMKEISLFUNDLE.csv | EIS_MT_EIMK_DMP_FUND |

#  Scenario: Prerequisite - Inserting ACGP for exclusion portfolios
#
#    Given I assign "'6234_PROD_EXCL'" to variable "PROD_PORTFOLIO_EXCLUSION"
#    And I assign "'6234_TMBAM'" to variable "UAT_PORTFOLIO_EXCLUSION"
#
#    #Pre-requisite : Insert row into ACGP for FAPRDEXCLPORT & FAPRDEXCLPORT group
#    And I execute below query to create paticipants for FAPRDEXCLPORT & FAPRDEXCLPORT
#    """
#    ${TESTDATA_PATH}/sql/InsertACGP.sql
#    """

  Scenario Outline: Load Instruments for all LBUs

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles/Instruments" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | <FILE_NAME> |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | <FILE_NAME>    |
      | MESSAGE_TYPE  | <MESSAGE_TYPE> |
      | BUSINESS_FEED |                |

    Examples:
      | FILE_NAME                        | MESSAGE_TYPE               |
#      | TBAMEISLINSTMT.csv               | EIS_MT_TMBAM_DMP_SECURITY  |
      | ESJPEISLINSTMT.csv               | EIS_MT_ESJP_DMP_SECURITY   |
      | BOCIEISLINSTMT.csv               | EIS_MT_BOCI_DMP_SECURITY   |
      | EIMKEISLINSTMT.csv               | EIS_MT_EIMK_DMP_SECURITY   |
      | LEGAEEISLINSTMT.csv              | EIS_MT_LEGACY_DMP_SECURITY |
      | esi_ADX_EOD_NON-ASIA_2019.sm.xml | EIS_MT_BRS_SECURITY_NEW    |

  Scenario Outline: Load Positions for all LBUs

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles/Positions/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | <FILE_NAME> |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | <FILE_NAME>    |
      | MESSAGE_TYPE  | <MESSAGE_TYPE> |
      | BUSINESS_FEED |                |

    Examples:
      | FILE_NAME          | MESSAGE_TYPE                             |
#      | TBAMEISLPOSITN.csv | EIS_MT_TMBAM_DMP_POSITION     |
      | ESJPEISLPOSITN.csv | EIS_MT_ESJP_DMP_POSITION                 |
      | BOCIEISLPOSITN.csv | EIS_MT_BOCI_DMP_POSITION                 |
      | EIMKEISLPOSITN.csv | EIS_MT_EIMK_DMP_POSITION                 |
      | LEGAEISLPOSITN.csv | EIS_MT_LEGACY_DMP_POSITION               |
      | BRSPOSITION.xml    | EIS_MT_BRS_EOD_POSITION_LATAM            |
      | BRSTMBAMSBLPOS.xml | EIS_MT_BRS_RESTRICTED_HOLDINGS_TMBAM_211 |

  Scenario: Load Thomson Reuters Terms and conditions files

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles/ThomsonReuters" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TR_TermsAndCondtions1.csv |
      | TR_TermsAndCondtions2.csv |
      | TR_TermsAndCondtions3.csv |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | *.csv                         |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |
      | BUSINESS_FEED |                               |

  Scenario: Load Thomson reuters Composite file

    Given I copy files below from local folder "${TESTDATA_PATH}/infiles/ThomsonReuters" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | TR_Composite.csv  |
      | TR_Composite2.csv |

    When I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | TR_Composite*.csv        |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_COMPOSITE |
      | BUSINESS_FEED |                          |

  Scenario: Load BNP exchange rate file

    Given I process "${TESTDATA_PATH}/infiles/Positions/testdata/ESISODP_EXR_1.out" file with below parameters
      | FILE_PATTERN  | ESISODP_EXR_1.out            |
      | MESSAGE_TYPE  | EIS_MT_BNP_EOD_EXCHANGE_RATE |
      | BUSINESS_FEED |                              |

  Scenario: Create Cross Rates

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "CREATE_RATES"

    And I process the workflow template file "${CREATE_RATES}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_create_fxrt_cross_rates |

  Scenario: Create dummy data for PDR
    Given I execute below query to "Update and set up dummy PDR instrument RDMSecType"
    """
    UPDATE FT_T_ISCL set CL_VALUE='PDR', clsf_oid = (select CLSF_OID from ft_t_incl where indus_cl_set_id='RDMSCTYP' and cl_value='PDR')
    where indus_cl_set_id='RDMSCTYP' and instr_id in (select instr_Id from ft_t_isid where iss_id='TESTPDR' and end_tms is null);
    """

  Scenario: Refresh FT_V_LPD2 for PROD publishing

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_RefreshMView/request.xmlt" to variable "REFRESH_MVIEW"

    And I process the workflow template file "${REFRESH_MVIEW}" with below parameters and wait for the job to be completed
      | MVIEW_NAME        | ft_v_lpd2                        |
      | PROC_NAME         | esi_refresh_ft_v_lpd2            |
      | SUBSCRIPTION_NAME | EIS_DMP_TO_FUNDAPPS_POSITION_SUB |

  Scenario: Publish outbound position File for PROD publishing profile
    Given I assign "outbound_positions_expected.xml" to variable "REFERENCE_POSITIONS_FILE_NAME"
    And I assign "${PUBLISHING_FILE_NAME_PROD}_${VAR_SYSDATE}_1.xml" to variable "ACTUAL_POSTIONS_FILE_NAME"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_PROD}_*.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_PROD}.xml |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_POSITION_SUB |
      | XML_MERGE_LEVEL      | 2                                |
      | PUBLISHING_BULK_SIZE | 50                               |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_PROD}_${VAR_SYSDATE}_1.xml |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_PROD}_${VAR_SYSDATE}_1.xml |

  Scenario Outline: Extract ISS_ID (ID_CTXT_TYP='EISLSTID') and Instrument name (ISS_NME) from dmp for EIMK, ESJP, TBAM2 and TBAM Instruments

    Given I extract below values for row <ROW_NUMBER> from PSV file "<FILE_NAME>" in local folder "${TESTDATA_PATH}/infiles/Instruments" with reference to "Security Id" column and assign to variables:
      | ISIN | <ISIN_ID> |

    And I assign "${<ISIN_ID>}" to variable "RCR_ISIN"
    When I execute below query and extract values of "ISS_ID;ISS_NME" into same variables
    """
    ${TESTDATA_PATH}/sql/Iss_Id_And_Iss_Nme_Extraction.sql
    """

    Then  I assign "${ISS_ID}" to variable "<INSTRUMENT_ID>"
    And   I assign "${ISS_NME}" to variable "<INSTRUMENT_NAME>"

    Examples: Extract Instrument Id and Name for EIMK
      | ROW_NUMBER | FILE_NAME          | INSTRUMENT_ID | INSTRUMENT_NAME | ISIN_ID    |
      | 2          | EIMKEISLINSTMT.csv | ISS_ID_EIMK   | ISE_NME_EIMK    | ISIN_EIMK  |
      | 3          | EIMKEISLINSTMT.csv | ISS_ID_EIMK2  | ISE_NME_EIMK2   | ISIN_EIMK2 |

    Examples: Extract Instrument Id and Name for ESJP
      | ROW_NUMBER | FILE_NAME          | INSTRUMENT_ID | INSTRUMENT_NAME | ISIN_ID   |
      | 2          | ESJPEISLINSTMT.csv | ISS_ID_ESJP   | ISE_NME_ESJP    | ISIN_ESJP |
#    Examples: Extract Instrument Id and Name for TBAM
#      | ROW_NUMBER | FILE_NAME          | INSTRUMENT_ID | INSTRUMENT_NAME | ISIN_ID    |
#      | 2          | TBAMEISLINSTMT.csv | ISS_ID_TBAM1  | ISE_NME_TBAM1   | ISIN_TBAM1 |
#      | 3          | TBAMEISLINSTMT.csv | ISS_ID_TBAM2  | ISE_NME_TBAM2   | ISIN_TBAM2 |
#      | 4          | TBAMEISLINSTMT.csv | ISS_ID_TBAM3  | ISE_NME_TBAM3   | ISIN_TBAM3 |
#      | 5          | TBAMEISLINSTMT.csv | ISS_ID_TBAM4  | ISE_NME_TBAM4   | ISIN_TBAM4 |
#      | 6          | TBAMEISLINSTMT.csv | ISS_ID_TBAM5  | ISE_NME_TBAM5   | ISIN_TBAM5 |

  Scenario: Extract ISS_ID (ID_CTXT_TYP='EISLSTID'), Instrument name and Market details from dmp for BOCI Instruments

    Given I extract below values for row 2 from PSV file "BOCIEISLINSTMT.csv" in local folder "${TESTDATA_PATH}/infiles/Instruments" with reference to "SECURITY_ID" column and assign to variables:
      | ISIN | ISIN_BOCI |
    And I assign "${ISIN_BOCI}" to variable "RCR_ISIN"
    And I execute below query and extract values of "ISS_ID;ISS_NME" into same variables
    """
    ${TESTDATA_PATH}/sql/Iss_Id_And_Iss_Nme_Extraction.sql
    """

    And I assign "${ISS_ID}" to variable "ISS_ID_BOCI"
    And  I assign "${ISS_NME}" to variable "ISS_NME_BOCI"

  Scenario: Extract ISS_ID (ID_CTXT_TYP='EISLSTID'), Instrument name and Market details from dmp for BRS TRS Instruments

    Given I assign "${BCUSIP_VAR2}" to variable "RCR_ISIN"
    And I execute below query and extract values of "ISS_ID;ISS_NME" into same variables
    """
    ${TESTDATA_PATH}/sql/Iss_Id_And_Iss_Nme_Extraction.sql
    """

    And I assign "${ISS_ID}" to variable "ISS_ID_BRSTRS"
    And  I assign "${ISS_NME}" to variable "ISS_NME_BRSTRS"

  Scenario: Perform the reconciliation between reference xml and outbound positions xml
  Verify all Portfolio Assets details published as expected

    When I create input file "${REFERENCE_POSITIONS_FILE_NAME}" using template "outbound_positions_template.xml" from location "${TESTDATA_PATH}/outfiles/reference"
    And I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${TESTDATA_PATH}/outfiles/reference/testdata/${REFERENCE_POSITIONS_FILE_NAME}" should exist in file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and exceptions to be written to "${TESTDATA_PATH}/outfiles/runtime/exceptions_${recon.timestamp}.xml" file

  Scenario Outline: Verify all Instrument details published for <INSTRUMENT_NAME> instrument
  Extract Instrument outbound field values from actual outbound positions file and verify fields are published as expected

    When I extract attribute values from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and assign to variables:
      | xpath                                        | attributeName                       | variableName     |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | InstrumentId                        | VAR_INSTR_ID     |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | InstrumentName                      | VAR_INSTR_NAME   |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | AssetClassCustomer                  | VAR_ASSET_CLASS  |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | ClassSharesOutstanding              | VAR_CLASS_SHARES |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | Market                              | VAR_MARKET       |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | InstrumentCurrency                  | VAR_INSTR_CUR    |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | TotalSharesOutstanding              | VAR_TOTAL_SHARES |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] | HasAlternateUSSection12Registration | VAR_HAUS12REG    |

    Then I expect the value of var "${VAR_INSTR_ID}" equals to "<INSTRUMENT_ID>"
    And I expect the value of var "${VAR_INSTR_NAME}" equals to "<INSTRUMENT_NAME>"
    And I expect the value of var "${VAR_ASSET_CLASS}" equals to "<ASSET_CLASS>"
    And I expect the value of var "${VAR_CLASS_SHARES}" equals to "<CLASS_SHARES>"
    And I expect the value of var "${VAR_INSTR_CUR}" equals to "<INSTR_CUR>"
    And I expect the value of var "${VAR_MARKET}" equals to "<MARKET>"
    And I expect the value of var "${VAR_TOTAL_SHARES}" equals to "<TOTAL_SHARES>"
    And I expect the value of var "${VAR_HAUS12REG}" equals to "FALSE"

    Examples: Extract Instrument Id and Name for TBAM
      | SEC_TYPE | INSTRUMENT_ID  | INSTRUMENT_NAME | ISIN_ID      | ASSET_CLASS | CLASS_SHARES | INSTR_CUR | MARKET | TOTAL_SHARES |
      | Equity   | ${ISS_ID_EIMK} | ${ISE_NME_EIMK} | ${ISIN_EIMK} | COM         | 399748336    | BMD       | XNGS   | 399748336    |
      | Equity   | ${ISS_ID_ESJP} | ${ISE_NME_ESJP} | ${ISIN_ESJP} | COM         | 8032297166   | BRL       | BVMF   | 8032297166   |
#      | Unit     | ${ISS_ID_TBAM1} | ${ISE_NME_TBAM1} | ${ISIN_TBAM1} | AUT         | 24791714.06  | USD       | Lipper | 24791714.06  |

#  Scenario: Verify all Underlying Rights Instrument details published for TBAM
#  Extract Instrument outbound field values from actual outbound positions file and verify fields are published as expected
#
#    When I extract attribute values from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and assign to variables:
#      | xpath                                                            | attributeName      | variableName    |
#      | //Instruments//Rights[@InstrumentId='${ISS_ID_TBAM5}']           | InstrumentName     | VAR_INSTR_NAME  |
#      | //Instruments//Rights[@InstrumentId='${ISS_ID_TBAM5}']           | AssetClassCustomer | VAR_ASSET_CLASS |
#      | //Instruments//Rights[@InstrumentId='${ISS_ID_TBAM5}']           | Market             | VAR_MARKET      |
#      | //Instruments//Rights[@InstrumentId='${ISS_ID_TBAM5}']           | InstrumentCurrency | VAR_INSTR_CUR   |
#      | //Instruments//Rights[@InstrumentId='${ISS_ID_TBAM5}']/Component | InstrumentId       | VAR_UL_INSTR    |
#
#    And I expect the value of var "${VAR_INSTR_NAME}" equals to "${ISE_NME_TBAM5}"
#    And I expect the value of var "${VAR_ASSET_CLASS}" equals to "RTS"
#    And I expect the value of var "${VAR_INSTR_CUR}" equals to "EUR"
#    And I expect the value of var "${VAR_MARKET}" equals to "XXXX"
#    And I expect the value of var "${VAR_UL_INSTR}" equals to ""

  Scenario: Verify all SWAP Attributes related to BRS instrument
  Extract Instrument outbound field values from actual outbound positions file and verify fields are published as expected

    When I extract attribute values from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and assign to variables:
      | xpath                                                 | attributeName      | variableName    |
      | //Instruments//SWAP[@InstrumentId='${ISS_ID_BRSTRS}'] | AssetClassCustomer | VAR_ASSET_CLASS |
      | //Instruments//SWAP[@InstrumentId='${ISS_ID_BRSTRS}'] | InstrumentName     | VAR_INSTR_NAME  |

    And I expect the value of var "${VAR_ASSET_CLASS}" equals to "TRS"
    And I expect the value of var "${VAR_INSTR_NAME}" equals to "${ISS_NME_BRSTRS}"

  Scenario Outline: Verify all Underlying Warrant and Option Instruments details published for TBAM
  Extract Instrument outbound field values from actual outbound positions file and verify fields are published as expected

    When I extract attribute values from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and assign to variables:
      | xpath                                                   | attributeName      | variableName    |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>']            | InstrumentId       | VAR_INSTR_ID    |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>']            | InstrumentName     | VAR_INSTR_NAME  |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>']            | AssetClassCustomer | VAR_ASSET_CLASS |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>']            | CallOrPut          | VAR_CALL_OR_PUT |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>']            | Market             | VAR_MARKET      |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>']            | InstrumentCurrency | VAR_INSTR_CUR   |
      | //Instruments//<SEC_TYPE>[@ISIN='<ISIN_ID>'] /Component | InstrumentId       | VAR_UL_INSTR    |

    Then I expect the value of var "${VAR_INSTR_ID}" equals to "<INSTRUMENT_ID>"
    And I expect the value of var "${VAR_INSTR_NAME}" equals to "<INSTRUMENT_NAME>"
    And I expect the value of var "${VAR_ASSET_CLASS}" equals to "<ASSET_CLASS>"
    And I expect the value of var "${VAR_CALL_OR_PUT}" equals to "<CALL_PUT>"
    And I expect the value of var "${VAR_INSTR_CUR}" equals to "<INSTR_CUR>"
    And I expect the value of var "${VAR_MARKET}" equals to "<MARKET>"
    And I expect the value of var "${VAR_UL_INSTR}" equals to "<UL_INSTR>"

    Examples: Extract Instrument Id and Name for TBAM
      | SEC_TYPE | INSTRUMENT_ID   | INSTRUMENT_NAME  | ISIN_ID       | ASSET_CLASS | CALL_PUT | INSTR_CUR | MARKET | UL_INSTR   |
#      | Warrant  | ${ISS_ID_TBAM2} | ${ISE_NME_TBAM2} | ${ISIN_TBAM2} | WARR        | Call     | THB       | XBKK   | ESL9772410 |
#      | Option   | ${ISS_ID_TBAM4} | ${ISE_NME_TBAM4} | ${ISIN_TBAM4} | ECO         |          | EUR       | XXXX   |            |
      | Future   | ${ISS_ID_EIMK2} | ${ISE_NME_EIMK2} | ${ISIN_EIMK2} | EFUT        |          | INR       | XXXX   | ESL7108643 |

  Scenario: Verify excluded portfolios are not published in the PROD output file

    Given I assign count of child nodes "Asset" under node xpath "//Portfolio[@PortfolioId='6234_PROD_EXCL']" from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" to variable "6234_PROD_EXCL_COUNT"
    Then I expect the value of var "${6234_PROD_EXCL_COUNT}" equals to "2"

  Scenario: Refresh FT_V_LPD2 for UAT publishing

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_RefreshMView/request.xmlt" to variable "REFRESH_MVIEW"

    And I process the workflow template file "${REFRESH_MVIEW}" with below parameters and wait for the job to be completed
      | MVIEW_NAME        | ft_v_lpd2                            |
      | PROC_NAME         | esi_refresh_ft_v_lpd2                |
      | SUBSCRIPTION_NAME | EIS_DMP_TO_FUNDAPPS_POSITION_UAT_SUB |

  Scenario: Publish outbound position File for UAT publishing profile
    Given I assign "${PUBLISHING_FILE_NAME_UAT}_${VAR_SYSDATE}_1.xml" to variable "ACTUAL_POSTIONS_FILE_NAME"
    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME_UAT}_*.xml |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_UAT}.xml      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_FUNDAPPS_POSITION_UAT_SUB |
      | XML_MERGE_LEVEL      | 2                                    |
      | PUBLISHING_BULK_SIZE | 50                                   |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME_UAT}_${VAR_SYSDATE}_1.xml |

    And I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${TESTDATA_PATH}/outfiles/runtime":
      | ${PUBLISHING_FILE_NAME_UAT}_${VAR_SYSDATE}_1.xml |

  Scenario: Verify excluded portfolios are not published in the UAT output file and BRS portfolio is published

    Given I assign count of child nodes "Asset" under node xpath "//Portfolio[@PortfolioId='6234_TMBAM']" from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" to variable "6234_TMBAM_COUNT"
    Then I expect the value of var "${6234_TMBAM_COUNT}" equals to "0"

    Given I assign count of child nodes "Asset" under node xpath "//Portfolio[@PortfolioId='6234_PROD_EXCL']" from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" to variable "6234_PROD_COUNT"
    Then I expect the value of var "${6234_PROD_COUNT}" equals to "2"
