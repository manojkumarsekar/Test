# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 03/08/2018      TOM-3512    First Version
# 14/08/2018      TOM-3555    Changes to BidPrice Rounding
# =====================================================================

#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45845204
#https://jira.intranet.asia/browse/TOM-3482

@gc_interface_prices
@dmp_regression_integrationtest
@tom_3512 @dmp_interfaces @dmp_prices @1003_esi_pricing_idc_outbound @tom_4442
Feature: IDC Price Outbound to BRS

  Below records should be present in the outbound

  VNBVBS164062 117.95505
  VNTD16314633 124.1587
  B3YH4S3 106.95309

  Scenario: TC_1: Load Inbound to test the outbound

    Given I assign "ESI_Pricing_IDC_001_MandatoryFields_Verification20180731.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3512" to variable "testdata.path"

     # Clear data for the given instruments from ISGP and ISPC tables
    Given I execute below query
      """
      ${testdata.path}/sql/ESI_Pricing_IDC_001_ClearData.sql
      """
    Given I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                   |
      | FILE_PATTERN  | ${INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_IDC_PRICE  |

  Scenario: TC_2: Triggering Publishing Wrapper Event for CSV file into directory for Price

    Given I assign "esi_idc_price_pub" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/eod" to variable "PUBLISHING_DIR"

    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv                                     |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_PRICE_VIEW_SUB                                   |
      | SQL                  | &lt;sql&gt; TRUNC(PRC1_ADJST_TMS) =TRUNC(SYSDATE ) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "tests/test-data/DevTest/TOM-3512/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_3: Check the price for ISIN/SEDOL in IDC outbound file

    Given I assign "tests/test-data/DevTest/TOM-3512/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if ISIN VNBVBS164062 has price 117.95505 in the outbound
    Then I expect column "PRICE" value to be "117.95505" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN    | VNBVBS164062 |
      | SOURCE  | IDCVN        |
      | PURPOSE | ESILOCAL     |

    #Check if ISIN VNTD16314633 has price 124.1587 in the outbound
    Then I expect column "PRICE" value to be "124.1587" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN    | VNTD16314633 |
      | SOURCE  | IDCVN        |
      | PURPOSE | ESILOCAL     |

    #Check if SEDOL B3YH4S3 has price 106.95309 in the outbound
    Then I expect column "PRICE" value to be "106.95309" where columns values are as below in CSV file "${CSV_FILE}"
      | SEDOL   | B3YH4S3  |
      | SOURCE  | IDCVN    |
      | PURPOSE | ESILOCAL |
