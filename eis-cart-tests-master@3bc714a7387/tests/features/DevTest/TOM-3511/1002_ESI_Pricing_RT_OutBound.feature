# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03/08/2018      TOM-3511    First Version
# 13/08/2018      TOM-3521    Code beautification and formatting
# 14/08/2018      TOM-3555    Changes to BidPrice Rounding
# 29/11/2018      TOM-3971    Fixed HeaderDate in outbound to match with inbound
# 11/03/2019      TOM-4341    Changed the Vendor Defintion id from "RT" to "REUTERS"
# =====================================================================

#https://jira.intranet.asia/browse/TOM-3481
#https://jira.intranet.asia/browse/TOM-3487
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45843320

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3511 @1002_esi_pricing_rt_outbound @tom_4341 @eisdev_7379
Feature: Reuters Price Outbound to BRS

  Below records should be present in the outbound

  VNTD16214460 131.681
  VNTD15302894 121.605
  VNTB13281548 122.027
  VNTD17474097 120.871

  Scenario: TC_1: Load Inbound to test Outbound
    Given I assign "ESI_Pricing_RT_001_Positive_MandatoryFields.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3511" to variable "testdata.path"

    # Clear data for the given instruments from ISGP and ISPC tables
    When I execute below query
    """
    ${testdata.path}/sql/ESI_Pricing_RT_001_ClearData.sql
    """

    And I execute below query and extract values of "DYNAMIC_DATE_BEFORE_STALE" into same variables
     """
     SELECT TO_CHAR(TO_DATE('07/27/2018','MM/DD/YYYY')-TO_NUMBER(intrnl_dmn_val_txt),'MM/dd/YYYY') as DYNAMIC_DATE_BEFORE_STALE FROM ft_t_idmv WHERE intrnl_dmn_val_nme = 'REUTERS_STALE_PRICE_DAYS' AND fld_id = '41000801'
     """
    And I modify date "${DYNAMIC_DATE_BEFORE_STALE}" with "-1d" from source format "MM/dd/YYYY" to destination format "MM/dd/YYYY" and assign to "DYNAMIC_DATE_STALE"
    And I assign "ESI_Pricing_RT_001_Positive_MandatoryFields_template.csv" to variable "INPUT_TEMPLATENAME"
    And I create input file "${INPUT_FILENAME}" using template "${INPUT_TEMPLATENAME}" from location "${testdata.path}"


    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                      |
      | FILE_PATTERN  | ${INPUT_FILENAME}    |
      | MESSAGE_TYPE  | EIS_MT_REUTERS_PRICE |

  Scenario: TC_2: Triggering Publishing Wrapper Event for CSV file into directory for Price

    Given I assign "esi_reuters_price_pub" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                   |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3511/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Check price for respective ISINs in outbound

    Given I assign "tests/test-data/DevTest/TOM-3511/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if ISIN VNTD16214460 has price 131.681 in the outbound
    Given I expect column "PRICE" value to be "131.681" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN    | VNTD16214460 |
      | SOURCE  | ESIVN        |
      | PURPOSE | ESIVNM       |
      | DATE    | 20180727     |

    #Check if ISIN VNTD15302894 has price  121.605 in the outbound
    Given I expect column "PRICE" value to be "121.605" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN    | VNTD15302894 |
      | SOURCE  | ESIVN        |
      | PURPOSE | ESIVNM       |
      | DATE    | 20180727     |

    #Check if ISIN VNTB13281548  has price 122.027 in the outbound
    Given I expect column "PRICE" value to be "122.027" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN    | VNTB13281548 |
      | SOURCE  | ESIVN        |
      | PURPOSE | ESIVNM       |
      | DATE    | 20180727     |

    #Check if ISIN VNTD17474097  has price 120.871 in the outbound
    Given I expect column "PRICE" value to be "120.871" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN    | VNTD17474097 |
      | SOURCE  | ESIVN        |
      | PURPOSE | ESIVNM       |
      | DATE    | 20180727     |
