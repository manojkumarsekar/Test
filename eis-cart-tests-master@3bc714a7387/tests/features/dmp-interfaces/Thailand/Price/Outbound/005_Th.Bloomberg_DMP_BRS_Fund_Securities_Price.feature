#https://jira.pruconnect.net/browse/EISDEV-6658
#Architectue Requirement: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOMR3&title=Solution+Area+-+Price+R3
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?pageId=60838770
# EISDEV-7037: Wrapper class created for BB request and replay


@dmp_regression_unittest @eisdev_7037
@eisdev_6658 @001_price_6658 @001_th_bloomberg_price @bbpersecurity @dmp_thailand_price @dmp_thailand @dmp_interfaces @eisdev_6725
@gc_interface_portfolios @gc_interface_positions @gc_interface_refresh_soi @gc_interface_request_reply @gc_interface_prices
@dmp_regression_integrationtest


@eisdev_6846
Feature: Thailand Fund Securities Price to BRS | Bloomberg Request and Reply

  This testcase validate the BB Request and Reply and publish price to BRS

  Below Steps are followed to validate this testing

  1. Load Portgroup file to create account participant as per below
  Entity	Group	Fund	Accont	    Instr_ID	Busip	       ISIN	                     Scenarios
  TFUND	  TFB-AG	883	 GS0000012186	kCrms&s%81	BPM1EKVE4	TW000T0708Y5	3rd party Fund, Part of AISR and not thailand fundgroup, Send request to Bloomberg
  TFUND	  TFB-AG	919	 GS0000012131	m-r~x(uCG1	BES38VP66	TH9454010009	Internal fund, Part of AISR and Thailand fundgroup, do not send request to Bloomerg
  TFUND	  TFB-AG	883	 GS0000012186	Mp9R02nGG2	S62248711	KR7017670001	Do not send to Bloomberg because we need to send only SICAV and AUT RDMSECTYPE
  TMBAM	  THB-AG	I20	 GS0000007676	Bp9ZD2nGG2	BRSRZS373	TW000T0712Y7	3rd party Fund, Part of AISR and not thailand fundgroup, Send request to Bloomberg
  TMBAM	  TFB-AG	I02	 GS0000009216	QZ$Iw~Wb81	BES38W5X7	TH1905010001	Internal fund, Part of AISR and Thailand fundgroup, do not send request to Bloomerg
  TMBAM	  TFB-AG	I20	 GS0000007676	Gq9j72nGG2	S62295977	JP3967200001	Do not send to Bloomberg because we need to send only SICAV and AUT RDMSECTYPE
  2. Load positions for one TMBAM and TFUND using the "EIS_MT_BRS_EOD_POSITION_NON_LATAM" Messagetype
  3. SOI Refresh to create issue participants (Issuer group : ESI_TH_BBG_FUNDSEC_RATES_SOI, Query : EITH_REFRESH_BBG_FUNDSEC_RAT)
  3. Generate the request file it should contains newly loaded positions
  4. Mock up response file for corresponding loaded position and copy to dmp.ssh.outbound.path with current date and time
  5. Publish Price file and perform recon

  Scenario:TC1: Initialize all the variables

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Outbound" to variable "testdata.path"

    #Portgroup
    And I assign "005_Th.Bloomberg_Fund_Securities_port_group.xml" to variable "INPUT_PORTGROUP"

    #Position
    And I assign "005_Th.Bloomberg_DMP_Fund_Securities_position_template.xml" to variable "INPUT_POSITION_TEMPLATENAME"
    And I assign "005_Th.Bloomberg_DMP_Fund_Securities_position.xml" to variable "INPUT_POSITION_FILENAME"

    #Bloomberg details
    And I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_PATH_IN"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_PATH_OUT"
    And I assign "005_gs_th_fund_securities_price_template.out" to variable "RESPONSE_TEMPLATENAME"

    #Publishing
    And I assign "005_esi_brs_th_fund_securities_price" to variable "PUBLISHING_FILE_NAME"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "005_fund_securities_price_expected_template.csv" to variable "PUBLISH_FILE_TEMPLATE"

  Scenario:TC2: Load Port group file to create participant for TMBAM and TFUND as per point no 1

    Given I process "${testdata.path}/testdata/${INPUT_PORTGROUP}" file with below parameters
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${INPUT_PORTGROUP}         |
      | MESSAGE_TYPE  | EIS_MT_BRS_PORTFOLIO_GROUP |

    Then I expect workflow is processed in DMP with total record count as "4"

  Scenario: TC_3: Create Position file with POS_DATE as SYSDATE and Load into DMP

    Given I create input file "${INPUT_POSITION_FILENAME}" using template "${INPUT_POSITION_TEMPLATENAME}" with below codes from location "${testdata.path}/outfiles"
      | POS_DATE | DateTimeFormat:M/dd/YYYY |

    # Ensure there are no future dated positions (created by other feature files, so rows should be small in number)
    And I execute below query to "clear future dated positions"
     """
     ${testdata.path}/sql/005_Fund_Securities_Clean_Future_Dated_Balh.sql
     """

    When I process "${testdata.path}/outfiles/testdata/${INPUT_POSITION_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_POSITION_FILENAME}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_EOD_POSITION_NON_LATAM |
      | BUSINESS_FEED |                                   |

    Then I expect workflow is processed in DMP with total record count as "6"

    #This check to verify BALH table MAX(AS_OF_TMS) rowcount with PositionFileLoad.xml file rowcount
    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "6":
     """
     ${testdata.path}/sql/005_Fund_Securities_Check_Positions_Loaded.sql
     """

  Scenario: TC_4: SOI Refresh to create issue participants

    Given I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | ESI_TH_BBG_FUNDSEC_RATES_SOI       |
      | NO_OF_BRANCH | 5                                  |
      | QUERY_NAME   | EITH_REFRESH_BBG_FUNDSEC_RATES_SOI |

    Then I expect value of column "ISGP_STATUS" in the below SQL query equals to "PASS":
    """
     SELECT CASE
              WHEN COUNT (0)> 0 THEN 'PASS'
              ELSE 'FAIL'
           END as ISGP_STATUS
     FROM FT_T_ISGP  WHERE PRNT_ISS_GRP_OID IN
        (SELECT ISS_GRP_OID
        FROM   FT_T_ISGR
        WHERE  ISS_GRP_ID = 'ESI_TH_BBG_FUNDSEC_RATES_SOI'
        AND END_TMS IS NULL)
      AND END_TMS IS NULL
     """

  Scenario: TC_5: Check the BB Request Reply for EITH_Fund_SecPrice

    Given I assign "${dmp.ssh.inbound.path}/bloomberg" to variable "BB_DOWNLOAD_DIR"
    And I assign "${dmp.ssh.outbound.path}/bloomberg" to variable "BB_UPLOAD_DIR"
    And I assign "005_gs_th_fund_securities_price_template.out" to variable "RESPONSE_TEMPLATENAME"


    # Clear VREQ
    And I execute below query to "clear VREQ for re-runs"
	 """
	 UPDATE FT_T_VREQ SET VND_RQST_TYP = 'Dummy' WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EITH_Fund_SecPrice' AND
	 VND_RQST_XREF_ID_CTXT_TYP in ('ISIN') AND VND_RQST_XREF_ID IN ('TW000T0712Y7','TW000T0708Y5')
	 """

    Given Setup BB request reply prerequisites with following details
      | VND_RQST_TYP            | EITH_Fund_SecPrice                                                       |
      | RESPONSE_TEMPLATE_PATH  | tests/test-data/dmp-interfaces/Thailand/Price/Outbound/outfiles/template |
      | RESPONSE_TEMPLATE_FILES | ${RESPONSE_TEMPLATENAME}                                                 |
      | BB_PATH                 | ${BB_DOWNLOAD_DIR}                                                       |

    # We are copying the response file on server because request reply workflow will generate request file and expect response file with same date.
    # Since, we are not connecting to BBG for testing this is to simulate the process of request reply

    Given I assign "tests/test-data/intf-specs/gswf/template/EIS_BBPerSecurity/request.xmlt" to variable "BB_PER_SECURITY"

    And I process the workflow template file "${BB_PER_SECURITY}" with below parameters and wait for the job to be completed
      | BB_DOWNLOAD_DIR    | ${BB_DOWNLOAD_DIR}           |
      | BB_UPLOAD_DIR      | ${BB_UPLOAD_DIR}             |
      | FIRM_NAME          | dl790188                     |
      | GROUP_NAME         | ESI_TH_BBG_FUNDSEC_RATES_SOI |
      | PRICE_POINT_DEF_ID | ESIPRPTEOD                   |
      | REQUEST_TYPE       | EITH_Fund_SecPrice           |
      | SN                 | 191305                       |
      | USER_NUMBER        | 30350268                     |
      | WORK_STATION       | 0                            |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${BB_PATH_OUT}" after processing:
      | gs_thfsprice${LATEST_SEQ}.req |

    Then I expect workflow is processed in DMP with total record count as "2"

    #This check to verify if 4 securities which satisfied condition for EITH_Fund_SecPrice were requested and response was loaded.
    And I expect value of column "VREQ_STATUS_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
          CASE
              WHEN COUNT (1) = 2   THEN 'PASS'
              ELSE 'FAIL'
          END
      AS VREQ_STATUS_CHECK
      FROM FT_T_VREQ
      WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE) AND   VND_RQST_TYP = 'EITH_Fund_SecPrice' AND   VND_RQST_XREF_ID_CTXT_TYP in ('ISIN') AND   VND_RQST_XREF_ID IN (
        'TW000T0712Y7','TW000T0708Y5'
      ) AND   (
          VND_RQST_STAT_TYP = 'CLOSED' OR    (
              VND_RQST_STAT_TYP = 'FAILED' AND VND_RQST_STAT_TXT = 'Processing messages in the engine failed.'
          )
      )
     """

    #This check to verify if Request count should be 2 which is our external fund(TW000T0712Y7,TW000T0708Y5) and internal fund(TH9454010009, TH1905010001) should not send to request
    And I expect value of column "VREQ_REQ_COUNT" in the below SQL query equals to "2":
     """
      select count(0) as VREQ_REQ_COUNT from FT_T_VREQ
      where vnd_rqst_oid in (SELECT vnd_rqst_oid FROM FT_T_VREQ
                             WHERE TRUNC (VND_RQST_TMS) = TRUNC (SYSDATE)
                             AND VND_RQST_TYP = 'EITH_Fund_SecPrice'
                             AND VND_RQST_XREF_ID_CTXT_TYP in ('ISIN')
                             AND   VND_RQST_XREF_ID IN ('TW000T0712Y7','TW000T0708Y5')
                             )
     """

    #This check to verify if ISPC requested and response was loaded.
    Then I expect value of column "ISPC_CHECK" in the below SQL query equals to "PASS":
     """
      SELECT
	CASE
		WHEN COUNT (1) >=2 THEN 'PASS'
		ELSE 'FAIL'
	END
      AS ISPC_CHECK
      FROM FT_T_ISPC
      WHERE prc_typ = '003'	AND  trunc(adjst_tms) = trunc(sysdate)
      AND INSTR_ID IN ( SELECT INSTR_ID
                    FROM FT_T_ISID
                    WHERE ISS_ID IN ('TW000T0712Y7','TW000T0708Y5')
                    AND ID_CTXT_TYP in ('ISIN')
                    AND   END_TMS IS NULL
                     )
      """

  Scenario: TC_6: Trigger Price publishing for CSV file into directory for Thailand Fund Securities Rate Validate

    Given I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                                                                      |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                                                                    |
      | SQL                  | <![CDATA[<sql>TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate) and PRC1_GRP_NME = 'ESI_TH_BBG_FUNDSEC_RATES_SOI' </sql>]]> |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

     #This check to verify nternal fund(TH9454010009, TH1905010001) should not Publish to BRS
    And I expect value of column "INTRNAL_PUBLISH_COUNT" in the below SQL query equals to "0":
     """
     select count(0) as INTRNAL_PUBLISH_COUNT from FT_V_PRC1 where TRUNC(PRC1_ADJST_TMS) = TRUNC(sysdate)
     and PRC1_GRP_NME = 'ESI_TH_BBG_FUNDSEC_RATES_SOI' and PRC1_ISIN in ('TH9454010009','TH1905010001')
     """

  Scenario: TC_7: Check if published file contains all the records which were loaded for BB Thailand Fund Securities

    Given I create input file "${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.csv" using template "${PUBLISH_FILE_TEMPLATE}" from location "${testdata.path}/outfiles"

    Then I expect all records from file1 of type CSV exists in file2
      | File1 | ${testdata.path}/outfiles/testdata/${PUBLISH_FILE_EXPECTED}_${VAR_SYSDATE}.csv |
      | File2 | ${testdata.path}/outfiles/actual/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv  |

