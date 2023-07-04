USE [TestAutomation]
GO
/****** Object:  StoredProcedure [dbo].[Compare_BOR_CPR_BNP]    Script Date: 12/01/2018 4:00:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[TestAutomation].[dbo].[Compare_BOR_CPR_BNP]', 'P') IS NOT NULL DROP PROCEDURE [dbo].[Compare_BOR_CPR_BNP];
GO


CREATE PROCEDURE [dbo].[Compare_BOR_CPR_BNP]
(
    @CPRTable SYSNAME, -- 'TestAutomation.dbo.CPRTable'
    @BNPTable SYSNAME, -- 'TestAutomation.dbo.BNPTable'
    @NumericTolerance NUMERIC(10, 6) = 0.0001,
    @RowReturnCount INT = 100000, -- NULL or negative values = 100k records.
    @SourceMoniker VARCHAR(8) = 'CPR',
    @TargetMoniker VARCHAR(8) = 'BNP',
    @ComparisonRequestId INT = NULL OUTPUT
)
AS
BEGIN
    -- Revision History
    -- CreatedBy    CreatedDate     Messages
    -- =========    ===========     =========
    -- SankaranS    23-Oct-2017    Initial Version
    -- Baktiad      19-Jan-2018    Fixed the wrong column bug TOM-2068

    --EXEC TestAutomation.dbo.Compare_BOR_CPR_BNP
    --    @CPRTable = 'TestAutomation.dbo.CPRTable',
    --    @BNPTable = 'TestAutomation.dbo.BNPTable',
    --    @NumericTolerance = 0.0001,
    --    @RowReturnCount = 100000,
    --    @SourceMoniker = 'CPR',
    --    @TargetMoniker = 'BNP'

    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    -- Variable Declarations
    DECLARE @ErrorMessage VARCHAR(8000),
            @UpdateList VARCHAR(MAX) = '',
            @SQL VARCHAR(MAX) = '',
            @DateString VARCHAR(30) = REPLACE(CONVERT(VARCHAR(30), GETDATE(), 112) + CONVERT(VARCHAR(30), GETDATE(), 114), ':', ''),
            @SourceQuery VARCHAR(MAX) = '',
            @TargetQuery VARCHAR(MAX) = '',
            @SourceTable VARCHAR(1000),
            @TargetTable VARCHAR(1000);

    BEGIN TRY
        --------------------------------------------------------------------
        -- Validations
        IF ISNULL(@CPRTable, '') = ''
        BEGIN
            SET @ErrorMessage = 'Error: Invalid value for parameter @CPRTable'
            RAISERROR(@ErrorMessage, 16, 1)
        END

        IF ISNULL(@BNPTable, '') = ''
        BEGIN
            SET @ErrorMessage = 'Error: Invalid value for parameter @BNPTable'
            RAISERROR(@ErrorMessage, 16, 1)
        END
        --------------------------------------------------------------------
        -- Cleanse input
        IF @RowReturnCount < 0
        BEGIN
           SET @RowReturnCount = NULL
        END

        IF @RowReturnCount >= 100000
        BEGIN
           SET @RowReturnCount = 100000
        END

        SET @RowReturnCount = ISNULL(@RowReturnCount, 100000) -- max 100k records to be returned by default
        --------------------------------------------------------------------


        -- Step #1: Load Source and Target into staging tables
        SELECT  @SourceTable = 'dbo.CPR_BOR_Raw_Internal_' + @DateString,
                @TargetTable = 'dbo.BNP_BOR_Raw_Internal_' + @DateString

        IF OBJECT_ID(@SourceTable, 'U') IS NOT NULL
        BEGIN
            SET @SQL = 'DROP TABLE ' + @SourceTable
            EXEC(@SQL)
        END

        IF OBJECT_ID(@TargetTable, 'U') IS NOT NULL
        BEGIN
            SET @SQL = 'DROP TABLE ' + @TargetTable
            EXEC(@SQL)
        END

        SET @SQL = 'SELECT * INTO ' + @SourceTable + ' FROM ' + @CPRTable
        EXEC(@SQL)

        SET @SQL = 'SELECT * INTO ' + @TargetTable + ' FROM ' + @BNPTable
        EXEC(@SQL)


        ---------------------------------------------------
        -- Step #2: Cleanse data
        ---------------------------------------------------
        -- Remove %
        SELECT @UpdateList = @UpdateList + '[' + name + '] = REPLACE([' + name + '], ''%'', '''')' + ','
        FROM sys.columns
        WHERE object_id = object_id(@TargetTable, 'U')
        AND name LIKE '%return%';

        SET @UpdateList = LTRIM(RTRIM(@UpdateList));
        IF @UpdateList <> '' SET @UpdateList = LEFT(@UpdateList, LEN(@UpdateList) - 1);

        SET @SQL = 'UPDATE ' + @TargetTable + ' SET ' + @UpdateList;

        EXEC(@SQL);

        -- Remove ','
        SET @SQL = 'UPDATE ' + @SourceTable + ' SET [FUM $ Base in mio] = REPLACE([FUM $ Base in mio], '','', ''''), [Return Source] = LTRIM(RTRIM([Return Source])), [Return Type] = LTRIM(RTRIM([Return Type]))';
        EXEC(@SQL);

        -- Remove ','
        SET @SQL = 'UPDATE ' + @TargetTable + ' SET [ShareClass AUM (M.)] = REPLACE([ShareClass AUM (M.)], '','', ''''), [Accounting Code] = LTRIM(RTRIM([Accounting Code]))';
        EXEC(@SQL);
        ---------------------------------------------------



        -- Step #3: Standardize the queries
        SET @SourceQuery =
        '
        SELECT
            X.[ReportType],
            X.[Asset Class],
            X.[Entity Id],
            X.[Return Type],
            X.[Perf Ccy],
            X.[FUM $ Base in mio],
            X.[Fund 1M],
            X.[Official BM 1M],
            X.[Rel 1M Eagle],
            X.[Fund 3M],
            X.[Official BM 3M],
            X.[Rel 3M Eagle],
            X.[6M],
            X.[Official BM 6M],
            X.[Rel 6M Eagle],
            X.[Fund YTD],
            X.[Official BM YTD],
            X.[Rel YTD Eagle],
            X.[Fund 1Y],
            X.[Official BM 1Y],
            X.[Rel 1Y Eagle],
            X.[2Y PA],
            X.[Official BM 2Y PA],
            X.[Rel 2Y pa Eagle],
            X.[Fund 3Y pa],
            X.[Official BM 3Y pa],
            X.[Rel 3Y pa Eagle],
            X.[4Y PA],
            X.[Official BM 4Y PA],
            X.[Rel 4Y pa(Official)],
            X.[Fund 5Y pa],
            X.[Official BM 5Y pa],
            X.[Rel 5Y pa Eagle],
            X.[10Y PA],
            X.[Official BM 10Y PA],
            X.[Rel 10Y pa(Official)],
            X.[Inception Date],
            X.[Fund SI pa],
            X.[Official BM SI pa],
            X.[Rel SI pa]
        FROM
        (
        SELECT
            CASE WHEN [Return Source] = ''TWRR'' THEN ''IBOR'' WHEN [Return Source] = ''NAV'' THEN ''ABOR'' END AS [ReportType],
            [Asset Class],
            [Entity Id],
            [Return Type],
            [Perf Ccy],
            [FUM $ Base in mio],
            [Fund 1M],
            [Official BM 1M],
            [Rel 1M Eagle],
            [Fund 3M],
            [Official BM 3M],
            [Rel 3M Eagle],
            [6M],
            [Official BM 6M],
            [Rel 6M Eagle],
            [Fund YTD],
            [Official BM YTD],
            [Rel YTD Eagle],
            [Fund 1Y],
            [Official BM 1Y],
            [Rel 1Y Eagle],
            [2Y PA],
            [Official BM 2Y PA],
            [Rel 2Y pa Eagle],
            [Fund 3Y pa],
            [Official BM 3Y pa],
            [Rel 3Y pa Eagle],
            [4Y PA],
            [Official BM 4Y PA],
            [Rel 4Y pa(Official)],
            [Fund 5Y pa],
            [Official BM 5Y pa],
            [Rel 5Y pa Eagle],
            [10Y PA],
            [Official BM 10Y PA],
            [Rel 10Y pa(Official)],
            [Inception Date],
            [Fund SI pa],
            [Official BM SI pa],
            [Rel SI pa],
            ROW_NUMBER() OVER (PARTITION BY [Return Source], [Entity Id], [Return Type] ORDER BY [Inception Date] ASC) AS RankOrder
        FROM ' + @SourceTable + '
        WHERE [Return Type] = ''Gross''
        AND [Return Source] IN (''TWRR'', ''NAV'')
        UNION ALL
        SELECT
            CASE WHEN [Return Source] = ''TWRR'' THEN ''IBOR'' WHEN [Return Source] = ''NAV'' THEN ''ABOR'' END AS [ReportType],
            [Asset Class],
            [Entity Id],
            [Return Type],
            [Perf Ccy],
            [FUM $ Base in mio],
            [Fund 1M],
            [Official BM 1M],
            [Rel 1M Eagle],
            [Fund 3M],
            [Official BM 3M],
            [Rel 3M Eagle],
            [6M],
            [Official BM 6M],
            [Rel 6M Eagle],
            [Fund YTD],
            [Official BM YTD],
            [Rel YTD Eagle],
            [Fund 1Y],
            [Official BM 1Y],
            [Rel 1Y Eagle],
            [2Y PA],
            [Official BM 2Y PA],
            [Rel 2Y pa Eagle],
            [Fund 3Y pa],
            [Official BM 3Y pa],
            [Rel 3Y pa Eagle],
            [4Y PA],
            [Official BM 4Y PA],
            [Rel 4Y pa(Official)],
            [Fund 5Y pa],
            [Official BM 5Y pa],
            [Rel 5Y pa Eagle],
            [10Y PA],
            [Official BM 10Y PA],
            [Rel 10Y pa(Official)],
            [Inception Date],
            [Fund SI pa],
            [Official BM SI pa],
            [Rel SI pa],
            ROW_NUMBER() OVER (PARTITION BY [Return Source], [Entity Id], [Return Type] ORDER BY [Inception Date] ASC) AS RankOrder
        FROM ' + @SourceTable + '
        WHERE [Return Type] = ''Net''
        AND [Return Source] IN (''TWRR'', ''NAV'')
        ) AS X
        WHERE X.RankOrder = 1
        '

        SET @TargetQuery =
        '
        SELECT
            CASE WHEN [Accounting Code] LIKE ''%\_I'' ESCAPE ''\'' THEN ''IBOR'' WHEN [Accounting Code] LIKE ''%\_A'' ESCAPE ''\'' THEN ''ABOR'' END AS [ReportType],
            [Asset Class] AS [Asset Class],
            CASE WHEN RIGHT(LTRIM(RTRIM([Accounting Code])), 2) IN (''_A'', ''_I'') THEN LEFT(LTRIM(RTRIM([Accounting Code])), LEN(LTRIM(RTRIM([Accounting Code]))) - 2) ELSE [Accounting Code] END AS [Entity Id],
            [Value Date],
            ''Net'' AS [Return Type],
            [Currency] AS [Perf Ccy],
            [ShareClass AUM (M.)] AS [FUM $ Base in mio],
            [1M Fund Net Return] AS [Fund 1M],
            [1M Fund Pri. Benchmark Return] AS [Official BM 1M],
            [1M Fund Net Relative Return] AS [Rel 1M Eagle],
            [3M Fund Net Return] AS [Fund 3M],
            [3M Fund Pri. Benchmark Return] AS [Official BM 3M],
            [3M Fund Net Relative Return] AS [Rel 3M Eagle],
            [6M Fund Net Return] AS [6M],
            [6M Fund Pri. Benchmark Return] AS [Official BM 6M],
            [6M Fund Net Relative Return] AS [Rel 6M Eagle],
            [YTD Fund Net Return] AS [Fund YTD],
            [YTD Fund Pri. Benchmark Return] AS [Official BM YTD],
            [YTD Fund Net Relative Return] AS [Rel YTD Eagle],
            [1Y Fund Net Return] AS [Fund 1Y],
            [1Y Fund Pri. Benchmark Return] AS [Official BM 1Y],
            [1Y Fund Net Relative Return] AS [Rel 1Y Eagle],
            [2Y Fund Net Return (Ann.)] AS [2Y PA],
            [2Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 2Y PA],
            [2Y Fund Net Relative Return (Ann.)] AS [Rel 2Y pa Eagle],
            [3Y Fund Net Return (Ann.)] AS [Fund 3Y pa],
            [3Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 3Y pa],
            [3Y Fund Net Relative Return (Ann.)] AS [Rel 3Y pa Eagle],
            [4Y Fund Net Return (Ann.)] AS [4Y PA],
            [4Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 4Y PA],
            [4Y Fund Net Relative Return (Ann.)] AS [Rel 4Y pa(Official)],
            [5Y Fund Net Return (Ann.)] AS [Fund 5Y pa],
            [5Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 5Y pa],
            [5Y Fund Net Relative Return (Ann.)] AS [Rel 5Y pa Eagle],
            [10Y Fund Net Return (Ann.)] AS [10Y PA],
            [10Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 10Y PA],
            [10Y Fund Net Relative Return (Ann.)] AS [Rel 10Y pa(Official)],
            [SI Date] AS [Inception Date],
            [SI Fund Net Return (Ann.)] AS [Fund SI pa],
            [SI Fund Pri. Benchmark Return (Ann.)] AS [Official BM SI pa],
            [SI Fund Net Relative Return (Ann.)] AS [Rel SI pa]
        FROM ' + @TargetTable + '
        WHERE ([Accounting Code] LIKE ''%\_I'' ESCAPE ''\'' OR [Accounting Code] LIKE ''%\_A'' ESCAPE ''\'')
        UNION ALL
        SELECT
            CASE WHEN [Accounting Code] LIKE ''%\_I'' ESCAPE ''\'' THEN ''IBOR'' WHEN [Accounting Code] LIKE ''%\_A'' ESCAPE ''\'' THEN ''ABOR'' END AS [ReportType],
            [Asset Class] AS [Asset Class],
            CASE WHEN RIGHT(LTRIM(RTRIM([Accounting Code])), 2) IN (''_A'', ''_I'') THEN LEFT(LTRIM(RTRIM([Accounting Code])), LEN(LTRIM(RTRIM([Accounting Code]))) - 2) ELSE [Accounting Code] END AS [Entity Id],
            [Value Date],
            ''Gross''  AS [Return Type],
            [Currency] AS [Perf Ccy],
            [ShareClass AUM (M.)] AS [FUM $ Base in mio],
            [1M Fund Gross Return] AS [Fund 1M],
            [1M Fund Pri. Benchmark Return] AS [Official BM 1M],
            [1M Fund Gross Relative Return] AS [Rel 1M Eagle],
            [3M Fund Gross Return] AS [Fund 3M],
            [3M Fund Pri. Benchmark Return] AS [Official BM 3M],
            [3M Fund Gross Relative Return] AS [Rel 3M Eagle],
            [6M Fund Gross Return] AS [6M],
            [6M Fund Pri. Benchmark Return] AS [Official BM 6M],
            [6M Fund Gross Relative Return] AS [Rel 6M Eagle],
            [YTD Fund Gross Return] AS [Fund YTD],
            [YTD Fund Pri. Benchmark Return] AS [Official BM YTD],
            [YTD Fund Gross Relative Return] AS [Rel YTD Eagle],
            [1Y Fund Gross Return] AS [Fund 1Y],
            [1Y Fund Pri. Benchmark Return] AS [Official BM 1Y],
            [1Y Fund Gross Relative Return] AS [Rel 1Y Eagle],
            [2Y Fund Gross Return (Ann.)] AS [2Y PA],
            [2Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 2Y PA],
            [2Y Fund Gross Relative Return (Ann.)] AS [Rel 2Y pa Eagle],
            [3Y Fund Gross Return (Ann.)] AS [Fund 3Y pa],
            [3Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 3Y pa],
            [3Y Fund Gross Relative Return (Ann.)] AS [Rel 3Y pa Eagle],
            [4Y Fund Gross Return (Ann.)] AS [4Y PA],
            [4Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 4Y PA],
            [4Y Fund Gross Relative Return (Ann.)] AS [Rel 4Y pa(Official)],
            [5Y Fund Gross Return (Ann.)] AS [Fund 5Y pa],
            [5Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 5Y pa],
            [5Y Fund Gross Relative Return (Ann.)] AS [Rel 5Y pa Eagle],
            [10Y Fund Gross Return (Ann.)] AS [10Y PA],
            [10Y Fund Pri. Benchmark Return (Ann.)] AS [Official BM 10Y PA],
            [10Y Fund Gross Relative Return (Ann.)] AS [Rel 10Y pa(Official)],
            [SI Date] AS [Inception Date],
            [SI Fund Gross Return (Ann.)] AS [Fund SI pa],
            [SI Fund Pri. Benchmark Return (Ann.)] AS [Official BM SI pa],
            [SI Fund Gross Relative Return (Ann.)] AS [Rel SI pa]
        FROM ' + @TargetTable + '
        WHERE ([Accounting Code] LIKE ''%\_I'' ESCAPE ''\'' OR [Accounting Code] LIKE ''%\_A'' ESCAPE ''\'')
        '

        ---------------------------------------------------
        -- Step #4: Load Standardized Queries into Table
        SELECT  @SourceTable = 'dbo.CPR_BOR_Processed_' + @DateString,
                @TargetTable = 'dbo.BNP_BOR_Processed_' + @DateString

        EXEC TestAutomation.dbo.LoadQuery @Query = @SourceQuery,
                                          @LinkedServer = NULL,
                                          @TableName = @SourceTable;

        EXEC TestAutomation.dbo.LoadQuery @Query = @TargetQuery,
                                          @LinkedServer = NULL,
                                          @TableName = @TargetTable;
        ---------------------------------------------------

        -- Step #5 - Run Comparison
        EXEC TestAutomation.dbo.Compare
            @SourceTable = @SourceTable,
            @TargetTable = @TargetTable,
            @MatchKeySourceList = '[Entity Id], [Return Type], [ReportType]',
            @ExcludedColumnSourceList = NULL,
            @ExcludedColumnTargetList = NULL,
            @ColumnMappingList = NULL,
            @NumericTolerance = 0.0001,
            @CaseSensitiveFlag = 0,
            @IgnoreOrphanColumnsFlag  = 1,
            @OptimizedStorageFlag = 1,
            @SourceMoniker = @SourceMoniker,
            @TargetMoniker = @TargetMoniker,
            @ComparisonGUID = NULL,
            @ComparisonRequestId = @ComparisonRequestId OUTPUT
        ---------------------------------------------------
        -- Step #4 - Review Results
        SELECT 'Summary' AS ReportTitle
        SELECT *
        FROM TestAutomation.dbo.ComparisonRequest
        WHERE ComparisonRequestId = @ComparisonRequestId

        SELECT 'Mismatch Smell' AS ReportTitle
        SET @SQL = 'SELECT * FROM dbo.vwMismatchSmell_' + CONVERT(VARCHAR(30), @ComparisonRequestId) + ' ORDER BY MismatchCount DESC'
        EXEC(@SQL)

        SELECT 'Mismatch' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwMismatch_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        SELECT 'Source Surplus' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwSourceSurplus_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        SELECT 'Target Surplus' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwTargetSurplus_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        SELECT 'Source Duplicate' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwSourceDuplicate_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        SELECT 'Target Duplicate' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwTargetDuplicate_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        SELECT 'Match' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwMatch_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        SELECT 'Source' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwSource_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        SELECT 'Target' AS ReportTitle
        SET @SQL = 'SELECT TOP (' + CONVERT(VARCHAR(30), @RowReturnCount) + ') * FROM dbo.vwTarget_' + CONVERT(VARCHAR(30), @ComparisonRequestId)
        EXEC(@SQL)

        ---------------------------------------------------
    END TRY

    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE()
        RAISERROR(@ErrorMessage, 16, 1)
    END CATCH
END;
