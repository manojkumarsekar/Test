#https://jira.pruconnect.net/browse/EISDEV-7004
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=SET+EQ+Sector+Classification%2CTBMA+Upload+and+Publish+FI+Prices%2CRatings%7CRIMES%3EDMP%3EBRS%7CPassthrough#businessRequirements-1989358494

@gc_interface_portfolios @gc_interface_nav @gc_interface_prices
@dmp_regression_integrationtest
@eisdev_7004 @004_tmbam_thaibma_price_load @dmp_thailand_price @dmp_thailand

Feature: TMBAM Thai BMA Price load for Thailand

  The purpose of this interface is to load Thai BMA price in DMP.
  It is a pass-through file from RIMES but is getting loaded on request from IDM team.
  The loaded data will not be published to BRS as we continue to send the pass-through file to BRS.

  Scenario: TC1: Initialize variables and clean price table

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Price/Inbound" to variable "testdata.path"
    And I assign "004_Th.Aldn-13_TMBAM_DMP_ThaiBMA_Price" to variable "PRICE_INPUT_FILENAME"
    And I assign "004_Th.Aldn-13_TMBAM_DMP_ThaiBMA_Price_Template.csv" to variable "PRICE_INPUT_TEMPLATENAME"

    #Date Variable
    And I execute below query and extract values of "DYNAMIC_DATE" into same variables
    """
      select to_char(max(GREG_DTE),'dd/MM/YYYY') as DYNAMIC_DATE from ft_t_cadp where cal_id = 'PRPTUAL' and GREG_DTE <= trunc(sysdate-1) and BUS_DTE_IND = 'Y' and END_TMS IS NULL
    """

    And I modify date "${DYNAMIC_DATE}" with "+0d" from source format "dd/MM/YYYY" to destination format "YYYYMMdd" and assign to "DYNAMIC_FILE_DATE"

    #Delete old data
    And I execute below query to "delete existing price"
    """
      DELETE FT_T_ISPC WHERE PRC_SRCE_TYP ='THBMA' AND PRCNG_METH_TYP  = 'ESITHA' AND INSTR_ID IN
      (SELECT INSTR_ID FROM FT_T_ISID WHERE ID_CTXT_TYP = 'TSC' AND ISS_ID = 'MPSC22OA' AND END_TMS IS NULL)
      AND TRUNC(PRC_TMS) >= TO_DATE('${DYNAMIC_DATE}','dd/MM/YYYY')
    """

  Scenario:TC2: Load TMBAM Thai BMA Price File

    Given I create input file "${PRICE_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv" using template "${PRICE_INPUT_TEMPLATENAME}" from location "${testdata.path}"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${PRICE_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${PRICE_INPUT_FILENAME}_${DYNAMIC_FILE_DATE}.csv |
      | MESSAGE_TYPE  | EITH_MT_RIMES_DMP_THAIBMA_PRICE                  |
      | BUSINESS_FEED |                                                  |

    Then I expect workflow is processed in DMP with total record count as "3"
    Then I expect workflow is processed in DMP with filtered record count as "1"

  Scenario: TC3: Check if Price record is created in the FT_T_ISPC table using THAIID

    Then I expect value of column "PRICE" in the below SQL query equals to "106.288539":
    """
      select unit_cprc as PRICE
	  from ft_t_ispc WHERE prcng_meth_typ = 'ESITHA' AND prc_srce_typ = 'THBMA'
	  and trunc(PRC_TMS) >= to_date('${DYNAMIC_DATE}','dd/MM/YYYY')
	  and instr_id in (select instr_id from ft_t_isid where id_ctxt_typ = 'TSC' and iss_id = 'MPSC22OA' and end_tms is null)
    """

    Then I expect value of column "DATA_MISSING" in the below SQL query equals to "1":
    """
      select count(*) as DATA_MISSING
      from ft_t_ntel where last_chg_trn_id in
      (select trn_id from ft_t_trid where job_id = '${JOB_ID}') and notfcn_id = '60001'
    """