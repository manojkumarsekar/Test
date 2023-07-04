#https://jira.intranet.asia/browse/TOM-3275
#https://jira.intranet.asia/browse/TOM-3254
#https://collaborate.intranet.asia/pages/viewpage.action?pageId=24943456

@gc_interface_benchmark
@dmp_regression_unittest
@tom_3504
Feature: Testing Publishing wrapper Event for DMP to BNP drifted benchmark

  Currently same BCUSIP from BRS is mapped to different drifted BM components violating BNP's requirement for a one to one relationship between BCUSIP and BM component.
  Due to this, the BCUSIPs are manually being updated in the GAA Drifted Benchmark interface file for the Actual Return components of Sub Portfolios to make it as an unique BCUSIPs.

  This testcase validate the BNP drifted benchmark file generate from DMP.

  Requirement 1: TOM-3275
  If the Security Master: Issue UI screen "proxy in BRS" flag is Yes then DMP will concatenate Benchmark Code and BCUSIP
  and it will be published in the "BENCHMARK COMPONENT IDENTIFIER" field.
  else only BCUSIP received in Risk Analytics file from BRS will be published in the "BENCHMARK COMPONENT IDENTIFIER" field.

  Requirement 2: TOM-3254 outbound mdx
  The "Fund Code" field in GAA Drifted Benchmark output interface file needs to be sourced from this new "IRP Code" field(i.e Customer master : accound master UI screen : Xreference tab)

  Scenario: TC_1: Getting Data from DMP

    Given I assign "tests/test-data/DevTest/TOM-3504" to variable "testdata.path"
    And I execute below query and extract values of "IRPID_Y;BENCHMARKCODE_Y;BCUSIP_Y" into same variables
    """
    ${testdata.path}/sql/extract_proxy_y_data.sql
    """
    And I execute below query and extract values of "IRPID_N;BENCHMARKCODE_N;BCUSIP_N" into same variables
    """
    ${testdata.path}/sql/extract_proxy_n_or_null_data.sql
    """

    And I execute below query and extract values of "FUND_CODE;BENCHMARK_CODE" into same variables
    """
    ${testdata.path}/sql/extract_fund_irp_code_data.sql
    """

  Scenario: TC_2: Triggering Publishing Wrapper Event for CSV file into directory

    Given I assign "esi_bnp_drifted_bmk_weights" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/bnp/eod" to variable "PUBLISHING_DIR"

    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "PUBLISING_FILE_FULL_NAME"

    And I execute below query
	"""	
	DELETE FROM FT_CFG_SBEX WHERE SBEX_OID=(SELECT MAX(SBEX.SBEX_OID) FROM FT_CFG_SBEX SBEX, FT_CFG_SBDF SBDF
	WHERE SBEX.SBDF_OID=SBDF.SBDF_OID AND SBDF.SUBSCRIPTION_NME = 'EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB')
	"""

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_*_1.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME   | ${PUBLISHING_FILE_NAME}.csv           |
      | SUBSCRIPTION_NAME      | EIS_DMP_TO_BNP_DRIFTED_BM_WEIGHTS_SUB |
      | PUBLISHING_DESTINATION | directory                             |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISING_FILE_FULL_NAME} |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISING_FILE_FULL_NAME} |

  Scenario: TC_3: Check the BenchmarkCode and BCUSIP should append in "BENCHMARK COMPONENT IDENTIFIER" column where Security master:ISSUE Screen "PROXY in BRS" Flag="Y"

    Then I expect column "BENCHMARK CODE" value to be "${BENCHMARKCODE_Y}" where columns values are as below in CSV file "${testdata.path}/outfiles/${PUBLISING_FILE_FULL_NAME}"
      | FUND CODE                      | ${IRPID_Y}  |
      | BENCHMARK COMPONENT IDENTIFIER | ${BCUSIP_Y} |

  Scenario: TC_4: Check the BCUSIP should display in "BENCHMARK COMPONENT IDENTIFIER" column where Security master:ISSUE Screen "PROXY in BRS" Flag="N" or null

    Then I expect column "BENCHMARK CODE" value to be "${BENCHMARKCODE_N}" where columns values are as below in CSV file "${testdata.path}/outfiles/${PUBLISING_FILE_FULL_NAME}"
      | FUND CODE                      | ${IRPID_N}  |
      | BENCHMARK COMPONENT IDENTIFIER | ${BCUSIP_N} |

  Scenario: TC_5: Check the "Fund code" should populate from Customer master : accound master UI screen : Xreference tab : IRP Code control

    Then I expect column "FUND CODE" value to be "${FUND_CODE}" where column "BENCHMARK CODE" value is "${BENCHMARK_CODE}" in CSV file "${testdata.path}/outfiles/${PUBLISING_FILE_FULL_NAME}"

	
	