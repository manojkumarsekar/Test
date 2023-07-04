#https://jira.pruconnect.net/browse/EISDEV-6983
#https://collaborate.pruconnect.net/display/EISPRM/Portfolio+Integration
#https://collaborate.pruconnect.net/display/EISTOMR4/Portfolio+Integration

# ===================================================================================================================================================================================
# Date            JIRA        Comments
# ===================================================================================================================================================================================
# 14/12/2020      EISDEV-6983    Portfolio Integration
# 29/01/2021      EISDEV-7332    Store Portfolio additional attributes from Fundipedia
# 02/03/2021      EISDEV-7395    Store Portfolio additional attributes(Financial Institution and IDMV) from Fundipedia
# 18/03/2021      EISDEV-7451    Custodian value not displayed in UI and IDMV lookup change to description instead of name
# 23/03/2021      EISDEV-7458    Disable drools for MainEntityID and MainEntityIdCtxtTyp and move to java rule to suppress additional changes shown for those 2 fields on UI
# =========== ========================================================================================================================================================================


@dmp_regression_integrationtest @gc_interface_portfolio @gc_interface_fundipedia
@eisdev_6983 @eisdev_6983_crtsid_present @eisdev_7332 @eisdev_7395 @eisdev_7447 @eisdev_7451 @eisdev_7458

