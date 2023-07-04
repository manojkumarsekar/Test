package com.eastspring.tom.cart.dmp.pages.customer.master;

public class CustomerMasterOR {

    private CustomerMasterOR() {

    }
    //Locators

    //region Account Master OR

    public static final String ACCOUNTMASTER_PORTFOLIONAME_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioLongName']//input";
    public static final String ACCOUNTMASTER_PORTFOLIOLEGALNAME_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioLegalName']//textarea";
    public static final String ACCOUNTMASTER_INCEPTIONDATE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioOpenDate']//input";
    public static final String ACCOUNTMASTER_ACTIVEFLAG_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioActiveFlag']//input";
    public static final String ACCOUNTMASTER_PORTFOLIODOMICILE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioCountryOfDomicile']//input";
    public static final String ACCOUNTMASTER_INVESTMENT_TEAM_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioInvestmentTeam']//input";
    public static final String ACCOUNTMASTER_BASECCY_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioCurrency']//input";
    public static final String ACCOUNTMASTER_PORTFOLIOLEI_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioLEI']//input";
    public static final String ACCOUNTMASTER_PROCESSED_UNPROCESSED_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioProcessedNonPorcessedFlag']//input";
    public static final String ACCOUNTMASTER_MASTERPORTFOLIONAME_SEARCHBUTTON = "xpath://*[contains(@id,'EISMasterRoleTypeRel')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_PORTMANAGER1_SEARCHBUTTON = "xpath://*[contains(@id,'EISPortfolioManager1')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_PORTMANAGER2_SEARCHBUTTON = "xpath://*[contains(@id,'EISPortfolioManager2')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_BACKUP_PM_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioManagers.EISPortfolioBackupManager.FinancialServicesProfessional.FinancialPro.EISFinsServProId']//input";
    public static final String ACCOUNTMASTER_FUNDCATEGORY_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioFundDetails.EISPortfolioFundCategory']//input";
    public static final String ACCOUNTMASTER_FUNDPLATFORM_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioFundDetails.EISPortfolioFundPlatform']//input";
    public static final String ACCOUNTMASTER_FUNDTYPE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioFundDetails.EISPortfolioFundType']//input";
    public static final String ACCOUNTMASTER_INVESTMENT_STRATEGY_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioFundDetails.EISPortfolioInvStrategy']//input";
    public static final String ACCOUNTMASTER_MNG_MOTHERFUND_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioFundDetails.EISPortfolioMotherFund']//input";
    public static final String ACCOUNTMASTER_FUND_REGION_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioFundDetails.EISPortfolioFundRegion']//input";
    public static final String ACCOUNTMASTER_SUBPORT_SECURITYID_SEARCHBUTTON = "xpath://*[contains(@id,'EISPortfolioClientSecID1')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_UNIT_TRUST_SECURITYID_SEARCHBUTTON = "xpath://*[contains(@id,'EISPortfolioClientSecID2')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_CLONE_PORTFOLIONAME_SEARCHBUTTON = "xpath://*[contains(@id,'EISAccountToModelPortfolioRelation')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_RDMPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLegacyIdentifiers.EISPortfolioRDMCode']//input";
    public static final String ACCOUNTMASTER_CRTSPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLegacyIdentifiers.EISPortfolioCRTSCode']//input";
    public static final String ACCOUNTMASTER_HIPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLegacyIdentifiers.EISPortfolioHIPORTCode']//input";
    public static final String ACCOUNTMASTER_SYLVANPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLegacyIdentifiers.EISPortfolioSYLVANCode']//input";
    public static final String ACCOUNTMASTER_EISPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLegacyIdentifiers.EISPortfolioCode']//input";
    public static final String ACCOUNTMASTER_ALT_CRTSID_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLegacyIdentifiers.EISPortfolioALTCRTSID']//input";
    public static final String ACCOUNTMASTER_TSTARPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLBUIdentifiers.EISPortfolioTSTARCode']//input";
    public static final String ACCOUNTMASTER_DBANKPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLBUIdentifiers.EISPortfolioDBANKCode']//input";
    public static final String ACCOUNTMASTER_MFUNDPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLBUIdentifiers.EISPortfolioMFUNDCode']//input";
    public static final String ACCOUNTMASTER_DMSPORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLBUIdentifiers.EISPortfolioDMSCode']//input";
    public static final String ACCOUNTMASTER_KOREAMD_PORTCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLBUIdentifiers.EISPortfolioITraderCode']//input";
    public static final String ACCOUNTMASTER_BRS_PORTID_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioXReference.EISPortfolioBRSFundID']//input";
    public static final String ACCOUNTMASTER_BRS_LEGALENTITY_TICKER_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioXReference.EISBRSLegalStructureLETICKER']//input";
    public static final String ACCOUNTMASTER_BRS_BUSINESSLINE_TICKER_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioXReference.EISBRSInvestmentTypeBLTICKER']//input";
    public static final String ACCOUNTMASTER_BNP_PORTID_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioXReference.EISPortfolioBNPFundID']//input";
    public static final String ACCOUNTMASTER_IRPCODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioXReference.EISPortfolioIRPID']//input";
    public static final String ACCOUNTMASTER_FUND_MGTCOMP_SEARCHBUTTON = "xpath://*[contains(@id,'EISPortfolioFundMgmntCompany')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_INVSTMGR_SEARCH_BUTTON = "xpath://*[contains(@id,'EISPortfolioInvstMgr')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_INVSTMGR_LEV3_LE_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISPorfolioParties.EISInvstAdvLvl3LENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_INVSTMGR_LEV4_LE_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISPorfolioParties.EISInvstAdvLvl4LENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_INVSTMGR_LEV3_LE_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISPorfolioParties.EISInvstAdvLvl3LENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_INVSTMGR_LEV4_LE_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISPorfolioParties.EISInvstAdvLvl4LENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_SUB_INVESTMENT_MANAGER_SEARCH_BUTTON = "xpath://*[contains(@id,'EISPortfolioSubInvstMgr')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_INVST_MANAGER_LOCATION_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioLoc']//input";
    public static final String ACCOUNTMASTER_ADVISOR_SEARCH_BUTTON = "xpath://*[contains(@id,'EISPortfolioAdvisor')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_TRUSTEE_LOCATOR = "xpath://*[contains(@id,'EISPortfolioTrustee')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_CUSTODIAN_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioCustodian.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_CUSTODIAN_ACCTNO_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioCustodianAccNo']//input";
    public static final String ACCOUNTMASTER_ACCOUNTING_AGENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioActgAgent.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_VALNAGENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioValuationAgent.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_REGISTRAR_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioRegistrar.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_SUBREGISTRAR_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioSubRegistrar.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_TRANSFER_AGENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioTransferAgent.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_SUBTRANSFER_AGENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioSubTransferAgent.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_GLOBAL_DISTRIBUTOR_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioGlobalDistributor.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_FUND_ADMINISTRATOR_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioFundAdmin.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName']//input";
    public static final String ACCOUNTMASTER_CLIENT_NAME_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPorfolioParties.EISPortfolioClient.Customer.AllCustomerIdentifiers.AllIdentifiersCustomerId']//input";
    public static final String ACCOUNTMASTER_MAS_CATEGORY_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioRegulatory.EISPortfolioMASCategory']//input";
    public static final String ACCOUNTMASTER_BNP_PORTFOLIO_PERMNCE_FLAG_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDetails.EISPortfolioPerformanceFlag']//input";
    public static final String ACCOUNTMASTER_THAILAND_PORTFOLIO_CODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLBUIdentifiers.EISPortfolioThailandCode']//input";
    public static final String ACCOUNTMASTER_HIPORT_SUFFIX_CODE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioLBUIdentifiers.EISPortfolioHIPORTSFXCD']//input";
    public static final String ACCOUNTMASTER_PRU_GROUP_LE_NAME_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISSSDRDetails.EISPruGroupLENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_NON_GROUP_LE_NAME_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISSSDRDetails.EISNonGroupLENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_SID_NAME_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISSSDRDetails.EISSIDNmeOrgChrtRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_QFII_CN_FLAG_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISQFIICNFlag']//input";
    public static final String ACCOUNTMASTER_STC_VN_FLAG_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISSTCVNFlag']//input";
    public static final String ACCOUNTMASTER_INVESTMENT_DISCRETION_LE_INVESTMENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISInvestmentDiscretionLEInvestmentDiscretion']//input";
    public static final String ACCOUNTMASTER_FINI_TAIWAN_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISFINITaiwanFlag']//input";
    public static final String ACCOUNTMASTER_PPMA_FLAG_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISPPMAFlag']//input";
    public static final String ACCOUNTMASTER_SSH_FLAG_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISSSHFlag']//input";
    public static final String ACCOUNTMASTER_FUND_VEHICLE_TYPE_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISFundVehicleType']//input";
    public static final String ACCOUNTMASTER_INVESTMENT_DISCRETION_LE_VR_LOCATOR = "xpath://*[@id='EISAccountMaster.EISSSDRDetails.EISInvestmentDiscretionLEVRDiscretion']//input";
    public static final String ACCOUNTMASTER_PRU_GROUP_LE_NAME_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISSSDRDetails.EISPruGroupLENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_NON_GROUP_LE_NAME_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISSSDRDetails.EISNonGroupLENmeRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_SID_NAME_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISSSDRDetails.EISSIDNmeOrgChrtRel.FinancialInstitution.FinancialInstitutionDetails.FinancialInstitutionName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_ESI_PRIM_BNCHMRK_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterPrimaryBNCH.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_ESI_SEC_BNCHMRK_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterSecondary.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_BNP_L1_PRMY_BNCHMRK_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterBNPPrimaryL1.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_BNP_L1_SEC_BNCHMRK_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterBNPSecondaryL1.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_BNP_L3_PRMY_BNCHMRK_LOCATOR = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterBNPPrimaryL3.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input[@type='text']";
    public static final String ACCOUNTMASTER_ESI_PRIM_BNCHMRK_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterPrimaryBNCH.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_ESI_SEC_BNCHMRK_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterSecondary.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_BNP_L1_PRMY_BNCHMRK_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterBNPPrimaryL1.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_BNP_L1_SEC_BNCHMRK_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterBNPSecondaryL1.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_BNP_L3_PRMY_BNCHMRK_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISPortfolioBenchmarkDetails.EISAccountMasterBNPPrimaryL3.Benchmark.EISBenchmarkDefinition.EISBenchmarkName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_PORTFOLIO_ISIN_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioXReference.EISPortfolioISIN']//input";
    public static final String ACCOUNTMASTER_DOP_BM_ADD_LOCATOR = "xpath:(//*[contains(@class,'v-slot-gsGreenIcon')]/div[@role='button'])[2]";
    public static final String ACCOUNTMASTER_DOP_EIS_BM_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDOPDRFTBNCHDetails.EISAccountMasterDOPDRFTBNCH.Benchmark.EISBenchmarkDefinition.EISBenchmarkName']//input";
    public static final String ACCOUNTMASTER_DOP_EIS_BM_SEARCH_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDOPDRFTBNCHDetails.EISAccountMasterDOPDRFTBNCH.Benchmark.EISBenchmarkDefinition.EISBenchmarkName']//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_DOP_ALADDIN_BM_LOCATOR = "xpath://*[@id='EISAccountMaster.EISPortfolioDOPDRFTBNCHDetails.EISAccountMasterDOPDRFTBNCH.Benchmark.EISBenchmarkDefinition.EISBenchmarkID.EISBenchmarkAlladinCode']//input";
    public static final String ACCOUNTMASTER_DOP_VS_ACTUAL_PORTFOLIO_LOCATOR = "xpath://*[@id='EISAccountMaster.EISDOPPortfolioCashFlowDetails.EISDOPPortfolioToActualPortfolioLink.EISAccountMaster.EISPortfolioDetails.EISPortfolioLongName']//input";
    public static final String ACCOUNTMASTER_DOP_VS_ACTUAL_PORTFOLIO_SEARCH_BUTTON = "xpath://*[contains(@id,'EISAccountMaster.EISDOPPortfolioCashFlowDetails.EISDOPPortfolioToActualPortfolioLink.EISAccountMaster.EISPortfolioDetails.EISPortfolioLongName')]//input/../../div[@role='button'][1]";
    public static final String ACCOUNTMASTER_TARGET_PERCENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISDOPPortfolioCashFlowDetails.EISDOPCFETarget']//input";
    public static final String ACCOUNTMASTER_LOWER_TOLERANCE_PERCENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISDOPPortfolioCashFlowDetails.EISDOPCFELowerTolerance']//input";
    public static final String ACCOUNTMASTER_UPPER_TOLERANCE_PERCENT_LOCATOR = "xpath://*[@id='EISAccountMaster.EISDOPPortfolioCashFlowDetails.EISDOPCFEUpperTolerance']//input";
    public static final String ACCOUNTMASTER_IDENTIFIER_FUNDIPEDIA_FUND_ID = "cssSelector:div[id$='EISAccountMaster.EISPortfolioXReference.EISPortfolioFFUNDID'] input";
    public static final String ACCOUNTMASTER_IDENTIFIER_FUNDIPEDIA_PORTFOLIO_ID = "cssSelector:div[id$='EISAccountMaster.EISPortfolioXReference.EISPortfolioFPORTID'] input";


