#https://jira.pruconnect.net/browse/EISDEV-7176
#https://collaborate.pruconnect.net/display/EISTOM/Portfolio+Average+Rating
#EISDEV-7238: Adding additonal test case for null
#EISDEV_7353 : Load and publish PHKL_IP_RATING for Portfolio Average rating
#EISDEV_7445 : Changing Day3 input file rating from C to C/CC/D which will convert to the same value CC in output

@gc_interface_ratings @gc_interface_risk_analytics
@dmp_regression_integrationtest
@eisdev_7176 @eisdev_7238 @eisdev_7353 @eisdev_7445
Feature: Verify Duplicate Issue Ratings are not created.

  This feature tests the load of ratings from risk analytics file for 4 days where ratings where
  day 1 rating is received with CC
  day 2 rating is received with CCC+
  day 3 rating is received with CC
  day 4 rating is received with B
  this scenario creates duplicate active ratings for CCC+ and B

  After change in time series, only one active recod with B should be present in DB

  Scenario: Initialize variables used across the feature file

    Given I assign "tests/test-data/DevTest/EISDEV-3743" to variable "testdata.path"
    And I assign "portfolio_avgrating_allvalid.xml" to variable "INPUT_FILENAME1"
    And I assign "portfolio_avgrating_allvalid_day2.xml" to variable "INPUT_FILENAME2"
    And I assign "portfolio_avgrating_allvalid_day3.xml" to variable "INPUT_FILENAME3"
    And I assign "portfolio_avgrating_allvalid_day4.xml" to variable "INPUT_FILENAME4"

    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"

  Scenario: Read Instrument identifiers and clear the Ratings for the selected instrument
  Read ISIN, BCUSIP, SEDOL and EISLSTID from FT_T_ISID table at runtime.

    And  I execute below query and extract values of "INSTRID;BCUSIPVAL;ISINVAL;SEDOLVAL;EISLSTIDVAL" into same variables
    """
    SELECT isid.instr_id as INSTRID, isid.iss_id AS ISINVAL,
    (SELECT iss_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND isid.instr_id = instr_id AND end_tms IS NULL) as BCUSIPVAL,
    (SELECT iss_id FROM ft_t_isid WHERE id_ctxt_typ = 'SEDOL' AND isid.instr_id = instr_id AND end_tms IS NULL) as SEDOLVAL,
    (SELECT iss_id FROM ft_t_isid WHERE id_ctxt_typ = 'EISLSTID' AND isid.instr_id = instr_id AND end_tms IS NULL) as EISLSTIDVAL
    FROM ft_t_isid isid, ft_t_balh balh, ft_t_acgp acgp, ft_t_acgr acgr
    WHERE isid.instr_id = balh.instr_id
    AND isid.id_ctxt_typ = 'ISIN'
    AND balh.acct_id = acgp.acct_id
    AND acgp.prnt_acct_grp_oid = acgr.acct_grp_oid
    AND acgr.acct_grp_id  = 'SGBFI'
    AND (SELECT count(1) FROM ft_t_isid WHERE id_ctxt_typ = 'SEDOL' AND isid.instr_id = instr_id AND end_tms IS NULL) = 1
    AND (SELECT count(1) FROM ft_t_isid WHERE id_ctxt_typ = 'EISLSTID' AND isid.instr_id = instr_id AND end_tms IS NULL) = 1
    AND (SELECT count(1) FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND isid.instr_id = instr_id AND end_tms IS NULL) = 1
    AND rownum=1
    """

    And I execute below query to "Clear data for the given instruments from FT_T_ISRT"
    """
    DELETE FROM ft_t_isrt
    WHERE instr_id = '${INSTRID}'
    """

  Scenario: Load Risk Analytics files and verify data is successfully processed for Day 1

    Given I create input file "${INPUT_FILENAME1}" using template "portfolio_avgrating_allvalid_template.xml" from location "${testdata.path}/inputfiles"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME1} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME1}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Load Risk Analytics files and verify data is successfully processed for Day 2

    Given I create input file "${INPUT_FILENAME2}" using template "portfolio_avgrating_allvalid_template_day2.xml" from location "${testdata.path}/inputfiles"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME2} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME2}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Load Risk Analytics files and verify data is successfully processed for Day 3

    Given I create input file "${INPUT_FILENAME3}" using template "portfolio_avgrating_allvalid_template_day3.xml" from location "${testdata.path}/inputfiles"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME3} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME3}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with success record count as "1"

    Then I expect value of column "rtng_cde" in the below SQL query equals to "CC":
    """
    select rtng_cde FROM ft_t_isrt
    WHERE instr_id IN ('${INSTRID}')
    AND end_tms IS NULL
    AND rtng_set_oid = 'ESWARFRATS'
    """

  Scenario: Load Risk Analytics files and verify data is successfully processed for Day 4

    Given I create input file "${INPUT_FILENAME4}" using template "portfolio_avgrating_allvalid_template_day4.xml" from location "${testdata.path}/inputfiles"

    And I copy files below from local folder "${testdata.path}/inputfiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME4} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME4}        |
      | MESSAGE_TYPE  | EIS_MT_BRS_RISK_ANALYTICS |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Verify Duplicate ESWARFRATS Ratings are not created

    Then I expect value of column "ESWARFRATS_COUNT" in the below SQL query equals to "1":
    """
    select count(*) as  ESWARFRATS_COUNT from ft_t_isrt
    WHERE instr_id = '${INSTRID}'
    and RTNG_SET_OID = 'ESWARFRATS'
    and end_tms is null
    and SYS_EFF_END_TMS is null
    """

  Scenario: Verify null ratings are created

    Then I expect value of column "PRTFRATING_COUNT" in the below SQL query equals to "6":
    """
    select count(*) as  PRTFRATING_COUNT from ft_t_isrt
    WHERE instr_id = '${INSTRID}'
    and RTNG_SET_OID in
      (select rtng_set_oid from ft_t_rtng
      where rtng_set_mnem in ('ESCMPHK','CMPWRSTI','CMPSECND','CMPBSTAO','ESCMPTCR','WARFRATS','PHKLIPRT'))
    and rtng_cde='Null'
    and end_tms is null
    and SYS_EFF_END_TMS is null
    """