Feature: Load Portfolio for CRTS ID already present in GS and verify data points

  This feature tests the below scenarios
  1. The CRTS ID received is present in GS. Entity status type = Active.
  2. The CRTS ID received is present in GS. Entity status type = Archived.
  3. The CRTS ID received is present in GS. Entity status type = Deleted.
  4. The CRTS ID received is present in GS. Entity status type = Created.

  Scenario: Initialize all the variables and setup data

    Given I assign "tests/test-data/dmp-interfaces/Fundipedia/EISDEV-6983" to variable "testdata.path"
    And I assign "Portfolio_CRTS_ID_Present.xml" to variable "INPUT_FILE_NAME"

    And I execute below query to "Activate any Portfolio that might have been inactivated"
    """
    ${testdata.path}/sql/ActivateInactivePortfolio.sql
    """

    And I execute below query to "set up FPRO"
	"""
    update ft_t_fpro set FINS_PRO_ID = 'testautomation@eastspring.com', PRO_DESIGNATION_TXT = 'PM' where fpro_oid = 'Ec6Q58Mj81';
    commit
    """

  Scenario: Load the Portfolio class file

    When I process "${testdata.path}/testdata/${INPUT_FILE_NAME}" file with below parameters
      | FILE_PATTERN  | ${INPUT_FILE_NAME}                   |
      | MESSAGE_TYPE  | EIS_MT_FUNDIPEDIA_DMP_PORTFOLIO_INTG |
      | BUSINESS_FEED |                                      |

    Then I expect workflow is processed in DMP with total record count as "4"
    And I expect workflow is processed in DMP with success record count as "3"
    And I expect workflow is processed in DMP with filtered record count as "1"


  Scenario Outline: Verify the account status for each of the record

    Then I expect value of column "ACCOUNT_STATUS" in the below SQL query equals to "<Acct_Status>":
    """
    SELECT ACCT_STAT_TYP AS ACCOUNT_STATUS
    FROM FT_T_ACCT
    WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = '<Crtsid>')
    """

    Examples:
      | Acct_Status | Crtsid |
      | OPEN        | ASUDPF |
      | INACTIVE    | ALGEMD |
      | INACTIVE    | ALGENF |

  Scenario Outline: Verify the values saved in ACID table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT ACCT_ALT_ID AS <Column> FROM FT_T_ACID
    WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = 'ASUDPF')
    AND ACCT_ID_CTXT_TYP = '<ID_Ctxt_Type>'
    """

    Examples:
      | Column             | ID_Ctxt_Type  | Value          |
      | CrtsID             | CRTSID        | ASUDPF         |
      | PortfolioID        | FPORTID       | 4              |
      | IrpID              | IRPID         | ASUDPF         |
      | MfundID            | MFUNDID       | MFUND_ASUDPF   |
      | RDMID              | RDMID         | RDM_ASUDPF     |
      | TstarID            | TSTARID       | TSTAR_ASUDPF   |
      | KoreaID            | KOREAID       | KOREA_ASUDPF   |
      | ThaID              | THAIID        | THAI_ASUDPF    |
      | HiportSuffixID     | HIPORTSFXCD   | SUFFIX_ASUDPF  |
      | UBNID              | UNIBUSNUM     | UBN_ASUDPF     |
      | SITCAID            | SITCAFNDID    | SITCA_ASUDPF   |
      | TWALTPortfolioCode | ALTCRTSID     | ALTCRTS_ASUDPF |
      | DMSID              | DMSID         | DMSID_ASUDPF   |
      | PortfolioISIN      | PORTFOLIOISIN | SG9999002828   |

  Scenario Outline: Verify the values saved in ACCT table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT <DBColumnName> AS <Column> FROM FT_T_ACCT
    WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = 'ASUDPF')
    """

    Examples:
      | Column              | DBColumnName  | Value                                                    |
      | PortfolioName       | ACCT_NME      | EASTSPRING INV UT DRAGON PEA                             |
      | PortfolioLegalName  | ACCT_DESC     | EASTSPRING INVESTMENTS UNIT TRUSTS - DRAGON PEACOCK FUND |
      | AccountStatus       | ACCT_STAT_TYP | OPEN                                                     |
      | BKID                | BK_ID         | EIS                                                      |
      | OrgID               | ORG_ID        | EIS                                                      |
      | AccountType         | ACTP_ACCT_TYP | FUND                                                     |
      | ACTPOrgID           | ACTP_ORG_ID   | EIS                                                      |
      | DataStatType        | DATA_STAT_TYP | ACTIVE                                                   |
      | DataSrcID           | DATA_SRC_ID   | FPEDIA                                                   |
      | PortfolioLaunchDate | ACCT_OPEN_DTE | 2004-06-18 00:00:00                                      |
      | FundCategory        | ACCT_PURP_TYP | Model                                                    |
      | FundType            | ACCT_SUB_TYP  | DIRECT                                                   |


  Scenario Outline: Verify the values saved in FNCH table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT <DBColumnName> AS <Column> FROM FT_T_FNCH
    WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = 'ASUDPF')
    """

    Examples:
      | Column              | DBColumnName       | Value               |
      | PortfolioCurrency   | FUND_CURR_CDE      | SGD                 |
      | PortfolioLaunchDate | FUND_INCEPTION_DTE | 2004-06-18 00:00:00 |
      | InvestmentStrategy  | FND_CLFS_TYP       | F                   |

  Scenario Outline: Verify the values saved in ACST table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT STAT_CHAR_VAL_TXT AS <Column> FROM FT_T_ACST
    WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = 'ASUDPF')
    AND STAT_DEF_ID = '<StatDefID>'
    """

    Examples:
      | Column      | Value  | StatDefID |
      | FundId      | 22     | FFUNDID   |
      | BNPPerfFlag | N      | PORTFLAG  |
      | Atentyp     | N      | NPP       |
      | SUNFlag     | N      | ESUNPLTF  |
      | SSHFlag     | Y      | SSHFLAG   |
      | PPMAFlag    | Y      | PPMFLAG   |
      | QFFIFlag    | N      | QFIIFLAG  |
      | STCFlag     | N      | STCFLAG   |
      | FINIFlag    | Y      | FINIFLAG  |
      | USPersonInd | N      | USPERSON  |

  Scenario Outline: Verify the values saved in ACGU table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT GU_ID AS <Column> FROM FT_T_ACGU
    WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID
    WHERE ACCT_ALT_ID = 'ASUDPF')
    AND ACCT_GU_PURP_TYP = '<Purptype>'
    AND GU_TYP = '<GU_TYP>' AND GU_CNT = '1'
    """

    Examples:
      | Column                 | Value    | Purptype | GU_TYP  |
      | PortfolioExtensionGUID | SG       | INVLOCTN | COUNTRY |
      | PortfolioDomicile      | SG       | DOMICILE | COUNTRY |
      | FundRegion             | NONLATAM | POS_SEGR | REGION  |


  Scenario Outline: Verify the values saved in FRAP table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT FINS.INST_NME AS <Column>
    FROM FT_T_FRAP FRAP, FT_T_FINR FINR, FT_T_FINS FINS WHERE
    FINS.INST_MNEM=FINR.INST_MNEM AND FINS.END_TMS IS NULL AND
    FINR.FINSRL_TYP=FRAP.FINSRL_TYP AND FINR.INST_MNEM=FRAP.INST_MNEM AND FINR.END_TMS IS NULL AND
    FRAP.FINSRL_TYP ='<FINSRL_TYP>' AND FRAP.END_TMS IS NULL AND
    FRAP.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '<ACCT_ALT_ID>' AND END_TMS IS NULL)
    """

    Examples:
      | ACCT_ALT_ID | FINSRL_TYP | Column                | Value                                                       |
      | ASUDPF      | INVMGR     | Invmgr                | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED                  |
      | ASUDPF      | FMC        | FundManagementCompany | EASTSPRING INVESTMENTS (LUXEMBOURG) S.A.                    |
      | ASUDPF      | SBINVMGR   | SubInvestmentManager  | EASTSPRING INVESTMENTS (SINGAPORE) LIMITED                  |
      | ASUDPF      | TRUSTEE    | Trustee               | DEUTSCHE TRUSTEES MALAYSIA BERHAD                           |
      | ASUDPF      | ADVISOR    | Advisor               | EASTSPRING INVESTMENT MANAGEMENT (SHANGHAI) COMPANY LIMITED |
      | ASUDPF      | ACCTAGNT   | AccountingAgent       | STANDARD CHARTERED BANK INDONESIA                           |
      | ASUDPF      | VALAGENT   | ValuationAgent        | Kasikorn Bank of Thailand                                   |
      | ASUDPF      | REGSTR     | Registrar             | HSBC INSTITUTIONAL TRUST SERVICES SINGAPORE LTD             |
      | ASUDPF      | SBRGSTAR   | SubRegistrar          | SSB HONG KONG                                               |
      | ASUDPF      | TRAGENT    | TransferAgent         | TA - STATE STREET DUBLIN                                    |
      | ASUDPF      | SBTRFAGT   | SubTransferAgent      | BNP PARIBAS LUXEMBOURG                                      |
      | ASUDPF      | GLBDISTB   | GlobalDistributor     | CITIBANK HONGKONG                                           |
      | ASUDPF      | FUNDADM    | FundAdministrator     | CITIBANK MALAYSIA                                           |
      | ASUDPF      | PRUGROUP   | PruGroupLEName        | SQUIRE CAPITAL I LLC                                        |
      | ASUDPF      | NONGROUP   | NonGroupLEName        | PRUDENTIAL (US HOLDCO 1) LIMITED                            |
      | ASUDPF      | SIDIDTAG   | SIDNumber             | Asian Equity Portfolio  (SID - OTF010153613607)             |
      | ASUDPF      | CUSTDIAN   | Custodian             | BNP SECURITY SERVICES                                       |


  Scenario Outline: Verify the values saved in ACDE table

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT <ColumnName> AS <Column>
    FROM FT_T_ACDE WHERE ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ASUDPF'AND END_TMS IS NULL)
    AND DESC_USAGE_TYP = '<DescUsageTyp>'
    AND NLS_CDE = '<NlsCde>' AND END_TMS IS NULL
    """

    Examples:
      | Column                                 | ColumnName | Value                        | DescUsageTyp | NlsCde   |
      | TWPortfolioShortnameTraditionalchinese | ACCT_NME   | 收益優化傘型證券投資信託基金之南非幣保本證券投資信託基金 | PRIMARY      | CHINESEM |
      | TWPortfoliolongnameTraditionalchinese  | ACCT_DESC  | 收益優化傘型證券投資信託基金之南非幣保本證券投資信託基金 | PRIMARY      | CHINESEM |

  Scenario: Verify Benchmark & DOP relation

    Then I expect value of column "BNCH_RDMCODE" in the below SQL query equals to "OTJPMASG":
    """
    SELECT BNID.BNCHMRK_ID AS BNCH_RDMCODE FROM FT_T_ABMR ABMR, FT_T_BNID BNID WHERE ABMR.BNCH_OID = BNID.BNCH_OID
    AND ABMR.RL_TYP = 'PRIMARY' AND BNID.BNCHMRK_ID_CTXT_TYP = 'RDMCODE' AND ABMR.ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ASUDPF' AND END_TMS IS NULL)
    """

    Then I expect value of column "DOP_CRTSID" in the below SQL query equals to "ASUDPF":
    """
    SELECT ACID.ACCT_ALT_ID AS DOP_CRTSID FROM FT_T_ACCR ACCR, FT_T_ACID ACID WHERE ACCR.ACCT_ID = ACID.ACCT_ID
    AND ACCR.RL_TYP = 'DOPAPPRT' AND ACID.ACCT_ID_CTXT_TYP = 'CRTSID' AND ACCR.ACCT_ID IN
    (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ASUDPF' AND END_TMS IS NULL)
    AND ACCR.END_TMS IS NULL AND ACID.END_TMS IS NULL
    """

  Scenario Outline: Verify DOP Target Percent, Upper and Lower Tolerance

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT <ColumnName> AS <Column>
    FROM FT_T_FNCH FNCH, FT_T_FNVS FNVS, FT_T_FNVD FNVD WHERE FNCH.FNCH_OID = FNVS.FNCH_OID AND FNVS.FNVS_OID = FNVD.FNVS_OID
    AND FNCH.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = 'ASUDPF' AND END_TMS IS NULL)
    AND FNCH.END_TMS IS NULL AND FNVS.END_TMS IS NULL AND FNVD.END_TMS IS NULL AND INVEST_CRIT_DTL_NUM = 1
    """

    Examples:
      | Column            | ColumnName      | Value |
      | DOPTargetPercent  | TRGT_ALLOC_CPCT | .09   |
      | DOPLowerTolerance | MIN_SHR_CAMT    | .01   |
      | DOPUpperTolerance | MAX_SHR_CAMT    | .02   |


  Scenario Outline: Verify the values saved in ACCL table using INCL lookup

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT INCL.CL_NME AS <Column>
    FROM FT_T_ACCL ACCL, FT_T_INCL INCL WHERE
    INCL.CLSF_OID=ACCL.CLSF_OID  AND INCL.INDUS_CL_SET_ID=ACCL.INDUS_CL_SET_ID AND INCL.END_TMS IS NULL AND
    ACCL.INDUS_CL_SET_ID='<INDUS_CL_SET_ID>' AND ACCL.END_TMS IS NULL AND
    ACCL.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '<ACCT_ALT_ID>')
    """
    Examples:
      | ACCT_ALT_ID | INDUS_CL_SET_ID | Column                 | Value                                |
      | ASUDPF      | MASCATGY        | MASCategory            | FUNDS UNDER DISCRETIONARY MANAGEMENT |
      | ASUDPF      | INVSTEAM        | InvestmentTeam         | EQUITY                               |
      | ASUDPF      | FNDPLTFM        | FundPlatform           | UNIT TRUST                           |
      | ASUDPF      | FNDVHCLTYP      | FundVehicletype        | Corporate                            |
      | ASUDPF      | LEVRDISC        | LEVRDiscretion         | Sole                                 |
      | ASUDPF      | LEINDISC        | LEInvestmentDiscretion | Sole                                 |
      | ASUDPF      | BRSLEGST        | BRSLETicker            | EQFEEDER                             |
      | ASUDPF      | BRSINVTP        | BRSBLTicker            | ES-MUT                               |


  Scenario Outline: Verify the values saved in ACTA table using FPRO lookup

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT FPRO.FINS_PRO_ID AS <Column>
    FROM FT_T_ACTA ACTA, FT_T_FPRO FPRO WHERE
    FPRO.PRO_DESIGNATION_TXT='<PRO_DESIGNATION_TXT>' AND FPRO.FPRO_OID=ACTA.FPRO_OID AND FPRO.END_TMS IS NULL AND
    ACTA.CONTCT_RL_TYP='<CONTCT_RL_TYP>' AND ACTA.END_TMS IS NULL AND
    ACTA.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '<ACCT_ALT_ID>')
    """

    Examples:
      | ACCT_ALT_ID | CONTCT_RL_TYP        | PRO_DESIGNATION_TXT | Column                      | Value                         |
      | ASUDPF      | PORTFOLIO_MANAGER1   | PM                  | PortfolioManager1Email      | testautomation@eastspring.com |
      | ASUDPF      | PORTFOLIO_MANAGER2   | PM                  | PortfolioManager2Email      | testautomation@eastspring.com |
      | ASUDPF      | BACKUP_PORTFOLIO_MGR | PM                  | BackupPortfolioManagerEmail | testautomation@eastspring.com |


  Scenario Outline: Verify the values saved in CACR table using CUID lookup

    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
    """
    SELECT CUID.CUSTOMER_ID AS <Column>
    FROM FT_T_CACR CACR, FT_T_CUID CUID WHERE
    CUID.CST_ID=CACR.CST_ID  AND CUID.CST_ID_CTXT_TYP='<CST_ID_CTXT_TYP>' AND CUID.END_TMS IS NULL AND
    CACR.RL_TYP='<RL_TYP>' AND CACR.END_TMS IS NULL AND
    CACR.ACCT_ID IN (SELECT ACCT_ID FROM FT_T_ACID WHERE ACCT_ALT_ID = '<ACCT_ALT_ID>')

    """
    Examples:
      | ACCT_ALT_ID | RL_TYP | CST_ID_CTXT_TYP | Column     | Value                                          |
      | ASUDPF      | CLIENT | INHOUSE         | Clientname | Prudential Assurance Company Limited – UK Life |


