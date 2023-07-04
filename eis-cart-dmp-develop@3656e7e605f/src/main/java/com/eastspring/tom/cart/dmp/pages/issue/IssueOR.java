package com.eastspring.tom.cart.dmp.pages.issue;

public final class IssueOR {
    private IssueOR() {
    }

    //Locators
    public static final String ISSUE_INST_NAME_LOCATOR = "cssSelector:div[id$='PreferredInstrumentName'] input";
    public static final String ISSUE_INST_DESC_LOCATOR = "cssSelector:div[id$='PreferredInstrumentDescription'] textarea";
    public static final String ISSUE_PREF_IDEN_TYPE_LOCATOR = "cssSelector:div[id$='PreferredIdentifierType'] input";
    public static final String ISSUE_PREF_IDEN_VALUE_LOCATOR = "cssSelector:div[id$='PreferredIdentifierValue'] input";
    public static final String ISSUE_INST_TYPE_LOCATOR = "cssSelector:div[id$='InstrumentType'] input";
    public static final String ISSUE_DENOM_CCY_LOCATOR = "cssSelector:div[id$='PrincipalCurrency'] input";
    public static final String ISSUE_PRICE_METHOD_LOCATOR = "cssSelector:div[id$='PricingMethod'] input";
    public static final String ISSUE_DATE_LOCATOR = "cssSelector:div[id$='IssueDate'] input";
    public static final String ISSUE_MATURITY_DATE_LOCATOR = "cssSelector:div[id$='MaturityDate'] input";
    public static final String ISSUE_INST_SYSTEM_STATUS_LOCATOR = "cssSelector:div[id$='InstrumentSystemStatus'] input";
    public static final String ISSUE_STATUS_REASON_LOCATOR = "cssSelector:div[id$='StatusReason'] input";
    public static final String ISSUE_WHEN_USED_LOCATOR = "cssSelector:div[id$='WhenIssuedIndicator'] input";
    public static final String ISSUE_CREATED_ON_LOCATOR = "cssSelector:div[id$='CreatedOn'] input";
    public static final String ISSUE_ACTIVE_UNTIL_LOCATOR = "cssSelector:div[id$='ActiveUntil'] input";
    public static final String ISSUE_FINAL_MATURITY_DATE_LOCATOR = "cssSelector:div[id$='FinalMaturity'] input";
    public static final String ISSUE_SOURCE_CCY_LOCATOR = "cssSelector:div[id$='SourceCurrency'] input";
    public static final String ISSUE_TARGET_CCY_LOCATOR = "cssSelector:div[id$='TargetCurrency'] input";
    public static final String ISSUE_NOTIONAL_INDICATOR_LOCATOR = "cssSelector:div[id$='NotionalIndicator'] input";
    public static final String ISSUE_ILLIQUIDITY_INDICATOR_LOCATOR = "cssSelector:div[id$='IlliquidityIndicator'] input";
    public static final String ISSUE_PROXY_IN_BRS_LOCATOR = "cssSelector:div[id$='EISISSTBenchMarkSecurityBRSProxy'] input";



