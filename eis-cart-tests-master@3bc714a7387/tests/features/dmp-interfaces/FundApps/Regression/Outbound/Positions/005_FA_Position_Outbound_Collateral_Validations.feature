#https://collaborate.intranet.asia/pages/viewpage.action?spaceKey=FUNDAPPS&title=01.+Outbound+FundApps+Position+File#MainDeck--1455554384
# Dev Ticket    : https://jira.intranet.asia/browse/EISDEV_6475
#eisdev_6933 : Map PRC_CURR_CDE for InstrumentCurrency field
#eisdev_6842 : Recon was failing because, snapshot date was returning T date due to other ff data load. Moving the SNAPSHOT_DATE store string after BALH delete
#eisdev_6788: changes for HasAlternateUSSection12Registration=TRUE

@gc_interface_positions
#Reducing burden on integration test by tagging this under too_slow tag. temporarily adding this under unit_tests as integration already overloaded
@too_slow
@dmp_regression_unittest
#@dmp_regression_integrationtest
@fa_outbound @fa_outbound_positions @dmp_fundapps_regression @dmp_gs_upgrade
@eisdev_6475 @eisdev_6933 @eisdev_6842 @eisdev_6788
Feature: FundApps_Positions_Outbound : Verify Outbound positions for collateral are published correctly

  Scenario: Prerequisite - Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Regression/Outbound/Positions" to variable "TESTDATA_PATH"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/fundapps" to variable "PUBLISHING_DIRECTORY"
    And I assign "600" to variable "workflow.max.polling.time"
    And I assign "outbound_positions_collateral" to variable "PUBLISHING_FILE_NAME"
    And I modify date "${VAR_SYSDATE}" with "-5d" from source format "YYYYMMdd" to destination format "dd/MM/YYYY" and assign to "CURR_DATE"
    And I execute below query and extract values of "DYNAMIC_DATE_SBL" into same variables
     """
     select to_char(max(GREG_DTE),'DD Mon YYYY') as DYNAMIC_DATE_SBL from (select GREG_DTE, row_number() over(order by greg_dte desc) r from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE between trunc(sysdate-10) and trunc(SYSDATE) and BUS_DTE_IND = 'Y') where r=3
     """

  Scenario: Prerequisite - End dating Instruments to reload the same set of records and to delete positions
  This scenario set END_TMS as SYSDATE in FT_T_ISID table for all TBAM instruments

    Given I extract below values for row 2 from CSV file "ROBOSBL-POSN_COLL_TEMPLATE.csv" in local folder "${TESTDATA_PATH}/infiles/Positions/template" with reference to "Date" column and assign to variables:
      | ISIN  | RCR_ISIN  |
      | SEDOL | RCR_SEDOL |

    Then I inactivate "${RCR_ISIN},${RCR_SEDOL}" instruments in GC database
    And I execute below query to "Clear all positions greater than SYSDATE-5 and only keeping 2 positions"
    """
    ${TESTDATA_PATH}/sql/ClearBALH.sql;
    ${TESTDATA_PATH}/sql/Clear_LBUPositions_balh.sql
    """

    And I execute below query and extract values of "SNAPSHOT_DATE" into same variables
     """
     SELECT to_char(MAX(AS_OF_TMS),'YYYY-MM-DD') as SNAPSHOT_DATE FROM FT_T_BALH BALH, FT_T_IDMV IDMV WHERE IDMV.FLD_ID = '00005045' AND IDMV.QUAL_VAL_TXT = 'FUNDAPPSPUB' AND TRIM(BALH.RQSTR_ID) = TRIM(IDMV.INTRNL_DMN_VAL_TXT)
     """

  Scenario: Load Positions data for ROBO Collateral
    Given I create input file "ROBOSBL-POSN_COLL.csv" using template "ROBOSBL-POSN_COLL_TEMPLATE.csv" from location "${TESTDATA_PATH}/infiles/Positions"

    When I process "${TESTDATA_PATH}/infiles/Positions/testdata/ROBOSBL-POSN_COLL.csv" file with below parameters
      | FILE_PATTERN  | ROBOSBL-POSN_COLL.csv        |
      | MESSAGE_TYPE  | EIS_MT_ROBO_DMP_SBL_POSITION |
      | BUSINESS_FEED |                              |

  Scenario: Set up PRC_CURR_CDE
    Given I execute below query to "set up PRC_CURR_CDE"
    """
    update ft_t_mkis set PRC_CURR_CDE = 'USD' where instr_id in(
    select instr_id from ft_t_isid where iss_id = 'US36962G3P70')
    """

    Given I execute below query to "link instrument with institution with country of issue = US and country of incorporation = US"
    """
    Insert into FT_T_FRIP (FINSRL_ISS_PRT_ID,INST_MNEM,FINSRL_TYP,INSTR_ID,
    PRT_PURP_TYP,START_TMS,LAST_CHG_TMS,LAST_CHG_USR_ID,DATA_STAT_TYP,DATA_SRC_ID)
    values (new_oid,(select inst_mnem from ft_t_fiid where fins_id = '669967' and end_tms is null),
    'ISSUER  ',(select instr_id from ft_t_isid where iss_id = 'US36962G3P70' and end_tms is null),
    'BRSISSR ',sysdate,sysdate,'AUTOMATION','ACTIVE','BRS')
    """

  Scenario: Refresh FT_V_LPD2

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_CallStoredProcedure/request.xmlt" to variable "STORED_PROCEDURE"

    And I process the workflow template file "${STORED_PROCEDURE}" with below parameters and wait for the job to be completed
      | SQL_PROC_NAME | esi_refresh_ft_v_lpd2 |


  Scenario: Publish outbound position File
    Given I assign "outbound_positions_collateral_expected.xml" to variable "REFERENCE_POSITIONS_FILE_NAME"
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

    When I execute below query and extract values of "ISS_ID;ISS_NME" into same variables
    """
    ${TESTDATA_PATH}/sql/Iss_Id_And_Iss_Nme_Extraction.sql
    """

    Then  I assign "${ISS_ID}" to variable "ISS_ID_COLL"
    And   I assign "${ISS_NME}" to variable "ISE_NME_COLL"

  Scenario: Perform the reconciliation between reference xml and outbound positions xml
  Verify all Portfolio Assets details published as expected

    When I create input file "${REFERENCE_POSITIONS_FILE_NAME}" using template "outbound_positions_collateral_template.xml" from location "${TESTDATA_PATH}/outfiles/reference"
    Then I expect all records from file1 of type XML exists in file2
      | File1 | ${TESTDATA_PATH}/outfiles/reference/testdata/${REFERENCE_POSITIONS_FILE_NAME} |
      | File2 | ${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}                |

  Scenario: Verify all Attributes related to collateral instruments are published.
  Extract Instrument outbound field values from actual outbound positions file and verify fields are published as expected

    When I extract attribute values from the xml file "${TESTDATA_PATH}/outfiles/runtime/${ACTUAL_POSTIONS_FILE_NAME}" and assign to variables:
      | xpath                                                   | attributeName                       | variableName     |
      | //Instruments//Equity[@InstrumentId='${ISS_ID_COLL}_C'] | ISIN                                | ISIN_COLL        |
      | //Instruments//Equity[@InstrumentId='${ISS_ID_COLL}_C'] | InstrumentName                      | VAR_ISS_NME_COLL |
      | //Instruments//Equity[@InstrumentId='${ISS_ID_COLL}_C'] | InstrumentCurrency                  | VAR_CURR         |
      | //Instruments//Equity[@InstrumentId='${ISS_ID_COLL}_C'] | HasAlternateUSSection12Registration | VAR_HAUS12REG    |

    And I expect the value of var "${ISIN_COLL}" equals to "${RCR_ISIN}"
    And I expect the value of var "${VAR_ISS_NME_COLL}" equals to "${ISE_NME_COLL}"
    And I expect the value of var "${VAR_CURR}" equals to "USD"
    And I expect the value of var "${VAR_HAUS12REG}" equals to "TRUE"