    //endregion

    //region Account Group Details OR
    public static final String ACCOUNT_GRP_DETAIL_GROUP_ID = "xpath://div[@id='EISAccountGroup.EISAccountGroupDetails.EISAccountGroupID']//input";
    public static final String ACCOUNT_GRP_DETAIL_GROUP_NAME = "xpath://div[@id='EISAccountGroup.EISAccountGroupDetails.EISAccountGroupName']//input";
    public static final String ACCOUNT_GRP_DETAIL_GROUP_PURPOSE = "xpath://div[@id='EISAccountGroup.EISAccountGroupDetails.EISAccountGroupPurpose']//input";
    public static final String ACCOUNT_GRP_DETAIL_GROUP_DESCRIPTION = "xpath://div[@id='EISAccountGroup.EISAccountGroupDetails.EISAccountGroupDescription']//input";


    private static final String PORTFOLIO_NAME_VAR = "xpath://div[contains(@id,'EISAccountMaster.EISPortfolioDetails.EISPortfolioLongName')]";
    private static final String GROUP_NAME_VAR = "xpath://div[contains(@id,'EISAccountGroup.EISAccountGroupParticipantDetails.EISAccountGroupAsParticipant.EISAccountGroup.EISAccountGroupDetails.EISAccountGroupName')]";

