#https://jira.intranet.asia/browse/TOM-3968
#https://collaborate.intranet.asia/display/TOMTN/Taiwan+Rating+-+TRC+sourced+from+CMoney#MainDeck-162766660
#EISDEV-5510: Count query & recon check change to fetch rating for specific issuer as same rating can exist on more than one issuer
#EISDEV-6454: mapping changes for ISSID:IssuerID from UNIBUSNUM to BRSISSRID
#EISDEV-6992: Header and Rating value changes for long and short ratings

@gc_interface_securities @gc_interface_issuer
@dmp_regression_integrationtest
@dmp_taiwan
@tom_3968 @eisdev_5510 @eisdev_6454 @eisdev_6992
Feature: Storing ratings in DMP received from CMONEY and translated rating provided in CSV file to BRS

  Load a file with one issuer ratings, where long rating value as "twAA-" and short rating value as "twA-1+"
  These ratings should get loaded into FIRT as identifier UBN is present in database
  "twAA-" and  "twA-1+" should get defined in RTVL and ERVL

  Load a file with three issuer ratings,
  First Issuer rating record contain update of previous long rating (from twAA-) to "twAAA"
  "twAA-" should get updated to "twAAA" in FIRT
  "twAAA" should defined into RTVL and ERVL

  Second Issuer rating record should throw custom warning message for translation failure of long rating as ERVL is missing
  however FIRT should get set up successfully

  Third Issuer rating record should throw 541 reference exception as UBN is not present in database

  Publish TRC Issuer rating file to BRS
  CSV file should get published with translated ratings

  Scenario: TC_1: Clear the data as a Prerequisite

    Given  I assign "Issuer_Security_TOM_3968.csv" to variable "INPUT_FILENAME1"
    And I assign "Issuer_Rating_TOM_3968.csv" to variable "INPUT_FILENAME2"
    And I assign "Issuer_Rating_update_TOM_3968.csv" to variable "INPUT_FILENAME3"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CMoney" to variable "testdata.path"

     #Clear data for the given entity from FINS, FIID and FIRT for ratings "twAA-", "twAAA" and  "twA-1+"
    Given I execute below query
    """
    ${testdata.path}/sql/CLEAR_DUMMY_FINS_DATA_TOM_3968.sql
    """

  Scenario: TC_2: Load Issuer Rating file to set up rating data in DMP

  Load a file with one issuer ratings, where long rating value as "twAA-" and short rating value as "twA-1+"
  These ratings should get loaded into FIRT as identifier UBN is present in database
  "twAA-" and  "twA-1+" should defined in RTVL and ERVL

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |
      | ${INPUT_FILENAME2} |
      | ${INPUT_FILENAME3} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                             |
      | FILE_PATTERN  | ${INPUT_FILENAME1}          |
      | MESSAGE_TYPE  | EITW_MT_CMONEY_DMP_SECURITY |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: JBLG logged
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      AND TASK_CMPLTD_CNT ='3'
      AND JOB_STAT_TYP = 'CLOSED'
      """

    And I expect value of column "FIID_ROW_COUNT" in the below SQL query equals to "3":
      """
      SELECT count(*) as FIID_ROW_COUNT FROM ft_t_fiid fiid, ft_t_frip frip, ft_t_isid isid
      WHERE isid.iss_id IN ('MYBUN1500908','MYBVO1602585','XS1467374473')
      AND   isid.id_ctxt_typ = 'ISIN'
      AND   isid.instr_id = frip.instr_id
      AND   frip.inst_mnem = fiid.inst_mnem
      AND   fiid.fins_id_ctxt_typ = 'UNIBUSNUM'
      AND   fiid.fins_id IN ('TEST_3968','TEST_3968_1','TEST_3968_2')
      AND   fiid.end_tms IS NULL
      AND   frip.end_tms IS NULL
      AND   isid.end_tms IS NULL
      """

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME2}                |
      | MESSAGE_TYPE  | EITW_MT_CMONEY_DMP_ISSUER_RATINGS |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: JBLG logged
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      AND TASK_SUCCESS_CNT ='2'
      AND JOB_STAT_TYP = 'CLOSED'
      """

    Then I expect value of column "FIRT_ROW_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS FIRT_ROW_COUNT FROM ft_t_firt firt, ft_t_fiid fiid
      WHERE fiid.inst_mnem = firt.inst_mnem AND fiid.fins_id = 'TEST_3968'
      AND firt.rtng_set_oid in (SELECT rtng_set_oid FROM ft_t_rtng WHERE
      RTNG_SET_MNEM in ('TRCMIRLR','TRCMIRSR') AND end_tms IS NULL)
      AND firt.end_tms IS NULL AND fiid.end_tms IS NULL
      """

  Scenario: TC_3: Load update of Issuer Rating file to update rating data in DMP

  Load a file with three issuer ratings,
  First Issuer rating record contain update of previous long rating (from twAA-) to "twAAA"
  "twAA-" should get updated to "twAAA" in FIRT
  "twAAA" should defined into RTVL and ERVL

  Second Issuer rating record should throw custom warning message for translation failure of long rating as ERVL is missing
  however FIRT should get set up successfully

  Third Issuer rating record should throw 541 reference exception as UBN is not present in database

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                   |
      | FILE_PATTERN  | ${INPUT_FILENAME3}                |
      | MESSAGE_TYPE  | EITW_MT_CMONEY_DMP_ISSUER_RATINGS |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    # Validation: JBLG logged
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      AND TASK_SUCCESS_CNT ='2'
      AND TASK_FILTERED_CNT ='1'
      AND JOB_STAT_TYP = 'CLOSED'
      """

    Then I expect value of column "FIRT_ROW_COUNT" in the below SQL query equals to "4":
      """
      SELECT count(*) as FIRT_ROW_COUNT FROM FT_T_FIRT
      WHERE rtng_cde in ('twAAA','twA-1+','twA-2','NR')
      AND rtng_set_oid in (SELECT rtng_set_oid FROM ft_t_rtng WHERE
      rtng_set_mnem in ('TRCMIRLR','TRCMIRSR') AND end_tms IS NULL)
      AND end_tms IS NULL
      AND inst_mnem IN (SELECT inst_mnem from ft_T_FIID Where fins_id in ('TEST_3968','TEST_3968_2','TEST_3968_1')
      AND end_tms IS NULL)
      """

    Then I expect value of column "FIRT_END_DATE_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as FIRT_END_DATE_ROW_COUNT FROM FT_T_FIRT WHERE rtng_cde = 'twAA-' AND end_tms IS NOT NULL
      AND rtng_set_oid in (SELECT rtng_set_oid FROM ft_t_rtng WHERE
      rtng_set_mnem in ('TRCMIRLR'))
      AND inst_mnem IN (SELECT inst_mnem from ft_T_FIID Where fins_id in ('TEST_3968')
      AND end_tms IS NULL)
      """

    # Validation: JBLG NTEL error logged for UBN missing
    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
      FROM ft_t_ntel ntel
      JOIN ft_t_trid trid
      ON ntel.last_chg_trn_id = trid.trn_id
      WHERE trid.job_id = '${JOB_ID}'
      AND ntel.msg_typ = 'EITW_MT_CMONEY_DMP_ISSUER_RATINGS'
      AND ntel.notfcn_stat_typ = 'OPEN'
      AND ntel.appl_id = 'TPS'
      AND ntel.part_id = 'TRANS'
      AND ntel.NOTFCN_ID = '60001'
      AND ntel.PARM_VAL_TXT like '%User defined Error thrown! . Error - Translation failed for TRC Long Rating received from CMONEY - swap%'
    """

    # =====================================================================
    # Publish CMONEY Issuer Rating file
    # =====================================================================

  Scenario: TC_4: Check if CMONEY Rating is in the outbound

    Given I assign "CMONEY_Issuer_test" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIRECTORY"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv       |
      | SUBSCRIPTION_NAME    | EITW_DMP_TO_BRS_ISSUER_RATING_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIRECTORY}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Given I assign "${testdata.path}/outfiles/actual/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    Given I expect column "LG:TW_TRC_ILT" value to be "TRC_L_twAAA" where columns values are as below in CSV file "${CSV_FILE}"
      | ISSID:IssuerID | R79076 |

    Given I expect column "LG:TW_TRC_IST" value to be "TRC_S_twA11" where columns values are as below in CSV file "${CSV_FILE}"
      | ISSID:IssuerID | R79076 |

    Given I expect column "LG:TW_TRC_ILT" value to be "TRC_L_NR" where columns values are as below in CSV file "${CSV_FILE}"
      | ISSID:IssuerID | H74690 |

    Given I expect column "LG:TW_TRC_IST" value to be "TRC_S_twA2" where columns values are as below in CSV file "${CSV_FILE}"
      | ISSID:IssuerID | R71340 |