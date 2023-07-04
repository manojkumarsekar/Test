# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 04/03/2019      TOM-4126    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4126
#https://collaborate.intranet.asia/display/FUNDAPPS/FA-IN-SMF-LBURCR-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@gc_interface_org_chart
@dmp_regression_unittest
@tom_4126 @dmp_fundapps_functional_org_chart @tom_4419 @tom_4490 @tom_4687 @dmp_fundapps_regression
Feature: TOM-4126 ssdr legal entity list org chart

  1) Validate that missing MandatoryFields raise an exception
  2) Validate that COS_POS_ID has 1 or external value with ENTITY Org_type in input.
  3) Validate Linkage between parent_id and Co_Pos_id
  4) Validate Linkage With INHOUSE identifier
  5) Validate  that COS_POS_ID with UMBRELLA ORG_Type

  Scenario: TC_1: Clear old test data and setup variables

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/OrgChart" to variable "testdata.path"
    Given I assign "ORG_Chart_template.xls" to variable "INPUT_FILENAME"

    And I execute below query
	"""
	${testdata.path}/sql/4126_Clear_Data_finsID.sql
    """

  Scenario:Max polling time
    And I assign "200" to variable "workflow.max.polling.time"

  Scenario: TC_2: Load ORG_Chart_template.xls

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}      |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL |
      | BUSINESS_FEED |                        |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
	"""
    SELECT count(*) as JBLG_ROW_COUNT
    FROM FT_T_JBLG
    WHERE JOB_ID = '${JOB_ID}'
	AND JOB_STAT_TYP ='CLOSED'
    AND TASK_TOT_CNT = 7
    AND TASK_CMPLTD_CNT = 7
    AND TASK_SUCCESS_CNT = 7
    """

  Scenario: TC_3:verify fins is created or not for data present in file which check Company name for particular data.

    Then I expect value of column "FINS_CHECK" in the below SQL query equals to "1":
	"""
    SELECT count(inst_nme) AS FINS_CHECK
    FROM fT_T_fins
    WHERE inst_mnem in
                       (
                          SELECT inst_mnem
                          FROM  ft_T_fiid
                          WHERE  fins_id='1397169'
                          AND  FINS_ID_CTXT_TYP ='RCRLBUCOM'
                          AND  end_tms is null
                        )
    AND end_tms is null
    """

  Scenario: TC_4:Verify FinsID is created with data present in the test file(Company_number)

    Then  I expect value of column "VERIFY_NUM" in the below SQL query equals to "1":
	"""
    SELECT count(*) as VERIFY_NUM
    FROM FT_T_fiid
	WHERE inst_mnem IN
					   (
                           SELECT inst_mnem
                           FROM ft_T_fiid
                           WHERE fins_id='1'
                           AND FINS_ID_CTXT_TYP='RCRLBULEID'
                           AND END_TMS is null
                        )
	AND FINS_ID_CTXT_TYP='RCRLBUCOM'
	AND fins_id='1397169'
	AND end_tms is null
	"""

  Scenario: TC_5:Verify All Data with Proper Linkage
    #Check if Parent_id is linked with cos_pos_id created with data present in the test file(Cos_pos_id)(Negative Testing)
    #Parent_id is Not Presnt in input file i.e. no linkage found so it will return zero

    Then I expect value of column "LINKAGE_COS_ID" in the below SQL query equals to "0":
	"""
	SELECT  COUNT(*) AS LINKAGE_COS_ID
	FROM ft_t_ffrl
    WHERE rel_typ = 'PARNTCOF'
	AND end_tms is null AND inst_mnem IN
                                           (
                                              SELECT inst_mnem
                                              FROM ft_t_fiid
                                              WHERE  fins_id='1'
                                              AND fins_id_ctxt_typ = 'RCRLBULEID'
                                              AND end_tms is null
                                            )
	"""

  Scenario: TC_6:Verify Inhouse_identifier linked proper with test file

    Then I expect value of column "INHOUSE_ID_LINK" in the below SQL query equals to "1":
	"""
	SELECT count(*) as INHOUSE_ID_LINK
	FROM fT_T_fiid
	WHERE inst_mnem in
						(
							SELECT inst_mnem
							FROM ft_T_fiid
							WHERE fins_id='ES-HK'
							AND fins_id_ctxt_typ='INHOUSE'
							AND END_TMS is null
						)
	AND fins_id_ctxt_typ in ('RCRLBULEID')
	AND fins_id='40'
	AND end_tms is null
    """

  Scenario: TC_7: Verify whether Financial_institution role (FINR-Finsrl_typ)is created or not for Each fins.

    Then  I expect value of column "FINSROLE" in the below SQL query equals to "6":
	"""
	SELECT count(Finsrl_typ)as FINSROLE
	FROM ft_T_finr
	WHERE inst_mnem in
						(
							SELECT inst_mnem
							FROM ft_t_fiid
							WHERE fins_id in('1')
							AND FINS_ID_CTXT_TYP in ('RCRLBULEID')
							AND end_tms is null
						)
	AND last_chg_usr_id='EIS_RCRLBU_ORG_CHART'
	AND end_tms is null
	"""

  Scenario: TC_8: Verify whether financial_instition_statistic -REGULATOR created with data present in the test file.

    Then  I expect value of column "REGULTOR_VAL" in the below SQL query equals to "1":

	"""
	SELECT count(stat_char_val_txt)as  REGULTOR_VAL
	FROM fT_T_fist
	WHERE inst_mnem in
						(
							SELECT inst_mnem
							FROM ft_t_fiid
							WHERE  fins_id in('1')
							AND FINS_ID_CTXT_TYP in ('RCRLBULEID')
							AND end_tms is null
                        )
	AND stat_def_id='REGLTOR'
	AND last_chg_usr_id='EIS_RCRLBU_ORG_CHART'
	AND end_tms is null
	"""

  Scenario: TC_9: verify whether Mailing_address created with data And Linkage with fins

    Then   I expect value of column "ADDRESS" in the below SQL query equals to "1":
	"""
	SELECT count (*) as ADDRESS
	FROM ft_t_fins fins,
	ft_t_ccrf ccrf,
	ft_t_adtp adtp,
	ft_t_madr madr
	WHERE ccrf.fins_inst_mnem = fins.inst_mnem
	AND ccrf.cntl_cross_ref_oid = adtp.cntl_cross_ref_oid
	AND adtp.mail_addr_id = madr.mail_addr_id
	AND madr.ADDR_LN1_TXT='L P H'
	AND madr.ADDR_LN2_TXT='London'
	AND madr.CNTRY_NME='England'
	AND madr.last_chg_usr_id='EIS_RCRLBU_ORG_CHART'
	AND madr.end_tms is null
	and fins.inst_mnem in
							(
								select inst_mnem
								from ft_T_fiid
								where fins_id='1'
								and FINS_ID_CTXT_TYP ='RCRLBULEID'
								and end_tms is null
                            )
    """

  Scenario: TC_10: verify whether ORG_TYPE(UMBRELLA) created with data present in the test file or not

    Then  I expect value of column "UMBRELLA_ORG" in the below SQL query equals to "1":
    """
	SELECT count(inst_cat_typ)as UMBRELLA_ORG
	FROM fT_T_fins
	WHERE inst_mnem in
						(
							SELECT inst_mnem
							FROM ft_T_fiid
							WHERE fins_id='ESIL00001'
							and FINS_ID_CTXT_TYP ='RCRLBULEID'
							AND end_tms is null
							AND Last_chg_usr_id='EIS_RCRLBU_ORG_CHART'
                        )
    AND end_tms is null
    """

  Scenario: TC_11: verify whether ORG_TYPE(EXTERNAL) created with data present in the test file or not

    Then  I expect value of column "EXTERNAL_ORG" in the below SQL query equals to "1":
	"""
	SELECT count(inst_cat_typ)as EXTERNAL_ORG
	FROM fT_T_fins
	WHERE inst_mnem in
						(
							SELECT inst_mnem
							FROM ft_T_fiid
							WHERE fins_id='External'
							and FINS_ID_CTXT_TYP ='RCRLBULEID'
							AND end_tms is null
							AND Last_chg_usr_id='EIS_RCRLBU_ORG_CHART'
						)
	AND end_tms is null
	"""

  Scenario: TC_12: Load ORG_Chart_template_ChangeName.xls

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/OrgChart" to variable "testdata.path"
    Given I assign "ORG_Chart_template_ChangeName.xls" to variable "INPUT_FILENAME1"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME1}     |
      | MESSAGE_TYPE  | EIS_MT_ORG_CHART_EXCEL |
      | BUSINESS_FEED |                        |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
     """
     SELECT count(*) as JBLG_ROW_COUNT
     FROM FT_T_JBLG
     WHERE JOB_ID = '${JOB_ID}'
     AND JOB_STAT_TYP ='CLOSED'
     """

  Scenario: TC_13: check Company name( Institution_name )not overwritte SO Given Name AS "ABCD" To check data

    Then I expect value of column "FINS_CHECK" in the below SQL query equals to "1":
      """
      SELECT count(inst_nme) AS FINS_CHECK
      FROM fT_T_fins
      WHERE inst_mnem in
                         (
                            SELECT inst_mnem
                            FROM  ft_T_fiid
                            WHERE  fins_id='1397169'
                            AND  FINS_ID_CTXT_TYP ='RCRLBUCOM'
                            AND  end_tms is null
                          )
      And  INST_NME='PRUDENTIAL PUBLIC LIMITED COMPANY'
      AND end_tms is null
      """

  Scenario: Cleanup max polling time variable
    Then I remove variable "workflow.max.polling.time" from memory