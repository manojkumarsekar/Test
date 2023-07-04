#https://jira.pruconnect.net/browse/EISDEV-6178
#Architectue Requirement: https://collaborate.pruconnect.net/display/EISTOM/Th.Aldn-25+Th.TMBAM.Price+NAV_Per_Unit+TMBAM_HIPORT_FA+-%3E+ESI_DMP
#Functional specification : https://collaborate.pruconnect.net/display/EISTOMR4/Th.Aldn-25+Th.TMBAM.Price%28i.e+NAV_Per_Unit%29+from+TMBAM_HIPORT_FA+-+DMP

#The below jira helps to modify PRC_SRCE_TYP as TMBAM and PRCNG_METH_TYP as ESIPX
#https://jira.pruconnect.net/browse/EISDEV-6231

#AS per new requirement portfolio validation removed and added MDX filter condition
#https://jira.pruconnect.net/browse/EISDEV-6309

@gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@eisdev_6178 @eisdev_6231 @eisdev_6309 @001_tmbam_nav_price_load @dmp_thailand_price @dmp_thailand @eisdev_6846
Feature: TMBAM NAV Load for Thailand

  The purpose of this interface is to get NAV per unit data from TMBAM Fund Admin and load into DMP.
  By using eisdev_6179 it is published to BRS as Price.

  We tests the following Scenario with this feature file.
  1.Scenario TC2: Create relationship between portfolios(E01, LF1) and securities(VNTD16214767,IDA0000749A4) in FT_T_AISR, it is prerequisite for NAV load.
  2.Scenario TC3: Load NAV files for four Porfolios(E01, LF1_THAI_CODE, VALIDATE_PORTFOLIO_FILTER and RF3)
  3.Scenario TC4: Check if Price(FT_T_ISPC) record is created in the FT_T_ISPC table using Portfolio CRTSID as E01
  4.Scenario TC5: Check if Price(FT_T_ISPC) record is created in the FT_T_ISPC table using Portfolio THAIID as LF1_THAI_CODE
  5.Scenario TC6: Check if Issue Participants record is created in the FT_T_ISGP table


  Scenario: TC1: Initialize variables and Deactivate Existing test maintain clean state before executing tests

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Inbound" to variable "testdata.path"

    # Portfolio Uploader variable
    And I assign "001_Th.Aldn-25_TMBAM_DMP_R3_PortfolioMasteringTemplate_Final_4.11.xlsx" to variable "PROTFOLIO_INPUT_FILENAME"

    # NAV Load Variables
    And I assign "001_Th.Aldn-25_TMBAM_DMP_NAV" to variable "NAV_INPUT_FILENAME"
    And I assign "001_Th.Aldn-25_TMBAM_DMP_NAV_Template.xml" to variable "NAV_INPUT_TEMPLATENAME"
    And I extract value from the xml file "${testdata.path}/template/${NAV_INPUT_TEMPLATENAME}" with xpath "/header/fund_info/row[@id='1']/nav_per_unit" to variable "CRTSID_PORTFOLIO_PRICE"
    And I extract value from the xml file "${testdata.path}/template/${NAV_INPUT_TEMPLATENAME}" with xpath "/header/fund_info/row[@id='2']/nav_per_unit" to variable "THAIID_PORTFOLIO_PRICE"


    #Date Variables
    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
     """
     select to_char(max(GREG_DTE),'dd/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE <= trunc(sysdate-1) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
     """

    And I modify date "${DYNAMIC_DATE}" with "+0d" from source format "dd/MM/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"

    #Delete old data
    And I execute below query to "Delete existing price for ${DYNAMIC_DATE}"
    """
    DELETE FROM FT_T_ISGP WHERE trunc(START_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY')  AND LAST_CHG_USR_ID='EITH_TMBAM_DMP_FA_NAV_PRICE'
    AND   PRT_PURP_TYP='MEMBER' AND END_TMS IS NULL AND PRNT_ISS_GRP_OID IN (SELECT ISS_GRP_OID FROM FT_T_ISGR WHERE ISS_GRP_ID='TMBAMNAVSI'
    AND END_TMS IS NULL);
    DELETE FT_T_ISPC WHERE PRC_SRCE_TYP ='TMBAM' AND PRCNG_METH_TYP  = 'ESIPX' AND DATA_SRC_ID='TMBAM' AND LAST_CHG_USR_ID='EITH_TMBAM_DMP_FA_NAV_PRICE' AND trunc(ADJST_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY');
    """

    #Remove the comma in XPATH Variable
    And I execute below query and extract values of "THAIID_PORTFOLIO_PRICE" into same variables
    """
    select replace('${THAIID_PORTFOLIO_PRICE}',',','' ) as THAIID_PORTFOLIO_PRICE from dual
    """

  Scenario:TC2: Create portfolio and security releationship(AUT) using portfolio uploader

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PROTFOLIO_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${PROTFOLIO_INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_RDM_PORTFOLIO_MASTER_TEMPLATE |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"

  Scenario:TC3: Load TMBAM NAV File

    Given I create input file "${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml" using template "${NAV_INPUT_TEMPLATENAME}" from location "${testdata.path}"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${NAV_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.xml |
      | MESSAGE_TYPE  | EITH_MT_TMBAM_DMP_FA_NAV_PRICE                 |
      | BUSINESS_FEED |                                                |

    Then I expect workflow is processed in DMP with total record count as "4"

    And filtered record count as "1"

  Scenario: TC4: Check if Price record is created in the FT_T_ISPC table using Portfolio CRTSID

    Then I expect value of column "PRICE" in the below SQL query equals to "${CRTSID_PORTFOLIO_PRICE}":
    """
    SELECT unit_cprc as PRICE
	FROM   ft_t_ispc
	WHERE  prcng_meth_typ  = 'ESIPX'
    AND    prc_srce_typ    = 'TMBAM'
    AND    last_chg_usr_id = 'EITH_TMBAM_DMP_FA_NAV_PRICE'
    AND    trunc(ADJST_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY')
	AND    instr_id IN (SELECT instr_id FROM ft_t_aisr
                        WHERE acct_issu_rl_typ='AUT'
                        AND end_tms is null
                        AND acct_id in (SELECT acct_id FROM ft_t_acid
                                        WHERE acct_alt_id = 'E01'
                                        AND   acct_id_ctxt_typ='CRTSID'
                                        AND   end_tms IS NULL))
    """

  Scenario: TC5: Check if Price record is created in the FT_T_ISPC table using Portfolio THAIID

    Then I expect value of column "PRICE" in the below SQL query equals to "${THAIID_PORTFOLIO_PRICE}":
    """
    SELECT unit_cprc as PRICE
	FROM   ft_t_ispc
	WHERE  prcng_meth_typ  = 'ESIPX'
    AND    prc_srce_typ    = 'TMBAM'
    AND    last_chg_usr_id = 'EITH_TMBAM_DMP_FA_NAV_PRICE'
    AND    trunc(ADJST_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY')
	AND    instr_id IN (SELECT instr_id FROM ft_t_aisr
                        WHERE acct_issu_rl_typ='AUT'
                        AND end_tms is null
                        AND acct_id in (SELECT acct_id FROM ft_t_acid
                                        WHERE acct_alt_id = 'LF1_THAI_CODE'
                                        AND   acct_id_ctxt_typ='THAIID'
                                        AND   end_tms IS NULL))
    """

  Scenario: TC6: Check if issue group participants records are created in FT_T_ISGP table

    Then I expect value of column "ISGP_STATUS" in the below SQL query equals to "PASS":
    """
    SELECT CASE
              WHEN COUNT (0)> 0 THEN 'PASS'
              ELSE 'FAIL'
           END as ISGP_STATUS
    FROM ft_t_isgp
    WHERE last_chg_usr_id='EITH_TMBAM_DMP_FA_NAV_PRICE'
    AND   prt_purp_typ='MEMBER'
    AND   end_tms IS NULL
    AND   prnt_iss_grp_oid IN (SELECT iss_grp_oid
                               FROM ft_t_isgr
                               WHERE iss_grp_id='TMBAMNAVSI'
                               AND end_tms IS NULL)
    """

