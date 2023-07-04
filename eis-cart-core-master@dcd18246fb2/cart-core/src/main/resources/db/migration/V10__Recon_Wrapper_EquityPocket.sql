--------------------------------------------
USE TestAutomation
GO
---------------------------------------------------
IF OBJECT_ID('dbo.AttributionModelMapping', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.AttributionModelMapping;
END;
---------------------------------------------------
IF OBJECT_ID('dbo.PortfolioMaster', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PortfolioMaster;
END;
---------------------------------------------------
IF OBJECT_ID('dbo.KDrive_EQ_Pocket_Raw_20180117105031653', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.KDrive_EQ_Pocket_Raw_20180117105031653
END
---------------------------------------------------
IF OBJECT_ID('dbo.DNA_EQ_Pocket_Raw_20180117105031653', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DNA_EQ_Pocket_Raw_20180117105031653
END;
GO
---------------------------------------------------
CREATE TABLE dbo.AttributionModelMapping
(
    PortfolioCode VARCHAR(50) NOT NULL,
    PortfolioName VARCHAR(200) NOT NULL,
    AttributionModelCode VARCHAR(50) NOT NULL,
    AttributionModelName VARCHAR(200) NOT NULL,
    SecurityFlag CHAR(1) NOT NULL,
    DNA_Breakdown VARCHAR(50) NULL
);
GO
CREATE TABLE dbo.PortfolioMaster
(
    PortfolioCode VARCHAR(50) NOT NULL,
    PortfolioName VARCHAR(200) NOT NULL
);
GO
---------------------------------------------------
CREATE TABLE dbo.KDrive_EQ_Pocket_Raw_20180117105031653
(
    CounterId INT IDENTITY(1, 1) NOT NULL,
    FileID VARCHAR(400) NOT NULL,
    PortfolioCode VARCHAR(50) NOT NULL,
    AttributionModelCode VARCHAR(50) NOT NULL,
    PortfolioName VARCHAR(200),
    AttributionMethodName VARCHAR(50),
    ReportEndDate DATE NOT NULL,
    AssetClass_TAB VARCHAR(200) NOT NULL,
    PORTFOLIO_ROR NUMERIC(20, 6),
    INDEX_ROR NUMERIC(20, 6),
    PORTFOLIO_WEIGHT_END NUMERIC(20, 6),
    PORTFOLIO_WEIGHT_AVERAGE NUMERIC(20, 6),
    INDEX_WEIGHT_END NUMERIC(20, 6),
    INDEX_WEIGHT_AVERAGE NUMERIC(20, 6),
    PORTFOLIO_CONTRIBUTION NUMERIC(20, 6),
    INDEX_CONTRIBUTION NUMERIC(20, 6),
    ASSET_WEIGHTING NUMERIC(20, 6),
    SECURITY_SELECTION NUMERIC(20, 6),
    CURRENCY_EFFECT NUMERIC(20, 6)
);
GO
---------------------------------------------------
CREATE TABLE dbo.DNA_EQ_Pocket_Raw_20180117105031653
(
    FileID VARCHAR(400) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    FundName VARCHAR(200),
    SecurityName VARCHAR(200),
    BenchName VARCHAR(200),
    Level1 VARCHAR(100) NOT NULL,
    Level2 VARCHAR(100),
    Level3 VARCHAR(100),
    DNA_Breakdown VARCHAR(50) NOT NULL,
    PortfolioWeight NUMERIC(20, 6),
    PortfolioReturn_Base NUMERIC(20, 6),
    PortfolioContrib NUMERIC(20, 6),
    BenchWeight NUMERIC(20, 6),
    BenchReturn_Base NUMERIC(20, 6),
    BenchContrib NUMERIC(20, 6),
    AllocationEffect NUMERIC(20, 6),
    SelectionEffect NUMERIC(20, 6),
    CurrencyEffect NUMERIC(20, 6),
    FundEndPeriodWeight NUMERIC(20, 6),
    BenchEndPeriodWeight NUMERIC(20, 6)
);
GO
---------------------------------------------------




IF OBJECT_ID('[dbo].[Compare_Equity_Pocket]', 'P') IS NOT NULL DROP PROCEDURE [dbo].[Compare_Equity_Pocket];
GO
CREATE PROCEDURE [dbo].[Compare_Equity_Pocket]
(
    @KDriveTable VARCHAR(300), -- 'TestAutomation.dbo.KDrive_EQ_Pocket_Raw_20180117105031653'
    @DNATable VARCHAR(300), -- 'TestAutomation.dbo.DNA_EQ_Pocket_Raw_20180117105031653'
    @NumericTolerance NUMERIC(10, 6) = 0.0001,
    @RowReturnCount INT = 100, -- NULL or negative values = 100k records.
    @SourceMoniker VARCHAR(8) = 'Legacy',
    @TargetMoniker VARCHAR(8) = 'DNA',
    @ComparisonRequestId INT = NULL OUTPUT
)
AS
BEGIN
    -- Revision History
    -- CreatedBy    CreatedDate     Messages
    -- =========    ===========     =========
    -- SankaranS    27-Jan-2018    Initial Version
    -- SankaranS    07-Feb-2018    Filter DNA records "WHERE DATEDIFF(dd, StartDate, EndDate) IN (28, 29, 30, 31)"
    -- SankaranS    10-Feb-2018    Reset the empty strings to NULL
    -- SankaranS    10-Feb-2018    Added FileID to the output
    -- SankaranS    10-Feb-2018    Added Validation for missing DNA_Breakdown, PortfolioCode

    --EXEC TestAutomation.dbo.Compare_Equity_Pocket
    --    @KDriveTable = 'TestAutomation.dbo.KDrive_EQ_Pocket_Raw_20180117105031653',
    --    @DNATable = 'TestAutomation.dbo.DNA_EQ_Pocket_Raw_20180117105031653',
    --    @NumericTolerance = 0.0001,
    --    @RowReturnCount = 100000,
    --    @SourceMoniker = 'Legacy',
    --    @TargetMoniker = 'DNA'

    SET XACT_ABORT ON;
    SET NOCOUNT ON;

    -- Variable Declarations
    DECLARE @ErrorMessage VARCHAR(8000),
            @UpdateList VARCHAR(MAX) = '',
            @SQL VARCHAR(MAX) = '',
            @FileID VARCHAR(400),
            @DateString VARCHAR(30) = REPLACE(CONVERT(VARCHAR(30), GETDATE(), 112) + CONVERT(VARCHAR(30), GETDATE(), 114), ':', ''),
            @SourceQuery VARCHAR(MAX) = '',
            @TargetQuery VARCHAR(MAX) = '',
            @SourceInternalTable VARCHAR(1000),
            @TargetInternalTable VARCHAR(1000),
            @SourceProcessedTable VARCHAR(1000),
            @TargetProcessedTable VARCHAR(1000);

    DECLARE @PortfolioCode VARCHAR(50),
            @AttributionModelCode VARCHAR(50),
            @AttributionMethodName VARCHAR(50),
            @ReportEndDate DATE,
            @DNA_Breakdown  VARCHAR(50),
            @PARENT_SECURITY_Natural VARCHAR(200),
            @SECURITY_NAME_Natural VARCHAR(200),
            @PARENT_SECURITY_Enriched VARCHAR(200),
            @SECURITY_NAME_Enriched VARCHAR(200)

    BEGIN TRY
        --------------------------------------------------------------------
        -- Enable config settings
        IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'show advanced options' AND value = 1)
        BEGIN
            EXEC sp_configure 'show advanced options', 1
            RECONFIGURE WITH OVERRIDE
        END

        IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'xp_cmdshell' AND value = 1)
        BEGIN
            EXEC sp_configure 'xp_cmdshell', 1
            RECONFIGURE WITH OVERRIDE
        END

        IF NOT EXISTS(SELECT * FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries' AND value = 1)
        BEGIN
            EXEC sp_configure 'Ad Hoc Distributed Queries', 1
            RECONFIGURE WITH OVERRIDE
        END
        --------------------------------------------------------------------
        -- Validations
        IF ISNULL(@KDriveTable, '') = ''
        BEGIN
            SET @ErrorMessage = 'Error: Invalid value for parameter @KDriveTable'
            RAISERROR(@ErrorMessage, 16, 1)
        END

        IF ISNULL(@DNATable, '') = ''
        BEGIN
            SET @ErrorMessage = 'Error: Invalid value for parameter @DNATable'
            RAISERROR(@ErrorMessage, 16, 1)
        END

        IF OBJECT_ID(@KDriveTable, 'U') IS NULL
        BEGIN
            SET @ErrorMessage = 'Error: Missing table ' + @KDriveTable
            RAISERROR(@ErrorMessage, 16, 1)
        END

        IF OBJECT_ID(@DNATable, 'U') IS NULL
        BEGIN
            SET @ErrorMessage = 'Error: Missing table ' + @DNATable
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
        IF OBJECT_ID('tempdb..#RecordCount', 'U') IS NOT NULL DROP TABLE #RecordCount;

        CREATE TABLE #RecordCount
        (
            RecordCount INT
        );
        -- Step #1: Load Source and Target into staging tables
        --          Add additional columns for data-enrichment purposes
        SELECT  @SourceInternalTable = 'dbo.KDrive_EQ_Pocket_Internal_' + @DateString,
                @TargetInternalTable = 'dbo.DNA_EQ_Pocket_Internal_' + @DateString

        IF OBJECT_ID(@SourceInternalTable, 'U') IS NOT NULL
        BEGIN
            SET @SQL = 'DROP TABLE ' + @SourceInternalTable
            EXEC(@SQL)
        END

        IF OBJECT_ID(@TargetInternalTable, 'U') IS NOT NULL
        BEGIN
            SET @SQL = 'DROP TABLE ' + @TargetInternalTable
            EXEC(@SQL)
        END

        SET @SQL = 'SELECT *,
                        CONVERT(VARCHAR(50), NULL) AS DNA_Breakdown,
                        CONVERT(VARCHAR(200), NULL) AS SECURITY_NAME_Natural,
                        CONVERT(VARCHAR(200), NULL) AS SECURITY_NAME_Enriched,
                        CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Natural,
                        CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Enriched
                    INTO ' + @SourceInternalTable + '
                    FROM ' + @KDriveTable + '  with (NOLOCK)'

        EXEC(@SQL)

        SET @SQL = 'SELECT *,
                           CONVERT(VARCHAR(50), NULL) AS PortfolioCode,
                           CONVERT(VARCHAR(200), NULL) AS SECURITY_NAME_Enriched,
                           CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Enriched
                    INTO ' + @TargetInternalTable + '
                    FROM ' + @DNATable + ' with (NOLOCK)
                    WHERE DATEDIFF(dd, StartDate, EndDate) IN (28, 29, 30, 31)'
        EXEC(@SQL)
        ---------------------------------------------------
        SET @SQL = 'CREATE CLUSTERED INDEX CIX_KDrive ON ' + @SourceInternalTable + '(CounterId)';
        EXEC(@SQL)

        SET @SQL = 'CREATE INDEX NCIX_KDrive_PortfolioCode ON ' + @SourceInternalTable + '(PortfolioCode, AttributionModelCode, ReportEndDate)';
        EXEC(@SQL)

        SET @SQL = 'CREATE INDEX NCIX_KDrive_FileID ON ' + @SourceInternalTable + '(FileID, AttributionMethodName)';
        EXEC(@SQL)
        ---------------------------------------------------
        -- Step #2: Update Breakdown column in KDrive table
        SET @SQL =
        '
        UPDATE A
        SET A.DNA_Breakdown = B.DNA_Breakdown
        FROM ' + @SourceInternalTable + ' A
            JOIN dbo.AttributionModelMapping B
                 ON A.PortfolioCode = B.PortfolioCode
                    AND A.AttributionModelCode = B.AttributionModelCode
                    AND A.AttributionMethodName = ''NCAS*CLS*AR''
                    AND B.SecurityFlag = ''N''
        '
        EXEC(@SQL)
        ---------------------------------------------------
        -- Validation to check if DNA_Breakdown is missing
        SET @SQL =
        '
        SELECT TOP(1) 1
        FROM ' + @SourceInternalTable + ' WITH (NOLOCK)
        WHERE DNA_Breakdown IS NULL
        '

        TRUNCATE TABLE #RecordCount;

        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        IF EXISTS(SELECT * FROM #RecordCount)
        BEGIN
            SET @ErrorMessage = 'Error: DNA_Breakdown could not be determined for one or more Legacy reports. Please check the DNA_Breakdown mapping'
            RAISERROR(@ErrorMessage, 16, 1)
        END
        ---------------------------------------------------
        -- Step #3: Update PortfolioCode column in DNA_Raw table
        SET @SQL =
        '
        UPDATE A
        SET A.PortfolioCode = B.PortfolioCode
        FROM ' + @TargetInternalTable + ' A
            JOIN dbo.PortfolioMaster B
                ON A.FundName = B.PortfolioName
        '
        EXEC(@SQL);
        ---------------------------------------------------
        -- Validation to check if PortfolioCode is missing
        SET @SQL =
        '
        SELECT TOP(1) 1
        FROM ' + @TargetInternalTable + ' WITH (NOLOCK)
        WHERE PortfolioCode IS NULL
        '

        TRUNCATE TABLE #RecordCount;

        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        IF EXISTS(SELECT * FROM #RecordCount)
        BEGIN
            SET @ErrorMessage = 'Error: PortfolioCode could not be determined for one or more DNA reports. Please check the PortfolioCode mapping'
            RAISERROR(@ErrorMessage, 16, 1)
        END
        ---------------------------------------------------
        -- Step #4: Standardization
        ---------------------------------------------------
        -- Setting the values to NULL if empty string
        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET Level1 = CASE WHEN LTRIM(RTRIM(Level1)) = '''' THEN NULL ELSE Level1 END,
            Level2 = CASE WHEN LTRIM(RTRIM(Level2)) = '''' THEN NULL ELSE Level2 END,
            Level3 = CASE WHEN LTRIM(RTRIM(Level3)) = '''' THEN NULL ELSE Level3 END,
        SecurityName = CASE WHEN LTRIM(RTRIM(SecurityName)) = '''' THEN NULL ELSE SecurityName END
        '
        EXEC(@SQL)
        ---------------------------------------------------
        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = SecurityName,
            PARENT_SECURITY_Enriched = Level1
        WHERE SecurityName IS NOT NULL
        AND Level1 IS NOT NULL
        AND Level2 IS NOT NULL
        AND Level3 IS NOT NULL
        AND SecurityName <> Level1
        AND SecurityName = Level2
        AND SecurityName = Level3
        AND SECURITY_NAME_Enriched IS NULL
        '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = SecurityName,
            PARENT_SECURITY_Enriched = Level3
        WHERE SecurityName IS NOT NULL
        AND Level1 IS NOT NULL
        AND Level2 IS NOT NULL
        AND Level3 IS NOT NULL
        AND SecurityName <> Level3
        AND SECURITY_NAME_Enriched IS NULL
        '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = SecurityName,
            PARENT_SECURITY_Enriched = ''TOTAL''
        WHERE SecurityName IS NOT NULL
        AND Level1 IS NOT NULL
        AND Level2 IS NOT NULL
        AND Level3 IS NOT NULL
        AND SecurityName = Level3
        AND SECURITY_NAME_Enriched IS NULL
        '
        EXEC(@SQL)
        --------------------------------------------------------
        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = SecurityName,
            PARENT_SECURITY_Enriched = Level2
        WHERE SecurityName IS NOT NULL
        AND Level1 IS NOT NULL
        AND Level2 IS NOT NULL
        AND Level3 IS NULL
        AND SecurityName <> Level2
        AND SECURITY_NAME_Enriched IS NULL
        '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = SecurityName,
            PARENT_SECURITY_Enriched = ''TOTAL''
        WHERE SecurityName IS NOT NULL
        AND Level1 IS NOT NULL
        AND Level2 IS NOT NULL
        AND Level3 IS NULL
        AND SecurityName = Level2
        AND SECURITY_NAME_Enriched IS NULL
        '
        EXEC(@SQL)
        --------------------------------------------------------
        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = SecurityName,
            PARENT_SECURITY_Enriched = Level1
        WHERE SecurityName IS NOT NULL
        AND Level1 IS NOT NULL
        AND Level2 IS NULL
        AND Level3 IS NULL
        AND SecurityName <> Level1
        AND SECURITY_NAME_Enriched IS NULL
        '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = SecurityName,
            PARENT_SECURITY_Enriched = ''TOTAL''
        WHERE SecurityName IS NOT NULL
        AND Level1 IS NOT NULL
        AND Level2 IS NULL
        AND Level3 IS NULL
        AND SecurityName = Level1
        AND SECURITY_NAME_Enriched IS NULL
        '
        EXEC(@SQL)
        --------------------------------------------------------
        SET @SQL =
        '
        UPDATE ' + @SourceInternalTable + '
        SET SECURITY_NAME_Natural = LTRIM(RTRIM(AssetClass_TAB)),
            SECURITY_NAME_Enriched = CASE
                                        WHEN LTRIM(RTRIM(AssetClass_TAB)) = ''Liquids'' THEN ''Cash and Equivalents (Liquids)''
                                        ELSE LTRIM(RTRIM(AssetClass_TAB))
                                     END;
         '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = CASE
                                        WHEN SecurityName = ''fund'' AND UPPER(Level1) = ''TOTAL'' THEN ''TOTAL''
                                        WHEN SecurityName = ''Cash and Equivalents'' THEN ''Cash and Equivalents (Liquids)''
                                        ELSE SECURITY_NAME_Enriched
                                     END,
            PARENT_SECURITY_Enriched =  CASE
                                            WHEN SecurityName = ''fund'' AND UPPER(Level1) = ''TOTAL'' THEN ''TOTAL''
                                            ELSE PARENT_SECURITY_Enriched
                                        END;
        '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET PARENT_SECURITY_Enriched = ''TOTAL''
        WHERE PARENT_SECURITY_Enriched IS NULL;
        '
        EXEC(@SQL);

        ---------------------------------------------------
        -- Step #5: Set Parent
        IF OBJECT_ID('tempdb..#Parent_Loop', 'U') IS NOT NULL DROP TABLE #Parent_Loop;
        CREATE TABLE #Parent_Loop
        (
            FileID VARCHAR(400) NOT NULL
        );

        IF OBJECT_ID('tempdb..#KDrive', 'U') IS NOT NULL DROP TABLE #KDrive;
        CREATE TABLE #KDrive
        (
            FileID VARCHAR(400),
            CounterId INT,
            SECURITY_NAME_Natural VARCHAR(200),
            SECURITY_NAME_Enriched VARCHAR(200),
            SpaceCount SMALLINT,
            PARENT_SECURITY_Natural VARCHAR(200),
            PARENT_SECURITY_Enriched VARCHAR(200)
        );

        SET @SQL =
        '
        SELECT DISTINCT FileID
        FROM ' + @SourceInternalTable + ' with (NOLOCK)
        WHERE AttributionMethodName = ''NCAS*CLS*AR''
        '

        INSERT INTO #Parent_Loop(FileID)
        EXEC(@SQL)

        WHILE EXISTS(SELECT * FROM #Parent_Loop)
        BEGIN
            SET @FileID = NULL

            SELECT TOP 1 @FileID = FileID
            FROM #Parent_Loop
            ORDER BY FileID ASC

            SET @SQL =
            '
            SELECT  FileID,
                    CounterId,
                    SECURITY_NAME_Natural,
                    SECURITY_NAME_Enriched,
                    PATINDEX(''%[A-Za-z0-9]%'', AssetClass_TAB) - 1 AS SpaceCount,
                    CONVERT(VARCHAR(1000), NULL) AS PARENT_SECURITY_Natural,
                    CONVERT(VARCHAR(1000), NULL) AS PARENT_SECURITY_Enriched
            FROM ' + @SourceInternalTable + ' with (NOLOCK)
            WHERE AttributionMethodName = ''NCAS*CLS*AR''
            AND FileID = ''' + @FileID + ''''

            IF EXISTS(SELECT * FROM tempdb.sys.indexes WHERE name = 'IX_KDrive' AND object_id = object_id('tempdb..#KDrive'))
            BEGIN
                DROP INDEX IX_KDrive ON #KDrive;
            END

            TRUNCATE TABLE #KDrive;

            INSERT INTO #KDrive
            (
                FileID,
                CounterId,
                SECURITY_NAME_Natural,
                SECURITY_NAME_Enriched,
                SpaceCount,
                PARENT_SECURITY_Natural,
                PARENT_SECURITY_Enriched
            )
            EXEC(@SQL)

            CREATE CLUSTERED INDEX IX_KDrive ON #KDrive(CounterId, FileId);
            --------------------------------------------------------
            UPDATE C
            SET C.PARENT_SECURITY_Natural = P.SECURITY_NAME_Natural,
                C.PARENT_SECURITY_Enriched = P.SECURITY_NAME_Enriched
            FROM #KDrive P
                JOIN
                (
                SELECT C.CounterId AS C_CounterId, MAX(P.CounterId) AS P_CounterId
                FROM #KDrive P
                        JOIN #KDrive C
                                ON P.CounterId < C.CounterId
                                AND P.SpaceCount < C.SpaceCount
                GROUP BY C.CounterId, C.SECURITY_NAME_Enriched
                ) X
                ON P.CounterId = X.P_CounterId
                JOIN #KDrive C
                ON C.CounterId = X.C_CounterId

            SET @SQL =
            '
            UPDATE A
            SET A.PARENT_SECURITY_Natural = B.PARENT_SECURITY_Natural,
                A.PARENT_SECURITY_Enriched = B.PARENT_SECURITY_Enriched
            FROM ' + @SourceInternalTable + ' A
                JOIN #KDrive B
                    ON A.AttributionMethodName = ''NCAS*CLS*AR''
                        AND A.FileID = B.FileID
                        AND A.CounterId = B.CounterId
                        AND A.SECURITY_NAME_Enriched = B.SECURITY_NAME_Enriched
            '
            EXEC(@SQL)

            DELETE
            FROM #Parent_Loop
            WHERE FileID = @FileID
        END;

        SET @SQL =
        '
        UPDATE ' + @SourceInternalTable + '
        SET PARENT_SECURITY_Natural = ''TOTAL'',
            PARENT_SECURITY_Enriched = ''TOTAL''
        WHERE PARENT_SECURITY_Enriched IS NULL
        AND UPPER(SECURITY_NAME_Enriched) = ''TOTAL''
        AND AttributionMethodName = ''NCAS*CLS*AR'';
        '
        EXEC(@SQL);
        -----------------------------------------------------------------------
        -- Step #9: Load Standardized Queries into Table
        SELECT  @SourceProcessedTable = 'dbo.KDrive_EQ_Pocket_Processed_' + @DateString,
                @TargetProcessedTable = 'dbo.DNA_EQ_Pocket_Processed_' + @DateString

        SET @SourceQuery =
        '
        SELECT
            PortfolioCode,
            DNA_Breakdown,
            PortfolioName,
            ReportEndDate,
            SECURITY_NAME_Enriched AS SECURITY_NAME,
            FileID,
            PARENT_SECURITY_Enriched AS PARENT_SECURITY,
            ISNULL(PORTFOLIO_ROR, 0) AS PORTFOLIO_ROR,
            ISNULL(INDEX_ROR, 0) AS INDEX_ROR,
            ISNULL(PORTFOLIO_WEIGHT_END, 0) AS PORTFOLIO_WEIGHT_END,
            ISNULL(PORTFOLIO_WEIGHT_AVERAGE, 0) AS PORTFOLIO_WEIGHT_AVERAGE,
            ISNULL(INDEX_WEIGHT_END, 0) AS INDEX_WEIGHT_END,
            ISNULL(INDEX_WEIGHT_AVERAGE, 0) AS INDEX_WEIGHT_AVERAGE,
            ISNULL(PORTFOLIO_CONTRIBUTION, 0) AS PORTFOLIO_CONTRIBUTION,
            ISNULL(INDEX_CONTRIBUTION, 0) AS INDEX_CONTRIBUTION,
            ISNULL(ASSET_WEIGHTING, 0) AS ALLOCATION_EFFECT,
            ISNULL(SECURITY_SELECTION, 0) AS SELECTION_EFFECT,
            ISNULL(CURRENCY_EFFECT, 0) AS CURRENCY_EFFECT
        FROM ' + @SourceInternalTable + '
        WHERE AttributionMethodName = ''NCAS*CLS*AR''
        '

        SET @TargetQuery =
        '
        SELECT
            PortfolioCode,
            DNA_Breakdown,
            [FundName] as PortfolioName,
            EndDate AS ReportEndDate,
            SECURITY_NAME_Enriched AS SECURITY_NAME,
            FileID,
            PARENT_SECURITY_Enriched AS PARENT_SECURITY,
            100.0  * [PortfolioReturn_Base] as PORTFOLIO_ROR,
            100.0  * [BenchReturn_Base] as INDEX_ROR,
            100.0  * [FundEndPeriodWeight] as PORTFOLIO_WEIGHT_END,
            100.0  * [PortfolioWeight] as PORTFOLIO_WEIGHT_AVERAGE,
            100.0  * [BenchEndPeriodWeight] as INDEX_WEIGHT_END,
            100.0  * [BenchWeight] as INDEX_WEIGHT_AVERAGE,
            100.0  * [PortfolioContrib] as PORTFOLIO_CONTRIBUTION,
            100.0  * [BenchContrib] as INDEX_CONTRIBUTION,
            100.0  * [AllocationEffect] as ALLOCATION_EFFECT,
            100.0  * [SelectionEffect] as SELECTION_EFFECT,
            100.0  * [CurrencyEffect] as CURRENCY_EFFECT
        FROM ' + @TargetInternalTable + '
        WHERE DNA_Breakdown LIKE ''%POCKET''
        '
        EXEC TestAutomation.dbo.LoadQuery @Query = @SourceQuery,
                                          @LinkedServer = NULL,
                                          @TableName = @SourceProcessedTable;

        EXEC TestAutomation.dbo.LoadQuery @Query = @TargetQuery,
                                          @LinkedServer = NULL,
                                          @TableName = @TargetProcessedTable;
        ---------------------------------------------------
        -- Step #10 - Run Comparison
        EXEC TestAutomation.dbo.Compare
            @SourceTable = @SourceProcessedTable,
            @TargetTable = @TargetProcessedTable,
            @MatchKeySourceList = 'PortfolioCode, ReportEndDate, DNA_Breakdown, PARENT_SECURITY, SECURITY_NAME',
            @ExcludedColumnSourceList = NULL,
            @ExcludedColumnTargetList = NULL,
            @DisplayOnlyColumnSourceList = 'FileID',
            @DisplayOnlyColumnTargetList = 'FileID',
            @ColumnMappingList = NULL,
            @NumericTolerance = @NumericTolerance,
            @CaseSensitiveFlag = 0,
            @IgnoreOrphanColumnsFlag  = 1,
            @OptimizedStorageFlag = 1,
            @SourceMoniker = @SourceMoniker,
            @TargetMoniker = @TargetMoniker,
            @ComparisonGUID = NULL,
            @ComparisonRequestId = @ComparisonRequestId OUTPUT
        ---------------------------------------------------
        -- Step #11 - Review Results
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

GO




