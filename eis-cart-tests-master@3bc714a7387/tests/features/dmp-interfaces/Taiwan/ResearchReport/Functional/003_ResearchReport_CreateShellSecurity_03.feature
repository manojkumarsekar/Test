#https://jira.intranet.asia/browse/TOM-4236

@tom_4236 @researchreport_createshellsecurity_03 @dmp_twrr_functional @dmp_tw_functional
Feature: Test creation of shell security from research report (BRS -> report email -> order file)

  Research report are created before placing orders in aladdin and the order placed should map with the research report based on trn type, category and security.
  We are also creating a shell security as part of this to resolve the issue of instrument not being loaded in DMP by BRS and research report is loaded.
  This feature will test the creation of security by research report interface. Also tests different combination of file processing for security.

  This feature is about Load BRS security file followed by research report email info converted to xml file through interface followed by order file

  Scenario: TC1: Assignment of variables and Clearing the security and order

    Given I assign "tests/test-data/dmp-interfaces/Taiwan/ResearchReport" to variable "testdata.path"
    And I assign "researchreport_inputfile.xml" to variable "RESEARCH_REPORT_FILE"
    And I assign "orders_inputfile.xml" to variable "ORDER_INPUT_FILENAME"
    And I assign "brssecurity_inputfile.xml" to variable "BRS_SECURITY_INPUT_FILENAME"

    Then I extract value from the xml file "${testdata.path}/infiles/${BRS_SECURITY_INPUT_FILENAME}" with tagName "CUSIP" to variable "BCUSIP"

    Then I set end_tms to SYSDATE in database "dmp.db.VD" where iss_id in "'${BCUSIP}'"
    Then I set end_tms to SYSDATE in database "dmp.db.GC" where iss_id in "'${BCUSIP}'"

    Given I execute below query
	"""
    UPDATE FT_T_AUOR SET PREF_ORDER_ID = NEW_OID,
    LAST_CHG_USR_ID = LAST_CHG_USR_ID|| 'AUTOMATION',
    LAST_CHG_TMS = SYSDATE WHERE PREF_ORDER_ID IN ('A1230046') AND PREF_ORDER_ID_CTXT_TYP = 'BRS_ORDER';
    COMMIT
    """

  Scenario: TC2: Loading BRS security file in DMP

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${BRS_SECURITY_INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${BRS_SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW        |
      | BUSINESS_FEED |                                |

  Scenario: TC3: Verification of Security loaded from BRS file in FT_T_ISID table

    Then I expect value of column "ISID_ROW_COUNT" in the below SQL query equals to "6":
      """
      SELECT count(*) as ISID_ROW_COUNT FROM FT_T_ISID WHERE
      INSTR_ID in
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND END_TMS IS NULL
      """


  Scenario: TC4: Verification of Security mapping loaded from BRS file in FT_T_ISID table for valid market

    Then I expect value of column "ISID_ROW_COUNT_MKTOID" in the below SQL query equals to "4":
     """
      SELECT count(*) as ISID_ROW_COUNT_MKTOID FROM FT_T_ISID WHERE
      INSTR_ID =
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND MKT_OID IN
      (
        select MKT_OID from ft_T_mkid where mkt_id = 'TAI' and mkt_id_ctxt_typ = 'ALADDIN'
      )
      AND END_TMS IS NULL
     """

  Scenario: TC5: Verification of Security mapping loaded from BRS file in FT_T_MKIS table for valid market

    Then I expect value of column "BRS_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKIS_COUNT FROM FT_T_MKIS
      WHERE INSTR_ID =
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND MKT_OID IN
      (
        select MKT_OID from ft_T_mkid where mkt_id = 'TAI' and mkt_id_ctxt_typ = 'ALADDIN'
      )
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND TRDNG_STAT_TYP='ACTIVE'
      """

  Scenario: TC6: Loading Research report email in DMP

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${RESEARCH_REPORT_FILE} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${RESEARCH_REPORT_FILE} |
      | MESSAGE_TYPE  | EITW_MT_RESEARCH_REPORT |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
      """
      SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
      """

  Scenario: TC7: Verification of Security loaded from BRS file in FT_T_ISID table

    Then I expect value of column "ISID_ROW_COUNT" in the below SQL query equals to "6":
      """
      SELECT count(*) as ISID_ROW_COUNT FROM FT_T_ISID WHERE
      INSTR_ID in
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND END_TMS IS NULL
      """


  Scenario: TC8: Verification of Security mapping loaded from BRS file in FT_T_ISID table for valid market

    Then I expect value of column "ISID_ROW_COUNT_MKTOID" in the below SQL query equals to "4":
     """
      SELECT count(*) as ISID_ROW_COUNT_MKTOID FROM FT_T_ISID WHERE
      INSTR_ID =
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND MKT_OID IN
      (
        select MKT_OID from ft_T_mkid where mkt_id = 'TAI' and mkt_id_ctxt_typ = 'ALADDIN'
      )
      AND END_TMS IS NULL
     """

  Scenario: TC9: Verification of Security mapping loaded from BRS file in FT_T_MKIS table for valid market

    Then I expect value of column "BRS_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKIS_COUNT FROM FT_T_MKIS
      WHERE INSTR_ID =
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND MKT_OID IN
      (
        select MKT_OID from ft_T_mkid where mkt_id = 'TAI' and mkt_id_ctxt_typ = 'ALADDIN'
      )
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND TRDNG_STAT_TYP='ACTIVE'
      """

  Scenario: TC10 : Verification of security loaded from Reasearch report in FT_T_RSR1 table

    Then I expect value of column "RSR1_COUNT" in the below SQL query equals to "1":
    """
     SELECT COUNT(*) AS RSR1_COUNT FROM FT_T_RSR1 WHERE INSTR_ID IN(SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL)
    """

  Scenario: TC11: Loading order file in DMP

    Given I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${ORDER_INPUT_FILENAME} |

    Given I set the workflow template parameter "MESSAGE_TYPE" to "EIS_MT_BRS_ORDERS"
    And I set the workflow template parameter "INPUT_DIR" to "${dmp.ssh.inbound.path}"

 #Mail verification to be done manually
    And I set the workflow template parameter "EMAIL_TO" to "mahesh.gummaraju@eastspring.com"
    And I set the workflow template parameter "EMAIL_SUBJECT" to "TEST SPLIT ORDERS"
    And I set the workflow template parameter "PUBLISH_LOAD_SUMMARY" to "true"
    And I set the workflow template parameter "SUCCESS_ACTION" to "DELETE"
    And I set the workflow template parameter "FILE_PATTERN" to "${ORDER_INPUT_FILENAME}"
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

  Scenario: TC12: Verification of Security loaded from BRS file in FT_T_ISID table

    Then I expect value of column "ISID_ROW_COUNT" in the below SQL query equals to "6":
      """
      SELECT count(*) as ISID_ROW_COUNT FROM FT_T_ISID WHERE
      INSTR_ID in
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND END_TMS IS NULL
      """


  Scenario: TC13: Verification of Security mapping loaded from BRS file in FT_T_ISID table for valid market

    Then I expect value of column "ISID_ROW_COUNT_MKTOID" in the below SQL query equals to "4":
     """
      SELECT count(*) as ISID_ROW_COUNT_MKTOID FROM FT_T_ISID WHERE
      INSTR_ID =
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND MKT_OID IN
      (
        select MKT_OID from ft_T_mkid where mkt_id = 'TAI' and mkt_id_ctxt_typ = 'ALADDIN'
      )
      AND END_TMS IS NULL
     """

  Scenario: TC14: Verification of Security mapping loaded from BRS file in FT_T_MKIS table for valid market

    Then I expect value of column "BRS_MKIS_COUNT" in the below SQL query equals to "1":
      """
      SELECT COUNT(*) AS BRS_MKIS_COUNT FROM FT_T_MKIS
      WHERE INSTR_ID =
      (
        SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = '${BCUSIP}' AND END_TMS IS NULL
      )
      AND MKT_OID IN
      (
        select MKT_OID from ft_T_mkid where mkt_id = 'TAI' and mkt_id_ctxt_typ = 'ALADDIN'
      )
      AND TRUNC(LAST_CHG_TMS) = TRUNC(SYSDATE)
      AND TRDNG_STAT_TYP='ACTIVE'
      """