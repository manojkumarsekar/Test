# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 31/Oct/2019     TOM-5228    Sourcing Unlisted Warrant Price
# 10/02/2020      EISDEV-5570 feature file fix - overlying issue group added with new securities in Prod. Feature file changed to verify test data only.
# 22/09/2020      EISDEV-6801 verify exception is not thrown if the overlying security does not have an underlying security set up in RIDF
# 11/12/2020      EISDEV-7250 feature file was picking up a security which was already part of overlying security.
#                             delete scenario have a where condition to delete with data_src_id = 'EISDEV5570:Warrant Pricing'.
#                             update select query to pick up security which is not part of unlisted warrant overlying SOI
# ===================================================================================================================================================================================
#FS: https://collaborate.intranet.asia/display/TOM/Unlisted+Warrant+Pricing?src=jira

@gc_interface_refresh_soi @gc_interface_prices
@dmp_regression_unittest
@eisdev_5228 @eisdev_5228_soirefresh @eisdev_5570 @derive_unlisted_warrant_price @eisdev_6801 @eisdev_7105 @eisdev_7250
Feature: Test Underlying Dynamic SOI Refresh for Warrant Security

  This feature file tests that the ISGP of underlying listed security group is refreshed as per the overlying warrant security group participants.
  Warrant security is added in overlying Issue group(maintained by IDM team). Th underlying issue group is expected to refresh after running SOI
  refresh query with underlying securities of the overlying security added in other group.
  - Insert in overlying security group(UNLWARSOI) expected to insert overlying security in underlying issue group(UNLUSECSOI)
  - Delete in overlying security group(UNLWARSOI) expected to delete overlying security in underlying issue group(UNLUSECSOI)


  Scenario: Read WARRANT security at runtime based on desired criteria instead of hard coding in feature
  example: id_ctxt_typ = 'BCUSIP' and entlmnt_typ = 'WARRANT'

    Given I execute below query and extract values of "BCUSIPVAL" into same variables
    """
    SELECT distinct isid.iss_id as BCUSIPVAL FROM FT_T_ISID isid, FT_T_ENCH ench, FT_T_RISS riss, FT_T_RIDF ridf, ft_t_isgp isgp
    WHERE isid.instr_id = ridf.instr_id
    AND isid.id_ctxt_typ = 'BCUSIP'
    AND ridf.rld_iss_feat_id = riss.rld_iss_feat_id
    AND isid.instr_id = ench.instr_id
    AND ench.entlmnt_typ = 'WARRANT'
    AND isid.end_tms is null
    AND ench.end_tms is null
    AND riss.end_tms is null
    AND ridf.end_tms is null
    and isid.instr_id = isgp.instr_id
    and isgp.PRNT_ISS_GRP_OID != '=00008E254'
    and isgp.end_tms is null
    and rownum=1
    """

  Scenario: Insert security participant in Overlying Issue group and clear data in Underlying issue group

    Given I execute below query to "Insert security participant ${BCUSIPVAL} to issue group UNLWARSOI"
    """
    INSERT INTO ft_t_isgp
    (
      SELECT
        (
          SELECT iss_grp_oid FROM ft_t_isgr
          WHERE iss_grp_id = 'UNLWARSOI'
          AND end_tms IS NULL
         ),
        SYSDATE, NULL, instr_id, SYSDATE, 'AUTOTEST', 'MEMBER', NULL, NULL, NULL,NULL, 'ACTIVE', 'EISDEV5570:Warrant Pricing', NULL, NULL, NULL, NULL, new_oid, NULL
        FROM ft_t_isid
        WHERE id_ctxt_typ = 'BCUSIP'
        AND iss_id = '${BCUSIPVAL}'
        AND end_tms IS NULL
    )
    """

    And I execute below query to "Delete group participants of issue group UNLUSECSOI"
    """
    DELETE FROM ft_t_isgp WHERE prnt_iss_grp_oid IN (SELECT iss_grp_oid from ft_t_isgr where iss_grp_id  = 'UNLUSECSOI' AND end_tms IS NULL)
    AND instr_id = (SELECT instr_id FROM ft_t_riss WHERE rld_iss_feat_id = (SELECT rld_iss_feat_id FROM ft_t_ridf
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIPVAL}' AND end_tms IS NULL and REL_TYP = 'UNDRLYNG') AND end_tms IS NULL) AND end_tms IS NULL)
    """

  Scenario: Verify Refresh SOI workflow should refresh underlying issue group if there is an Insert in overlying security group

    Given I expect value of column "ISGP_CNT_INS_BEFORE_REFRSH" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) AS ISGP_CNT_INS_BEFORE_REFRSH FROM ft_t_isgp
    WHERE prnt_iss_grp_oid IN (SELECT iss_grp_oid FROM ft_t_isgr WHERE iss_grp_id  = 'UNLUSECSOI' AND end_tms IS NULL) AND end_tms IS NULL
    AND instr_id = (SELECT instr_id FROM ft_t_riss WHERE rld_iss_feat_id = (SELECT rld_iss_feat_id FROM ft_t_ridf
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIPVAL}' AND end_tms IS NULL) AND end_tms IS NULL and REL_TYP = 'UNDRLYNG') AND end_tms IS NULL)
    """

   #This will refresh SOI for UNLUSECSOI
    When I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | UNLUSECSOI                             |
      | NO_OF_BRANCH | 5                                      |
      | QUERY_NAME   | EIS_REFRESH_UNLISTED_WARRANT_PRICE_SOI |

    Then I expect value of column "ISGP_CNT_INS_AFTER_REFRSH" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) as ISGP_CNT_INS_AFTER_REFRSH FROM ft_t_isgp WHERE prnt_iss_grp_oid IN (SELECT iss_grp_oid FROM ft_t_isgr WHERE iss_grp_id  = 'UNLUSECSOI' AND end_tms IS NULL) AND end_tms IS NULL
    AND instr_id = (SELECT instr_id FROM ft_t_riss WHERE rld_iss_feat_id = (SELECT rld_iss_feat_id FROM ft_t_ridf
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIPVAL}' AND end_tms IS NULL) AND end_tms IS NULL and REL_TYP = 'UNDRLYNG') AND end_tms IS NULL)
    """

  Scenario: Delete security participant on Overlying Issue group

    Given I execute below query to "Delete security participant from issue group UNLWARSOI"
   """
   DELETE FROM ft_t_isgp WHERE prnt_iss_grp_oid IN (SELECT iss_grp_oid FROM ft_t_isgr WHERE iss_grp_id  = 'UNLWARSOI' AND end_tms IS NULL)
   AND instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id  ='${BCUSIPVAL}' AND end_tms IS NULL) AND data_src_id = 'EISDEV5570:Warrant Pricing'
   """

  Scenario: Verify Refresh SOI should refresh underlying issue group if there is an Delete in overlying security group

    Given I expect value of column "ISGP_CNT_DEL_BEFORE_REFRSH" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) as ISGP_CNT_DEL_BEFORE_REFRSH FROM ft_t_isgp WHERE prnt_iss_grp_oid IN (SELECT iss_grp_oid FROM ft_t_isgr WHERE iss_grp_id  = 'UNLUSECSOI' AND end_tms IS NULL) AND end_tms IS NULL
    AND instr_id = (SELECT instr_id FROM ft_t_riss WHERE rld_iss_feat_id = (SELECT rld_iss_feat_id FROM ft_t_ridf
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIPVAL}' AND end_tms IS NULL) AND end_tms IS NULL and REL_TYP = 'UNDRLYNG') AND end_tms IS NULL)
    """

     #This will refresh SOI for UNLUSECSOI
    When I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | UNLUSECSOI                             |
      | NO_OF_BRANCH | 5                                      |
      | QUERY_NAME   | EIS_REFRESH_UNLISTED_WARRANT_PRICE_SOI |


    Then I expect value of column "ISGP_CNT_DEL_AFTER_REFRSH" in the below SQL query equals to "0":
    """
    SELECT COUNT(*) as ISGP_CNT_DEL_AFTER_REFRSH FROM ft_t_isgp WHERE prnt_iss_grp_oid IN (SELECT iss_grp_oid FROM ft_t_isgr WHERE iss_grp_id  = 'UNLUSECSOI' AND end_tms IS NULL) AND end_tms IS NULL
    AND instr_id = (SELECT instr_id FROM ft_t_riss WHERE rld_iss_feat_id = (SELECT rld_iss_feat_id FROM ft_t_ridf
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = '${BCUSIPVAL}' AND end_tms IS NULL) AND end_tms IS NULL and REL_TYP = 'UNDRLYNG') AND end_tms IS NULL)
    """

  Scenario: Read security at runtime which does not have an underlying security set up

    Given I execute below query and extract values of "NO_UNDERLYING_SEC" into same variables
    """
    select iss_id as NO_UNDERLYING_SEC FROM ft_t_isid where instr_id not in (select instr_id from ft_t_ridf where end_tms is null) and id_ctxt_typ = 'ISIN' and rownum = 1 and end_tms is null
    """

  Scenario: Add security participant on Overlying Issue group

    Given I execute below query to "Delete security participant from issue group UNLWARSOI"
   """
   INSERT INTO ft_t_isgp
    (SELECT (SELECT iss_grp_oid
         FROM   ft_t_isgr
         WHERE  iss_grp_id = 'UNLWARSOI'
                AND end_tms IS NULL),
        SYSDATE,
        NULL,
        instr_id,
        SYSDATE,
        'EIS:CSTM',
        'MEMBER',
        NULL,
        NULL,
        NULL,
        NULL,
        'ACTIVE',
        'Unlisted Warrant Pricing',
        NULL,
        NULL,
        NULL,
        NULL,
        new_oid,
        NULL
    FROM  ft_t_isid where iss_id = '${NO_UNDERLYING_SEC}' and end_tms is null)
   """

  Scenario: Execute SOI Refresh

    Given I process RefreshSOI workflow with below parameters and wait for the job to be completed
      | GROUP_NAME   | UNLUSECSOI                             |
      | NO_OF_BRANCH | 5                                      |
      | QUERY_NAME   | EIS_REFRESH_UNLISTED_WARRANT_PRICE_SOI |

    Then I expect workflow is processed in DMP with total record count as "0"

  Scenario: Verify Refresh SOI should not throw an exception

    Then I expect 0 exceptions are captured with the following criteria
      | NOTFCN_STAT_TYP | OPEN |