#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45867643
#https://jira.intranet.asia/browse/TOM-3351

@gc_interface_securities
@dmp_regression_unittest
@tom_3351 @dmp_bb_care_rating @r3_in_care_ratings_inbound_scenarios
Feature: Inbound Care ratings from BB to DMP Interface Testing

  Load new ratings response file with below records (details below)
  INE134E08II2 Corp|0|39|BBG00DKLMHT9|INE134E08II2|BYWR114|QZ1988620|POWFIN|Corp|NSE INDIA|POWFIN 7.63 08/14/26|239452|Power Finance Corp Ltd|180906|Republic of India| |AAA|20160812|AAA|20160812|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180816|57|20190816|AAA|20160812|
  INE053F07603 Corp|0|39|BBG004CVSFY8|INE053F07603|B9XQY49|EJ6085124|INRCIN|Corp|NSE INDIA|INRCIN 8.83 03/25/23|217210|Indian Railway Finance Corp Ltd|1482300|India Ministry of Railways| |AAA|20130315|AAA|20130315|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180415|180|20190415|AAA|20130315|
  INE134E08HV7 Corp|0|39|BBG009LDSYV9|INE134E08HV7|BF02YG4|AF2692123|POWFIN|Corp|NSE INDIA|POWFIN 8.36 09/04/20|239452|Power Finance Corp Ltd|180906|Republic of India| |AAA|20150904|AAA|20150904|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180904|38|20190904|AAA|20150904|
  INE038A07274 Corp|0|39|BBG0035GLYF8|INE038A07274|BHWQR92|EJ2602351|HNDLIN|Corp|NSE INDIA|HNDLIN 9.6 08/02/22|152975|Hindalco Industries Ltd| | | |AA|20171017|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180802|71|20190802|AA+|20170926|
  XS0562852376 Corp|0|39|BBG00DS6HA00|XS0562852376|BYZ6127|QZ5126123|EASYTB|Corp|NOT LISTED|EASYTB 2.99 09/15/23|10529145|Easy Buy PCL|125931|Acom Co Ltd| |N.A.|N.A.|N.A.|N.A.|WR|20150702|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180915|31|20190315|AA|20180909|

  Reload ratings response file
  INE134E08II2 Corp|0|39|BBG00DKLMHT9|INE134E08II2|BYWR114|QZ1988620|POWFIN|Corp|NSE INDIA|POWFIN 7.63 08/14/26|239452|Power Finance Corp Ltd|180906|Republic of India| |AAA|20160812|AAA|20160812|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180816|57|20190816|AA+|20160812|
  INE053F07603 Corp|0|39|BBG004CVSFY8|INE053F07603|B9XQY49|EJ6085124|INRCIN|Corp|NSE INDIA|INRCIN 8.83 03/25/23|217210|Indian Railway Finance Corp Ltd|1482300|India Ministry of Railways| |AAA|20130315|AAA|20130315|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180415|180|20190415|AA|20130315|
  INE134E08HV7 Corp|0|39|BBG009LDSYV9|INE134E08HV7|BF02YG4|AF2692123|POWFIN|Corp|NSE INDIA|POWFIN 8.36 09/04/20|239452|Power Finance Corp Ltd|180906|Republic of India| |AAA|20150904|AAA|20150904|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180904|38|20190904|AAA|20150904|
  INE038A07274 Corp|0|39|BBG0035GLYF8|INE038A07274|BHWQR92|EJ2602351|HNDLIN|Corp|NSE INDIA|HNDLIN 9.6 08/02/22|152975|Hindalco Industries Ltd| | | |AA|20171017|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|N.A.|DOMESTIC|20180802|71|20190802|AA+|20170926|


  Scenario: TC_1: Clear the data as a Prerequisite

    Given I assign "R3_IN_CARE_Ratings_Test_File_For_Verification.out" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3351" to variable "testdata.path"

    # Clear data
    And I execute below query
    """
    ${testdata.path}/sql/ClearData_R3_IN_CARE_Ratings.sql
    """

    And I set the database connection to configuration "dmp.db.VD"
    And I execute below query
    """
    ${testdata.path}/sql/ClearData_R3_IN_CARE_Ratings.sql
    """

  Scenario: TC_2: Load BB Response File for Care Ratings

    Given I set the database connection to configuration "dmp.db.GC"
    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    When I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

  Scenario: TC_3: Data Verifications in GC and VDDB

    # Validation 1: Ratings - Total Successfully Processed Records => 4 records should be created in ISRT
    Then I expect value of column "PROCESSED_ROW_COUNT" in the below SQL query equals to "4":
      """
      ${testdata.path}/sql/R3_IN_CARE_Ratings_Processed_Row_Count.sql
      """

    # Validation 2: Ratings - New => 4 records should be created in isrt for CARE Rating with correct mapping for columns  RTG_CARE, CARE_EFF_DT
    Then I expect value of column "ISRT_COUNT" in the below SQL query equals to "4":
      """
      ${testdata.path}/sql/R3_IN_CARE_Ratings_Data_Verification.sql
      """

    # Validation 3: Ratings - Mandatory Field Missing Records => 1 record should be created in NTEL
    Then I expect value of column "EXCEPTION_ROW_COUNT" in the below SQL query equals to "1":
      """
      ${testdata.path}/sql/R3_IN_CARE_Ratings_Missing_Fields_Data_Exception.sql
      """

    # Validation 4: Ratings - New => 4 records should be created in VDDB for  isrt for CARE Rating
    Given I set the database connection to configuration "dmp.db.VD"
    Then I expect value of column "ISRT_COUNT" in the below SQL query equals to "4":
      """
      ${testdata.path}/sql/R3_IN_CARE_Ratings_Data_Verification.sql
      """

  Scenario: TC_4: Reload BB Response File for Care Ratings

    Given I assign "R3_IN_CARE_Ratings_Test_File_For_Reload_Verification.out" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3351" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

  Scenario: TC_5: Data Verifications for Reload

   # Validation 1: Ratings - Total Successfully Processed Records => 4 records should be updated in ISRT
    Then I expect value of column "RELOAD_PROCESSED_ROW_COUNT" in the below SQL query equals to "4":
      """
      ${testdata.path}/sql/R3_IN_CARE_Ratings_Reload_Processed_Row_Count.sql
      """

   # Validation 2: Ratings - Total Successfully Inactivated Records => 2 records should be inactivated in ISRT
    Then I expect value of column "RELOAD_INACTIVE_ROW_COUNT" in the below SQL query equals to "2":
      """
      ${testdata.path}/sql/R3_IN_CARE_Ratings_Reload_Inactive_Row_Count.sql
      """