    public static final String ACCOUNT_GRP_PARTICIPANT_DETAIL_PORTFOLIO_NAME_LOOKUP = PORTFOLIO_NAME_VAR + "//div[contains(@class,'gsLookupField')]/div[@role='button']";
    public static final String ACCOUNT_GRP_PARTICIPANT_DETAIL_GROUP_NAME_LOOKUP = GROUP_NAME_VAR + "//div[contains(@class,'gsLookupField')]/div[@role='button']";

    public static final String ACCOUNT_GRP_PARTICIPANT_DETAIL_PORTFOLIO_NAME = PORTFOLIO_NAME_VAR + "//input";
    public static final String ACCOUNT_GRP_PARTICIPANT_DETAIL_GROUP_NAME = GROUP_NAME_VAR + "//input";

    public static final String ACCOUNT_GRP_PARTICIPANT_DETAIL_PARTICIPANT_PURPOSE = "xpath://div[contains(@id,'EISAccountGroupParticipantPurpose')]//input";
    public static final String ACCOUNT_GRP_PARTICIPANT_DETAIL_PARTICIPANT_DESCRIPTION = "xpath://div[contains(@id,'EISAccountGroupParticipantDescription')]//input";

    public static final String ACCOUNT_GRP_PARTICIPANT_CRTS_PORTFOLIO_CODE = "xpath://div[contains(@id,'EISAccountGroupCRTSPortfolioCode')]//input";


