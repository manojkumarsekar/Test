#https://jira.pruconnect.net/browse/EISDEV-6125
#https://collaborate.pruconnect.net/display/EISTOMR4/Resolving+Split+Security+Issue+in+DMP

@gc_interface_orders @gc_interface_securities
@dmp_regression_integrationtest
@dmp_taiwan
@eisdev_6125 @001_sm_api
Feature: Split security gets created in DMP through Order file(334) load and Security master file(F10) load which is resulting duplicate securities.

  This feature will test if ProcessFiles&CallAPI workflow is creating security before order gets loaded.
  It will also validate whether split security is not getting created and order file is referencing existing security instead of creating new

  Scenario: TC1: Initialize all the variables

    Given I assign "001_R5.IN.REFTW5_BRS_DMP_SecurityMaster_Order.xml" to variable "ORDER_INPUT_FILENAME_1"

    And I assign "tests/test-data/dmp-interfaces/Taiwan/Security/API" to variable "testdata.path"

    And I extract value from the xml file "${testdata.path}/testdata/${ORDER_INPUT_FILENAME_1}" with tagName "CUSIP" to variable "BCUSIP"
    And I extract value from the xml file "${testdata.path}/testdata/${ORDER_INPUT_FILENAME_1}" with tagName "SEDOL" to variable "SEDOL"

    And I extract value from the xml file "${testdata.path}/testdata/${ORDER_INPUT_FILENAME_1}" with tagName "ORD_NUM" to variable "ORD_NUM"

    And I assign "tests/test-data/intf-specs/gswf/template/EIS_LoadFiles_PublishExceptions/request.xmlt" to variable "ORDER_WORKFLOW"

  Scenario: TC2: Process a order file to call BRS API to create security before loading a order file

    Given I execute below query to "Clean ISID for BCUSIP & SEDOL"
	  """
      ${testdata.path}/sql/clean_isid.sql
      """

    Then I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ORDER_INPUT_FILENAME_1} |

    And I process Brs Api RequestReply workflow with below parameters and wait for the job to be completed
      | CHECK_FOR_EXISTENCE_OF_ENTITY | true                                 |
      | FILE_PATTERN                  | ${ORDER_INPUT_FILENAME_1}            |
      | BRS_WEBSERVICE_URL            | ${brswebservice.url}                 |
      | MSG_TYP_API                   | EIS_MT_BRS_ORDERS_API                |
      | MSG_TYP_PROCESS               | EIS_MT_BRS_SECURITY_NEW              |
      | TRANSLATION_MDX               | ${transalationmdx.validfilelocation} |
      | BRSPROPERTY_FILE_LOCATION     | ${brscredentials.validfilelocation}  |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC3: Check if Security is created in DMP and store the value of INSTR_ID

    Given I expect value of column "BCUSIP_IN_DB" in the below SQL query equals to "1":
      """
	  SELECT COUNT(1) AS BCUSIP_IN_DB FROM ft_t_isid
	  WHERE  end_tms IS NULL AND id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIP}'
	  """

    And I expect value of column "BCUSIP_COUNT_CHECK" in the below SQL query equals to "PASS":
      """
	  SELECT CASE WHEN COUNT(1) >= 2 THEN 'PASS' ELSE 'FAIL' END AS BCUSIP_COUNT_CHECK FROM ft_t_isid
	  WHERE end_tms is null and id_ctxt_typ = 'BCUSIP' and instr_id in
	  (select instr_id from ft_t_isid
	  WHERE  end_tms IS NULL AND id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIP}')
	  """

    And I execute below query and extract values of "INSTR_ID" into same variables
      """
      SELECT INSTR_ID FROM ft_t_isid WHERE end_tms IS NULL AND id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIP}'
      """

  Scenario: TC4: Process a order file to load it in database

    Given I execute below query to "Clean Order"
	  """
      ${testdata.path}/sql/clean_order.sql
      """

    And I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ORDER_INPUT_FILENAME_1} |

    And I process Load files and publish exceptions with below parameters and wait for the job to be completed
      | MESSAGE_TYPE            | EIS_MT_BRS_ORDERS                           |
      | INPUT_DIR               | ${dmp.ssh.inbound.path}                     |
      | EMAIL_TO                | testautomation@eastspring.com               |
      | EMAIL_SUBJECT           | SANITY TEST PUBLISH ORDERS                  |
      | PUBLISH_LOAD_SUMMARY    | true                                        |
      | SUCCESS_ACTION          | DELETE                                      |
      | FILE_PATTERN            | ${ORDER_INPUT_FILENAME_1}                   |
      | POST_EVENT_NAME         | EIS_UpdateInactiveOrder                     |
      | ATTACHMENT_FILENAME     | Exceptions.xlsx                             |
      | HEADER                  | Please see the summary of the load below    |
      | FOOTER                  | DMP Team, Please do not reply to this mail. |
      | FILE_LOAD_EVENT         | StandardFileLoad                            |
      | EXCEPTION_DETAILS_COUNT | 10                                          |
      | NOOFFILESINPARALLEL     | 1                                           |

    Then I expect workflow is processed in DMP with total record count as "1"

  Scenario: TC5: Check if order got loaded on the security which got created from API call

    Given I expect value of column "ORDER_IN_DB" in the below SQL query equals to "2":
    """
     SELECT COUNT(*) AS ORDER_IN_DB FROM FT_T_AUOR WHERE
     PREF_ORDER_ID = '${ORD_NUM}'
    """

    And I expect value of column "INSTR_ID_ORD" in the below SQL query equals to "${INSTR_ID}":
    """
     SELECT INSTR_ID AS INSTR_ID_ORD FROM FT_T_AUOR WHERE
     PREF_ORDER_ID = '${ORD_NUM}' AND INSTR_ID IS NOT NULL
     AND ACCT_ID IS NULL
    """