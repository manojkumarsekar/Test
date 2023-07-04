#Feature History
#TOM-4091 : Initial Feature File

@gc_interface_securities
@dmp_regression_unittest
@tom_3805
Feature: BRS-DMP | F10 | TOM-3805 | Verify SETTLE_METHOD Update in MKIS table

  Scenario: Validate New Domain Set up in DMP for SETTLE_METHOD received as part of F10 in MKIS.SETTLEMETHTYP in GC

    Given I expect value of column "DOMAIN_FLD_ID" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS DOMAIN_FLD_ID FROM FT_T_IDMV WHERE FLD_ID = '00161254'
    """

    Given I expect value of column "IDMV_SCBJK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS IDMV_SCBJK FROM FT_T_IDMV
    WHERE FLD_DATA_CL_ID ='DSRCID'
    AND INTRNL_DMN_VAL_NME ='SCBJK' AND INTRNL_DMN_VAL_TXT = 'SCBJK'
    """

    Given I expect value of column "IDMV_MARGIN" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS IDMV_MARGIN FROM FT_T_IDMV
    WHERE FLD_ID ='00068074' AND INTRNL_DMN_VAL_NME ='MARGIN'
    AND INTRNL_DMN_VAL_TXT = 'MARGIN'
    """

    Given I expect value of column "IDMV_UPFRONT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS IDMV_UPFRONT FROM FT_T_IDMV
    WHERE FLD_ID ='00068074' AND INTRNL_DMN_VAL_NME ='UPFRONT'
    AND INTRNL_DMN_VAL_TXT = 'UPFRONT'
    """

    Given I expect value of column "EDMV_MARGIN" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EDMV_MARGIN FROM FT_T_EDMV
    WHERE DATA_SRC_ID = 'BRS' AND EXT_DMN_VAL_TXT = 'M'
    AND INTRNL_DMN_VAL_ID = (SELECT INTRNL_DMN_VAL_ID FROM FT_T_IDMV WHERE FLD_ID = '00068074' AND INTRNL_DMN_VAL_TXT = 'MARGIN')
    """

    Given I expect value of column "EDMV_UPFRONT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EDMV_UPFRONT FROM FT_T_EDMV
    WHERE DATA_SRC_ID = 'BRS' AND EXT_DMN_VAL_TXT = 'U'
    AND INTRNL_DMN_VAL_ID = (SELECT INTRNL_DMN_VAL_ID FROM FT_T_IDMV WHERE FLD_ID = '00068074' AND INTRNL_DMN_VAL_TXT = 'UPFRONT')
    """

  Scenario: Validate New Domain Set up in DMP for SETTLE_METHOD received as part of F10 in MKIS.SETTLEMETHTYP in VDDB

    Given I set the database connection to configuration "dmp.db.VD"

    Given I expect value of column "DOMAIN_FLD_ID" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS DOMAIN_FLD_ID FROM FT_T_IDMV WHERE FLD_ID = '00161254'
    """

    Given I expect value of column "IDMV_SCBJK" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS IDMV_SCBJK FROM FT_T_IDMV
    WHERE FLD_DATA_CL_ID ='DSRCID'
    AND INTRNL_DMN_VAL_NME ='SCBJK' AND INTRNL_DMN_VAL_TXT = 'SCBJK'
    """

    Given I expect value of column "IDMV_MARGIN" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS IDMV_MARGIN FROM FT_T_IDMV
    WHERE FLD_ID ='00068074' AND INTRNL_DMN_VAL_NME ='MARGIN'
    AND INTRNL_DMN_VAL_TXT = 'MARGIN'
    """

    Given I expect value of column "IDMV_UPFRONT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS IDMV_UPFRONT FROM FT_T_IDMV
    WHERE FLD_ID ='00068074' AND INTRNL_DMN_VAL_NME ='UPFRONT'
    AND INTRNL_DMN_VAL_TXT = 'UPFRONT'
    """

    Given I expect value of column "EDMV_MARGIN" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EDMV_MARGIN FROM FT_T_EDMV
    WHERE DATA_SRC_ID = 'BRS' AND EXT_DMN_VAL_TXT = 'M'
    AND INTRNL_DMN_VAL_ID = (SELECT INTRNL_DMN_VAL_ID FROM FT_T_IDMV WHERE FLD_ID = '00068074' AND INTRNL_DMN_VAL_TXT = 'MARGIN')
    """

    Given I expect value of column "EDMV_UPFRONT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS EDMV_UPFRONT FROM FT_T_EDMV
    WHERE DATA_SRC_ID = 'BRS' AND EXT_DMN_VAL_TXT = 'U'
    AND INTRNL_DMN_VAL_ID = (SELECT INTRNL_DMN_VAL_ID FROM FT_T_IDMV WHERE FLD_ID = '00068074' AND INTRNL_DMN_VAL_TXT = 'UPFRONT')
    """

  Scenario: Validate data set up for SETTLE_METHOD  = M received as part of F10 in MKIS.SETTLEMETHTYP

  # Re-start Engine

    When I send a web service request using template file "tests/test-data/intf-specs/gswf/template/EIS_RestartAllEngines_ClearPubCache/request.xmlt" and save the response to file "testout/evidence/gswf/resp/asyncResponse.xml"
    Then I extract a value from the XML file "testout/evidence/gswf/resp/asyncResponse.xml" using XPath query in file "tests/test-data/intf-specs/gswf/template/EIS_RestartAllEngines_ClearPubCache/flowResultIdQuery.xpath" to variable "flowResultId"

    Then I poll for maximum 60 seconds and expect the result of the SQL query below equals to "DONE":
        """
        SELECT WF_RUNTIME_STAT_TYP FROM FT_WF_WFRI WHERE INSTANCE_ID='${flowResultId}'
        """

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE INSTANCE_ID='${flowResultId}'
      """

  #Assign Variables
    And I assign "tests/test-data/DevTest/TOM-3805" to variable "TESTDATA_PATH"
    And I assign "sm_3805_load1.xml" to variable "INPUT_FILENAME_1"
    And I assign "sm_3805_load2.xml" to variable "INPUT_FILENAME_2"

  #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_1} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_1}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID1}'
      """

    Then I expect value of column "MKIS_MARGIN_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS MKIS_MARGIN_COUNT FROM FT_T_MKIS WHERE
    INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'SXOZ82011')
    AND MKT_OID IN (SELECT MKT_OID FROM FT_T_MKID WHERE MKT_ID = 'XEUR' AND MKT_ID_CTXT_TYP = 'MIC')
    AND SETTLE_METH_TYP = 'MARGIN'
    """

  Scenario: Validate data set up for SETTLE_METHOD  = U received as part of F10 in MKIS.SETTLEMETHTYP

    #Load Data
    Given I copy files below from local folder "${TESTDATA_PATH}" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME_2} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_2}     |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW |

    Then I extract new job id from jblg table into a variable "JOB_ID1"

    Then I poll for maximum 20 seconds and expect the result of the SQL query below equals to "CLOSED":
      """
      SELECT JOB_STAT_TYP FROM FT_T_JBLG WHERE JOB_ID='${JOB_ID1}'
      """

    Then I expect value of column "MKIS_MARGIN_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS MKIS_MARGIN_COUNT FROM FT_T_MKIS WHERE
    INSTR_ID IN (SELECT INSTR_ID FROM FT_T_ISID WHERE ISS_ID = 'SXOH92010')
    AND MKT_OID IN (SELECT MKT_OID FROM FT_T_MKID WHERE MKT_ID = 'XEUR' AND MKT_ID_CTXT_TYP = 'MIC')
    AND SETTLE_METH_TYP = 'UPFRONT'
    """