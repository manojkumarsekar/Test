#https://jira.pruconnect.net/browse/EISDEV-7352

@gc_interface_rating
@dmp_regression_unittest
@eisdev_7352 @001_rtg_tris_rating_load

Feature: Bloomberg TRIS Rating Watch Type | Store clean rating

  Bloomberg sends watch type as part of the rating. This is causing failure in Aladdin.
  This feature tests if clean rating gets stored in DMP and watch type gets in RTOP table

  Scenario: TC1: Initialize variables and clean rating table

    Given I assign "tests/test-data/dmp-interfaces/Rating/Inbound" to variable "testdata.path"
    And I assign "001_Bloomberg_RTG_TRIS_Rating.out" to variable "RATING_INPUT_FILENAME"

    And I execute below query to "delete rtop"
    """
      delete from ft_t_rtop where instr_id in
      (select instr_id from ft_t_isid where iss_id in ('TH0355039601','TH0834035907','TH0834036509','TH035503T608') and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """
    And I execute below query to "delete isrt"
    """
      delete from ft_t_isrt where instr_id in
      (select instr_id from ft_t_isid where iss_id in ('TH0355039601','TH0834035907','TH0834036509','TH035503T608') and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

  Scenario:TC2: Load Bloomberg rating file to create new ratings

    Given I process "${testdata.path}/${RATING_INPUT_FILENAME}" file with below parameters
      | FILE_PATTERN  | ${RATING_INPUT_FILENAME}         |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |
      | BUSINESS_FEED |                                  |

    Then I expect workflow is processed in DMP with total record count as "4"

  Scenario: TC3: Rating Verification in ISRT

    Then I expect value of column "ISRT_1" in the below SQL query equals to "AAA":
    """
      select rtng_cde as ISRT_1 from ft_t_isrt where instr_id in
      (select instr_id from ft_t_isid where iss_id = 'TH0355039601' and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

    Then I expect value of column "ISRT_2" in the below SQL query equals to "AA-":
    """
      select rtng_cde as ISRT_2 from ft_t_isrt where instr_id in
      (select instr_id from ft_t_isid where iss_id = 'TH0834035907' and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

    Then I expect value of column "ISRT_3" in the below SQL query equals to "AA+":
    """
      select rtng_cde as ISRT_3 from ft_t_isrt where instr_id in
      (select instr_id from ft_t_isid where iss_id = 'TH0834036509' and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

    Then I expect value of column "ISRT_4" in the below SQL query equals to "AA+":
    """
      select rtng_cde as ISRT_4 from ft_t_isrt where instr_id in
      (select instr_id from ft_t_isid where iss_id = 'TH035503T608' and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

  Scenario: TC4: Rating Opinion Verification in RTOP

    Then I expect value of column "RTOP_1" in the below SQL query equals to "WATCH":
    """
      select rtng_opinion_stat_typ as RTOP_1 from ft_t_rtop where instr_id in
      (select instr_id from ft_t_isid where iss_id = 'TH0834035907' and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

    Then I expect value of column "RTOP_2" in the below SQL query equals to "UPG":
    """
      select rtng_opinion_stat_typ as RTOP_2 from ft_t_rtop where instr_id in
      (select instr_id from ft_t_isid where iss_id = 'TH0834036509' and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

    Then I expect value of column "RTOP_3" in the below SQL query equals to "DNG":
    """
      select rtng_opinion_stat_typ as RTOP_3 from ft_t_rtop where instr_id in
      (select instr_id from ft_t_isid where iss_id = 'TH035503T608' and end_tms is null)
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """

  Scenario: TC5: Verification for migration of existing data

    Then I expect value of column "RESULT" in the below SQL query equals to "PASS":
    """
      select case when count(1)=0 then 'PASS' else 'FAIL' end as RESULT from ft_t_isrt
      where (rtng_cde like '%*' or rtng_cde like '%*+' or rtng_cde like '%*-')
      and rtng_set_oid in (select rtng_set_oid from ft_t_rtng where
      rtng_set_mnem = 'TRISLTRT' and end_tms is null)
    """