    public static final String ISSUE_CUSIP_LOCATOR = "cssSelector:div[id$='InstrumentLevelIdentifiers.CUSIP'] input";
    public static final String ISSUE_ISIN_LOCATOR = "cssSelector:div[id$='InstrumentLevelIdentifiers.ISIN'] input";
    public static final String ISSUE_DESC_INSTRUMENT_NAME = "cssSelector:div[id$='InstrumentDescription.InstrumentName'] input";
    public static final String ISSUE_DESC_INSTRUMENT_DESC = "cssSelector:div[id$='InstrumentDescription.InstrumentDescription'] textarea";
    public static final String ISSUE_SOURCE_OF_DESC_LOCATOR = "cssSelector:div[id$='InstrumentDescription.SourceOfInstrumentDescription'] input";
    public static final String ISSUE_INST_DESC_USAGE_LOCATOR = "cssSelector:div[id$='InstrumentDescription.InstrumentDescriptionUsage'] input";
    public static final String ISSUE_INST_DESC_LANG_LOCATOR = "cssSelector:div[id$='InstrumentDescription.InstrumentDescriptionLanguage'] input";
    public static final String ISSUE_RELATION_PURPOSE_LOCATOR = "cssSelector:div[id$='InstitutionRoles.InstitutionRelationshipPurpose'] input";
    public static final String ISSUE_EXCHANGE_NAME_LOCATOR = "xpath://*[contains(@id,'MarketDetails.MarketName')]//input/../../div[@role='button'][1]";
    public static final String ISSUE_PRIMARY_MKT_INDICATOR_LOCATOR = "cssSelector:div[id$='MarketListing.NonPrimaryTradingInd'] input";
    public static final String ISSUE_MARKET_STATUS_LOCATOR = "cssSelector:div[id$='MarketListing.MarketStatus'] input";
    public static final String ISSUE_TRADING_CCY_LOCATOR = "cssSelector:div[id$='MarketListing.TradingCurrency'] input";
    public static final String ISSUE_MKT_LISTING_CREATED_ON_LOCATOR = "cssSelector:div[id$='MarketListing.MarketListingCreatedOn'] input";

    public static final String ISSUE_CLASSI_SET_LOCATOR = "cssSelector:div[id$='ExtendedInstrumentClassifications.ClassificationSetId'] input";
    public static final String ISSUE_CLASSI_VALUE_LOCATOR = "cssSelector:div[id$='ExtendedInstrumentClassifications.ClassificationValue'] input";
    public static final String ISSUE_CLASSI_PUC_LOCATOR = "cssSelector:div[id$='ExtendedInstrumentClassifications.ClassificationPurpose'] input";
    public static final String ISSUE_CLASSI_RT_CLSS_SCH_LOCATOR = "xpath://*[contains(@id,'ReutersClassificationClValue')]//div[@role='combobox']/input";

    public static final String ISSUE_CAPITAL_TYPE_LOCATOR = "cssSelector:div[id$='InstrumentCapitalization.CapitalType'] input";
    public static final String ISSUE_MKT_CAPITALIZATION_LOCATOR = "cssSelector:div[id$='InstrumentCapitalization.MarketCapitalization'] input";
    public static final String ISSUE_ACTUAL_SHARE_OUTSTAN_LOCATOR = "cssSelector:div[id$='InstrumentCapitalization.ActualSharesOutstanding'] input";
    public static final String ISSUE_IDENTIFIER_VALUE_LOCATOR = "cssSelector:div[id$='ExtendedIdentifiers.IdentifierValue'] input";
    public static final String ISSUE_IDENTIFIER_TYPE_LOCATOR = "cssSelector:div[id$='ExtendedIdentifiers.IdentifierType'] input";
    public static final String ISSUE_IDENTIFIER_EFFECTIVE_DATE_LOCATOR = "cssSelector:div[id$='ExtendedIdentifiers.IdentifierEffectiveDate'] input";
    public static final String ISSUE_GLOBAL_UNIQUE_INDI_LOCATOR = "cssSelector:div[id$='ExtendedIdentifiers.GlobalUniqueIndicator'] input";
    public static final String ISSUE_RELATIONSHIP_TYPE_LOCATOR = "cssSelector:div[id$='RelatedInstrument.RelationshipType'] input";
    public static final String ISSUE_COMMENT_REASON_TYPE_LOCATOR = "cssSelector:div[id$='EISIssueComments.EISCommentReasonType'] input";
    public static final String ISSUE_COMMENT_TEXT_LOCATOR = "cssSelector:div[id$='EISIssueComments.EISCommentText'] textarea";
    public static final String ISSUE_LINE_NUMBER_LOCATOR = "cssSelector:div[id$='EISIssueComments.EISLineNumber'] input";
    public static final String ISSUE_COMMENT_DATE_LOCATOR = "cssSelector:div[id$='EISIssueComments.EISCommentDateTime'] input";
    public static final String ISSUE_RATING_NAME_LOCATOR = "cssSelector:div[id$='InstrumentRatings.RatingName'] input";
    public static final String ISSUE_RATING_VALUE_LOCATOR = "cssSelector:div[id$='InstrumentRatings.RatingValue'] input";
    public static final String ISSUE_MARKET_LEVEL_IDENTIFIER = "xpath://span[text()='%s']/../../..";
    public static final String ISSUE_MARKET_lISTING_LOCATOR ="xpath://div[@class='v-captiontext'][text()='Market Listing']";
    public static final String ISSUE_RDM_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityRDMCode'] input";
    public static final String ISSUE_BB_GLOBAL_LOCATOR = "cssSelector:div[id$='MarketListing.MarketLevelIdentifiers.BBGlobal'] input";
    public static final String ISSUE_TICKER_LOCATOR = "cssSelector:div[id$='MarketListing.MarketLevelIdentifiers.Ticker'] input";
    public static final String ISSUE_RIC_LOCATOR = "cssSelector:div[id$='MarketListing.MarketLevelIdentifiers.RIC'] input";
    public static final String ISSUE_REUTERS_TICKER_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.ReutersTicker'] input";
    public static final String ISSUE_MARKET_lISTING_LINK_LOCATOR ="xpath://div[contains(@class,'gsCustomDisclosurePanel')]//div[contains(@class,'gsBreadCrumb')]//div[contains(@class,'v-button-link')]";

