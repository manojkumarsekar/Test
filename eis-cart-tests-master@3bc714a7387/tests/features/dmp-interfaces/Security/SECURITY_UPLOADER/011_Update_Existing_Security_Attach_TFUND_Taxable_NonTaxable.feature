#https://collaborate.pruconnect.net/display/EISTOMR4/Security+Uploader+-+Technical+Spec
#EISDEV-7047 : Initial Version

@gc_interface_securities
@dmp_regression_integrationtest
@dmp_security_uploader @update_exiting_security_tfund_taxable_nontaxable @eisdev_7047
@dmp_thailand_securities @dmp_thailand

Feature: 011 | Security Uploader | Update Existing Security | Attach TFUND Taxable & NonTaxable on BCUSIP
  Verify TFUND Taxable Non Taxable from the Security Uploader is attached to existing security

  Scenario: End date Instruments in GC and VD DB and Assign Variables

    Given I assign "tests/test-data/dmp-interfaces/Security/SECURITY_UPLOADER/inputfiles" to variable "testdata.path"
    And I assign "BPM22BM47_BRS_F10.xml" to variable "INPUT_FILENAME_BRS_F10"
    And I assign "DMP_ShellSecurityUploaderTemplate_2.0_01_BPM22BM47.xlsx" to variable "INPUT_FILENAME_EIS_SECURITY_UPLOADER"
    And I inactivate "BPM22BM47" instruments in GC database
    And I inactivate "BPM22BM47" instruments in VD database

  Scenario: Loading F10 for BCUSIP BPM22BM47

    Given I process "${testdata.path}/testdata/${INPUT_FILENAME_BRS_F10}" file with below parameters
      | BUSINESS_FEED |                           |
      | FILE_PATTERN  | ${INPUT_FILENAME_BRS_F10} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW   |

    Then I expect workflow is processed in DMP with success record count as "1"

  Scenario: Verify if BCUSIP was created

    Then I expect value of column "BCUSIP" in the below SQL query equals to "BPM22BM47":
    """
      select iss_id as BCUSIP from ft_t_isid where iss_id = 'BPM22BM47'
      and id_ctxt_typ = 'BCUSIP' and end_tms is null
    """

  Scenario: Loading Securities using Security Uploader for BCUSIP BPM22BM47

    Given I process "${testdata.path}/testdata/${INPUT_FILENAME_EIS_SECURITY_UPLOADER}" file with below parameters
      | BUSINESS_FEED |                                         |
      | FILE_PATTERN  | ${INPUT_FILENAME_EIS_SECURITY_UPLOADER} |
      | MESSAGE_TYPE  | EIS_MT_DMP_SECURITY_MASTER_TEMPLATE     |

    Then I expect workflow is processed in DMP with success record count as "2"

  Scenario: Verify if Taxable & Non Taxable ID was created

    Then I expect value of column "TFUND_TAXABLE" in the below SQL query equals to "CPF20NAR":
    """
      select iss_id as TFUND_TAXABLE from ft_t_isid
      where instr_id in (select instr_id from ft_t_isid where iss_id = 'BPM22BM47'
      and id_ctxt_typ = 'BCUSIP' and end_tms is null)
      and end_tms is null
      and id_ctxt_typ = 'TFHIPORTIDT'
    """

    Then I expect value of column "TFUND_NON_TAXABLE" in the below SQL query equals to "CPF20NA":
    """
      select iss_id as TFUND_NON_TAXABLE from ft_t_isid
      where instr_id in (select instr_id from ft_t_isid where iss_id = 'BPM22BM47'
      and id_ctxt_typ = 'BCUSIP' and end_tms is null)
      and end_tms is null
      and id_ctxt_typ = 'TFHIPORTIDNT'
    """