    //endregion

    //region Shareclass Details
    public static final String SC_IDENTIFIER_ALT_CRTS_ID = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioLegacyIdentifiers.EISPortfolioALTCRTSID'] input";
    public static final String SC_IDENTIFIER_RDM_CODE = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioLegacyIdentifiers.EISPortfolioRDMCode'] input";
    public static final String SC_IDENTIFIER_FUNDIPEDIA_SHARECLASS_ID = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioXReference.EISPortfolioFSHRCLSID'] input";
    public static final String SC_IDENTIFIER_FUNDIPEDIA_FUND_ID = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioXReference.EISPortfolioFFUNDID'] input";
    public static final String SC_IDENTIFIER_FUNDIPEDIA_PORTFOLIO_ID = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioXReference.EISPortfolioFPORTID'] input";
    public static final String SC_IDENTIFIER_ISIN = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioLegacyIdentifiers.EISPortfolioRDMCode'] input";
    public static final String SC_IDENTIFIER_PORTFOLIO_NAME = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioDetails.EISPortfolioLongName'] input";
    public static final String SC_IDENTIFIER_BASE_CCY = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioDetails.EISPortfolioCurrency'] input";
    public static final String SC_IDENTIFIER_INCEPTION_DATE = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioDetails.EISPortfolioOpenDate'] input";
    public static final String SC_IDENTIFIER_SHARECLASS_TYPE = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioDetails.EISPortfolioShareClassType'] input";
    public static final String SC_IDENTIFIER_ACTIVE_FLAG = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioDetails.EISPortfolioActiveFlag'] input";
    public static final String SC_IDENTIFIER_BNP_PERF_FLAG = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioDetails.EISPortfolioPerformanceFlag'] input";
    public static final String SC_IDENTIFIER_IRP_CODE = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioXReference.EISPortfolioIRPID'] input";
    public static final String SC_IDENTIFIER_PORTFOLIO_ISIN = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioXReference.EISPortfolioISIN'] input";
    public static final String SC_IDENTIFIER_PRIMARY_BM_SRCH_BTN = "xpath://*[contains(@id,'EISShareClassPrimaryBNCH')]//input/../../div[@role='button'][1]";
    public static final String SC_IDENTIFIER_PRIMARY_BM = "cssSelector:div[id$='EISShareClassAccount.EISPortfolioBenchmarkDetails.EISShareClassPrimaryBNCH.Benchmark.EISBenchmarkDefinition.EISBenchmarkName'] input";
//endregion
}
