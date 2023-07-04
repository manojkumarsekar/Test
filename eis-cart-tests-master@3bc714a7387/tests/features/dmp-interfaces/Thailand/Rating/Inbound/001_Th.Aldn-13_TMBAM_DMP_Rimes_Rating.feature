#https://jira.pruconnect.net/browse/EISDEV-7082
#Functional specification : https://collaborate.pruconnect.net/pages/viewpage.action?spaceKey=EISTT&title=SET+EQ+Sector+Classification%2CTBMA+Upload+and+Publish+FI+Prices%2CRatings%7CRIMES%3EDMP%3EBRS%7CPassthrough#businessRequirements-1989358494

#EISDEV-7352: removed suffix

@gc_interface_rating
@dmp_regression_unittest
@eisdev_7082 @001_tmbam_rating_load @dmp_thailand_rating @dmp_thailand @eisdev_7352

Feature: TMBAM Rimes Rating load for Thailand

  The purpose of this interface is to load Rimes Rating in DMP.
  It was a pass-through file from RIMES but is getting loaded to handle the change in Rating effective date
  Rimes default the Rating effective date to sysdate which creates duplicate in Aladdin.
  As part of this interface we will handle the above scenario and change the rating effective only when rating changes

  Scenario: TC1: Initialize variables and clean price table

    Given I assign "tests/test-data/dmp-interfaces/Thailand/Rating/Inbound" to variable "testdata.path"
    And I assign "001_Th.Aldn-13_TMBAM_DMP_Rimes_Rating_New.csv" to variable "RATING_INPUT_FILENAME_NEW"
    And I assign "001_Th.Aldn-13_TMBAM_DMP_Rimes_Rating_Update.csv" to variable "RATING_INPUT_FILENAME_UPDATE"

    #Delete old data
    And I execute below query to "delete existing price"
    """
      DELETE FT_T_RTG2 WHERE EXT_ISIN = 'TEST74033501' OR EXT_CLIENT_ID = 'TEST7082' OR EXT_CLIENT_ID LIKE 'TEST7352%';
    """

  Scenario:TC2: Load TMBAM Rimes rating file to create new ratings

    Given I process "${testdata.path}/${RATING_INPUT_FILENAME_NEW}" file with below parameters
      | FILE_PATTERN  | ${RATING_INPUT_FILENAME_NEW} |
      | MESSAGE_TYPE  | EITH_MT_RIMES_DMP_BRS_RATING |
      | BUSINESS_FEED |                              |

    Then I expect workflow is processed in DMP with total record count as "9"
    Then I expect workflow is processed in DMP with success record count as "9"

  Scenario: TC3: Check if Rating record is created in the FT_T_RTG2 table

    Then I expect value of column "RATING_1" in the below SQL query equals to "BBB":
    """
      select ext_value as RATING_1 from ft_t_rtg2 where ext_isin = 'TEST74033501'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_2" in the below SQL query equals to "AAA":
    """
      select ext_value as RATING_2 from ft_t_rtg2 where ext_client_id = 'TEST7082'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_3" in the below SQL query equals to "AAA":
    """
      select ext_value as RATING_3 from ft_t_rtg2 where ext_client_id = 'TEST7352p'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_4" in the below SQL query equals to "A":
    """
      select ext_value as RATING_4 from ft_t_rtg2 where ext_client_id = 'TEST7352e'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_5" in the below SQL query equals to "B":
    """
      select ext_value as RATING_5 from ft_t_rtg2 where ext_client_id = 'TEST7352sf'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_6" in the below SQL query equals to "CC":
    """
      select ext_value as RATING_6 from ft_t_rtg2 where ext_client_id = 'TEST7352*'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_7" in the below SQL query equals to "CCC+":
    """
      select ext_value as RATING_7 from ft_t_rtg2 where ext_client_id = 'TEST7352*+'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_8" in the below SQL query equals to "C+":
    """
      select ext_value as RATING_8 from ft_t_rtg2 where ext_client_id = 'TEST7352*-'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_9" in the below SQL query equals to "AA+":
    """
      select ext_value as RATING_9 from ft_t_rtg2 where ext_client_id = 'TEST7352(sf)'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_10" in the below SQL query equals to "AA+(sf)":
    """
      select ext_rtng_symbol_txt as RATING_10 from ft_t_rtg2 where ext_client_id = 'TEST7352(sf)'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

  Scenario:TC3: Load TMBAM Rimes rating file to update ratings

    Given I process "${testdata.path}/${RATING_INPUT_FILENAME_UPDATE}" file with below parameters
      | FILE_PATTERN  | ${RATING_INPUT_FILENAME_UPDATE} |
      | MESSAGE_TYPE  | EITH_MT_RIMES_DMP_BRS_RATING    |
      | BUSINESS_FEED |                                 |

    Then I expect workflow is processed in DMP with total record count as "2"

  Scenario: TC3: Check if Rating record is updated in the FT_T_RTG2 table

    Then I expect value of column "RATING_1" in the below SQL query equals to "BBB":
    """
      select ext_value as RATING_1 from ft_t_rtg2 where ext_isin = 'TEST74033501'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is null
    """

    Then I expect value of column "RATING_2_ENDDATED" in the below SQL query equals to "AAA":
    """
      select ext_value as RATING_2_ENDDATED from ft_t_rtg2 where ext_client_id = 'TEST7082'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201020' and end_tms is not null
    """

    Then I expect value of column "RATING_2" in the below SQL query equals to "CCC":
    """
      select ext_value as RATING_2 from ft_t_rtg2 where ext_client_id = 'TEST7082'
      and ext_agy = '10402' and to_char(ext_rtg_date,'YYYYMMDD') = '20201022' and end_tms is null
    """

  Scenario: TC4: Verification for migration of existing data

    Then I expect value of column "RESULT" in the below SQL query equals to "PASS":
    """
      select case when count(1)=0 then 'PASS' else 'FAIL' end as RESULT from ft_t_rtg2
      where ext_value like '%(sf)' or ext_value like '%sf' or ext_value like '%*' or ext_value like '%*+'
      or ext_value like '%*-' or ext_value like '%p' or ext_value like '%e'
    """