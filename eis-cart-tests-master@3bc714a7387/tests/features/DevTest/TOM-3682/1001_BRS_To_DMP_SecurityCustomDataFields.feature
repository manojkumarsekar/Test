#https://jira.intranet.asia/browse/TOM-3682
#https://jira.intranet.asia/browse/TOM-3789 - add LEAD_MGR and fix JPM fund code ID context type
#https://jira.intranet.asia/browse/TOM-3891 - fix updating or end dating of TW IDs
#https://jira.intranet.asia/browse/TOM-4032 - reverse/remove the LEAD_MGR consumption from TOM-3789

#https://collaborate.intranet.asia/display/TOMR4/R3.IN-1Y+BRS-%3EDMP+%27Security%27+%3A+Taiwan+fund+security+identifiers

@gc_interface_securities
@dmp_regression_unittest
@taiwan_dmp_interfaces
@tom_3682 @dmp_smoke @tom_3789 @tom_3891 @tom_4032 @dmp_gs_upgrade
Feature: Test changes to BRS security interface for TW implementation: TW security identifiers and default broker for fund securities

  # TOM-3682 - load two external fund codes into DMP
  # TOM-3789 - fix one of the domain values used in TOM-3682 and load default broker for fund securities

  Scenario: TC1: Create Security F10 file with AS_OF_DATE as SYSDATE and Load into DMP

    Given I assign "TW_Security_F10_Template.xml" to variable "SECURITY_INPUT_TEMPLATENAME"
    And I assign "TW_Security_F10.xml" to variable "SECURITY_INPUT_FILENAME"
    And I assign "tests/test-data/DevTest/TOM-3682" to variable "testdata.path"

    And I execute below query to "End date existing ISIDs to ensure new security created"
    """
    UPDATE ft_t_isid
    SET start_tms = SYSDATE - 1, end_tms = SYSDATE
    WHERE instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    And I assign "MNY-TEST-1" to variable "MNY_VALUE"
    And I assign "JPM-TEST-1" to variable "JPM_VALUE"

    And I create input file "${SECURITY_INPUT_FILENAME}" using template "${SECURITY_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE | DateTimeFormat:YYYY-MM-dd |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect value of column "MONEY_TRUST_ID" in the below SQL query equals to "MNY-TEST-1":
    """
    SELECT iss_id AS MONEY_TRUST_ID
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWMNYTRST'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "JPM_FUND_CODE" in the below SQL query equals to "JPM-TEST-1":
    """
    SELECT iss_id AS JPM_FUND_CODE
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWJPMFNDCDE'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

  Scenario: TC2: Load new security F10 file with modified identifiers and ensure old identifiers updated

    Given I assign "MNY-TEST-2" to variable "MNY_VALUE"
    And I assign "JPM-TEST-2" to variable "JPM_VALUE"

    And I create input file "${SECURITY_INPUT_FILENAME}" using template "${SECURITY_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE | DateTimeFormat:YYYY-MM-dd |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect value of column "MONEY_TRUST_ID" in the below SQL query equals to "MNY-TEST-2":
    """
    SELECT iss_id AS MONEY_TRUST_ID
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWMNYTRST'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "NO_OF_ACTIVE_MONEY_TRUST_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_MONEY_TRUST_ID
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWMNYTRST'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "JPM_FUND_CODE" in the below SQL query equals to "JPM-TEST-2":
    """
    SELECT iss_id AS JPM_FUND_CODE
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWJPMFNDCDE'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "NO_OF_ACTIVE_JPM_FUND_CODE" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_JPM_FUND_CODE
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWJPMFNDCDE'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

  Scenario: TC3: Load new security F10 file with modified identifiers and ensure (previous day's) old identifiers are end dated

    # Move TC2 entries back a day
    Given I execute below query
    """
    UPDATE ft_t_isid
    SET    start_tms = start_tms - 1
    WHERE  id_ctxt_typ IN ('TWMNYTRST', 'TWJPMFNDCDE')
    AND    end_tms IS NULL
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Given I assign "MNY-TEST-3" to variable "MNY_VALUE"
    And I assign "JPM-TEST-3" to variable "JPM_VALUE"

    And I create input file "${SECURITY_INPUT_FILENAME}" using template "${SECURITY_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE | DateTimeFormat:YYYY-MM-dd |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect value of column "MONEY_TRUST_ID" in the below SQL query equals to "MNY-TEST-3":
    """
    SELECT iss_id AS MONEY_TRUST_ID
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWMNYTRST'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "NO_OF_ACTIVE_MONEY_TRUST_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_MONEY_TRUST_ID
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWMNYTRST'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "JPM_FUND_CODE" in the below SQL query equals to "JPM-TEST-3":
    """
    SELECT iss_id AS JPM_FUND_CODE
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWJPMFNDCDE'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "NO_OF_ACTIVE_JPM_FUND_CODE" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_JPM_FUND_CODE
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWJPMFNDCDE'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

  Scenario: TC4: Load new security F10 file with modified identifiers and ensure latest identifiers updated

    Given I assign "MNY-TEST-4" to variable "MNY_VALUE"
    And I assign "JPM-TEST-4" to variable "JPM_VALUE"

    And I create input file "${SECURITY_INPUT_FILENAME}" using template "${SECURITY_INPUT_TEMPLATENAME}" with below codes from location "${testdata.path}/infiles"
      | AS_OF_DATE | DateTimeFormat:YYYY-MM-dd |

    When I copy files below from local folder "${testdata.path}/infiles/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${SECURITY_INPUT_FILENAME} |

    Given I process files with below parameters and wait for the job to be completed
      | BUSINESS_FEED |                            |
      | FILE_PATTERN  | ${SECURITY_INPUT_FILENAME} |
      | MESSAGE_TYPE  | EIS_MT_BRS_SECURITY_NEW    |

    Then I expect value of column "MONEY_TRUST_ID" in the below SQL query equals to "MNY-TEST-4":
    """
    SELECT iss_id AS MONEY_TRUST_ID
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWMNYTRST'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "NO_OF_ACTIVE_MONEY_TRUST_ID" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_MONEY_TRUST_ID
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWMNYTRST'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "JPM_FUND_CODE" in the below SQL query equals to "JPM-TEST-4":
    """
    SELECT iss_id AS JPM_FUND_CODE
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWJPMFNDCDE'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

    Then I expect value of column "NO_OF_ACTIVE_JPM_FUND_CODE" in the below SQL query equals to "1":
    """
    SELECT COUNT(1) NO_OF_ACTIVE_JPM_FUND_CODE
    FROM   ft_t_isid
    WHERE  end_tms IS NULL
    AND    id_ctxt_typ = 'TWJPMFNDCDE'
    AND    instr_id IN (SELECT instr_id FROM ft_t_isid WHERE id_ctxt_typ = 'BCUSIP' AND iss_id = 'TWTOM3682' AND end_tms IS NULL)
    """