    public static final String ISSUE_RCR_ESJP_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityESJPCODE'] input";
    public static final String ISSUE_RCR_BOCI_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityBOCICODE'] input";
    public static final String ISSUE_RCR_EIMKOR_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityEIMKORCDE'] input";
    public static final String ISSUE_RCR_ESGA_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityESGACODE'] input";
    public static final String ISSUE_RCR_PPMJNAM_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityPPMJNAMCDE'] input";
    public static final String ISSUE_RCR_MNG_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityMNGCODE'] input";
    public static final String ISSUE_RCR_TMBAM_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityTMBAMCDE'] input";
    public static final String ISSUE_RCR_WFOE_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityWFOECODE'] input";
    public static final String ISSUE_RCR_THANA_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityTHANACODE'] input";
    public static final String ISSUE_BRS_BCUSIP_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.BCUSIP'] input" ;
    public static final String ISSUE_BNP_BBGLOBAL_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityBNPBBGLOBAL'] input";
    public static final String ISSUE_MNG_BCUSIP_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.MNGBCUSIP'] input" ;
    public static final String ISSUE_RCR_WFOECCB_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityWFOECCBCODE'] input";
    public static final String ISSUE_RCR_ROBOCOLL_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityROBOCOLLCDE'] input";
    public static final String ISSUE_BNP_HIPEXT21D_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityHIPEXT2ID'] input";
    public static final String ISSUE_BNP_LISTINGID_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISBNPLSTID'] input";
    public static final String ISSUE_BB_ID_MIC_PRIM_EXCH_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityIDMICPRIMEXCH'] input";
    public static final String ISSUE_RCR_PAMTC_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityPAMTCCODE'] input";
    public static final String ISSUE_RCR_WELLINGTON_CODE_LOCATOR = "cssSelector:div[id$='MarketLevelIdentifiers.EISSecurityWELLINGTONCDE'] input";

    public static final String ISSUE_SSDR_ROUND_LOT_LOCATOR = "cssSelector:div[id$='MarketFeatures.EISTRDSSRoundLot'] input";

