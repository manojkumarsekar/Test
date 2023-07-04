#https://collaborate.intranet.asia/pages/viewpage.action?pageId=48893798
#https://jira.intranet.asia/browse/TOM-3873
#https://jira.intranet.asia/browse/TOM-4244 : Created BROKER role(FINR) as well for FINS which have Role setup as TRAGENT from File15

@tom_3873 @tom_4244
Feature: Test the counterparty file from BRS

  This feature file is to test the counter party file from BRS.

  Background:
    Given I assign "tests/test-data/dmp-interfaces/Taiwan/CounterParty/" to variable "testdata.path"

  Scenario: TC_1: Counterparty file load without BROKER_ISSUER
  New Financial Institution for counterparty will be created along with its identifier, description and role in DMP

    Given I assign "COUNTERPARTYFILE.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "COUNTERPARTY_NAME" to variable "COUNTERPARTY_NAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "BROKER_TICKER" to variable "BROKER_TICKER"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "TRD_COUNTERPARTY" to variable "TRD_COUNTERPARTY"

    And I execute below query
    """
    UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
    SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE}','${BROKER_TICKER}','${TRD_COUNTERPARTY}')AND end_tms IS NULL );
    COMMIT
    """

    And I execute below query
    """
    UPDATE ft_T_fins set end_tms = sysdate where inst_mnem in (SELECT inst_mnem FROM FT_T_FINS
    WHERE INST_NME = '${COUNTERPARTY_NAME}'
    AND DATA_SRC_ID = 'BRS'
    AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY' AND END_TMS IS NULL);
    COMMIT
    """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |


    Then I expect value of column "FINS_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FIID_COUNT" in the below SQL query equals to "3":
        """
        SELECT COUNT(*) AS FIID_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND END_TMS IS NULL)
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FIID_CNTCDE_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_CNTCDE_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND END_TMS IS NULL)
        AND FINS_ID = '${COUNTERPARTY_CDE}'
        AND FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
         AND END_TMS IS NULL
        """
    Then I expect value of column "FIID_BROKRTICKR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_BROKRTICKR_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND END_TMS IS NULL)
        AND FINS_ID = '${BROKER_TICKER}'
        AND FINS_ID_CTXT_TYP = 'BRSBROKRTICKR'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """
    Then I expect value of column "FIID_TRDCNTCDE_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_TRDCNTCDE_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND END_TMS IS NULL)
        AND FINS_ID = '${TRD_COUNTERPARTY}'
        AND FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """
    Then I expect value of column "FIDE_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIDE_COUNT FROM FT_T_FIDE
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND END_TMS IS NULL)
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """
    Then I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND END_TMS IS NULL)
        AND FINSRL_TYP = 'TRAGENT'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """
    Then I expect value of column "FINR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT FROM FT_T_FINR
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND END_TMS IS NULL)
        AND FINSRL_TYP = 'BROKER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """


  Scenario: TC_2: Counterparty file load with BROKER_ISSUER

  New Financial Institution for counterparty will be created along with its identifier, description and role in DMP.
  New Financial Institution for issuer will be created. Also, Relationship between counterparty and brokerissuer is created.

    Given I assign "CP_WITHBROKERISSUER.xml" to variable "INPUT_FILENAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "COUNTERPARTY_NAME" to variable "COUNTERPARTY_NAME"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "COUNTERPARTY_CODE" to variable "COUNTERPARTY_CDE"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "BROKER_TICKER" to variable "BROKER_TICKER"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "TRD_COUNTERPARTY" to variable "TRD_COUNTERPARTY"
    Then I extract value from the xml file "${testdata.path}/testdata/${INPUT_FILENAME}" with tagName "BROKER_ISSUER" to variable "BROKER_ISSUER"


    And I execute below query
       """
        UPDATE FT_T_FIID SET START_TMS=SYSDATE-1, END_TMS=SYSDATE, LAST_CHG_TMS=SYSDATE WHERE INST_MNEM IN (
        SELECT INST_MNEM FROM FT_T_FIID WHERE FINS_ID IN('${COUNTERPARTY_CDE}','${BROKER_TICKER}','${TRD_COUNTERPARTY}','${BROKER_ISSUER}')AND end_tms IS NULL );
        COMMIT
        """
    And I execute below query
       """
        UPDATE ft_T_fins set end_tms = sysdate where inst_mnem in (SELECT inst_mnem FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY' AND END_TMS IS NULL);
        COMMIT
       """

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I expect value of column "FINS_COUNTRPRTY_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_COUNTRPRTY_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND PREF_FINS_ID = '${COUNTERPARTY_CDE}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FINS_ISSR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINS_ISSR_COUNT FROM FT_T_FINS
        WHERE INST_NME = '${COUNTERPARTY_NAME}'
        AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND PREF_FINS_ID = '${BROKER_ISSUER}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FIID_COUNTRPRTY_COUNT" in the below SQL query equals to "3":
        """
        SELECT COUNT(*) AS FIID_COUNTRPRTY_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FIID_ISSRID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_ISSRID_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND PREF_FINS_ID = '${BROKER_ISSUER}' AND END_TMS IS NULL)
        AND FINS_ID = '${BROKER_ISSUER}'
        AND FINS_ID_CTXT_TYP = 'BRSISSRID'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FIID_CNTCDE_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_CNTCDE_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND FINS_ID = '${COUNTERPARTY_CDE}'
        AND FINS_ID_CTXT_TYP = 'BRSCNTCDE'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FIID_BROKRTICKR_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_BROKRTICKR_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND FINS_ID = '${BROKER_TICKER}'
        AND FINS_ID_CTXT_TYP = 'BRSBROKRTICKR'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """
    Then I expect value of column "FIID_TRDCNTCDE_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIID_TRDCNTCDE_COUNT FROM FT_T_FIID
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND FINS_ID = '${TRD_COUNTERPARTY}'
        AND FINS_ID_CTXT_TYP = 'BRSTRDCNTCDE'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """
    Then I expect value of column "FIDE_CNTCDE_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FIDE_CNTCDE_COUNT FROM FT_T_FIDE
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND INST_DESC = '${COUNTERPARTY_NAME}'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FINR_COUNT_EXCBROKR" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FINR_COUNT_EXCBROKR FROM FT_T_FINR
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND FINSRL_TYP = 'EXBROKER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FINR_COUNT_BROKER" in the below SQL query equals to "0":
        """
        SELECT COUNT(*) AS FINR_COUNT_BROKER FROM FT_T_FINR
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND FINSRL_TYP = 'BROKER'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

    Then I expect value of column "FFRL_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FFRL_COUNT FROM FT_T_FFRL
        WHERE INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSCNTCDE'
                         AND PREF_FINS_ID = '${COUNTERPARTY_CDE}' AND END_TMS IS NULL)
        AND PRNT_INST_MNEM = (SELECT INST_MNEM FROM FT_T_FINS WHERE INST_NME = '${COUNTERPARTY_NAME}' AND PREF_FINS_ID_CTXT_TYP = 'BRSISSRID'
                         AND PREF_FINS_ID = '${BROKER_ISSUER}' AND END_TMS IS NULL)
        AND REL_TYP = 'PRIMBRKR'
        AND DATA_SRC_ID = 'BRS'
        AND LAST_CHG_USR_ID = 'EIS_BRS_DMP_COUNTERPARTY'
        AND END_TMS IS NULL
        """

  Scenario: TC_3: Counterparty file load without COUNTERPARTY_CODE
  Since counterparty code is not present, message will fail.

    Given I assign "CP_WITHOUTCNTCODE.xml" to variable "INPUT_FILENAME"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "NTEL_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS NTEL_COUNT FROM FT_T_NTEL
        WHERE  NOTFCN_STAT_TYP = 'OPEN'
        AND LAST_CHG_USR_ID = 'EIS_MT_BRS_COUNTERPARTY'
        AND LAST_CHG_TRN_ID IN (SELECT TRN_ID FROM FT_T_TRID WHERE JOB_ID = '${JOB_ID}')
        AND PARM_VAL_TXT = 'User defined Error thrown! . COUNTERPARTY_CODE is not present in the input record.'
        """

  Scenario: TC_4: Counterparty file load with BROKER_TYP = GEN
  The record will be filtered and not saved.

    Given I assign "CP_WITHGENBROKERTYP.xml" to variable "INPUT_FILENAME"

    When I copy files below from local folder "${testdata.path}/testdata" to the host "dmp.ssh.inbound" folder "${dmp.ssh.inbound.path}":
      | ${INPUT_FILENAME} |

    And I process files with below parameters and wait for the job to be completed
      | FILE_PATTERN  | ${INPUT_FILENAME}       |
      | MESSAGE_TYPE  | EIS_MT_BRS_COUNTERPARTY |
      | BUSINESS_FEED |                         |

    Then I extract new job id from jblg table into a variable "JOB_ID"

    Then I expect value of column "FILTERED_TRID_COUNT" in the below SQL query equals to "1":
        """
        SELECT COUNT(*) AS FILTERED_TRID_COUNT FROM FT_T_TRID
        WHERE JOB_ID = '${JOB_ID}'
        AND TRN_USR_STAT_TYP = 'FILTERED'
        AND INPUT_MSG_TYP = 'EIS_MT_BRS_COUNTERPARTY'
        """
