#https://collaborate.intranet.asia/pages/viewpage.action?pageId=45867643
#https://jira.intranet.asia/browse/TOM-3351

@gc_interface_ratings @gc_interface_securities
@dmp_regression_integrationtest
@tom_3351 @dmp_bb_care_rating @r3_in_care_ratings_outbound_scenarios @eisdev_7324
Feature: Outbound BB Care ratings from DMP to BRS Interface Testing

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

  Below records should be present in the outbound

  EXTERN_NEWCASH_ID1,PORTFOLIO,AMOUNT,CURRENCY,CASH_TYPE,SETTLE_DATE,TRADE_DATE,AUTHORIZED_BY,CASH_REASON,COMMENTS,CONFIRMED_BY,ESTIMATED,SOURCE
  123,NDSICF,2300000,IDR,CASHIN,20180628,20180625,ID-TA,CCRE,NewCash for NDSICF,ID-TA,F,X
  456,ADPSEF,456789.67,IDR,CASHOUT,20180628,20180622,ID-TA,,,ID-TA,F,X

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

  Scenario: TC_3: Reload BB Response File for CARE Ratings

    Given I assign "R3_IN_CARE_Ratings_Test_File_For_Reload_Verification.out" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3351" to variable "testdata.path"

    When I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    Then I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                                  |
      | FILE_PATTERN  | ${INPUT_FILENAME}                |
      | MESSAGE_TYPE  | EIS_MT_BBG_SECURITY_PER_SECURITY |

  Scenario: TC_4: Triggering Publishing Wrapper Event for CSV file into directory for BB Care Ratings

    Given I assign "esi_brs_p_ratings" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/brs/1a_security" to variable "PUBLISHING_DIR"

    And I remove below files with pattern in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}*.csv |

    When I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv   |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_BRS_BBGRATINGS_SUB |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

    And I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles/actual":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

  Scenario: TC_5: Check the attributes in the outbound file for BB Care Ratings

    Given I assign "BRS_RATINGS_MASTER_TEMPLATE.csv" to variable "RATINGS_MASTER_TEMPLATE"
    And I assign "${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" to variable "RATINGS_CURR_FILE"

    When I capture current time stamp into variable "recon.timestamp"
    Then I expect each record in file "${testdata.path}/outfiles/expected/${RATINGS_MASTER_TEMPLATE}" should exist in file "${testdata.path}/outfiles/actual/${RATINGS_CURR_FILE}" and exceptions to be written to "${testdata.path}/outfiles/exceptions_${recon.timestamp}.csv" file