#  Scenario Outline: Verify the values saved in AISR table using ISIN and Portfolio lookup
#
#    Then I expect value of column "<Column>" in the below SQL query equals to "<Value>":
#    """
#    SELECT ISID.ISS_ID AS <Column>
#    FROM FT_T_AISR AISR, FT_T_ISID ISID
#    WHERE ISID.INSTR_ID = AISR.INSTR_ID AND ISID.ID_CTXT_TYP='<ID_CTXT_TYP>' AND ISID.END_TMS IS NULL
#    AND   AISR.ACCT_ISSU_RL_TYP ='<ACCT_ISSU_RL_TYP>'
#    AND   AISR.END_TMS IS NULL
#    AND   AISR.ACCT_ID IN (SELECT acct_id FROM ft_t_acid
#    WHERE acct_alt_id = '<ACCT_ALT_ID>'
#    AND   acct_id_ctxt_typ='<ACCT_ID_CTXT_TYP>'
#    AND   end_tms IS NULL)
#    """
#
#    Examples:
#      | ACCT_ALT_ID | ACCT_ID_CTXT_TYP | ACCT_ISSU_RL_TYP | ID_CTXT_TYP | Column        | Value        |
#      | ASUDPF      | CRTSID           | AUT              | ISIN        | PortfolioISIN | SG9999002828 |

  Scenario:Re-set FPRO

    Given I execute below query to "reset FPRO"
	"""
  update ft_t_fpro set FINS_PRO_ID = 'azhar.arayilakath@eastspring.com' where fpro_oid = 'Ec6Q58Mj81';
  commit
  """