    public static final String ISSUE_FA_DELTA_LOCATOR = "cssSelector:div[id$='EISDeltaRate'] input";
    public static final String ISSUE_FA_CONV_DATA_IND_LOCATOR = "cssSelector:div[id$='EISContributionDataIndicator'] input";
    public static final String ISSUE_FA_CLOSE_PRICE_LOCATOR = "cssSelector:div[id$='EISTRDSSClosePrice'] input";
    public static final String ISSUE_FA_TOT_ISSUE_NOM_CAP_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalIssuedNominalCap'] input";
    public static final String ISSUE_FA_TOT_SHARES_TRSRY_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalSharesInTreasury'] input";
    public static final String ISSUE_FA_RDM_SECTYPE_LOCATOR = "cssSelector:div[id$='EISSecurityforLegacy.EISRDMSecType'] input";
    public static final String ISSUE_FA_FUND_SHARES_OS_LOCATOR = "cssSelector:div[id$='EISTRDSSFundSharesOutstanding'] input";
    public static final String ISSUE_FA_TOT_NET_ASSETS_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalNetAssets'] input";
    public static final String ISSUE_FA_RT_SHARES_OS_LOCATOR = "cssSelector:div[id$='EISTRDSSSharesOutstanding'] input";
    public static final String ISSUE_FA_LIST_SHR_ISS_SHR_AMT_LOCATOR = "cssSelector:div[id$='EISTRDSSListedSharesIssueSharesAmount'] input";
    public static final String ISSUE_FA_TOT_SHR_OS_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalSharesOutstanding'] input";
    public static final String ISSUE_FA_CONV_RATIO_LOCATOR = "cssSelector:div[id$='EISTRDSSConversionRatio'] input";
    public static final String ISSUE_FA_ASSET_RATIO_AGAINST_LOCATOR = "cssSelector:div[id$='EISTRDSSAssetRatioAgainst'] input";
    public static final String ISSUE_FA_ASSET_RATIO_FOR_LOCATOR = "cssSelector:div[id$='EISTRDSSAssetRatioFor'] input";
    public static final String ISSUE_FA_MKT_CAPZN_LOCATOR = "cssSelector:div[id$='EISTRDSSMarketCapitalization'] input";
    public static final String ISSUE_FA_EXCH_CNTRY_CDE_LOCATOR = "cssSelector:div[id$='EISTRDSSExchangeCountryCode'] input";
    public static final String ISSUE_FA_TOT_SHR_ISS_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalSharesIssued'] input";
    public static final String ISSUE_FA_TOT_VOTE_RIGHT_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingRights'] input";
    public static final String ISSUE_FA_TOT_VOTE_RIGHT_UL_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingRightsUnlisted'] input";
    public static final String ISSUE_FA_TOT_VOTE_RIGHT_L_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingRightsListed'] input";
    public static final String ISSUE_FA_TOT_VOTE_SHR_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingShares'] input";
    public static final String ISSUE_FA_TOT_VOTE_SHR_ISS_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingSharesIssued'] input";
    public static final String ISSUE_FA_TOT_VOTE_SHR_UL_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingSharesUnlisted'] input";
    public static final String ISSUE_FA_TOT_VOTE_SHR_L_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingSharesListed'] input";
    public static final String ISSUE_FA_TOT_VOTE_SHR_OS_LOCATOR = "cssSelector:div[id$='EISTRDSSTotalVotingSharesOutstanding'] input";
    public static final String ISSUE_FA_CLOSE_PR_CURR_LOCATOR = "cssSelector:div[id$='EISTRDSSClosePriceCurrency'] input";
    public static final String ISSUE_FA_CLOSE_PR_DATE_LOCATOR = "cssSelector:div[id$='EISTRDSSClosePricePRCTMS'] input";

    public static final String ISSUE_FA_MIC_CODE_SRCH_BTN_LOCATOR = "xpath://*[contains(@id,'MarketDetails.MICCode')]//input/../../div[@role='button'][1]";
    public static final String ISSUE_FA_MIC_CODE_LOCATOR = "cssSelector:div[id$='MarketDetails.MICCode'] input";
    public static final String ISSUE_FA_PRTCPN_AMT_LOCATOR = "cssSelector:div[id$='EISParticipatioAmount'] input";

}
