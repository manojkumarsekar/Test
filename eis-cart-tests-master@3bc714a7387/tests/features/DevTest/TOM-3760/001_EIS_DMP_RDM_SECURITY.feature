#https://jira.intranet.asia/browse/TOM-3760
#https://jira.intranet.asia/browse/TOM-3919

@gc_interface_securities
@dmp_regression_unittest
@tom_3760 @tom_3919
Feature: Duplicate field present in Fullinstrument.gso

  Removed the duplicate field from the GSO and changed the mapping in outbound MDX

  Scenario: Providing filename and output directory

    Given I assign "tests/test-data/DevTest/TOM-3760" to variable "testdata.path"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "PERP_Case" to variable "PUBLISHING_FILE_NAME_1"
    And I assign "OtherThenPERPCase" to variable "PUBLISHING_FILE_NAME_2"
    And I assign "BlankValueCase" to variable "PUBLISHING_FILE_NAME_3"
    And I assign "R_Case" to variable "PUBLISHING_FILE_NAME_4"
    And I assign "/dmp/out/eis/refdata" to variable "PUBLISHING_DIR"
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |
      | ${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |
      | ${PUBLISHING_FILE_NAME_4}_${VAR_SYSDATE}_1.csv |

  Scenario: Publish file for where DescInstmt2 field contain PERP

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_1}.csv                                                                                              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SECURITY_CREATION_SUB                                                                                       |
      | SQL                  | &lt;sql&gt; instr_id in (select instr_id from fT_T_isid where iss_id in ('SG7EB6000007') and end_tms is null) &lt;/sql&gt; |

    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the value for PORTFOLIO in outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_1}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if ISIN SG7EB6000007 has value Y Perpetual Flag field in the outbound

    Given I expect column "Perpetual Flag" value to be "Y" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN           | SG7EB6000007             |
      | SEDOL          | BF1BL25                  |
      | Exchange       | UUU                      |
      | Security Name  | ARA ASSET MANAGEMENT LTD |
      | Perpetual Flag | Y                        |
      | Security Type  | CB                       |


  Scenario: Publish file for where DescInstmt2 field contain other then PERP

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_2}.csv                                                                                              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SECURITY_CREATION_SUB                                                                                       |
      | SQL                  | &lt;sql&gt; instr_id in (select instr_id from fT_T_isid where iss_id in ('US06120TAA60') and end_tms is null) &lt;/sql&gt; |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the value for PORTFOLIO in outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_2}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if ISIN US06120TAA60 has null value for Perpetual Flag field in the outbound

    Given I expect column "Perpetual Flag" value to be "" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN           | US06120TAA60      |
      | SEDOL          | BSKPG02           |
      | Exchange       | UUU               |
      | Security Name  | BANK OF CHINA LTD |
      | Perpetual Flag |                   |
      | Security Type  | CB                |


  Scenario: Publish file for where DescInstmt2 field does not have value

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_3}.csv                                                                                              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SECURITY_CREATION_SUB                                                                                       |
      | SQL                  | &lt;sql&gt; instr_id in (select instr_id from fT_T_isid where iss_id in ('US00131M2B87') and end_tms is null) &lt;/sql&gt; |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the value for PORTFOLIO in outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_3}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if ISIN US00131M2B87 has null value for Perpetual Flag field in the outbound

    Given I expect column "Perpetual Flag" value to be "" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN           | US00131M2B87  |
      | SEDOL          | BKHDRW2       |
      | Exchange       | UUU           |
      | Security Name  | AIA GROUP LTD |
      | Perpetual Flag |               |
      | Security Type  | CB            |


  Scenario: Publish file for where DescInstmt2 field have R

    Given I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME_4}.csv                                                                                              |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_RDM_SECURITY_CREATION_SUB                                                                                       |
      | SQL                  | &lt;sql&gt; instr_id in (select instr_id from fT_T_isid where iss_id in ('FI0009005961') and end_tms is null) &lt;/sql&gt; |


    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME_4}_${VAR_SYSDATE}_1.csv |

    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME_4}_${VAR_SYSDATE}_1.csv |

  Scenario: Check the value for PORTFOLIO in outbound file

    Given I assign "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME_4}_${VAR_SYSDATE}_1.csv" to variable "CSV_FILE"

    #Check if ISIN US00131M2B87 has null value for Perpetual Flag field in the outbound

    Given I expect column "Perpetual Flag" value to be "" where columns values are as below in CSV file "${CSV_FILE}"
      | ISIN           | FI0009005961       |
      | SEDOL          | 5072673            |
      | Exchange       | HEL                |
      | Security Name  | STORA ENSO CLASS R |
      | Perpetual Flag |                    |
      | Security Type  | COM                |