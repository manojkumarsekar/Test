#https://jira.intranet.asia/browse/TOM-4089 : Initial dev
#https://jira.intranet.asia/browse/TOM-4144 : Handle nulls (coming as 0 from Excel)
#https://jira.intranet.asia/browse/TOM-4220 : Change FIID context from BRSCNTCDE to BRSTRDCNTCDE
#https://jira.intranet.asia/browse/TOM-4244 : Ensure all 46 FINS have broker roles
#

#This scenario to be deleted after adding UI tests
@tom_4089 @tom_4144 @tom_4220 @tom_4244
Feature: Sanity checks that broker setup scripts have been applied successfully

  This would be better as an automated check against the UI, to ensure the DMP data model is populated as expected.
  However this requires Selenium changes, so for now those UI checks are manual (refer JIRA) and we're just checking tables populated.
  This should NOT be part of regression test pack as it's likely last_chg_usr_id could change in future for these records.

  Scenario: TC1: Check tables populated

    # Given this script is running

    Then I expect value of column "TOM_4089_FINS_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_FINS_LOADED
    FROM   ft_t_fins
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4089_FINR_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),46,'Y','N') AS TOM_4089_FINR_LOADED
    FROM   ft_t_finr
    WHERE  last_chg_usr_id = 'TOM-4089'
    AND    finsrl_typ = 'BROKER'
    """

    And I expect value of column "TOM_4089_EXAC_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_EXAC_LOADED
    FROM   ft_t_exac
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4089_AEAR_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_AEAR_LOADED
    FROM   ft_t_aear
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4089_FICM_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_FICM_LOADED
    FROM   ft_t_ficm
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4089_FIDE_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_FIDE_LOADED
    FROM   ft_t_fide
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4089_FIID_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_FIID_LOADED
    FROM   ft_t_fiid
    WHERE  last_chg_usr_id = 'TOM-4089'
    AND    fins_id_ctxt_typ = 'BRSTRDCNTCDE'
    """

    And I expect value of column "TOM_4089_EADR_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_EADR_LOADED
    FROM   ft_t_eadr
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4089_CCRF_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_CCRF_LOADED
    FROM   ft_t_ccrf
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4089_ADTP_LOADED" in the below SQL query equals to "Y":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4089_ADTP_LOADED
    FROM   ft_t_adtp
    WHERE  last_chg_usr_id = 'TOM-4089'
    """

    And I expect value of column "TOM_4144_ZERO_FOR_FAX" in the below SQL query equals to "N":
    """
    SELECT DECODE(COUNT(1),0,'N','Y') AS TOM_4144_ZERO_FOR_FAX
    FROM   ft_t_eadr
    WHERE  last_chg_usr_id = 'TOM-4089' -- use original ticket number
    AND    fax_num_id = '0'
    """
