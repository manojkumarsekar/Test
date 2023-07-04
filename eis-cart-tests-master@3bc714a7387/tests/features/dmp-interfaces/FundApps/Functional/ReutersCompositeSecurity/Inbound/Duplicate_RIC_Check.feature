# =====================================================================
# Date            JIRA        Comments
# ============    ========    ========
# 26/03/2019      TOM-4604    First Version
# =====================================================================

#https://jira.intranet.asia/browse/TOM-4604
#https://collaborate.intranet.asia/display/TOMR4/FA-IN-SMF-Reuters-DMP-Security-File
#Security files received from LBU and RCR are to be stored in DMP

@tom_4604 @dmp_fundapps_functional  @dmp_interfaces @tom_4640

Feature: TOM_4604 SSDR_INBOUND | Duplicate RIC |

  This is an OMDX check .We are creating an OMDX so that the Issuer (FINS) and Instrument are linked via the Fins Role/Issue Participant (FRIP) link

  Scenario: TC_1: Load Reuters Terms and Conditions file Duplicate_RIC_File1.csv

    Given I assign "Duplicate_RIC_File1.csv" to variable "Duplicate_RIC_INPUT_FILE1"

    Given I assign "tests/test-data/dmp-interfaces/FundApps/Functional/ReutersTermsConditionsSecurity" to variable "testdata.path"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":

      | ${Duplicate_RIC_INPUT_FILE1} |

    And I assign "200" to variable "workflow.max.polling.time"

    Given I process files with below parameters and wait for the job to be completed

      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${Duplicate_RIC_INPUT_FILE1}   |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_2: Verifications for Issu_identifier (ISID)

    Then I expect value of column "VERIFY_ISID" in the below SQL query equals to "1":
    """
    SELECT count(*)as VERIFY_ISID FROM fT_T_isid where iss_id='00489LAA1=RRPS' and ID_ctxt_typ='RIC'
    """

  Scenario: TC_4: Load Reuters Terms and Conditions file Duplicate_RIC_File2.csv
    Given I assign "Duplicate_RIC_File1.csv" to variable "Duplicate_RIC_INPUT_FILE2"

    And I copy files below from local folder "${testdata.path}/infiles" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":

      | ${Duplicate_RIC_INPUT_FILE2} |

    And I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                               |
      | FILE_PATTERN  | ${Duplicate_RIC_INPUT_FILE2}   |
      | MESSAGE_TYPE  | ReutersDSS_TermsandConditions |

    Then I extract new job id from jblg table into a variable "JOB_ID"
    And I expect value of column "JBLG_ROW_COUNT" in the below SQL query equals to "1":
    """
	SELECT count(*) as JBLG_ROW_COUNT FROM FT_T_JBLG WHERE JOB_ID = '${JOB_ID}'
	"""

  Scenario: TC_5: Verifications for Issu_identifier (ISID)

    Then I expect value of column "VERIFY_ISID" in the below SQL query equals to "1":
    """
    SELECT count(*)as VERIFY_ISID
    from fT_T_isid
    where iss_id='00489LAA1=RRPS'
    and ID_ctxt_typ='RIC'
    """



