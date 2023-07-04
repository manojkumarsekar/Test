package com.eastspring.tom.cart.cst;

public class SqlQueryConstants {
    public static final String SQL_CREATE_TABLE_KDRIVE_SECURITY_RAW = "CREATE TABLE [dbo].[%s](\n" +
            "\t[CounterId] int IDENTITY(1,1) NOT NULL,\n" +
            "\t[FileID] varchar(400) NOT NULL,\n" +
            "\t[PortfolioCode] varchar(50) NOT NULL,\n" +
            "\t[AttributionModelCode] varchar(50) NOT NULL,\n" +
            "\t[PortfolioName] varchar(200) NULL,\n" +
            "\t[AttributionMethodName] varchar(50) NULL,\n" +
            "\t[ReportEndDate] [date] NOT NULL,\n" +
            "\t[AssetClass_TAB] varchar(200) NOT NULL,\n" +
            "\t[PORTFOLIO_ROR] numeric(22, 6) NULL,\n" +
            "\t[INDEX_ROR] numeric(22, 6) NULL,\n" +
            "\t[PORTFOLIO_WEIGHT_END] numeric(22, 6) NULL,\n" +
            "\t[PORTFOLIO_WEIGHT_AVERAGE] numeric(22, 6) NULL,\n" +
            "\t[INDEX_WEIGHT_END] numeric(22, 6) NULL,\n" +
            "\t[INDEX_WEIGHT_AVERAGE] numeric(22, 6) NULL,\n" +
            "\t[PORTFOLIO_CONTRIBUTION] numeric(22, 6) NULL,\n" +
            "\t[INDEX_CONTRIBUTION] numeric(22, 6) NULL,\n" +
            "\t[SECURITY_WEIGHTING] numeric(22, 6) NULL,\n" +
            "\t[ASSET_WEIGHTING] numeric(22, 6) NULL,\n" +
            "\t[SECURITY_TIMING] numeric(22, 6) NULL,\n" +
            "\t[SECURITY_SELECTION] numeric(22, 6) NULL,\n" +
            "\t[CURRENCY_EFFECT] numeric(22, 6) NULL\n" +
            ")\n";
    public static final String SQL_CREATE_TABLE_KDRIVE_POCKET_RAW = "CREATE TABLE [dbo].[%s](\n" +
            "\t[CounterId] int IDENTITY(1,1) NOT NULL,\n" +
            "\t[FileID] varchar(400) NOT NULL,\n" +
            "\t[PortfolioCode] varchar(50) NOT NULL,\n" +
            "\t[AttributionModelCode] varchar(50) NOT NULL,\n" +
            "\t[PortfolioName] varchar(200) NULL,\n" +
            "\t[AttributionMethodName] varchar(50) NULL,\n" +
            "\t[ReportEndDate] [date] NOT NULL,\n" +
            "\t[AssetClass_TAB] varchar(200) NOT NULL,\n" +
            "\t[PORTFOLIO_ROR] numeric(22, 6) NULL,\n" +
            "\t[INDEX_ROR] numeric(22, 6) NULL,\n" +
            "\t[PORTFOLIO_WEIGHT_END] numeric(22, 6) NULL,\n" +
            "\t[PORTFOLIO_WEIGHT_AVERAGE] numeric(22, 6) NULL,\n" +
            "\t[INDEX_WEIGHT_END] numeric(22, 6) NULL,\n" +
            "\t[INDEX_WEIGHT_AVERAGE] numeric(22, 6) NULL,\n" +
            "\t[PORTFOLIO_CONTRIBUTION] numeric(22, 6) NULL,\n" +
            "\t[INDEX_CONTRIBUTION] numeric(22, 6) NULL,\n" +
            "\t[ASSET_WEIGHTING] numeric(22, 6) NULL,\n" +
            "\t[SECURITY_SELECTION] numeric(22, 6) NULL,\n" +
            "\t[CURRENCY_EFFECT] numeric(22, 6) NULL\n" +
            ")\n";
    public static final String SQL_INSERT_KDRIVE_SECURITY_RAW = "INSERT INTO [dbo].[%s] " +
            "(FileID, PortfolioCode, AttributionModelCode, PortfolioName, AttributionMethodName, " +
            "ReportEndDate, AssetClass_TAB, PORTFOLIO_ROR, INDEX_ROR, PORTFOLIO_WEIGHT_END, " +
            "PORTFOLIO_WEIGHT_AVERAGE, INDEX_WEIGHT_END, INDEX_WEIGHT_AVERAGE, PORTFOLIO_CONTRIBUTION, INDEX_CONTRIBUTION," +
            "SECURITY_WEIGHTING, ASSET_WEIGHTING, SECURITY_TIMING, SECURITY_SELECTION, CURRENCY_EFFECT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    public static final String SQL_INSERT_KDRIVE_POCKET_RAW = "INSERT INTO [dbo].[%s] " +
            "(FileID, PortfolioCode, AttributionModelCode, PortfolioName, AttributionMethodName, " +
            "ReportEndDate, AssetClass_TAB, PORTFOLIO_ROR, INDEX_ROR, PORTFOLIO_WEIGHT_END, " +
            "PORTFOLIO_WEIGHT_AVERAGE, INDEX_WEIGHT_END, INDEX_WEIGHT_AVERAGE, PORTFOLIO_CONTRIBUTION, INDEX_CONTRIBUTION," +
            "ASSET_WEIGHTING, SECURITY_SELECTION, CURRENCY_EFFECT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    public static final String VERIFY_ORACLE_SQL_QUERY = "SELECT 1 AS RESULT FROM DUAL";
    public static final String VERIFY_MSSQL_SQL_QUERY = "SELECT 1 AS RESULT";

    private SqlQueryConstants() {
    }
}
