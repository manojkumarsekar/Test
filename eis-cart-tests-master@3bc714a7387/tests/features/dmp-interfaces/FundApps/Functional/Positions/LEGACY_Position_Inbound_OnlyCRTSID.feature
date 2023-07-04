# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 14/03/2019      TOM-4320    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4320
#https://collaborate.intranet.asia/display/FUNDAPPS/SSDR-RCRLBU-POSITION-file


@dmp_rcrlbu_legacy_positions @dmp_fundapps_functional @fund_apps_positions @tom_4451 @tom_4490
Feature: TOM-4320: Positions RCRLBU LEGACY file load (Golden Source) with only CRTSID

  1) Positions creation on security and fund combination in DMP through any feed file load from RCRLBU.
  2) As the security and fund data is not set up in the database yet, we are temporarily setting up the required identifiers through inserts. These will be replaced by file load steps once security and fund are completed.

  #Prerequisites
  Scenario: TC_1: Clear data for RCRLBU Position for Data Source LEGACY for Position with only CRSTID

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/Positions" to variable "testdata.path"
    And I assign "LEGAEISLPOSITN_20190402_OnlyCRTSID.csv" to variable "INPUT_FILENAME"

    When I extract below values for row 2 from PSV file "${INPUT_FILENAME}" in local folder "${testdata.path}/inputfiles/LEGACY" with reference to "Position Date" column and assign to variables:
      | Position Date | DATE_P   |
      | Security Id   | ISS_ID   |
      | Fund Id       | ACT_ID   |
      | Quantity      | QUANTITY |

    #Setting ID_CTXT according to Data Source

    And I assign "CRTSID" to variable "ACCT_ID_CTXT"
    And I assign "EISLSTID" to variable "ISSU_ID_CTXT"
    And I assign "EISEOD" to variable "RQSTR_ID"

    And I execute below query
    """
    ${testdata.path}/sql/ClearBALH.sql
    """

  Scenario: TC_2: File load for RCRLBU Position for Data Source LEGACY

    When I copy files below from local folder "${testdata.path}/inputfiles/LEGACY" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}          |
      | MESSAGE_TYPE  | EIS_MT_LEGACY_DMP_POSITION |
      | BUSINESS_FEED |                            |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG
	WHERE JOB_ID = '${JOB_ID}'
	AND JOB_STAT_TYP ='CLOSED'
	AND TASK_TOT_CNT = 1
	AND TASK_CMPLTD_CNT = 1
	AND TASK_SUCCESS_CNT = 1
	"""

  Scenario: TC_3: Verification of BALH table for the positions loaded with required data from file

    Then I expect value of column "BALH_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) as BALH_COUNT
	FROM   FT_T_BALH BALH, FT_T_ISID ISID, FT_T_ACID ACID
	WHERE  BALH.INSTR_ID = ISID.INSTR_ID
	AND    ISID.ID_CTXT_TYP IN ('${ISSU_ID_CTXT}')
	AND    ISID.ISS_ID IN ('${ISS_ID}')
	AND    ISID.END_TMS IS NULL
	AND    ISID.ISS_ID IS NOT NULL
	AND    BALH.RQSTR_ID = '${RQSTR_ID}'
	AND    BALH.ACCT_ID = ACID.ACCT_ID
	AND    ACID.ACCT_ID_CTXT_TYP IN ('${ACCT_ID_CTXT}')
	AND    ACID.END_TMS IS NULL
	AND    ACID.ACCT_ALT_ID IN ('${ACT_ID}')
	AND    QTY_CQTY='${QUANTITY}'
	AND    BALH.ADJST_TMS = TO_DATE('${DATE_P}','DD/MM/YYYY')
	AND    BALH.AS_OF_TMS = TO_DATE('${DATE_P}','DD/MM/YYYY')
	"""

