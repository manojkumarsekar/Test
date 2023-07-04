#https://jira.intranet.asia/browse/TOM-4715

#EISDEV-7484: Expected file updated

@dmp_regression_integrationtest
@tw_order_placement @tw_order_placement_bulk @tom_4715 @tom_3700 @cis_op_regression @cis_op_functional
@eisdev_7439 @eisdev_7484

Feature: CISOrderPlacement | Functional | F014_1 | This is to test if pdf files when generated in bulk are generated in proper format and no blank pdf's are generated

  Scenario: Load orders for portfolio.

    #Pre-requisite : Clear Orders
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement/" to variable "testdata.path"
    And I execute below query
	"""
    ${testdata.path}/order/sql/014_CleanOrders.sql
    """

    #Create ESUNPLTF for portfolio if not exists
    Given I execute below query
	"""
	${testdata.path}/order/sql/INSERT_Y_ESUNPLTF_TT56.sql
    """

    #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "014_esi_orders_bulk.xml" to variable "ORDER_INPUT_FILENAME"
    And I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" to variable "ORDER_WORKFLOW"

    #Load Data
    Given I copy files below from local folder "${testdata.path}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ORDER_INPUT_FILENAME} |
#    Then I extract value from the xml file "${testdata.path}/order/testdata/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
#    Then I extract value from the xml file "${testdata.path}/order/testdata/${INPUT_FILENAME}" with tagName "PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | *.pdf       |
      | *.pdf.error |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | *.pdf.error |

    And I process the workflow template file "${ORDER_WORKFLOW}" with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EIS_MT_BRS_ORDERS                           |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}                     |
      | EMAIL_TO                | testautomation@eastspring.com               |
      | EMAIL_SUBJECT           | SANITY TEST PUBLISH ORDERS                  |
      | PUBLISH_LOAD_SUMMARY    | true                                        |
      | SUCCESS_ACTION          | DELETE                                      |
      | FILE_PATTERN            | ${ORDER_INPUT_FILENAME}                     |
      | POST_EVENT_NAME         | EIS_UpdateInactiveOrder                     |
      | ATTACHMENT_FILENAME     | Exceptions.xlsx                             |
      | HEADER                  | Please see the summary of the load below    |
      | FOOTER                  | DMP Team, Please do not reply to this mail. |
      | FILE_LOAD_EVENT         | StandardFileLoad                            |
      | EXCEPTION_DETAILS_COUNT | 10                                          |
      | NOOFFILESINPARALLEL     | 1                                           |

    #Verify Data
    Then I expect value of column "ORDER_COUNT" in the below SQL query equals to "58":
    """
    ${testdata.path}/order/sql/014_VerifyOrders.sql
    """

  Scenario: Publish order placement forms for all the order loaded

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                    |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}             |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                 |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                 |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}    |

    #Verify Status
    Then I expect value of column "NEWSENT_COUNT" in the below SQL query equals to "29":
    """
    ${testdata.path}/order/sql/014_VerifyOrderStatus.sql
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | 24527526B*.pdf |
      | 24527528B*.pdf |
      | 24527533B*.pdf |
      | 24527532B*.pdf |
      | 24527534B*.pdf |
      | 24527524B*.pdf |
      | 2452751B*.pdf  |
      | 24527529B*.pdf |
      | 24527527B*.pdf |
      | 24527522B*.pdf |
      | 24527550B*.pdf |
      | 24527520B*.pdf |
      | 24527530B*.pdf |
      | 24527521B*.pdf |
      | 24527525B*.pdf |
      | 24527523B*.pdf |
      | 24527538B*.pdf |
      | 24527537B*.pdf |
      | 24527549B*.pdf |
      | 24527547B*.pdf |
      | 24527546B*.pdf |
      | 24527544B*.pdf |
      | 24527540B*.pdf |
      | 24527539B*.pdf |
      | 24527541B*.pdf |
      | 24527548B*.pdf |
      | 24527545B*.pdf |
      | 24527543B*.pdf |
      | 24527542B*.pdf |

  Scenario: Loading PDF file in local and performing direct PDF comparison with expected PDF

    Given I assign "24527542B.pdf" to variable "EXPECTED_FILE1"
    And I assign "24527526B.pdf" to variable "EXPECTED_FILE2"
    And I assign "24527528B.pdf" to variable "EXPECTED_FILE3"
    And I assign "24527533B.pdf" to variable "EXPECTED_FILE4"
    And I assign "24527532B.pdf" to variable "EXPECTED_FILE5"
    And I assign "24527534B.pdf" to variable "EXPECTED_FILE6"
    And I assign "24527524B.pdf" to variable "EXPECTED_FILE7"
    And I assign "2452751B.pdf" to variable "EXPECTED_FILE8"
    And I assign "24527529B.pdf" to variable "EXPECTED_FILE9"
    And I assign "24527527B.pdf" to variable "EXPECTED_FILE10"
    And I assign "24527522B.pdf" to variable "EXPECTED_FILE11"
    And I assign "24527550B.pdf" to variable "EXPECTED_FILE12"
    And I assign "24527520B.pdf" to variable "EXPECTED_FILE13"
    And I assign "24527530B.pdf" to variable "EXPECTED_FILE14"
    And I assign "24527521B.pdf" to variable "EXPECTED_FILE15"
    And I assign "24527525B.pdf" to variable "EXPECTED_FILE16"
    And I assign "24527523B.pdf" to variable "EXPECTED_FILE17"
    And I assign "24527538B.pdf" to variable "EXPECTED_FILE18"
    And I assign "24527537B.pdf" to variable "EXPECTED_FILE19"
    And I assign "24527549B.pdf" to variable "EXPECTED_FILE20"
    And I assign "24527547B.pdf" to variable "EXPECTED_FILE21"
    And I assign "24527546B.pdf" to variable "EXPECTED_FILE22"
    And I assign "24527544B.pdf" to variable "EXPECTED_FILE23"
    And I assign "24527540B.pdf" to variable "EXPECTED_FILE24"
    And I assign "24527539B.pdf" to variable "EXPECTED_FILE25"
    And I assign "24527541B.pdf" to variable "EXPECTED_FILE26"
    And I assign "24527548B.pdf" to variable "EXPECTED_FILE27"
    And I assign "24527545B.pdf" to variable "EXPECTED_FILE28"
    And I assign "24527543B.pdf" to variable "EXPECTED_FILE29"
    And I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIR"

    When I read latest file with the pattern "24527542B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE1"
    And I read latest file with the pattern "24527526B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE2"
    And I read latest file with the pattern "24527528B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE3"
    And I read latest file with the pattern "24527533B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE4"
    And I read latest file with the pattern "24527532B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE5"
    And I read latest file with the pattern "24527534B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE6"
    And I read latest file with the pattern "24527524B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE7"
    And I read latest file with the pattern "2452751B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE8"
    And I read latest file with the pattern "24527529B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE9"
    And I read latest file with the pattern "24527527B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE10"
    And I read latest file with the pattern "24527522B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE11"
    And I read latest file with the pattern "24527550B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE12"
    And I read latest file with the pattern "24527520B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE13"
    And I read latest file with the pattern "24527530B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE14"
    And I read latest file with the pattern "24527521B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE15"
    And I read latest file with the pattern "24527525B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE16"
    And I read latest file with the pattern "24527523B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE17"
    And I read latest file with the pattern "24527538B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE18"
    And I read latest file with the pattern "24527537B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE19"
    And I read latest file with the pattern "24527549B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE20"
    And I read latest file with the pattern "24527547B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE21"
    And I read latest file with the pattern "24527546B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE22"
    And I read latest file with the pattern "24527544B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE23"
    And I read latest file with the pattern "24527540B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE24"
    And I read latest file with the pattern "24527539B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE25"
    And I read latest file with the pattern "24527541B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE26"
    And I read latest file with the pattern "24527548B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE27"
    And I read latest file with the pattern "24527545B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE28"
    And I read latest file with the pattern "24527543B*.pdf" in the path "${PUBLISHING_DIR}" with the host "dmp.ssh.inbound" into variable "LATEST_PUBLISHED_FILE29"

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/output/runtime":
      | ${LATEST_PUBLISHED_FILE1}  |
      | ${LATEST_PUBLISHED_FILE2}  |
      | ${LATEST_PUBLISHED_FILE3}  |
      | ${LATEST_PUBLISHED_FILE4}  |
      | ${LATEST_PUBLISHED_FILE5}  |
      | ${LATEST_PUBLISHED_FILE6}  |
      | ${LATEST_PUBLISHED_FILE7}  |
      | ${LATEST_PUBLISHED_FILE8}  |
      | ${LATEST_PUBLISHED_FILE9}  |
      | ${LATEST_PUBLISHED_FILE10} |
      | ${LATEST_PUBLISHED_FILE11} |
      | ${LATEST_PUBLISHED_FILE12} |
      | ${LATEST_PUBLISHED_FILE13} |
      | ${LATEST_PUBLISHED_FILE14} |
      | ${LATEST_PUBLISHED_FILE15} |
      | ${LATEST_PUBLISHED_FILE16} |
      | ${LATEST_PUBLISHED_FILE17} |
      | ${LATEST_PUBLISHED_FILE18} |
      | ${LATEST_PUBLISHED_FILE19} |
      | ${LATEST_PUBLISHED_FILE20} |
      | ${LATEST_PUBLISHED_FILE21} |
      | ${LATEST_PUBLISHED_FILE22} |
      | ${LATEST_PUBLISHED_FILE23} |
      | ${LATEST_PUBLISHED_FILE24} |
      | ${LATEST_PUBLISHED_FILE25} |
      | ${LATEST_PUBLISHED_FILE26} |
      | ${LATEST_PUBLISHED_FILE27} |
      | ${LATEST_PUBLISHED_FILE28} |
      | ${LATEST_PUBLISHED_FILE29} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE1}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE1} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE2}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE2} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE3}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE3} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE4}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE4} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE5}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE5} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE6}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE6} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE7}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE7} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE8}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE8} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE9}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE9} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE10}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE10} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE11}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE11} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE12}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE12} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE13}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE13} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE14}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE14} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE15}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE15} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE16}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE16} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE17}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE17} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE18}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE18} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE19}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE19} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE20}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE20} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE21}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE21} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE22}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE22} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE23}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE23} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE24}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE24} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE25}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE25} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE26}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE26} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE27}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE27} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE28}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE28} |

    Then I expect below pdf files should be identical
      | ${testdata.path}/output/expected/${EXPECTED_FILE29}        |
      | ${testdata.path}/output/runtime/${LATEST_PUBLISHED_FILE29} |