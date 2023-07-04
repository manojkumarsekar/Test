# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 11/10/2018      TOM-3561    First Version
# =====================================================================

@tom_3561 @esi_netflows @esi_netflows_include_in_uklife
Feature: Netflows Inbound and Outbound: Since "ATPTWM" fund part of SGLUKLNP group in ACGP, Verify that INTERO is translated to SGOUFL; and INTERI is translated to SGINFL
# =====================================================================
# Load a HIP_CASHFLOW file containing 4 records
#   Pfolio Name                       Pfolio        Source        INFLOW/OUTFLOW
#   "PRU TAIWAN LIFE - NON PAR"       "ATPTWM"      "INTERI"      2766000000
#   "PRU TAIWAN LIFE - NON PAR"       "ATPTWM"      "INTERO"      2847000000
#   "REKSA DANA EASTSPRING INVESTME"  "NDCRMF"      "SGOUFL"      3200000000
#   "REKSA DANA EASTSPRING INVESTME"  "NDCRMF"      'SGINFL"      760000000
# Add "ATPTWM" fund to SGLUKLNP group in ACGP 
# Publish Netflows Report
# Verify that INTERO is translated to SGOUFL; and INTERI is translated to SGINFL for the UK-Life fund "ATPTWM"
# =====================================================================

# Step 1: Declare and assign variable
  Scenario: Set variables and run cleardown script
    Given I assign "CASHNFHIP.CSV" to variable "INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3561" to variable "testdata.path"
    And I assign "esi_netflows_002" to variable "PUBLISHING_FILE_NAME"
    And I generate value with date format "YYYYMMdd" and assign to variable "VAR_SYSDATE"
    And I assign "/dmp/out/eis/netflows" to variable "PUBLISHING_DIR"
    And I assign "esi_netflows_002_master_template.csv" to variable "MASTER_FILE"

# Step 2: Clear data to exclude "ATPTWM" and "NDCRMF" funds from SGLUKLNP group in ACGP
    When I execute below query
"""
${testdata.path}/sql/Insert_002.sql
"""

  Scenario: Trigger a Load followed by Publish

# Step 3: Delete and discard the output file if it exist
    And I remove below files in the host "dmp.ssh.inbound" from folder "${PUBLISHING_DIR}" if exists:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

# Step 4: Copy the input file to the input location
    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

# Step 5: Load a fresh set of 4 HIP_CASHFLOW records
    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                     |
      | FILE_PATTERN  | ${INPUT_FILENAME}   |
      | MESSAGE_TYPE  | EIS_MT_HIP_CASHFLOW |

# Step 6: Publish Netflows - it should contain 4 HIP_CASHFLOW records
    And I process publishing wrapper with below parameters and wait for the job to be completed
      | PUBLISHING_FILE_NAME | ${PUBLISHING_FILE_NAME}.csv |
      | SUBSCRIPTION_NAME    | EIS_DMP_TO_EIS_NETFLOWS_SUB |

# Step 7: Validate whether output file is generated
    Then I expect below files to be present in the host "dmp.ssh.inbound" into folder "${PUBLISHING_DIR}" after processing:
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

# Step 8: Copy the output file to reconcile data
    Then I copy files below from remote folder "${PUBLISHING_DIR}" on host "dmp.ssh.inbound" into local folder "${testdata.path}/outfiles":
      | ${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv |

# Step 9: Reconcile Data. Since "ATPTWM" fund part of SGLUKLNP group in ACGP, Verify that INTERO is translated to SGOUFL; and INTERI is translated to SGINFL for the UK-Life fund "ATPTWM"
    And I expect reconciliation between generated CSV file "${testdata.path}/outfiles/${PUBLISHING_FILE_NAME}_${VAR_SYSDATE}_1.csv" and reference CSV file "${testdata.path}/outfiles/template/${MASTER_FILE}" should be successful and exceptions to be written to "${TESTDATA_PATH}/outfiles/exceptions_${recon.timestamp}.csv" file