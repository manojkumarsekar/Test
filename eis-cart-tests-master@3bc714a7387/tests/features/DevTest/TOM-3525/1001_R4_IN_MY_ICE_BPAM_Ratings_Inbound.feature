#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45845598
#https://jira.intranet.asia/browse/TOM-3525

@gc_interface_ice
@dmp_regression_unittest
@tom_3525 @r4_in_my_ice_bpam_ratings_inbound_scenarios
Feature: Inbound ratings from ICE-BPAM Malaysia to DMP Interface Testing

  Load new ratings response file with below records (details below), all containing CLIENT_ID, MARC_LT_RATING, MARC_LT_RAT_EFF_DATE, RAM_LT_RATING, RAM_LT_RAT_EFF_DATE
  as mandatory fields and MARC_ST_RATING, RAM_ST_RATING as optional field

  CLIENT_ID,ISIN,PRICE_DATE,CURRENCY,PRICE,PRICE_PURPOSE,PRICE_SOURCE,SECTOR,RAM_LT_RATING,RAM_LT_RAT_EFF_DATE,RAM_ST_RATING,RAM_ST_RAT_EFF_DATE,MARC_LT_RATING,MARC_LT_RAT_EFF_DATE,MARC_ST_RATING,MARC_ST_RAT_EFF_DATE
  ESL7418182,MYBUN1701456,20180723,MYR,100.38,ESIMYS,ESIMY,FINANCIAL SERVICES,A1,20180815,,,A,20180815,,
  ESL4608988,MYBUN1700185,20180723,MYR,101.813,ESIMYS,ESIMY,FINANCIAL SERVICES,A2,20180815,,,AA-IS,20180815,,
  ESL2741151,MYBUN1500908,20180723,MYR,101.857,ESIMYS,ESIMY,FINANCIAL SERVICES,A3,20180815,,,AAA,20180815,,
  ESL5631554,MYBVK1104002,20180723,MYR,99.998,ESIMYS,ESIMY,PROPERTY AND REAL ESTATE,,,,,,,,

  Reload ratings response file

  CLIENT_ID,ISIN,PRICE_DATE,CURRENCY,PRICE,PRICE_PURPOSE,PRICE_SOURCE,SECTOR,RAM_LT_RATING,RAM_LT_RAT_EFF_DATE,RAM_ST_RATING,RAM_ST_RAT_EFF_DATE,MARC_LT_RATING,MARC_LT_RAT_EFF_DATE,MARC_ST_RATING,MARC_ST_RAT_EFF_DATE
  ESL7418182,MYBUN1701456,20180723,MYR,100.38,ESIMYS,ESIMY,FINANCIAL SERVICES,A1,20180815,,,A,20180815,,
  ESL4608988,MYBUN1700185,20180723,MYR,101.813,ESIMYS,ESIMY,FINANCIAL SERVICES,A2,20180815,,,AA-IS,20180815,,
  ESL2741151,MYBUN1500908,20180723,MYR,101.857,ESIMYS,ESIMY,FINANCIAL SERVICES,A3,20180815,,,AAA,20180815,,
  ESL5631554,MYBVK1104002,20180723,MYR,99.998,ESIMYS,ESIMY,PROPERTY AND REAL ESTATE,,,,,,,,

  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "R4_IN_MY_ICE_BPAM_Ratings_Test_File_For_Verification.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3525" to variable "testdata.path"

    And I execute below query to "Clear data"
    """
    ${testdata.path}/sql/ClearData_R4_IN_MY_ICE_BPAM_Ratings.sql
    """

    And I set the database connection to configuration "dmp.db.VD"
    And I execute below query
    """
    ${testdata.path}/sql/ClearData_R4_IN_MY_ICE_BPAM_Ratings.sql
    """

  Scenario: TC_2: Load ICE Response File

    Given I set the database connection to configuration "dmp.db.GC"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                    |
      | FILE_PATTERN  | ${INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIM_MT_ICE_REFDATA |

    Then I extract new job id from jblg table into a variable "JOB_ID"


  Scenario: TC_3: Data Verifications in GC and VDDB

    # Validation 1: Ratings - Total Successfully Processed Records => 6 records should be created in ISRT
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "6":
      """
      ${testdata.path}/sql/R4_IN_ID_4A_Processed_Row_Count.sql
      """

    # Validation 2: Ratings - New => 6 records should be created in isrt 3 for MARC Rating and 3 for RAM Rating with correct mapping for columns  CLIENT_ID, MARC_LT_RATING, MARC_LT_RAT_EFF_DATE, RAM_LT_RATING, RAM_LT_RAT_EFF_DATE
    Then I expect value of column "ISRT_COUNT" in the below SQL query equals to "6":
      """
      ${testdata.path}/sql/R4_IN_ID_4A_Data_Verification_Ratings.sql
      """

    # Validation 3: Ratings - Mandatory Field Missing Records => 2 record should be created in NTEL
    Then I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "2":
      """
      ${testdata.path}/sql/R4_IN_ID_4A_Missing_Fields_Data_Exception.sql
      """

    # Validation 4: Ratings - New => 6 records should be created in VDDB for  isrt 3 for MARC Rating and 3 for RAM Rating with correct mapping for columns  CLIENT_ID, MARC_LT_RATING, MARC_LT_RAT_EFF_DATE, RAM_LT_RATING, RAM_LT_RAT_EFF_DATE
    Given I set the database connection to configuration "dmp.db.VD"
    Then I expect value of column "ISRT_COUNT" in the below SQL query equals to "6":
      """
      ${testdata.path}/sql/R4_IN_ID_4A_Data_Verification_Ratings.sql
      """

  Scenario: TC_4: Reload ICE Response File

    Given I assign "R4_IN_MY_ICE_BPAM_Ratings_Test_File_For_Reload_Verification.csv" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3525" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                    |
      | FILE_PATTERN  | ${INPUT_FILENAME}  |
      | MESSAGE_TYPE  | EIM_MT_ICE_REFDATA |

  Scenario: TC_5: Data Verifications for Reload

   # Validation 1: Ratings - Total Successfully Processed Records => 6 records should be updated in ISRT
    Then I expect value of column "RELOAD_PROCESSED_ROW_COUNT" in the below SQL query equals to "6":
      """
      ${testdata.path}/sql/R4_IN_ID_4A_Reload_Processed_Row_Count.sql
      """

   # Validation 2: Ratings - Total Successfully Inactivated Records => 2 records should be inactivated in ISRT
    Then I expect value of column "RELOAD_INACTIVE_ROW_COUNT" in the below SQL query equals to "2":
      """
      ${testdata.path}/sql/R4_IN_ID_4A_Reload_Inactive_Row_Count.sql
      """