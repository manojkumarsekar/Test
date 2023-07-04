@tom_3700 @tom_3700_filternorows @cis_op_regression @cis_op_functional

Feature: CISOrderPlacement | Functional | F003 | Test Publish Document workflow with no filterqueryresult
  This is to test that workflow exits when filter query return no rows

  Scenario: Clear delta crossrefoids

    And I assign "tests/test-data/dmp-interfaces/Taiwan/CISOrderPlacement/" to variable "TESTDATA_PATH"

 #Pre-requisite : Clear delta crossrefoids
    Given I execute below query
	"""
    UPDATE
    (SELECT SBEX.END_TMS as endtms
    FROM FT_CFG_SBEX SBEX,
    FT_CFG_SBDF SBDF
     WHERE SBEX.SBDF_OID  = SBDF.SBDF_OID
     AND SBDF.SUBSCRIPTION_NME = 'EITW_DMP_TO_TW_ORDER_PLACE_SUB')
     SET endtms = (select MAX(JOB_END_TMS) from ft_T_jblg JBLG WHERE JBLG.JOB_MSG_TYP    = 'EIS_MT_BRS_ORDERS')+1;
     COMMIT
    """

  Scenario: Test if workflow exits when filter query return no rows

    Given I process publish document workflow with below parameters and wait for the job to be completed
      | SUBSCRIPTION_NAME              | EITW_DMP_TO_TW_ORDER_PLACE_SUB          |
      | BRS_WEBSERVICE_URL             | ${brswebservice.url}                    |
      | BRSPROPERTY_FILE_LOCATION      | ${brscredentials.validfilelocation}     |
      | INSIGHT_WEBSERVICE_URL         | ${gs.is.order.WORKFLOW.url}           |
      | INSIGHT_PROPERTY_FILE_LOCATION | ${insightcredentials.validfilelocation} |
      | MESSAGE_TYPE                   | EIS_MT_BRS_SECURITY_NEW                 |
      | DERIVE_STATUS_EVENTNAME        | EIS_TWDeriveOrderStatus                 |
      | TRANSLATION_MDX                | ${transalationmdx.validfilelocation}    |

    #Verify if PUB1 table row is created
    Then I expect value of column "PUB1COUNT" in the below SQL query equals to "1":
    """
    ${TESTDATA_PATH}order/sql/VERIFY_PUB1CNT.sql
    """

     #Verify if PUB1 entry is updated succesfully
    Then I expect value of column "NOROWPUB1COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS NOROWPUB1COUNT FROM FT_CFG_PUB1
    WHERE  PUB_STATUS = 'CLOSED'
    AND PUB_DESCRIPTION='No rows found by the publishing query'
    AND  PUB_CNT =0
    AND START_TMS > (SELECT START_TMS
    FROM (SELECT pub1.START_TMS, row_number() OVER (ORDER BY START_tMS DESC) rnum
          FROM FT_CFG_PUB1 pub1)
          WHERE rnum = 2)
    """

    #Revert SBEX end tms
    Given I execute below query
	"""
    UPDATE
    (SELECT SBEX.END_TMS as endtms
    FROM FT_CFG_SBEX SBEX,
    FT_CFG_SBDF SBDF
     WHERE SBEX.SBDF_OID  = SBDF.SBDF_OID
     AND SBDF.SUBSCRIPTION_NME = 'EITW_DMP_TO_TW_ORDER_PLACE_SUB')
     SET endtms = (select MAX(JOB_END_TMS) from ft_T_jblg JBLG WHERE JBLG.JOB_MSG_TYP    = 'EIS_MT_BRS_ORDERS');
     COMMIT
    """