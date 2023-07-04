@tom_3700 @tom_3700_sanity @cis_op_regression @cis_op_functional

Feature: CISOrderPlacement | Functional | F001 | Sanity Test Publish Document workflow

  Scenario: Load orders for E-SUN portfolio.

  #Pre-requisite : Clear Orders
    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('2252645','2252845') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';

    update ft_t_acid set acct_alt_id = 'TT56' where acct_alt_id = 'TSTTT56';

    COMMIT
    """

  #Assign Variables
    Given I assign "/dmp/out/taiwan/placement" to variable "PUBLISHING_DIRECTORY"
    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement/" to variable "TESTDATA_PATH"
    And I assign "001_esi_orders_publish_document.xml" to variable "INPUT_FILENAME"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}/order/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"
    Then I extract value from the xml file "${TESTDATA_PATH}/order/testdata/${INPUT_FILENAME}" with tagName "PORTFOLIO_NAME" to variable "PORTFOLIOCRTSID"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | 2252645_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | 2252645_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | 2252645_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf.error |

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" if exists:
      | 2252845_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf.error |


    #Create ESUNPLTF for portfolio if not exists
    Given I execute below query
	"""
	${TESTDATA_PATH}order/sql/INSERT_Y_ESUNPLTF.sql
    """

    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

    #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "SANITY TEST PUBLISH ORDERS"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${INPUT_FILENAME}"
    And I set the workflow template parameter "POST_EVENT_NAME" to "EIS_UpdateInactiveOrder"
    And I set the workflow template parameter "ATTACHMENT_FILENAME" to "Exceptions.xlsx"
    And I set the workflow template parameter "HEADER" to "Please see the summary of the load below"
    And I set the workflow template parameter "FOOTER" to "DMP Team, Please do not reply to this mail as this is an automated mail service. This e-mail message is only for the use of the intended recipient and may contain information that is privileged and confidential. If you are not the intended recipient, any disclosure, distribution or other use of this e-mail message is prohibited"
    And I set the workflow template parameter "FILE_LOAD_EVENT" to "StandardFileLoad"
    And I set the workflow template parameter "EXCEPTION_DETAILS_COUNT" to "10"
    And I set the workflow template parameter "NOOFFILESINPARALLEL" to "1"

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

  #Verify Data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN ('2252645','2252845')
    AND AOST.ORDER_STAT_TYP = 'ACTIVE'
    """

  Scenario: Test BRS API Call & Publish document by doing a API call to Insight

    #Pre-requisite : Clear Orders
    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                    |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}           |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                 |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                 |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}    |

    #Verify Data
    Then I expect value of column "RECORD_COUNT" in the below SQL query equals to "2":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_AUOR AUOR, FT_T_AOST AOST
    WHERE AUOR.AUOR_OID = AOST.AUOR_OID
    AND AUOR.PREF_ORDER_ID IN ('2252645','2252845')
    AND AOST.ORDER_STAT_TYP = 'NEWSENT'
    """

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | 2252645_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf |

    Then I expect below files with pattern to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIRECTORY}" after processing:
      | 2252845_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | 2252645_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf.error |

    Then I expect below files with pattern are not available in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIRECTORY}" after processing:
      | 2252845_${PORTFOLIOCRTSID}_${BCUSIP}_*_ACTIVE_*.pdf.error |

