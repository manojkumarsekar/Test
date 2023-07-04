USE [TestAutomation]
GO
IF OBJECT_ID('[dbo].[Compare_Equity_Security]', 'P') IS NOT NULL DROP PROCEDURE [dbo].[Compare_Equity_Security];
GO
CREATE PROCEDURE [dbo].[Compare_Equity_Security]
(
    @KDriveTable VARCHAR(300), -- 'TestAutomation.dbo.KDrive_EQ_Security_Raw_20180117105031653'
    @DNATable VARCHAR(300), -- 'TestAutomation.dbo.DNA_EQ_Security_Raw_20180117105031653'
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
    -- SankaranS    21-Jan-2018    Initial Version
    -- SankaranS    07-Feb-2018    Filter DNA records "WHERE DATEDIFF(dd, StartDate, EndDate) IN (28, 29, 30, 31)"
    -- SankaranS    07-Feb-2018    Parent_Security_Enriched column for Country is not stamped with "TOTAL"


    --EXEC TestAutomation.dbo.Compare_Equity_Security
    --    @KDriveTable = 'TestAutomation.dbo.KDrive_EQ_Security_Raw_20180117105031653',
    --    @DNATable = 'TestAutomation.dbo.DNA_EQ_Security_Raw_20180117105031653',
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
            @SECURITY_NAME_Enriched VARCHAR(200),
            @ISIN_Count SMALLINT,
            @ISIN_Lookup VARCHAR(400),
            @ISIN_Found BIT

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
        -- Step #1: Load Source and Target into staging tables
        --          Add additional columns for data-enrichment purposes
        SELECT  @SourceInternalTable = 'dbo.KDrive_EQ_Security_Internal_' + @DateString,
                @TargetInternalTable = 'dbo.DNA_EQ_Security_Internal_' + @DateString

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
                        CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Enriched,
                        CONVERT(BIT, NULL) AS LeafInd,
                        CONVERT(VARCHAR(400), NULL) AS ISIN_Enriched,
                        CONVERT(VARCHAR(3), NULL) AS ISIN_Source,
                        CONVERT(VARCHAR(10), NULL) AS ISIN_MatchType
                    INTO ' + @SourceInternalTable + '
                    FROM ' + @KDriveTable + '  with (NOLOCK)'

        EXEC(@SQL)

        SET @SQL = 'SELECT *,
                           CONVERT(VARCHAR(50), NULL) AS PortfolioCode,
                           CONVERT(VARCHAR(200), NULL) AS SECURITY_NAME_Enriched,
                           CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Enriched,
                           CONVERT(VARCHAR(400), NULL) AS ISIN_Enriched
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

        IF EXISTS(SELECT * FROM sys.indexes WHERE name = 'CIX_Security_ISIN' AND object_id = object_id('dbo.Security_ISIN', 'U'))
        BEGIN
            DROP INDEX CIX_Security_ISIN ON dbo.Security_ISIN;
        END;

        CREATE CLUSTERED INDEX CIX_Security_ISIN ON dbo.Security_ISIN(PortfolioCode, AttributionModelCode, ReportEndDate, SecurityFlag, PARENT_SECURITY_NAME, SECURITY_NAME);
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
                    AND A.AttributionMethodName = ''NCAS*SEC*AR''
                    AND B.SecurityFlag = ''Y''
        '
        EXEC(@SQL)
        ---------------------------------------------------
        -- Validation to check if DNA_Breakdown is missing
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
        EXEC(@SQL)
        ---------------------------------------------------
        -- Validation to check if PortfolioCode is missing
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
            ISIN = CASE WHEN LTRIM(RTRIM(ISIN)) = '''' THEN NULL ELSE ISIN END
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
                                            WHEN COALESCE(Level3, Level2, Level1) = ''Cash and Equivalents'' THEN ''Cash and Equivalents (Liquids)''
                                            ELSE PARENT_SECURITY_Enriched
                                        END;
        '
        EXEC(@SQL)
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
            PARENT_SECURITY_Enriched VARCHAR(200),
            LeafInd BIT
        );

        SET @SQL =
        '
        SELECT DISTINCT FileID
        FROM ' + @SourceInternalTable + ' with (NOLOCK)
        WHERE AttributionMethodName = ''NCAS*SEC*AR''
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
                    CONVERT(VARCHAR(1000), NULL) AS PARENT_SECURITY_Enriched,
                    CONVERT(BIT, NULL) AS LeafInd
            FROM ' + @SourceInternalTable + ' with (NOLOCK)
            WHERE AttributionMethodName = ''NCAS*SEC*AR''
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
                PARENT_SECURITY_Enriched,
                LeafInd
            )
            EXEC(@SQL)

            CREATE CLUSTERED INDEX IX_KDrive ON #KDrive(CounterId, FileId);
            --------------------------------------------------------
            UPDATE #KDrive
            SET LeafInd = 1
            WHERE CounterId NOT IN
            (
                SELECT DISTINCT P.CounterId AS P_CounterId
                FROM #KDrive P
                        JOIN #KDrive C
                                ON P.CounterId < C.CounterId
                                AND P.SpaceCount < C.SpaceCount
            )

            UPDATE #KDrive
                SET LeafInd = 0
            WHERE LeafInd IS NULL
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
                A.PARENT_SECURITY_Enriched = B.PARENT_SECURITY_Enriched,
                A.LeafInd = B.LeafInd
            FROM ' + @SourceInternalTable + ' A
                JOIN #KDrive B
                    ON A.AttributionMethodName = ''NCAS*SEC*AR''
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
        AND AttributionMethodName = ''NCAS*SEC*AR'';
        '
        EXEC(@SQL);

        ---------------------------------------------------
        -- Step #5: Updated ISIN based on DMP
        SET @SQL =
        '
        UPDATE A
        SET A.ISIN_Enriched = B.ISIN,
            A.ISIN_Source = ''DMP'',
            A.ISIN_MatchType = ''Exact''
        FROM ' + @SourceInternalTable + ' A
            JOIN TestAutomation.dbo.Security_ISIN B
                ON A.PortfolioCode = B.PortfolioCode
                    AND A.AttributionModelCode = B.AttributionModelCode
                    AND A.ReportEndDate = B.ReportEndDate
                    AND A.PARENT_SECURITY_Natural = ISNULL(B.PARENT_SECURITY_NAME, ''TOTAL'')
                    AND A.SECURITY_NAME_Natural = B.SECURITY_NAME
                    AND A.AttributionMethodName = ''NCAS*SEC*AR''
                    AND B.SecurityFlag = ''Y''
                    AND A.ISIN_Enriched IS NULL
                    AND A.ISIN_Source IS NULL
                    AND A.ISIN_MatchType IS NULL;
        '
        EXEC(@SQL)
        ---------------------------------------------------
        -- Step #6: Update ISIN based on DMP Soundex
        IF OBJECT_ID('tempdb..#ISINHuntDMP', 'U') IS NOT NULL DROP TABLE #ISINHuntDMP;
        CREATE TABLE #ISINHuntDMP
        (
            PortfolioCode VARCHAR(50),
            AttributionModelCode VARCHAR(50),
            ReportEndDate DATE,
            PARENT_SECURITY_Natural VARCHAR(200),
            SECURITY_NAME_Natural VARCHAR(200),
            PARENT_SECURITY_Enriched VARCHAR(200),
            SECURITY_NAME_Enriched VARCHAR(200),
            DNA_Breakdown VARCHAR(50),
            ISIN_Enriched VARCHAR(250),
            ISIN_Source VARCHAR(3),
            ISIN_MatchType VARCHAR(10)
        );

        IF OBJECT_ID('tempdb..#ISIN_DMP', 'U') IS NOT NULL DROP TABLE #ISIN_DMP;
        CREATE TABLE #ISIN_DMP
        (
            ISIN VARCHAR(250)
        );

        SET @SQL =
        '
        SELECT
            PortfolioCode,
            AttributionModelCode,
            ReportEndDate,
            PARENT_SECURITY_Natural,
            SECURITY_NAME_Natural,
            PARENT_SECURITY_Enriched,
            SECURITY_NAME_Enriched,
            DNA_Breakdown,
            ISIN_Enriched,
            ISIN_Source,
            ISIN_MatchType
        FROM ' + @SourceInternalTable + ' with (NOLOCK)
        WHERE AttributionMethodName = ''NCAS*SEC*AR''
        AND ISIN_Enriched IS NULL
        AND ISIN_Source IS NULL
        AND ISIN_MatchType IS NULL
        AND LeafInd = 1
        '

        INSERT INTO #ISINHuntDMP
        (
            PortfolioCode,
            AttributionModelCode,
            ReportEndDate,
            PARENT_SECURITY_Natural,
            SECURITY_NAME_Natural,
            PARENT_SECURITY_Enriched,
            SECURITY_NAME_Enriched,
            DNA_Breakdown,
            ISIN_Enriched,
            ISIN_Source,
            ISIN_MatchType
        )
        EXEC(@SQL)

        CREATE CLUSTERED INDEX CIX_ISINHuntDMP ON #ISINHuntDMP(PortfolioCode, AttributionModelCode, ReportEndDate, PARENT_SECURITY_Natural, SECURITY_NAME_Natural);

        WHILE EXISTS(SELECT * FROM #ISINHuntDMP)
        BEGIN
            SET @ISIN_Count = 0
            SET @ISIN_Lookup = NULL
            SET @ISIN_Found = 0

            SELECT TOP 1
                @PortfolioCode = PortfolioCode,
                @AttributionModelCode = AttributionModelCode,
                @ReportEndDate = ReportEndDate,
                @PARENT_SECURITY_Natural = PARENT_SECURITY_Natural,
                @SECURITY_NAME_Natural = SECURITY_NAME_Natural,
                @PARENT_SECURITY_Enriched = PARENT_SECURITY_Enriched,
                @SECURITY_NAME_Enriched = SECURITY_NAME_Enriched,
                @DNA_Breakdown = DNA_Breakdown
            FROM #ISINHuntDMP
            ORDER BY PortfolioCode, AttributionModelCode, ReportEndDate, PARENT_SECURITY_Natural, SECURITY_NAME_Natural
            -----------------------------------------------------------------------
            SET @SQL =
            '
            SELECT ISIN
            FROM dbo.Security_ISIN with (NOLOCK)
            WHERE PortfolioCode = ''' + @PortfolioCode + '''
            AND AttributionModelCode = ''' + @AttributionModelCode + '''
            AND ReportEndDate = ''' + CONVERT(VARCHAR(30), @ReportEndDate, 112) + '''
            AND PARENT_SECURITY_NAME = ''' + @PARENT_SECURITY_Natural + '''
            AND SOUNDEX(SECURITY_NAME) = SOUNDEX(''' + @SECURITY_NAME_Natural + ''')
            AND SECURITY_NAME <> ''' + @SECURITY_NAME_Natural + '''
            AND SecurityFlag = ''Y''
            AND ISIN IS NOT NULL
            AND ISIN NOT IN
            (
                SELECT ISIN_Enriched
                FROM ' + @SourceInternalTable + ' with (NOLOCK)
                WHERE PortfolioCode = ''' + @PortfolioCode + '''
                AND AttributionModelCode = ''' +  @AttributionModelCode + '''
                AND ReportEndDate = ''' + CONVERT(VARCHAR(30), @ReportEndDate, 112) + '''
                AND PARENT_SECURITY_Natural = ''' +  @PARENT_SECURITY_Natural + '''
                AND AttributionMethodName = ''NCAS*SEC*AR''
                AND ISIN_Enriched IS NOT NULL
            )
            '
            TRUNCATE TABLE #ISIN_DMP;

            INSERT INTO #ISIN_DMP(ISIN)
            EXEC(@SQL)

            SELECT @ISIN_Count = COUNT(*)
            FROM #ISIN_DMP
            WHERE ISNULL(ISIN, '') <> ''

            SET @ISIN_Count = ISNULL(@ISIN_Count, 0);

            IF @ISIN_Count = 1
            BEGIN
                SELECT @ISIN_Lookup = ISIN
                FROM #ISIN_DMP
                WHERE ISNULL(ISIN, '') <> ''

                SET @SQL =
                '
                UPDATE ' + @SourceInternalTable + '
                SET ISIN_Enriched = ''' + @ISIN_Lookup + ''',
                    ISIN_Source = ''DMP'',
                    ISIN_MatchType = ''Soundex''
                WHERE AttributionMethodName = ''NCAS*SEC*AR''
                AND PortfolioCode = ''' + @PortfolioCode + '''
                AND AttributionModelCode = ''' + @AttributionModelCode + '''
                AND ReportEndDate = ''' + CONVERT(VARCHAR(30), @ReportEndDate, 112) + '''
                AND PARENT_SECURITY_Natural = ''' + @PARENT_SECURITY_Natural + '''
                AND SECURITY_NAME_Natural = ''' + @SECURITY_NAME_Natural + ''''

                EXEC(@SQL)
            END

            DELETE
            FROM #ISINHuntDMP
            WHERE PortfolioCode = @PortfolioCode
            AND AttributionModelCode = @AttributionModelCode
            AND ReportEndDate = @ReportEndDate
            AND PARENT_SECURITY_Natural = @PARENT_SECURITY_Natural
            AND SECURITY_NAME_Natural = @SECURITY_NAME_Natural
        END
        ---------------------------------------------------
        -- Step #7: Update ISIN based on DNA Soundex
        IF OBJECT_ID('tempdb..#ISINHuntDNA', 'U') IS NOT NULL DROP TABLE #ISINHuntDNA;
        CREATE TABLE #ISINHuntDNA
        (
            PortfolioCode VARCHAR(50),
            AttributionModelCode VARCHAR(50),
            ReportEndDate DATE,
            PARENT_SECURITY_Natural VARCHAR(200),
            SECURITY_NAME_Natural VARCHAR(200),
            PARENT_SECURITY_Enriched VARCHAR(200),
            SECURITY_NAME_Enriched VARCHAR(200),
            DNA_Breakdown VARCHAR(50),
            ISIN_Enriched VARCHAR(250),
            ISIN_Source VARCHAR(3),
            ISIN_MatchType VARCHAR(10)
        );

        IF OBJECT_ID('tempdb..#ISIN_DNA', 'U') IS NOT NULL DROP TABLE #ISIN_DNA;
        CREATE TABLE #ISIN_DNA
        (
            ISIN VARCHAR(250)
        );

        SET @SQL =
        '
        SELECT
            PortfolioCode,
            AttributionModelCode,
            ReportEndDate,
            PARENT_SECURITY_Natural,
            SECURITY_NAME_Natural,
            PARENT_SECURITY_Enriched,
            SECURITY_NAME_Enriched,
            DNA_Breakdown,
            ISIN_Enriched,
            ISIN_Source,
            ISIN_MatchType
        FROM ' + @SourceInternalTable + ' with (NOLOCK)
        WHERE AttributionMethodName = ''NCAS*SEC*AR''
        AND ISIN_Enriched IS NULL
        AND ISIN_Source IS NULL
        AND ISIN_MatchType IS NULL
        AND LeafInd = 1;
        '

        INSERT INTO #ISINHuntDNA
        (
            PortfolioCode,
            AttributionModelCode,
            ReportEndDate,
            PARENT_SECURITY_Natural,
            SECURITY_NAME_Natural,
            PARENT_SECURITY_Enriched,
            SECURITY_NAME_Enriched,
            DNA_Breakdown,
            ISIN_Enriched,
            ISIN_Source,
            ISIN_MatchType
        )
        EXEC(@SQL)

        CREATE CLUSTERED INDEX CIX_ISINHuntDNA ON #ISINHuntDNA(PortfolioCode, AttributionModelCode, ReportEndDate, PARENT_SECURITY_Natural, SECURITY_NAME_Natural);

        WHILE EXISTS(SELECT * FROM #ISINHuntDNA)
        BEGIN
            SET @ISIN_Count = 0
            SET @ISIN_Lookup = NULL
            SET @ISIN_Found = 0

            SELECT TOP 1
                @PortfolioCode = PortfolioCode,
                @AttributionModelCode = AttributionModelCode,
                @ReportEndDate = ReportEndDate,
                @PARENT_SECURITY_Natural = PARENT_SECURITY_Natural,
                @SECURITY_NAME_Natural = SECURITY_NAME_Natural,
                @PARENT_SECURITY_Enriched = PARENT_SECURITY_Enriched,
                @SECURITY_NAME_Enriched = SECURITY_NAME_Enriched,
                @DNA_Breakdown = DNA_Breakdown
            FROM #ISINHuntDNA
            ORDER BY PortfolioCode, AttributionModelCode, ReportEndDate, PARENT_SECURITY_Natural, SECURITY_NAME_Natural
            -----------------------------------------------------------------------
            SET @SQL =
            '
            SELECT ISIN
            FROM ' + @TargetInternalTable + ' with (NOLOCK)
            WHERE PortfolioCode = ''' + @PortfolioCode + '''
            AND DNA_Breakdown = ''' + @DNA_Breakdown + '''
            AND EndDate = ''' + CONVERT(VARCHAR(30), @ReportEndDate, 112) + '''
            AND PARENT_SECURITY_Enriched = ''' + @PARENT_SECURITY_Enriched + '''
            AND SOUNDEX(SECURITY_NAME_Enriched) = SOUNDEX(''' + @SECURITY_NAME_Enriched + ''')
            AND ISIN IS NOT NULL
            AND ISIN NOT IN
            (
                SELECT ISIN_Enriched
                FROM ' + @SourceInternalTable + ' with (NOLOCK)
                WHERE PortfolioCode = ''' + @PortfolioCode + '''
                AND AttributionModelCode = ''' +  @AttributionModelCode + '''
                AND ReportEndDate = ''' + CONVERT(VARCHAR(30), @ReportEndDate, 112) + '''
                AND PARENT_SECURITY_Natural = ''' +  @PARENT_SECURITY_Natural + '''
                AND AttributionMethodName = ''NCAS*SEC*AR''
                AND ISIN_Enriched IS NOT NULL
            )
            '

            TRUNCATE TABLE #ISIN_DNA;

            INSERT INTO #ISIN_DNA(ISIN)
            EXEC(@SQL)

            SELECT @ISIN_Count = COUNT(*)
            FROM #ISIN_DNA
            WHERE ISNULL(ISIN, '') <> ''

            SET @ISIN_Count = ISNULL(@ISIN_Count, 0);

            IF @ISIN_Count = 1
            BEGIN
                SELECT @ISIN_Lookup = ISIN
                FROM #ISIN_DNA
                WHERE ISNULL(ISIN, '') <> ''

                SET @SQL =
                '
                UPDATE ' + @SourceInternalTable + '
                SET ISIN_Enriched = ''' + @ISIN_Lookup + ''',
                    ISIN_Source = ''DNA'',
                    ISIN_MatchType = ''Soundex''
                WHERE AttributionMethodName = ''NCAS*SEC*AR''
                AND PortfolioCode = ''' + @PortfolioCode + '''
                AND AttributionModelCode = ''' + @AttributionModelCode + '''
                AND ReportEndDate = ''' + CONVERT(VARCHAR(30), @ReportEndDate, 112) + '''
                AND PARENT_SECURITY_Natural = ''' + @PARENT_SECURITY_Natural + '''
                AND SECURITY_NAME_Natural = ''' + @SECURITY_NAME_Natural + '''
                '

                EXEC(@SQL)
            END

            DELETE
            FROM #ISINHuntDNA
            WHERE PortfolioCode = @PortfolioCode
            AND AttributionModelCode = @AttributionModelCode
            AND ReportEndDate = @ReportEndDate
            AND PARENT_SECURITY_Natural = @PARENT_SECURITY_Natural
            AND SECURITY_NAME_Natural = @SECURITY_NAME_Natural
        END
        -----------------------------------------------------------------------
        -- Step #8: Set Dummy ISIN
        SET @SQL =
        '
        UPDATE ' + @SourceInternalTable + '
        SET ISIN_Enriched = ''ISIN_'' + PARENT_SECURITY_Enriched + ''_'' + SECURITY_NAME_Enriched
        WHERE ISIN_Enriched IS NULL
        '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET ISIN_Enriched = CASE
                                WHEN ISIN IS NOT NULL THEN ISIN
                                ELSE ''ISIN_'' + PARENT_SECURITY_Enriched + ''_'' + SECURITY_NAME_Enriched
                            END
        WHERE ISIN_Enriched IS NULL
        '
        EXEC(@SQL)
        -----------------------------------------------------------------------
        -- Step #9: Load Standardized Queries into Table
        SELECT  @SourceProcessedTable = 'dbo.KDrive_EQ_Security_Processed_' + @DateString,
                @TargetProcessedTable = 'dbo.DNA_EQ_Security_Processed_' + @DateString

        SET @SourceQuery =
        '
        SELECT
            PortfolioCode,
            DNA_Breakdown,
            PortfolioName,
            ReportEndDate,
            ISIN_Enriched AS ISIN,
            LTRIM(RTRIM(AssetClass_TAB)) AS SECURITY_NAME,
            PARENT_SECURITY_Enriched AS PARENT_SECURITY,
            ISNULL(PORTFOLIO_ROR, 0) AS PORTFOLIO_ROR,
            ISNULL(INDEX_ROR, 0) AS INDEX_ROR,
            ISNULL(PORTFOLIO_WEIGHT_END, 0) AS PORTFOLIO_WEIGHT_END,
            ISNULL(PORTFOLIO_WEIGHT_AVERAGE, 0) AS PORTFOLIO_WEIGHT_AVERAGE,
            ISNULL(INDEX_WEIGHT_END, 0) AS INDEX_WEIGHT_END,
            ISNULL(INDEX_WEIGHT_AVERAGE, 0) AS INDEX_WEIGHT_AVERAGE,
            ISNULL(PORTFOLIO_CONTRIBUTION, 0) AS PORTFOLIO_CONTRIBUTION,
            ISNULL(INDEX_CONTRIBUTION, 0) AS INDEX_CONTRIBUTION,
            ISNULL(SECURITY_WEIGHTING, 0) AS SECURITY_WEIGHTING,
            ISNULL(ASSET_WEIGHTING, 0) AS ASSET_WEIGHTING,
            ISNULL(SECURITY_TIMING, 0) AS SECURITY_TIMING,
            ISNULL(SECURITY_SELECTION, 0) AS SECURITY_SELECTION,
            ISNULL(CURRENCY_EFFECT, 0) AS CURRENCY_EFFECT
        FROM ' + @SourceInternalTable + '
        WHERE AttributionMethodName = ''NCAS*SEC*AR''
        '

        SET @TargetQuery =
        '
        SELECT
            PortfolioCode,
            DNA_Breakdown,
            [FundName] as PortfolioName,
            EndDate AS ReportEndDate,
            ISIN_Enriched AS ISIN,
            SecurityName AS SECURITY_NAME,
            PARENT_SECURITY_Enriched AS PARENT_SECURITY,
            100.0  * [PortfolioReturn_Base] as PORTFOLIO_ROR,
            100.0  * [BenchReturn_Base] as INDEX_ROR,
            100.0  * [FundEndPeriodWeight] as PORTFOLIO_WEIGHT_END,
            100.0  * [PortfolioWeight] as PORTFOLIO_WEIGHT_AVERAGE,
            100.0  * [BenchEndPeriodWeight] as INDEX_WEIGHT_END,
            100.0  * [BenchWeight] as INDEX_WEIGHT_AVERAGE,
            100.0  * [PortfolioContrib] as PORTFOLIO_CONTRIBUTION,
            100.0  * [BenchContrib] as INDEX_CONTRIBUTION,
            100.0  * [AllocationEffect] as SECURITY_WEIGHTING,
            100.0  * [SelectionEffect] as SECURITY_TIMING,
            100.0  * [CurrencyEffect] as CURRENCY_EFFECT
        FROM ' + @TargetInternalTable + '
        WHERE DNA_Breakdown LIKE ''%SECURITY%''
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
            @MatchKeySourceList = 'PortfolioCode, DNA_Breakdown, ReportEndDate, PARENT_SECURITY, ISIN',
            @ExcludedColumnSourceList = NULL,
            @ExcludedColumnTargetList = NULL,
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




