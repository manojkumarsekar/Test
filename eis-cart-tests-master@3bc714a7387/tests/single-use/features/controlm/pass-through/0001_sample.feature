Feature: This is to test Control-m Pass through workflows

  Scenario: Test RIMES - GAA_ASIA_BENCHMARK_PRICELEVELS_DEV

    Given I have a file "esi_brs_asia_benchmark_pricelevels_20180713.csv" in folder "/dmp/in/rim/"

    When I trigger the control-m job
     """
      /opt/controlm/ctm/exe/ctmorder \
      -FOLDER EIS-APP-TOM-FROM-RIMES-DEV/GAA_DEV \
      -NAME GAA_ASIA_BENCHMARK_PRICELEVELS_DEV \
      -ODATE 20180713 \
      -FORCE y \
      -INTO_FOLDER_ORDERID NEWT
     """

    Then I expect below files to be archived to the host "dmp.ssh.inbound" into folder "/dmp/in/archive" after processing:
      | esi_brs_asia_benchmark_pricelevels_20180713.csv |

    And I expect value of column "RECORD_COUNT" in the below SQL query equals to "1":
    """
    SELECT COUNT(*) AS RECORD_COUNT FROM FT_T_JBLG
    WHERE JOB_INPUT_TXT LIKE 'esi_brs_asia_benchmark_pricelevels_20180713.csv'
    AND JOB_STAT_TYP = 'CLOSED'
    AND JOB_CONFIG_TXT = 'RIM'
    """

