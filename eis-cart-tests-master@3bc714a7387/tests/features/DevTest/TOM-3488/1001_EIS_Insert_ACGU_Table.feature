# ===================================================================================================================
# Date            JIRA        Comments                  Jira
# ============    ========    ========                  ========
# 27/11/2018      TOM-3488    First Version             https://jira.intranet.asia/browse/TOM-3488
# 27/11/2018      TOM-3953    Second Version            https://jira.intranet.asia/browse/TOM-3953
# 20/08/2020      Mahesh      Added @ignore - just inserting data into table is not sure is valid interface testing
# ====================================================================================================================


@ignore
@dmp_regression_unittest
@tom_3488 @dmp_data_insert
Feature: Insert Fund records in ACGU table

  As there is no GUI to tag the new fund in DMP for extracting data for SSH, we need to tag the below funds in the table (ft_t_acgu).
  IMDA SG BONDS
  ALGUMF
  UBZF
  AHPSHC
  AHPSHD

  Scenario: TC_1: Insert the FT_T_ACID data as a Prerequisite

    Given I assign "tests/test-data/DevTest/TOM-3488" to variable "testdata.path"

   # Insert data into FT_T_ACID tables, records are inserted only when the portfolio is not available
   # This is needed as the account and identifier details should be added before inserting into FT_T_ACGU table.
   # Please note that this data is not avaliable only in DEV, SIT and UAT but available in PROD

    Given I execute below query
      """
      ${testdata.path}/sql/Insert_ACID_Data_TC1.sql
      """

    Then I expect value of column "ACID_ID_COUNT" in the below SQL query equals to "5":
      """
      SELECT COUNT(*) AS ACID_ID_COUNT FROM FT_T_ACID
      WHERE ACCT_ID IN ('GS0000003705','GS0000004106','GS0000004107','GS0000003606','GS0000003805') AND ACCT_ID_CTXT_TYP = 'CRTSID'  AND END_TMS IS NULL
	  
      """

  Scenario: TC_2: Insert data into FT_T_ACGU table

    Given I execute below query
      """
      ${testdata.path}/sql/Insert_ACGU_Data_TC2.sql
      """

    Then I expect value of column "LATAM_ID_COUNT" in the below SQL query equals to "3":
      """
      SELECT COUNT(*) AS LATAM_ID_COUNT FROM FT_T_ACGU
	  WHERE ACCT_ID IN ('GS0000004106','GS0000004107','GS0000003606') AND gu_id = 'LATAM' AND gu_typ = 'REGION' AND acct_gu_purp_typ = 'POS_SEGR' AND DATA_STAT_TYP = 'ACTIVE'
      """

    Then I expect value of column "NON_LATAM_ID_COUNT" in the below SQL query equals to "2":
      """
      SELECT COUNT(*) AS NON_LATAM_ID_COUNT FROM FT_T_ACGU
	  WHERE ACCT_ID IN ('GS0000003705','GS0000003805') AND gu_id = 'NONLATAM' AND gu_typ = 'REGION' AND acct_gu_purp_typ = 'POS_SEGR' AND DATA_STAT_TYP = 'ACTIVE'
      """