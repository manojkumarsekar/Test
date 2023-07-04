#https://jira.intranet.asia/browse/TOM-3604
#https://jira.intranet.asia/browse/TOM-4111 - Fix regression failures of TOM-3604
#https://jira.pruconnect.net/browse/EISDEV-7015 - Delete issue fixed


@gc_interface_positions @gc_interface_securities @gc_interface_cdf @gc_interface_request_reply
@dmp_regression_integrationtest
@tom_4111 @tom_3604 @brs_cdf @eisdev_7015
Feature: Loading BB per sec and checking data for CNTRY_OF_INCORPORATION / CNTRY_ISSUE_ISO / CNTRY_OF_DOMICILE

  1.Load data BRS position data to create position in UBZF portfolio for single security (Clean the security data from BALH before load. )
  2.Request sec master data to BB and make sure the securities belonging to new portfolio UBZF are requested to BB.
  3.Load a sample BB secmaster file and compare that data for CNTRY_OF_INCORPORATION / CNTRY_ISSUE_ISO / CNTRY_OF_DOMICILE
  4.Publish CDF and compare that data for CNTRY_OF_INCORPORATION / CNTRY_ISSUE_ISO / CNTRY_OF_DOMICILE

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/DevTest/TOM-3604" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I modify date "${VAR_SYSDATE}" with "+1d" from source format "YYYYMMdd" to destination format "MM/dd/yyyy" and assign to "PUBLISH_DATE_IN"
    And I assign "/dmp/out/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "/dmp/in/bloomberg" to variable "BB_UPLOAD_DIR"

    And I execute below query
    """
    ${testdata.path}/sql/cleardown.sql
    """

    And I create input file "pos_3604.xml" using template "pos_3604.xml" from location "${testdata.path}"

  Scenario: TC_2: Load data BRS position data to create position in UBZF portfolio for single security

    Given I assign "pos_3604.xml" to variable "POSITION_FILENAME"
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${POSITION_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${POSITION_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_LATAM |

     #This check to verify BALH table MAX(AS_OF_TMS) rowcount WITH PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "1":
     """
     SELECT COUNT(0) AS BALH_COUNT
     FROM   FT_T_BALH BALH, FT_T_ISID ISID
     WHERE  BALH.INSTR_ID = ISID.INSTR_ID
     AND    ISID.ID_CTXT_TYP = 'BCUSIP'
     AND    ISID.ISS_ID IN ('S56810468')
     AND    ISID.END_TMS IS NULL
     AND    ISID.ISS_ID IS NOT NULL
     AND    BALH.RQSTR_ID = 'BRSEOD'
     AND    BALH.AS_OF_TMS IN (SELECT  MAX(AS_OF_TMS) FROM FT_T_BALH WHERE RQSTR_ID = 'BRSEOD')
     """

  Scenario: TC_3: Check the BB Request Reply

    #This is to generate the response filename which is driven by database sequence
    Given I execute below query and extract values of "SEQ_1" into same variables
        """
        SELECT LPAD(VREQ_FILE_SEQ.NEXTVAL+1,8,'0') AS SEQ_1 FROM DUAL
        """

    #This is to generate the response filename taking sequence value from previous step.
    And I execute below query and extract values of "RESPONSE_FILE_NAME_1" into same variables
        """
        SELECT SUBSTR(FILE_PATTERN_TYP,0,INSTR(FILE_PATTERN_TYP,'*')-1)|| '${SEQ_1}' || '.out' AS RESPONSE_FILE_NAME_1
        FROM FT_CFG_VRTY
        WHERE VND_RQST_TYP = 'EIS_Secmaster'
        """

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply
    Given I copy files below from local folder "${testdata.path}/template" to the host "dmp.ssh.inbound" folder "${BB_DOWNLOAD_DIR}":
      | gs_sec_master_response_template.out |

    Then I rename file "${BB_DOWNLOAD_DIR}/gs_sec_master_response_template.out" as "${BB_DOWNLOAD_DIR}/${RESPONSE_FILE_NAME_1}" in the named host "dmp.ssh.inbound"

    Given I process BBPerSecurity workflow with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR | ${BB_DOWNLOAD_DIR} |
      | BB_UPLOAD_DIR   | ${BB_UPLOAD_DIR}   |
      | FIRM_NAME       | dl790188           |
      | REQUEST_TYPE    | EIS_Secmaster      |
      | SN              | 191305             |
      | USER_NUMBER     | 3650834            |
      | WORK_STATION    | 0                  |
      | TIMEOUT         | 600                |

    #This check to if the secuirty was requested.
    Then I expect value of column "REQ_COUNT" in the below SQL query equals to "1":
     """
     SELECT COUNT(*) as REQ_COUNT FROM ft_t_vreq
     WHERE vnd_rqst_xref_id IN
     (  SELECT iss_id FROM ft_t_isid WHERE instr_id IN
          (
            SELECT instr_id FROM ft_t_isid WHERE ISs_id = 'S56810468'
          )
     )
     """

  Scenario: TC_4: Load a sample BB secmaster file and compare that data for CNTRY_OF_INCORPORATION / CNTRY_ISSUE_ISO / CNTRY_OF_DOMICILE

    Given I assign "bb_sec.out" to variable "BB_FILE"
    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BB_FILE} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${BB_FILE}                       |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

    #This check to CNTRY_ISSUE_ISO data in db for individual ISINs
    Then I expect value of column "COUNT" in the below SQL query equals to "10":
     """
     SELECT    COUNT(*) as COUNT FROM  ft_t_isid i , ft_T_isgu g
		WHERE   i.instr_id = g.instr_id and i.end_tms is null and g.end_tms is null and g.iss_gu_purp_typ ='TRADING' and (i.iss_id , trim(g.gu_id) ) in
		(
      	select 'TH062303O600', 'TH'  from dual union
		select 'TH1074031804', 'TH'  from dual union
		select 'TH5435A34400', 'TH'  from dual union
		select 'TH0623A38308', 'TH'  from dual union
		select 'USY62526AB72', 'SNAT'  from dual union
		select 'IE00B0M63623', 'GB'  from dual union
		select 'LU0514695690', 'DE'  from dual union
		select 'US4642865251', 'US'  from dual union
		select 'TH0038037907', 'TH'  from dual union
		select 'XS1728741346', 'VG'  from dual )

     """

    #This check to CNTRY_OF_INCORPORATION data in db for individual ISINs
    Then I expect value of column "COUNT" in the below SQL query equals to "10":
     """
     SELECT    COUNT(*) as COUNT FROM  ft_t_isid i , ft_T_figu g , ft_t_frip f
		WHERE   i.instr_id = f.instr_id and i.end_tms is null and g.end_tms is null and f.end_tms is null and g.FINS_GU_PURP_TYP ='BBINCRPT' and  f.prt_purp_typ ='BBGISSR' and g.inst_mnem = f.inst_mnem and (i.iss_id , trim(g.gu_id) ) in
		(
		select 'TH062303O600', 'TH'  from dual union
		select 'TH1074031804', 'TH'  from dual union
		select 'TH5435A34400', 'TH'  from dual union
		select 'TH0623A38308', 'TH'  from dual union
		select 'USY62526AB72', 'MULT'  from dual union
		select 'IE00B0M63623', 'IE'  from dual union
		select 'LU0514695690', 'LU'  from dual union
		select 'US4642865251', 'US'  from dual union
		select 'TH0038037907', 'TH'  from dual union
		select 'XS1728741346', 'VG'  from dual )

     """

    #This check to CNTRY_OF_DOMICILE data in db for individual ISINs
    Then I expect value of column "COUNT" in the below SQL query equals to "10":
     """
     SELECT    COUNT(*) as COUNT FROM  ft_t_isid i , ft_T_figu g , ft_t_frip f
		WHERE   i.instr_id = f.instr_id and i.end_tms is null and g.end_tms is null and f.end_tms is null and g.FINS_GU_PURP_TYP ='BBDOMCLE' and  f.prt_purp_typ ='BBGISSR' and g.inst_mnem = f.inst_mnem and (i.iss_id , trim(g.gu_id) ) in
		(
		select 'TH062303O600', 'TH'  from dual union
		select 'TH1074031804', 'TH'  from dual union
		select 'TH5435A34400', 'TH'  from dual union
		select 'TH0623A38308', 'TH'  from dual union
		select 'USY62526AB72', 'Mixed'  from dual union
		select 'IE00B0M63623', 'IE'  from dual union
		select 'LU0514695690', 'LU'  from dual union
		select 'US4642865251', 'US'  from dual union
		select 'TH0038037907', 'TH'  from dual union
		select 'XS1728741346', 'VG'  from dual )


     """

  Scenario: TC_4: Triggering Publishing Wrapper Event for CSV file into directory for CDF Publishing

    Given I assign "3604_cdf" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                                                                                                                                                                       |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_CDF_SUB                                                                                                                                                                                                                            |
      | SQL                  | &lt;sql&gt; instr_id in ( select instr_id from ft_t_isid where  iss_id in ( 'TH062303O600', 'TH1074031804','TH5435A34400','TH0623A38308','USY62526AB72','IE00B0M63623','LU0514695690','US4642865251','TH0038037907','XS1728741346')) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5:  Check publishing file for sample ISIN for  CNTRY_OF_INCORPORATION / CNTRY_ISSUE_ISO / CNTRY_OF_DOMICILE

    Given I assign "${testdata.path}/outfiles/actual/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

  #Check if ISIN TH062303O600 has ESI_CNTRY_INCOR TH in the outbound
    Then I expect column "VALUE" value to be "TH" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN | TH062303O600    |
      | TAG  | ESI_CNTRY_INCOR |

  #Check if ISIN TH062303O600 has ESI_CNTRY_DOM TH in the outbound
    Then I expect column "VALUE" value to be "TH" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN | TH062303O600  |
      | TAG  | ESI_CNTRY_DOM |

  #Check if ISIN TH062303O600 has ESI_CNTRY_ISSUE TH in the outbound
    Then I expect column "VALUE" value to be "TH" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN | TH062303O600    |
      | TAG  | ESI_CNTRY_ISSUE |
