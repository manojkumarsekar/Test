#https://jira.pruconnect.net/browse/EISDEV-6221
#Architectue Requirement: https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTOM&title=Th.Aldn-26+Th.TFUND.Price+NAV_Per_Unit+TFUND_HIPORT_FA+-%3E+ESI_DMP
#Functional specification : https://collaborate.pruconnect.net/display/EISTT/TFUND%7CNAV+Per+unit+price%7CHIPORT%3EDMP%3EBRS#businessRequirements-File%20Details

#AS per new requirement portfolio validation removed and added MDX filter condition
#https://jira.pruconnect.net/browse/EISDEV-6309

# EISDEV-7003 Changes --START--
# Change Notification ID to 60037 for missing EISLSTID
# EISDEV-7003 Changes --END--

@gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@eisdev_6221 @eisdev_6309 @001_tfund_nav_price_load @001_thana_nav_price_load @dmp_thailand_price @dmp_thailand
@eisdev_6846 @eisdev_7003
Feature: TFUND or THANA NAV Load for Thailand

  The purpose of this interface is to get NAV per unit data from TFUND or THANA Fund Admin and load into DMP.
  By using eisdev_6222 it is published to BRS as Price.

  We tests the following Scenario with this feature file.
  1.Scenario TC2: Create relationship between portfolios(AISCOP, AJMOTO) and securities(XS0881511868,US3138WFXD36) in FT_T_AISR, it is prerequisite for NAV load.
  2.Scenario TC3: Load NAV files for four Porfolios(AISCOP, AJMOTO_THAIID, FUND_NOT_EXISTS and ANKANA)
  3.Scenario TC4: Check if Price(FT_T_ISPC) record is created in the FT_T_ISPC table using Portfolio CRTSID as AISCOP
  4.Scenario TC5: Check if Price(FT_T_ISPC) record is created in the FT_T_ISPC table using Portfolio THAIID as AJMOTO_THAIID
  5.Scenario: TC6: Verification of failures due to missing EISLSTID.  Input file portfolio code as BSOLAR and EISLSTID :ESL5349322

  Scenario: TC1: Initialize variables and Deactivate Existing test maintain clean state before executing tests

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Inbound" to variable "testdata.path"

   # Portfolio Uploader variable
    And I assign "001_Th.Aldn-26_TFUND_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "PROTFOLIO_INPUT_FILENAME"

   # NAV Load Variables
    And I assign "001_Th.Aldn-26_TFUND_DMP_NAV" to variable "NAV_INPUT_FILENAME"
    And I assign "001_Th.Aldn-26_TFUND_DMP_NAV_Template.csv" to variable "NAV_INPUT_TEMPLATENAME"

   #Date Variables
    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'dd/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE <= trunc(sysdate-1) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I modify date "${DYNAMIC_DATE}" with "+0d" from source format "dd/MM/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"

   #Delete old data
    And I execute below query to "Delete existing price for ${DYNAMIC_DATE}"
    """
    DELETE FROM FT_T_ISGP WHERE trunc(START_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY')  AND LAST_CHG_USR_ID='EITH_TFUND_DMP_FA_NAV_PRICE'
    AND   PRT_PURP_TYP='MEMBER' AND END_TMS IS NULL AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID='TFUNDNAVSI'
    AND END_TMS IS NULL);
    DELETE FT_T_ISPC WHERE PRC_SRCE_TYP ='TFUND' AND PRCNG_METH_TYP  = 'ESIPX' AND DATA_SRC_ID='THANA' AND LAST_CHG_USR_ID='EITH_TFUND_DMP_FA_NAV_PRICE' AND trunc(ADJST_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY');
    """

   #Inactivate EISLSTID, to validate missing EISLSTID scenario
    And I execute below query to inactivate EISLSTID
     """
      UPDATE ft_t_isid SET end_tms=sysdate WHERE iss_id='ESL5349322';
     """

  Scenario:TC2: Create portfolio and security releationship(AUT) using portfolio uploader

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PROTFOLIO_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${PROTFOLIO_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"

  Scenario:TC3: Load TFUND or TFUND NAV File

    Given I create input file "${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${NAV_INPUT_TEMPLATENAME}" from location "${testdata.path}"

    When I copy below files into dmp inbound folder
      | ${testdata.path}/testdata/${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EITH_MT_TFUND_DMP_FA_NAV_PRICE                 |
      | BUSINESS_FEED |                                                |

    #Read Price from input file
    And I extract below values for row 2 from CSV file "${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" in local folder "${testdata.path}/testdata" with reference to "DATE" column and assign to variables:
      | PRICE | CRTSID_PORTFOLIO_PRICE |

    And I extract below values for row 3 from CSV file "${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" in local folder "${testdata.path}/testdata" with reference to "DATE" column and assign to variables:
      | PRICE | THAIID_PORTFOLIO_PRICE |

    Then I expect workflow is processed in DMP with total record count as "5"

    And filtered record count as "2"

  Scenario: TC4: Check if Price record is created in the FT_T_ISPC table using Portfolio CRTSID

    Then I expect value of column "PRICE" in the below SQL query equals to "${CRTSID_PORTFOLIO_PRICE}":
    """
    SELECT unit_cprc as PRICE
	FROM   ft_t_ispc
	WHERE  prcng_meth_typ  = 'ESIPX'
    AND    prc_srce_typ    = 'TFUND'
    AND    last_chg_usr_id = 'EITH_TFUND_DMP_FA_NAV_PRICE'
    AND    trunc(ADJST_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY')
	AND    instr_id IN (SELECT instr_id FROM ft_t_aisr
                        WHERE acct_issu_rl_typ='AUT'
                        AND end_tms is null
                        AND acct_id in (SELECT acct_id FROM ft_t_acid
                                        WHERE acct_alt_id = 'AISCOP'
                                        AND   acct_id_ctxt_typ='CRTSID'
                                        AND   end_tms IS NULL))
    """


  Scenario: TC5: Check if Price record is created in the FT_T_ISPC table using Portfolio THAIID

    Then I expect value of column "PRICE" in the below SQL query equals to "${THAIID_PORTFOLIO_PRICE}":
    """
    SELECT unit_cprc as PRICE
	FROM   ft_t_ispc
	WHERE  prcng_meth_typ  = 'ESIPX'
    AND    prc_srce_typ    = 'TFUND'
    AND    last_chg_usr_id = 'EITH_TFUND_DMP_FA_NAV_PRICE'
    AND    trunc(ADJST_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY')
	AND    instr_id IN (SELECT instr_id FROM ft_t_aisr
                        WHERE acct_issu_rl_typ='AUT'
                        AND end_tms is null
                        AND acct_id in (SELECT acct_id FROM ft_t_acid
                                        WHERE acct_alt_id = 'AJMOTO_THAIID'
                                        AND   acct_id_ctxt_typ='THAIID'
                                        AND   end_tms IS NULL))
    """

  Scenario: TC6: Verification of failures due to missing EISLSTID

    Then I expect value of column "EXCEPTION_MSG1_CHECK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EXCEPTION_MSG1_CHECK
    FROM ft_t_ntel ntel
    JOIN ft_t_trid trid
    ON ntel.last_chg_trn_id = trid.trn_id
    WHERE trid.job_id = '${JOB_ID}'
    AND ntel.notfcn_stat_typ = 'OPEN'
    AND ntel.notfcn_id = '60037'
    """

  Scenario: TC7 Check if issue group participants records are created in FT_T_ISGP table

    Then I expect value of column "ISGP_STATUS" in the below SQL query equals to "PASS":
    """
    SELECT CASE
              WHEN COUNT (0)> 0 THEN 'PASS'
              ELSE 'FAIL'
           END as ISGP_STATUS
    FROM ft_t_isgp
    WHERE last_chg_usr_id='EITH_TFUND_DMP_FA_NAV_PRICE'
    AND   prt_purp_typ='MEMBER'
    AND   end_tms IS NULL
    AND   prnt_iss_grp_oid IN (SELECT iss_grp_oid
                               FROM ft_t_isgr
                               WHERE iss_grp_id='TFUNDNAVSI'
                               AND end_tms IS NULL)
    """

  Scenario: TC8: Reset EISLSTID

    Then I execute below query to reset EISLSTID
    """
     UPDATE ft_t_isid SET end_tms=null WHERE iss_id='ESL5349322';
    """