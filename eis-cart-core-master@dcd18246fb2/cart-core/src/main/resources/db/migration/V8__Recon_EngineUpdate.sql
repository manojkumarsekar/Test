USE TestAutomation;
GO

--  Revison History
--  ==================================================================
--  ModifiedBy      ModifiedDate    Comments
--  ----------      ------------    --------
--  SS              05/08/2017      Initial Version (Draft)
--  SS              10/02/2018      Added Display-Only Column feature
--  ==================================================================

IF OBJECT_ID('TestAutomation.dbo.ComparisonRequest', 'U') IS NOT NULL DROP TABLE TestAutomation.dbo.ComparisonRequest;
GO
CREATE TABLE TestAutomation.dbo.ComparisonRequest
(
    ComparisonRequestId INTEGER NOT NULL IDENTITY(1, 1),
    ComparisonGUID UNIQUEIDENTIFIER NOT NULL,
    SourceTable NVARCHAR(400) NOT NULL,
    SourceRecordCount INT NULL,
    TargetTable NVARCHAR(400) NOT NULL,
    TargetRecordCount INT NULL,
    MatchKeySourceList NVARCHAR(MAX) NOT NULL,
    ExcludedColumnSourceList NVARCHAR(MAX) NULL,
    ExcludedColumnTargetList NVARCHAR(MAX) NULL,
    DisplayOnlyColumnSourceList NVARCHAR(MAX) NULL,
    DisplayOnlyColumnTargetList NVARCHAR(MAX) NULL,
    ColumnMappingList NVARCHAR(MAX) NULL,
    NumericTolerance NUMERIC(10, 6) NOT NULL DEFAULT 0.0,
    CaseSensitive BIT NOT NULL DEFAULT 0,
    IgnoreOrphanColumns BIT NOT NULL DEFAULT 0,
    OptimizedStorage BIT NOT NULL DEFAULT 1,
    ComparisonStatus NVARCHAR(50) NULL,
    [Source] NVARCHAR(400) NULL,
    [Target] NVARCHAR(400) NULL,
    SourceDuplicate NVARCHAR(400) NULL,
    SourceDuplicateRecordCount INT NULL,
    TargetDuplicate NVARCHAR(400) NULL,
    TargetDuplicateRecordCount INT NULL,
    SourceSurplus NVARCHAR(400) NULL,
    SourceSurplusRecordCount INT NULL,
    TargetSurplus NVARCHAR(400) NULL,
    TargetSurplusRecordCount INT NULL,
    Mismatch NVARCHAR(400) NULL,
    MismatchRecordCount INT NULL,
    [Match] NVARCHAR(400) NULL,
    MatchRecordCount INT NULL,
    MismatchSmell NVARCHAR(400) NULL,
    StartTime DATETIME2 NOT NULL,
    EndTime DATETIME2 NULL,
    UserName NVARCHAR(400) NULL,
    ErrorMessage VARCHAR(MAX) NULL,
    CONSTRAINT PK_ComparisonRequest PRIMARY KEY (ComparisonRequestId)
);
CREATE UNIQUE NONCLUSTERED INDEX IX_ComparisonGUID ON TestAutomation.dbo.ComparisonRequest(ComparisonGUID);
GO




--  Revison History
--  ==================================================================
--  ModifiedBy      ModifiedDate    Comments
--  ----------      ------------    --------
--  SS              05/08/2017      Initial Version (Draft)
--  SS              10/02/2018      Added Display-Only Column feature
--  ==================================================================

IF OBJECT_ID('TestAutomation.dbo.ColumnCategory', 'U') IS NOT NULL DROP TABLE TestAutomation.dbo.ColumnCategory;
GO
CREATE TABLE TestAutomation.dbo.ColumnCategory
(
    ComparisonRequestId INTEGER NOT NULL,
    ColumnOrder SMALLINT NULL,
    SourceColumn NVARCHAR(128) NULL,
    TargetColumn NVARCHAR(128) NULL,
    SourceDataType NVARCHAR(128) NULL,
    TargetDataType NVARCHAR(128) NULL,
    SourceDataLength INT NULL,
    TargetDataLength INT NULL,
    SourceDistinctCount INT NULL,
    TargetDistinctCount INT NULL,
    CombinedDistinctCount INT NULL,
    MatchKeyFlag BIT NULL,
    KeyOrder INT NULL,
    KeyDisplayOrder INT NULL,
    SourceExcludedFlag BIT NULL,
    TargetExcludedFlag BIT NULL,
    SourceDisplayOnlyFlag BIT NULL,
    TargetDisplayOnlyFlag BIT NULL,
    SkippedDataTypeFlag BIT NULL,
    Category NVARCHAR(20) NULL
);
GO
CREATE UNIQUE CLUSTERED INDEX IX_ColumnCategory ON TestAutomation.dbo.ColumnCategory(ComparisonRequestId, ColumnOrder, SourceColumn, TargetColumn);
GO



IF OBJECT_ID('TestAutomation.dbo.Compare', 'P') IS NOT NULL DROP PROCEDURE dbo.Compare;
GO

CREATE PROCEDURE dbo.Compare
(
    @SourceTable NVARCHAR(400),                         -- TestAutomation.dbo.Product
    @TargetTable NVARCHAR(400),                         -- TestAutomation.dbo.Product_New
    @MatchKeySourceList NVARCHAR(MAX),                  -- [ProductId], [Name]
    @ExcludedColumnSourceList NVARCHAR(MAX) = NULL,     -- [SellStartDate], [SellEndDate], [rowguid]
    @ExcludedColumnTargetList NVARCHAR(MAX) = NULL,     -- [SellStartDate], [SellEndDate], [rowguid]
    @DisplayOnlyColumnSourceList NVARCHAR(MAX) = NULL,     -- [Size], [Weight]
    @DisplayOnlyColumnTargetList NVARCHAR(MAX) = NULL,     -- [Size], [Weight]
    @ColumnMappingList NVARCHAR(MAX) = '[ProductNumber]::[ProductNumber_New], [Color]::[Color_New]',
    @NumericTolerance NUMERIC(10,6) = NULL,             -- 0.00
    @CaseSensitiveFlag BIT = 0,                         -- 0
    @IgnoreOrphanColumnsFlag BIT = 0,                   -- 0
    @OptimizedStorageFlag BIT = 1,                      -- 1
    @SourceMoniker VARCHAR(8) = 'A',
    @TargetMoniker VARCHAR(8) = 'B',
    @ComparisonGUID UNIQUEIDENTIFIER = NULL,            -- 9AC4AA0D-9997-45BB-9E53-9119A675D887
    @ComparisonRequestId INTEGER = NULL OUTPUT
)
WITH RECOMPILE
AS
BEGIN
--  Revison History
--  ==================================================================
--  ModifiedBy      ModifiedDate    Comments
--  ----------      ------------    --------
--  SS              05/08/2017      Initial Version (Draft)
--  SS              10/02/2018      Added Display-Only Column feature
--  ==================================================================
    BEGIN TRY
        SET NOCOUNT ON;
        SET ANSI_WARNINGS ON;

        DECLARE @Source NVARCHAR(400) = '',
                @Target NVARCHAR(400) = '',
                @SourceDuplicate NVARCHAR(400) = '',
                @TargetDuplicate NVARCHAR(400) = '',
                @SourceSurplus NVARCHAR(400) = '',
                @TargetSurplus NVARCHAR(400) = '',
                @Mismatch NVARCHAR(400) = '',
                @Match NVARCHAR(400) = '',
                @MismatchSmell NVARCHAR(400) = '',
                @SourceRecordCount BIGINT,
                @TargetRecordCount BIGINT,
                @SourceDuplicateRecordCount BIGINT,
                @TargetDuplicateRecordCount BIGINT,
                @SourceSurplusRecordCount BIGINT,
                @TargetSurplusRecordCount BIGINT,
                @MismatchRecordCount BIGINT,
                @MatchRecordCount BIGINT,
                @ColumnPairSourceList NVARCHAR(MAX) = '',
                @ColumnPairTargetList NVARCHAR(MAX) = '',
                @ColumnListA VARCHAR(MAX) = '',
                @ColumnListB VARCHAR(MAX) = '',
                @KeyListA VARCHAR(MAX) = '',
                @KeyListB VARCHAR(MAX) = '',
                @NonKeySourceList VARCHAR(MAX) = '',
                @NonKeyListAB VARCHAR(MAX) = '',
                @DisplayOnlyListA VARCHAR(MAX) = '',
                @DisplayOnlyListB VARCHAR(MAX) = '',
                @MismatchFilterListNumericAB VARCHAR(MAX) = '',
                @MismatchFilterListIntegerAB VARCHAR(MAX) = '',
                @MismatchFilterListStringAB VARCHAR(MAX) = '',
                @MismatchFilterListDateAB VARCHAR(MAX) = '',
                @MatchFilterListNumericAB VARCHAR(MAX) = '',
                @MatchFilterListIntegerAB VARCHAR(MAX) = '',
                @MatchFilterListStringAB VARCHAR(MAX) = '',
                @MatchFilterListDateAB VARCHAR(MAX) = '',
                @KeyNullListA VARCHAR(MAX) = '',
                @KeyNullListB VARCHAR(MAX) = '',
                @SmellList VARCHAR(MAX) = '',
                @JoinAB VARCHAR(MAX) = '',
                @Message NVARCHAR(1000) = '',
                @ErrorMessage NVARCHAR(1000) = '',
                @DuplicateKeyFlag SYSNAME = 'DuplicateKeyFlag',
                @DuplicateKeyFlagExtendedProperty SYSNAME = 'TA_DuplicateKeyFlag',
                @TableName SYSNAME = '',
                @SchemaName SYSNAME = '',
                @ColumnName SYSNAME = '',
                @GUID VARCHAR(50) = REPLACE(NEWID(), '-', ''),
                @CombinedView SYSNAME = '',
                @SourceTableColumnList VARCHAR(MAX) = '',
                @TargetTableColumnList VARCHAR(MAX) = '',
                @ColumnList NVARCHAR(MAX) = '',
                @SQL NVARCHAR(MAX) = '';

        ------------------------------------------------------------------------
        -- assign default values
        IF @ComparisonGUID IS NULL SET @ComparisonGUID = NEWID();
        IF @NumericTolerance IS NULL SET @NumericTolerance = 0.00;
        IF @CaseSensitiveFlag IS NULL SET @CaseSensitiveFlag = 0;
        IF @IgnoreOrphanColumnsFlag IS NULL SET @IgnoreOrphanColumnsFlag = 0;
        IF @OptimizedStorageFlag IS NULL SET @OptimizedStorageFlag = 1;
        IF ISNULL(@SourceMoniker, '') = '' SET @SourceMoniker = 'A';
        IF ISNULL(@TargetMoniker, '') = '' SET @TargetMoniker = 'B';
        ------------------------------------------------------------------------
        -- create all temporary tables at start
        IF OBJECT_ID('tempdb.dbo.#ColumnValidation', 'U') IS NOT NULL DROP TABLE #ColumnValidation;
        CREATE TABLE #ColumnValidation
        (
            ReturnValue TINYINT
        );
        IF OBJECT_ID('tempdb.dbo.#MatchKeySourceList', 'U') IS NOT NULL DROP TABLE #MatchKeySourceList;
        CREATE TABLE #MatchKeySourceList
        (
            ColumnName NVARCHAR(128),
            KeyDisplayOrder SMALLINT
        );
        IF OBJECT_ID('tempdb.dbo.#ExcludedColumnSourceList', 'U') IS NOT NULL DROP TABLE #ExcludedColumnSourceList;
        CREATE TABLE #ExcludedColumnSourceList
        (
            ColumnName NVARCHAR(128)
        );
        IF OBJECT_ID('tempdb.dbo.#ExcludedColumnTargetList', 'U') IS NOT NULL DROP TABLE #ExcludedColumnTargetList;
        CREATE TABLE #ExcludedColumnTargetList
        (
            ColumnName NVARCHAR(128)
        );
        IF OBJECT_ID('tempdb.dbo.#DisplayOnlyColumnSourceList', 'U') IS NOT NULL DROP TABLE #DisplayOnlyColumnSourceList;
        CREATE TABLE #DisplayOnlyColumnSourceList
        (
            ColumnName NVARCHAR(128)
        );
        IF OBJECT_ID('tempdb.dbo.#DisplayOnlyColumnTargetList', 'U') IS NOT NULL DROP TABLE #DisplayOnlyColumnTargetList;
        CREATE TABLE #DisplayOnlyColumnTargetList
        (
            ColumnName NVARCHAR(128)
        );
        IF OBJECT_ID('tempdb.dbo.#ColumnMappingList', 'U') IS NOT NULL DROP TABLE #ColumnMappingList;
        CREATE TABLE #ColumnMappingList
        (
            ColumnPair NVARCHAR(300),
            SourceColumnName NVARCHAR(128) NULL,
            TargetColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#SourceTargetMapping', 'U') IS NOT NULL DROP TABLE #SourceTargetMapping;
        CREATE TABLE #SourceTargetMapping
        (
            SourceColumnName NVARCHAR(128) NULL,
            TargetColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#ColumnLength', 'U') IS NOT NULL DROP TABLE #ColumnLength;
        CREATE TABLE #ColumnLength
        (
            TableName NVARCHAR(128) NULL,
            ColumnName NVARCHAR(128) NULL,
            ColumnLength INT NULL
        );
        IF OBJECT_ID('tempdb.dbo.#ColumnDistinctCount', 'U') IS NOT NULL DROP TABLE #ColumnDistinctCount;
        CREATE TABLE #ColumnDistinctCount
        (
            TableName NVARCHAR(128) NULL,
            ColumnName NVARCHAR(128) NULL,
            DistinctCount INT NULL
        );
        IF OBJECT_ID('tempdb.dbo.#DateColumn', 'U') IS NOT NULL DROP TABLE #DateColumn;
        CREATE TABLE #DateColumn
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#NumericColumn', 'U') IS NOT NULL DROP TABLE #NumericColumn;
        CREATE TABLE #NumericColumn
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#NotAllNullColumn', 'U') IS NOT NULL DROP TABLE #NotAllNullColumn;
        CREATE TABLE #NotAllNullColumn
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#AllNullColumn', 'U') IS NOT NULL DROP TABLE #AllNullColumn;
        CREATE TABLE #AllNullColumn
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#NullColumn', 'U') IS NOT NULL DROP TABLE #NullColumn;
        CREATE TABLE #NullColumn
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#NotNumber', 'U') IS NOT NULL DROP TABLE #NotNumber;
        CREATE TABLE #NotNumber
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#Number', 'U') IS NOT NULL DROP TABLE #Number;
        CREATE TABLE #Number
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#Numeric', 'U') IS NOT NULL DROP TABLE #Numeric;
        CREATE TABLE #Numeric
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#Integer', 'U') IS NOT NULL DROP TABLE #Integer;
        CREATE TABLE #Integer
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#NonDate', 'U') IS NOT NULL DROP TABLE #NonDate;
        CREATE TABLE #NonDate
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#Date', 'U') IS NOT NULL DROP TABLE #Date;
        CREATE TABLE #Date
        (
            ColumnName NVARCHAR(128) NULL
        );
        IF OBJECT_ID('tempdb.dbo.#RecordCount', 'U') IS NOT NULL DROP TABLE #RecordCount;
        CREATE TABLE #RecordCount
        (
            RecordCount BIGINT NULL
        );
        IF OBJECT_ID('tempdb.dbo.#KeyNullList', 'U') IS NOT NULL DROP TABLE #KeyNullList;
        CREATE TABLE #KeyNullList
        (
            KeyNullInd TINYINT NULL
        );
        ------------------------------------------------------------------------
        -- system check. is SQL Server 2012 or newer?
        IF CONVERT(VARCHAR(30), SERVERPROPERTY ('productversion')) NOT LIKE '1[1-4].%' -- 11.x, 12.x, 13.x, 14.x
        BEGIN
            SET @ErrorMessage = 'Unsupported version of SQL Server. Please use SQL Server versions 2012, 2014, 2016 or 2017';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        -- system check. are the necessary objects available?
        IF OBJECT_ID('TestAutomation.dbo.ComparisonRequest', 'U') IS NULL OR
           OBJECT_ID('TestAutomation.dbo.ColumnCategory', 'U') IS NULL
        BEGIN
            SET @ErrorMessage = 'One or more database objects required by the comparison tool is missing. Please re-deploy the tool';
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Validate input parameters
        IF LTRIM(RTRIM(ISNULL(@SourceTable, ''))) = ''
        BEGIN
            SET @ErrorMessage = 'Invalid value for parameter @SourceTable.';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        IF LTRIM(RTRIM(ISNULL(@TargetTable, ''))) = ''
        BEGIN
            SET @ErrorMessage = 'Invalid value for parameter @TargetTable.';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        IF LTRIM(RTRIM(ISNULL(@MatchKeySourceList, ''))) = ''
        BEGIN
            SET @ErrorMessage = 'Invalid value for parameter @MatchKeyList.';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        SET @ColumnMappingList = LTRIM(RTRIM(ISNULL(@ColumnMappingList, '')));
        IF @ColumnMappingList <> ''
        BEGIN
            IF @ColumnMappingList NOT LIKE '%::%'
            BEGIN
                SET @ErrorMessage = 'Invalid format for parameter @ColumnMappingList.';
                RAISERROR(@ErrorMessage, 16, 1);
            END;
        END;

        IF LTRIM(RTRIM(ISNULL(@SourceMoniker, ''))) = 'DisplayOnly'
        BEGIN
            SET @ErrorMessage = 'Invalid value for parameter @SourceMoniker. "DisplayOnly" is a reserved Moniker';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        IF LTRIM(RTRIM(ISNULL(@TargetMoniker, ''))) = 'DisplayOnly'
        BEGIN
            SET @ErrorMessage = 'Invalid value for parameter @TargetMoniker. "DisplayOnly" is a reserved Moniker';
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Validate if source exists
        IF OBJECT_ID(@SourceTable, 'U') IS NULL
        BEGIN
            SET @ErrorMessage = 'Table "' + @SourceTable + '" does not exist. Please check the table name and try again';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        -- Validate if target exists
        IF OBJECT_ID(@TargetTable, 'U') IS NULL
        BEGIN
            SET @ErrorMessage = 'Table "' + @TargetTable + '" does not exist. Please check the table name and try again';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        -- Validate if source exists in TestAutomation database
        IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@SourceTable, 'U'))
        BEGIN
            SET @ErrorMessage = 'Table "' + @SourceTable + '" does not exist in TestAutomation database.';
            RAISERROR(@ErrorMessage, 16, 1);
        END;

        -- Validate if target exists in TestAutomation database
        IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@TargetTable, 'U'))
        BEGIN
            SET @ErrorMessage = 'Table "' + @TargetTable + '" does not exist in TestAutomation database.';
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- check if this is a new request or an existing request for comparison.
        SELECT @ComparisonRequestId = ComparisonRequestId
        FROM TestAutomation.dbo.ComparisonRequest with (NOLOCK)
        WHERE ComparisonGUID = @ComparisonGUID;

        IF @ComparisonRequestId IS NULL
        BEGIN
            ------------------------------------------------------------------------
            -- Set the record, generate the identity value.
            INSERT INTO TestAutomation.dbo.ComparisonRequest
            (
               ComparisonGUID,
               SourceTable,
               TargetTable,
               MatchKeySourceList,
               ExcludedColumnSourceList,
               ExcludedColumnTargetList,
               DisplayOnlyColumnSourceList,
               DisplayOnlyColumnTargetList,
               ColumnMappingList,
               IgnoreOrphanColumns,
               NumericTolerance,
               CaseSensitive,
               OptimizedStorage,
               ComparisonStatus,
               StartTime,
               EndTime,
               UserName,
               ErrorMessage
            )
            VALUES
            (
               @ComparisonGUID,
               @SourceTable,
               @TargetTable,
               @MatchKeySourceList,
               @ExcludedColumnSourceList,
               @ExcludedColumnTargetList,
               @DisplayOnlyColumnSourceList,
               @DisplayOnlyColumnTargetList,
               @ColumnMappingList,
               @IgnoreOrphanColumnsFlag,
               @NumericTolerance,
               @CaseSensitiveFlag,
               @OptimizedStorageFlag,
               'Started',
               SYSDATETIME(),
               NULL,
               SUSER_SNAME(),
               ''
            );

            SET @ComparisonRequestId = SCOPE_IDENTITY();
            ------------------------------------------------------------------------
        END;
        ELSE
        BEGIN
            ------------------------------------------------------------------------
            -- if this is an existing request, clear the values before processing the request.
            UPDATE TestAutomation.dbo.ComparisonRequest
            SET
                SourceTable = @SourceTable,
                TargetTable = @TargetTable,
                MatchKeySourceList = @MatchKeySourceList,
                ExcludedColumnSourceList = @ExcludedColumnSourceList,
                ExcludedColumnTargetList = @ExcludedColumnTargetList,
                DisplayOnlyColumnSourceList = @DisplayOnlyColumnSourceList,
                DisplayOnlyColumnTargetList = @DisplayOnlyColumnTargetList,
                ColumnMappingList = @ColumnMappingList,
                IgnoreOrphanColumns = @IgnoreOrphanColumnsFlag,
                NumericTolerance = @NumericTolerance,
                CaseSensitive = @CaseSensitiveFlag,
                OptimizedStorage = @OptimizedStorageFlag,
                ComparisonStatus = 'Started',
                StartTime = SYSDATETIME(),
                EndTime = NULL,
                UserName = SUSER_SNAME(),
                ErrorMessage = ''
            WHERE ComparisonRequestId = @ComparisonRequestId;
            ------------------------------------------------------------------------
        END;
        ------------------------------------------------------------------------
        -- Clean up ColumnCategory table for this ComparisonRequestId
        DELETE
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId;
        ------------------------------------------------------------------------
        SELECT
                @Source = 'dbo.vwSource_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @Target = 'dbo.vwTarget_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @SourceDuplicate = 'dbo.vwSourceDuplicate_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @TargetDuplicate = 'dbo.vwTargetDuplicate_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @SourceSurplus = 'dbo.vwSourceSurplus_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @TargetSurplus = 'dbo.vwTargetSurplus_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @Mismatch = 'dbo.vwMismatch_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @MismatchSmell = 'dbo.vwMismatchSmell_' + CONVERT(VARCHAR(30), @ComparisonRequestId),
                @Match = 'dbo.vwMatch_' + CONVERT(VARCHAR(30), @ComparisonRequestId);
        ------------------------------------------------------------------------
        -- Clean up residual views
        IF OBJECT_ID(@Source, 'V') IS NOT NULL EXEC('DROP VIEW ' + @Source);
        IF OBJECT_ID(@Target, 'V') IS NOT NULL EXEC('DROP VIEW ' + @Target);
        IF OBJECT_ID(@SourceDuplicate, 'V') IS NOT NULL EXEC('DROP VIEW ' + @SourceDuplicate);
        IF OBJECT_ID(@TargetDuplicate, 'V') IS NOT NULL EXEC('DROP VIEW ' + @TargetDuplicate);
        IF OBJECT_ID(@SourceSurplus, 'V') IS NOT NULL EXEC('DROP VIEW ' + @SourceSurplus);
        IF OBJECT_ID(@TargetSurplus, 'V') IS NOT NULL EXEC('DROP VIEW ' + @TargetSurplus);
        IF OBJECT_ID(@Mismatch, 'V') IS NOT NULL EXEC('DROP VIEW ' + @Mismatch);
        IF OBJECT_ID(@MismatchSmell, 'V') IS NOT NULL EXEC('DROP VIEW ' + @MismatchSmell);
        IF OBJECT_ID(@Match, 'V') IS NOT NULL EXEC('DROP VIEW ' + @Match);
        ------------------------------------------------------------------------
        -- Get Source Table record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @SourceTable + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @SourceRecordCount = RecordCount
        FROM #RecordCount
        ------------------------------------------------------------------------
        -- Get Target Table record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @TargetTable + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @TargetRecordCount = RecordCount
        FROM #RecordCount
        ------------------------------------------------------------------------
        UPDATE TestAutomation.dbo.ComparisonRequest
        SET
            [Source] = @Source,
            [Target] = @Target,
            SourceDuplicate = @SourceDuplicate,
            TargetDuplicate = @TargetDuplicate,
            SourceSurplus = @SourceSurplus,
            TargetSurplus = @TargetSurplus,
            Mismatch = @Mismatch,
            MismatchSmell = @MismatchSmell,
            [Match] = @Match,
            SourceRecordCount = @SourceRecordCount,
            TargetRecordCount = @TargetRecordCount,
            SourceDuplicateRecordCount = NULL,
            TargetDuplicateRecordCount = NULL,
            SourceSurplusRecordCount = NULL,
            TargetSurplusRecordCount = NULL,
            MismatchRecordCount = NULL,
            MatchRecordCount = NULL
        WHERE ComparisonRequestId = @ComparisonRequestId;
        ------------------------------------------------------------------------
        -- drop all indexes in Source
        SET @SQL = '';

        SELECT @SQL = @SQL + 'DROP INDEX [' + name + '] ON ' + @SourceTable + ';'
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(@SourceTable, 'U')
        ORDER BY index_id DESC;

        IF @SQL <> '' EXEC(@SQL);

        -- drop all indexes in Target
        SET @SQL = '';

        SELECT @SQL = @SQL + 'DROP INDEX [' + name + '] ON ' + @TargetTable + ';'
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(@TargetTable, 'U')
        ORDER BY index_id DESC;

        IF @SQL <> '' EXEC(@SQL);
        ------------------------------------------------------------------------
        -- drop tool-specific DuplicateKeyFlag in Source
        SET @SQL = '';

        SELECT @SQL = @SQL + 'ALTER TABLE ' + @SourceTable + ' DROP COLUMN [' + B.name + '];'
        FROM sys.objects A
            JOIN sys.columns B
                ON A.object_id = B.object_id
                AND A.object_id = OBJECT_ID(@SourceTable, 'U')
                AND B.name LIKE @DuplicateKeyFlag + '%'
            JOIN sys.extended_properties C
                ON A.object_id = C.major_id
                AND B.column_id = C.minor_id
                AND C.name = @DuplicateKeyFlagExtendedProperty
                AND C.value = 'True'
                AND C.class = 1;

        IF @SQL <> '' EXEC(@SQL);

        -- drop tool-specific DuplicateKeyFlag in Target
        SET @SQL = '';

        SELECT @SQL = @SQL + 'ALTER TABLE ' + @TargetTable + ' DROP COLUMN [' + B.name + '];'
        FROM sys.objects A
            JOIN sys.columns B
                ON A.object_id = B.object_id
                AND A.object_id = OBJECT_ID(@TargetTable, 'U')
                AND B.name LIKE @DuplicateKeyFlag + '%'
            JOIN sys.extended_properties C
                ON A.object_id = C.major_id
                AND B.column_id = C.minor_id
                AND C.name = @DuplicateKeyFlagExtendedProperty
                AND C.value = 'True'
                AND C.class = 1;

        IF @SQL <> '' EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Add DuplicateKeyFlag column in Source and Target
        -- If DuplicateKeyFlag column exist in Source table AND extended property is not set to MC_DuplicateKeyFlagColumn THEN append GUID (sans '-') to DuplicateKeyFlag
        -- If not, (i.e. DuplicateKeyFlag does not exist, or DuplicateKeyFlag exists but the extended property is setthen use DuplicateKeyFlag
        -- check if tool specific DuplicateKeyFlag exists with extended property
        ------------------------------------------------------------------------
        -- check if application-specific DuplicateKeyFlag column exist...
        IF EXISTS
        (
            SELECT 1
            FROM sys.objects A
                JOIN sys.columns B
                    ON A.object_id = B.object_id
                    AND A.object_id = OBJECT_ID(@SourceTable, 'U')
                    AND B.name LIKE @DuplicateKeyFlag + '%'
            UNION ALL
            SELECT 1
            FROM sys.objects A
                JOIN sys.columns B
                    ON A.object_id = B.object_id
                    AND A.object_id = OBJECT_ID(@TargetTable, 'U')
                    AND B.name LIKE @DuplicateKeyFlag + '%'
        )
        BEGIN
            SET @DuplicateKeyFlag = @DuplicateKeyFlag + '_' + @GUID
        END;
        ELSE
        BEGIN
            SET @DuplicateKeyFlag = @DuplicateKeyFlag
        END;
        ------------------------------------------------------------------------
        -- add DuplicateKeyFlag to Source
        SET @SQL = 'ALTER TABLE ' + @SourceTable + ' ADD ' + @DuplicateKeyFlag + ' BIT NULL'

        EXEC(@SQL);

        SELECT @SchemaName = SCHEMA_NAME(schema_id),
                @TableName = name
        FROM sys.objects
        WHERE object_id = OBJECT_ID(@SourceTable, 'U')

        EXEC sp_addextendedproperty
            @name = @DuplicateKeyFlagExtendedProperty,
            @value = 'True',
            @level0type = N'Schema', @level0name = @SchemaName,
            @level1type = N'Table',  @level1name = @TableName,
            @level2type = N'Column', @level2name = @DuplicateKeyFlag;
        ------------------------------------------------------------------------
        -- add DuplicateKeyFlag to Target
        SET @SQL = 'ALTER TABLE ' + @TargetTable + ' ADD ' + @DuplicateKeyFlag + ' BIT NULL'

        EXEC(@SQL);

        SELECT @SchemaName = SCHEMA_NAME(schema_id),
               @TableName = name
        FROM sys.objects
        WHERE object_id = OBJECT_ID(@TargetTable, 'U')

        EXEC sp_addextendedproperty
            @name = @DuplicateKeyFlagExtendedProperty,
            @value = 'True',
            @level0type = N'Schema', @level0name = @SchemaName,
            @level1type = N'Table',  @level1name = @TableName,
            @level2type = N'Column', @level2name = @DuplicateKeyFlag;
        ------------------------------------------------------------------------
        -- Validate if MatchKeySourceList is valid in Source
        -- Validate if ExcludedColumnSourceList is valid in Source
        -- Validate if TargetExcludedColumns is valid in Target
        -- Validate if ColumnMappingList is valid in Source & Target
        -- Strip columns parameters of "[", "]" of load them into temp tables.
        ------------------------------------------------------------------------
        IF ISNULL(@ColumnMappingList, '') <> ''
        BEGIN
            INSERT INTO #ColumnMappingList(ColumnPair)
            SELECT LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS ColumnPair
            FROM
            (
                SELECT CAST('<X><R>' + REPLACE(@ColumnMappingList,',','</R><R>') + '</R></X>' AS XML) AS Y
            ) T
            CROSS APPLY Y.nodes('/X/R')m(n);

            UPDATE #ColumnMappingList
            SET SourceColumnName = LEFT(ColumnPair, CHARINDEX('::', ColumnPair) - 1),
                TargetColumnName = RIGHT(ColumnPair, CHARINDEX('::', ColumnPair) + 3);

            SET @ColumnPairSourceList = '';
            SET @ColumnPairTargetList = '';

            SELECT  @ColumnPairSourceList = @ColumnPairSourceList + SourceColumnName + ',',
                    @ColumnPairTargetList = @ColumnPairTargetList + TargetColumnName + ','
            FROM #ColumnMappingList;

            SET @ColumnPairSourceList = LTRIM(RTRIM(@ColumnPairSourceList));
            SET @ColumnPairTargetList = LTRIM(RTRIM(@ColumnPairTargetList));

            IF @ColumnPairSourceList <> '' SET @ColumnPairSourceList = LEFT(@ColumnPairSourceList, LEN(@ColumnPairSourceList) - 1);
            IF @ColumnPairTargetList <> '' SET @ColumnPairTargetList = LEFT(@ColumnPairTargetList, LEN(@ColumnPairTargetList) - 1);
        END;
        ------------------------------------------------------------------------

        BEGIN TRY
            IF ISNULL(@MatchKeySourceList, '') <> ''
            BEGIN
                -- Validate if MatchKey is valid in Source
                SET @Message = 'Parameter @MatchKeySourceList ("' + @MatchKeySourceList + '")';

                SET @SQL =
                '
                SELECT TOP(1) 1
                FROM
                (
                    SELECT TOP 1 ' + @MatchKeySourceList + '
                    FROM ' + @SourceTable + ' with (NOLOCK)
                ) AS X
                GROUP BY ' + @MatchKeySourceList

                INSERT INTO #ColumnValidation(ReturnValue)
                EXEC(@SQL);
            END;

            IF ISNULL(@ExcludedColumnSourceList, '') <> ''
            BEGIN
                -- Validate if ExcludedColumnSourceList is valid in Source
                SET @Message = 'Parameter @ExcludedColumnSourceList ("' + @ExcludedColumnSourceList + '")';

                SET @SQL =
                '
                SELECT TOP(1) 1
                FROM
                (
                    SELECT TOP 1 ' + @ExcludedColumnSourceList + '
                    FROM ' + @SourceTable + ' with (NOLOCK)
                ) AS X
                GROUP BY ' + @ExcludedColumnSourceList

                INSERT INTO #ColumnValidation(ReturnValue)
                EXEC(@SQL);
            END;

            IF ISNULL(@ExcludedColumnTargetList, '') <> ''
            BEGIN
                -- Validate if ExcludedColumnTargetList is valid in Target
                SET @Message = 'Parameter @ExcludedColumnTargetList ("' + @ExcludedColumnTargetList + '")';

                SET @SQL =
                '
                SELECT TOP(1) 1
                FROM
                (
                    SELECT TOP 1 ' + @ExcludedColumnTargetList + '
                    FROM ' + @TargetTable + ' with (NOLOCK)
                ) AS X
                GROUP BY ' + @ExcludedColumnTargetList

                INSERT INTO #ColumnValidation(ReturnValue)
                EXEC(@SQL);
            END;

            IF ISNULL(@DisplayOnlyColumnSourceList, '') <> ''
            BEGIN
                -- Validate if DisplayOnlyColumnSourceList is valid in Source
                SET @Message = 'Parameter @DisplayOnlyColumnSourceList ("' + @DisplayOnlyColumnSourceList + '")';

                SET @SQL =
                '
                SELECT TOP(1) 1
                FROM
                (
                    SELECT TOP 1 ' + @DisplayOnlyColumnSourceList + '
                    FROM ' + @SourceTable + ' with (NOLOCK)
                ) AS X
                GROUP BY ' + @DisplayOnlyColumnSourceList

                INSERT INTO #ColumnValidation(ReturnValue)
                EXEC(@SQL);
            END;

            IF ISNULL(@DisplayOnlyColumnTargetList, '') <> ''
            BEGIN
                -- Validate if DisplayOnlyColumnTargetList is valid in Target
                SET @Message = 'Parameter @DisplayOnlyColumnTargetList ("' + @DisplayOnlyColumnTargetList + '")';

                SET @SQL =
                '
                SELECT TOP(1) 1
                FROM
                (
                    SELECT TOP 1 ' + @DisplayOnlyColumnTargetList + '
                    FROM ' + @TargetTable + ' with (NOLOCK)
                ) AS X
                GROUP BY ' + @DisplayOnlyColumnTargetList

                INSERT INTO #ColumnValidation(ReturnValue)
                EXEC(@SQL);
            END;

            IF ISNULL(@ColumnPairSourceList, '') <> ''
            BEGIN
                -- Validate if ColumnPairSourceList is valid in Source
                SET @Message = 'Source columns in Column Mapping List ("' + @ColumnPairSourceList + '")';

                SET @SQL =
                '
                SELECT TOP(1) 1
                FROM
                (
                    SELECT TOP 1 ' + @ColumnPairSourceList + '
                    FROM ' + @SourceTable + ' with (NOLOCK)
                ) AS X
                GROUP BY ' + @ColumnPairSourceList

                INSERT INTO #ColumnValidation(ReturnValue)
                EXEC(@SQL);
            END;

            IF ISNULL(@ColumnPairTargetList, '') <> ''
            BEGIN
                -- Validate if ColumnPairTargetList is valid in Target
                SET @Message = 'Target columns in Column Mapping List ("' + @ColumnPairTargetList + '")';

                SET @SQL =
                '
                SELECT TOP(1) 1
                FROM
                (
                    SELECT TOP 1 ' + @ColumnPairTargetList + '
                    FROM ' + @TargetTable + ' with (NOLOCK)
                ) AS X
                GROUP BY ' + @ColumnPairTargetList

                INSERT INTO #ColumnValidation(ReturnValue)
                EXEC(@SQL);
            END;
        END TRY

        BEGIN CATCH
            SET @ErrorMessage = @Message + ': Error :' + ERROR_MESSAGE();
            RAISERROR(@ErrorMessage, 16, 1);
        END CATCH;

        -- Get the columns, sans the "[" "]" into temporary tables
        SET @SQL =
        '
        SELECT name, MIN(column_ordinal) AS column_ordinal
        FROM sys.dm_exec_describe_first_result_set (''SELECT ' + @MatchKeySourceList + ' FROM ' + @SourceTable + ''', NULL, 0)
        GROUP BY name
        ORDER BY column_ordinal ASC
        ' ;

        INSERT INTO #MatchKeySourceList(ColumnName, KeyDisplayOrder)
        EXEC(@SQL);

        IF ISNULL(@ExcludedColumnSourceList, '') <> ''
        BEGIN
            -- Get the columns, sans the "[" "]" into temporary tables
            SET @SQL = 'SELECT DISTINCT name FROM sys.dm_exec_describe_first_result_set (''SELECT ' + @ExcludedColumnSourceList + ' FROM ' + @SourceTable + ''', NULL, 0)' ;

            INSERT INTO #ExcludedColumnSourceList(ColumnName)
            EXEC(@SQL);
        END;

        IF ISNULL(@ExcludedColumnTargetList, '') <> ''
        BEGIN
            -- Get the columns, sans the "[" "]" into temporary tables
            SET @SQL = 'SELECT DISTINCT name FROM sys.dm_exec_describe_first_result_set (''SELECT ' + @ExcludedColumnTargetList + ' FROM ' + @TargetTable + ''', NULL, 0)' ;

            INSERT INTO #ExcludedColumnTargetList(ColumnName)
            EXEC(@SQL);
        END;

        IF ISNULL(@DisplayOnlyColumnSourceList, '') <> ''
        BEGIN
            -- Get the columns, sans the "[" "]" into temporary tables
            SET @SQL = 'SELECT DISTINCT name FROM sys.dm_exec_describe_first_result_set (''SELECT ' + @DisplayOnlyColumnSourceList + ' FROM ' + @SourceTable + ''', NULL, 0)' ;

            INSERT INTO #DisplayOnlyColumnSourceList(ColumnName)
            EXEC(@SQL);
        END;

        IF ISNULL(@DisplayOnlyColumnTargetList, '') <> ''
        BEGIN
            -- Get the columns, sans the "[" "]" into temporary tables
            SET @SQL = 'SELECT DISTINCT name FROM sys.dm_exec_describe_first_result_set (''SELECT ' + @DisplayOnlyColumnTargetList + ' FROM ' + @TargetTable + ''', NULL, 0)' ;

            INSERT INTO #DisplayOnlyColumnTargetList(ColumnName)
            EXEC(@SQL);
        END;

        IF ISNULL(@ColumnPairSourceList, '') <> '' AND ISNULL(@ColumnPairTargetList, '') <> ''
        BEGIN
            -- Get the columns, sans the "[" "]" into temporary tables
            SET @SQL =
            '
            SELECT X.name AS SourceMappedColumn, Y.name AS TargetMappedColumn
            FROM
            (
                SELECT column_ordinal, name
                FROM sys.dm_exec_describe_first_result_set (''SELECT ' + @ColumnPairSourceList + ' FROM ' + @SourceTable + ''', NULL, 0)
            ) AS X
            JOIN
            (
                SELECT column_ordinal, name
                FROM sys.dm_exec_describe_first_result_set (''SELECT ' + @ColumnPairTargetList + ' FROM ' + @TargetTable + ''', NULL, 0)
            ) AS Y
            ON X.column_ordinal = Y.column_ordinal
            ';

            INSERT INTO #SourceTargetMapping(SourceColumnName, TargetColumnName)
            EXEC(@SQL);
        END;
        ------------------------------------------------------------------------
        -- Create a mapping between Source, Target columns while factoring the manual mapping by user.
        INSERT INTO TestAutomation.dbo.ColumnCategory(ComparisonRequestId, SourceColumn, ColumnOrder, SourceDataType)
        SELECT @ComparisonRequestId, name, column_id, TYPE_NAME(system_type_id)
        FROM sys.columns
        WHERE object_id = OBJECT_ID(@SourceTable, 'U')
        AND name <> @DuplicateKeyFlag
        ORDER BY column_id ASC;

        UPDATE A
          SET A.TargetColumn = B.TargetColumnName
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN #SourceTargetMapping B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND A.SourceColumn = B.SourceColumnName;

        UPDATE A
          SET A.TargetColumn = B.name
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN sys.columns B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND B.object_id = OBJECT_ID(@TargetTable, 'U')
             AND A.SourceColumn = B.name
             AND A.TargetColumn IS NULL;

        INSERT INTO TestAutomation.dbo.ColumnCategory(ComparisonRequestId, TargetColumn)
        SELECT @ComparisonRequestId, name
        FROM sys.columns
        WHERE object_id = OBJECT_ID(@TargetTable, 'U')
        AND name NOT IN
          (
          SELECT TargetColumn
          FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
          WHERE ComparisonRequestId = @ComparisonRequestId
          )
        AND name <> @DuplicateKeyFlag
        ORDER BY column_id ASC;

        UPDATE A
          SET A.TargetDataType = TYPE_NAME(B.system_type_id)
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN sys.columns B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND B.object_id = OBJECT_ID(@TargetTable, 'U')
             AND A.TargetColumn = B.name;
        ------------------------------------------------------------------------
        -- mark the flags to indicate MatchKey, SourceExcludedFlag, and TargetExcludedFlag
        UPDATE A
          SET A.MatchKeyFlag = 1
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN #MatchKeySourceList B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND A.SourceColumn = B.ColumnName;

        UPDATE A
          SET A.SourceExcludedFlag = 1
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN #ExcludedColumnSourceList B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND A.SourceColumn = B.ColumnName;

        UPDATE A
          SET A.TargetExcludedFlag = 1
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN #ExcludedColumnTargetList B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND A.TargetColumn = B.ColumnName;

        UPDATE A
          SET A.SourceDisplayOnlyFlag = 1
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN #DisplayOnlyColumnSourceList B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND A.SourceColumn = B.ColumnName;

        UPDATE A
          SET A.TargetDisplayOnlyFlag = 1
        FROM TestAutomation.dbo.ColumnCategory A
          JOIN #DisplayOnlyColumnTargetList B
             ON A.ComparisonRequestId = @ComparisonRequestId
             AND A.TargetColumn = B.ColumnName;

        UPDATE TestAutomation.dbo.ColumnCategory
        SET SourceExcludedFlag = ISNULL(SourceExcludedFlag, 0),
            TargetExcludedFlag = ISNULL(TargetExcludedFlag, 0),
            SourceDisplayOnlyFlag = ISNULL(SourceDisplayOnlyFlag, 0),
            TargetDisplayOnlyFlag = ISNULL(TargetDisplayOnlyFlag, 0),
            MatchKeyFlag = ISNULL(MatchKeyFlag, 0)
        WHERE ComparisonRequestId = @ComparisonRequestId;
        ------------------------------------------------------------------------
        -- set the skipped datatypes.
        UPDATE TestAutomation.dbo.ColumnCategory
        SET SkippedDataTypeFlag = 1
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND SourceDataType NOT IN
        (
            'bigint',
            'bit',
            'char',
            'date',
            'datetime',
            'datetime2',
            'decimal',
            'float',
            'int',
            'money',
            'nchar',
            'numeric',
            'nvarchar',
            'real',
            'smalldatetime',
            'smallint',
            'smallmoney',
            'sql_variant',
            'sysname',
            'time',
            'tinyint',
            'uniqueidentifier',
            'varchar',
            'xml'
        )
        OR TargetDataType NOT IN
        (
            'bigint',
            'bit',
            'char',
            'date',
            'datetime',
            'datetime2',
            'decimal',
            'float',
            'int',
            'money',
            'nchar',
            'numeric',
            'nvarchar',
            'real',
            'smalldatetime',
            'smallint',
            'smallmoney',
            'sql_variant',
            'sysname',
            'time',
            'tinyint',
            'uniqueidentifier',
            'varchar',
            'xml'
        );

        UPDATE TestAutomation.dbo.ColumnCategory
        SET SkippedDataTypeFlag = ISNULL(SkippedDataTypeFlag, 0)
        WHERE ComparisonRequestId = @ComparisonRequestId;
        ------------------------------------------------------------------------
        -- If the flag is set to strict column comparison
        IF @IgnoreOrphanColumnsFlag = 0
        BEGIN
            -- are the orphan columns in Target?
            SET @ColumnList = '';

            SELECT @ColumnList = @ColumnList + '[' + TargetColumn + '], '
            FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND TargetColumn IS NOT NULL
            AND SourceColumn IS NULL
            AND TargetExcludedFlag = 0
            AND TargetDisplayOnlyFlag = 0;

            SET @ColumnList = LTRIM(RTRIM(@ColumnList));
            IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

            IF @ColumnList <> ''
            BEGIN
                SET @ErrorMessage = 'Column(s) "' + @ColumnList + '" is/are missing in Source table.';
                RAISERROR(@ErrorMessage, 16, 1);
            END;
            ------------------------------------------------------------------------
            -- are the orphan columns in Source?
            SET @ColumnList = '';

            SELECT @ColumnList = @ColumnList + '[' + SourceColumn + '], '
            FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND SourceColumn IS NOT NULL
            AND TargetColumn IS NULL
            AND SourceExcludedFlag = 0
            AND SourceDisplayOnlyFlag = 0;

            SET @ColumnList = LTRIM(RTRIM(@ColumnList));
            IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

            IF @ColumnList <> ''
            BEGIN
                SET @ErrorMessage = 'Column(s) "' + @ColumnList + '" is/are missing in Target table.';
                RAISERROR(@ErrorMessage, 16, 1);
            END;
        END
        ------------------------------------------------------------------------
        -- Validate whether Match Key is part of the Excluded columns in Source
        SET @ColumnList = '';

        SELECT @ColumnList = @ColumnList + '[' + SourceColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1
        AND (SourceExcludedFlag = 1 OR TargetExcludedFlag = 1);

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        IF @ColumnList <> ''
        BEGIN
            SET @ErrorMessage = 'Column(s) "' + @ColumnList + '" is/are marked as Match Key but is also part of the Excluded Columns in either Source or Target. Match Key and Excluded Columns are mutually exclusive';
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Validate whether Match Key is part of the DisplayOnly columns in Source
        SET @ColumnList = '';

        SELECT @ColumnList = @ColumnList + '[' + SourceColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1
        AND (SourceDisplayOnlyFlag = 1 OR TargetDisplayOnlyFlag = 1);

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        IF @ColumnList <> ''
        BEGIN
            SET @ErrorMessage = 'Column(s) "' + @ColumnList + '" is/are marked as Match Key but is also part of the DisplayOnly Columns in either Source or Target. Match Key and DisplayOnly Columns are mutually exclusive';
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Check if Match Key is missing in Source Table.
        SET @ColumnList = '';

        SELECT @ColumnList = @ColumnList + '[' + ColumnName + '], '
        FROM #MatchKeySourceList
        WHERE ColumnName NOT IN
        (
            SELECT SourceColumn
            FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND MatchKeyFlag = 1
        );

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        IF @ColumnList <> ''
        BEGIN
            SET @ErrorMessage = 'Column(s) "' + @ColumnList + '" is part of Match Key "' + @MatchKeySourceList + '" but is missing in Source table. Please check Match Key.' ;
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Check if Match Key is missing in Target Table.
        SET @ColumnList = '';

        SELECT @ColumnList = @ColumnList + '[' + SourceColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1
        AND TargetColumn IS NULL;

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        IF @ColumnList <> ''
        BEGIN
            SET @ErrorMessage = 'Column(s) "' + @ColumnList + '" is part of Match Key "' + @MatchKeySourceList + '" but is missing in Target table. Please check Target table.' ;
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Are there any Source/ Target columns remaining after all exclusions, and DisplayOnly columns?
        IF NOT EXISTS
        (
            SELECT '1'
            FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND SourceExcludedFlag = 0
            AND TargetExcludedFlag = 0
            AND SourceDisplayOnlyFlag = 0
            AND TargetDisplayOnlyFlag = 0
            AND SourceColumn IS NOT NULL
            AND TargetColumn IS NOT NULL
        )
        IF @ColumnList <> ''
        BEGIN
            SET @ErrorMessage = 'All columns in Source/ Target tables appear to be excluded or are marked DisplayOnly.';
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Does the Key Columns belong to unsupported datatypes?
        SET @ColumnList = '';

        SELECT @ColumnList = @ColumnList + '[' + SourceColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1
        AND SkippedDataTypeFlag = 1;

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        IF @ColumnList <> ''
        BEGIN
            SET @ErrorMessage = 'Column(s) "' + @ColumnList + '" is part of Match Key "' + @MatchKeySourceList + '" but has a datatype that is unsupported.' ;
            RAISERROR(@ErrorMessage, 16, 1);
        END;
        ------------------------------------------------------------------------
        -- Does the Key Columns contain NULL values?
        SET @KeyNullListA = '';
        SET @KeyNullListB = '';

        SELECT
            @KeyNullListA = @KeyNullListA + 'A.[' + SourceColumn + '] IS NULL OR ',
            @KeyNullListB = @KeyNullListB + 'B.[' + TargetColumn + '] IS NULL OR '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1

        SET @KeyNullListA = LTRIM(RTRIM(@KeyNullListA));
        SET @KeyNullListB = LTRIM(RTRIM(@KeyNullListB));

        IF @KeyNullListA <> '' SET @KeyNullListA = LEFT(@KeyNullListA, LEN(@KeyNullListA) - 2);
        IF @KeyNullListB <> '' SET @KeyNullListB = LEFT(@KeyNullListB, LEN(@KeyNullListB) - 2);
        ------------------------------------------------------------------------
        SET @SQL =
        '
        SELECT TOP(1) 1
        FROM ' + @SourceTable + ' A with (NOLOCK)
        WHERE ' + @KeyNullListA + ';
        '

        TRUNCATE TABLE #KeyNullList;

        INSERT INTO #KeyNullList(KeyNullInd)
        EXEC(@SQL);

        IF EXISTS(SELECT KeyNullInd FROM #KeyNullList)
        BEGIN
            SET @ErrorMessage = 'MatchKey column(s) in "' + @SourceTable + '" table contain one or more NULL values. MatchKey columns cannot contain NULLs and is an indicator that the specified MatchKey is invalid.' ;
            RAISERROR(@ErrorMessage, 16, 1);
        END
        ------------------------------------------------------------------------
        SET @SQL =
        '
        SELECT TOP(1) 1
        FROM ' + @TargetTable + ' B with (NOLOCK)
        WHERE ' + @KeyNullListB + ';
        '

        TRUNCATE TABLE #KeyNullList;

        INSERT INTO #KeyNullList(KeyNullInd)
        EXEC(@SQL);

        IF EXISTS(SELECT KeyNullInd FROM #KeyNullList)
        BEGIN
            SET @ErrorMessage = 'MatchKey column(s) in "' + @TargetTable + '" table contain one or more NULL values. MatchKey columns cannot contain NULLs and is an indicator that the specified MatchKey is invalid.' ;
            RAISERROR(@ErrorMessage, 16, 1);
        END
        ------------------------------------------------------------------------
        IF @OptimizedStorageFlag = 1
        BEGIN
            -- find the column lengths of the Source table
            SET @SQL = '';

            SELECT @SQL = @SQL + 'SELECT ''' + @SourceTable + ''',''' + SourceColumn + ''', MAX(DATALENGTH([' + SourceColumn + '])) FROM ' + @SourceTable + ' with (NOLOCK) UNION ALL '
            FROM TestAutomation.dbo.ColumnCategory
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND SourceDataType LIKE '%CHAR%'
            AND SourceColumn IS NOT NULL
            AND TargetColumn IS NOT NULL
            AND SourceExcludedFlag = 0
            AND TargetExcludedFlag = 0;

            SET @SQL = LTRIM(RTRIM(@SQL));
            IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

            IF @SQL <> ''
            BEGIN
                SET ANSI_WARNINGS OFF;

                INSERT INTO #ColumnLength(TableName, ColumnName, ColumnLength)
                EXEC(@SQL);

                SET ANSI_WARNINGS ON;
            END;

            -- find the column lengths of the Target table
            SET @SQL = ''
            SELECT @SQL = @SQL + 'SELECT ''' + @TargetTable + ''',''' + TargetColumn + ''', MAX(DATALENGTH([' + TargetColumn + '])) FROM ' + @TargetTable + ' with (NOLOCK) UNION ALL '
            FROM TestAutomation.dbo.ColumnCategory
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND SourceDataType LIKE '%CHAR%'
            AND SourceColumn IS NOT NULL
            AND TargetColumn IS NOT NULL
            AND SourceExcludedFlag = 0
            AND TargetExcludedFlag = 0;

            SET @SQL = LTRIM(RTRIM(@SQL));
            IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

            IF @SQL <> ''
            BEGIN
                SET ANSI_WARNINGS OFF;
                INSERT INTO #ColumnLength(TableName, ColumnName, ColumnLength)
                EXEC(@SQL);
                SET ANSI_WARNINGS ON;
            END;

            -- for any value that is 0 or null, set the value to 1
            UPDATE #ColumnLength
            SET ColumnLength = 1
            WHERE ColumnLength IS NULL
            OR ColumnLength = 0;

            -- Prepare an ALTER statement and execute
            SET @SQL = '';

            SELECT @SQL = @SQL + 'ALTER TABLE ' + A.TableName + ' ALTER COLUMN [' + A.ColumnName + '] VARCHAR(' + CASE WHEN A.ColumnLength <= 8000 THEN CONVERT(VARCHAR(30), A.ColumnLength) ELSE 'MAX' END + ') NULL' + ';'
            FROM #ColumnLength A
                JOIN sys.columns B
                    ON A.TableName = OBJECT_NAME(B.object_id)
                    AND A.ColumnName = B.name
                    AND (A.ColumnLength < B.max_length OR B.max_length = -1)

            IF @SQL <> '' EXEC(@SQL);
        END;
        ------------------------------------------------------------------------
        -- set the DataLength in ColumnCategory
        UPDATE A
        SET A.SourceDataType = TYPE_NAME(B.system_type_id),
            A.SourceDataLength = B.max_length
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN sys.columns B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND B.object_id = object_id(@SourceTable, 'U')
                AND A.SourceColumn = B.name;

        UPDATE A
        SET A.TargetDataType = TYPE_NAME(B.system_type_id),
            A.TargetDataLength = B.max_length
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN sys.columns B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND B.object_id = object_id(@TargetTable, 'U')
                AND A.TargetColumn = B.name;
        ------------------------------------------------------------------------
        -- Prepare lists of columns
        SET @SourceTableColumnList = '';
        SET @TargetTableColumnList = '';

        SELECT  @SourceTableColumnList = @SourceTableColumnList + 'CONVERT(VARCHAR(MAX), [' + SourceColumn + ']) AS [' + SourceColumn + '], ',
                @TargetTableColumnList = @TargetTableColumnList + 'CONVERT(VARCHAR(MAX), [' + TargetColumn + ']) AS [' + TargetColumn  + '], '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        ORDER BY ColumnOrder ASC;

        SET @SourceTableColumnList = LTRIM(RTRIM(@SourceTableColumnList));
        SET @TargetTableColumnList = LTRIM(RTRIM(@TargetTableColumnList));

        IF @SourceTableColumnList <> '' SET @SourceTableColumnList = LEFT(@SourceTableColumnList, LEN(@SourceTableColumnList) - 1);
        IF @TargetTableColumnList <> '' SET @TargetTableColumnList = LEFT(@TargetTableColumnList, LEN(@TargetTableColumnList) - 1);
        ------------------------------------------------------------------------
        -- Create a combined View
        SET @CombinedView = 'dbo.CombinedView_' + CONVERT(VARCHAR(30), @ComparisonRequestId)

        IF OBJECT_ID(@CombinedView, 'V') IS NOT NULL
        BEGIN
            SET @SQL = 'DROP VIEW ' + @CombinedView + ';'
            EXEC(@SQL);
        END

        SET @SQL =
        '
        CREATE VIEW ' + @CombinedView + '
        AS
        SELECT ' + @SourceTableColumnList + '
        FROM ' + @SourceTable + ' with (NOLOCK)
        UNION
        SELECT ' + @TargetTableColumnList + '
        FROM ' + @TargetTable + ' with (NOLOCK);
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- find the distinct count of each Key column in Source
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT ''' + @SourceTable + ''',''' + SourceColumn + ''', COUNT( DISTINCT [' + SourceColumn + ']) FROM ' + @SourceTable + ' with (NOLOCK) UNION ALL '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1;

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        INSERT INTO #ColumnDistinctCount(TableName, ColumnName, DistinctCount)
        EXEC(@SQL);

        -- find the distinct count of each Key column in Target
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT ''' + @TargetTable + ''',''' + TargetColumn + ''', COUNT( DISTINCT [' + TargetColumn + ']) FROM ' + @TargetTable + ' with (NOLOCK) UNION ALL '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1;

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        INSERT INTO #ColumnDistinctCount(TableName, ColumnName, DistinctCount)
        EXEC(@SQL);

        -- find the distinct count of each Key column in Combined View
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT ''' + @CombinedView + ''',''' + SourceColumn + ''', COUNT( DISTINCT [' + SourceColumn + ']) FROM ' + @CombinedView + ' with (NOLOCK) UNION ALL '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1;

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        INSERT INTO #ColumnDistinctCount(TableName, ColumnName, DistinctCount)
        EXEC(@SQL);

        UPDATE #ColumnDistinctCount
        SET DistinctCount = 0
        WHERE DistinctCount IS NULL;
        ------------------------------------------------------------------------
        -- set the DataLength in ColumnCategory
        UPDATE A
            SET A.SourceDistinctCount = B.DistinctCount
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN #ColumnDistinctCount B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND B.TableName = @SourceTable
                AND A.SourceColumn = B.ColumnName;

        UPDATE A
            SET A.TargetDistinctCount = B.DistinctCount
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN #ColumnDistinctCount B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND B.TableName = @TargetTable
                AND A.TargetColumn = B.ColumnName;

        UPDATE A
            SET A.CombinedDistinctCount = B.DistinctCount
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN #ColumnDistinctCount B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND B.TableName = @CombinedView
                AND A.SourceColumn = B.ColumnName;
        ------------------------------------------------------------------------
        -- determine the Display Order of KeyColumns
        UPDATE A
        SET A.KeyDisplayOrder = B.KeyDisplayOrder
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN #MatchKeySourceList B
                ON A.SourceColumn = B.ColumnName
                AND A.ComparisonRequestId = @ComparisonRequestId
                AND A.MatchKeyFlag = 1
        ------------------------------------------------------------------------
        -- determine the order of KeyColumns
        UPDATE X
        SET X.KeyOrder = X.RankOrder
        FROM
        (
            SELECT SourceColumn, KeyOrder, ROW_NUMBER() OVER (ORDER BY (SourceDistinctCount + TargetDistinctCount) DESC, CombinedDistinctCount ASC, (SourceDataLength + TargetDataLength) ASC, ColumnOrder ASC) AS RankOrder
            FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND MatchKeyFlag = 1
        ) AS X;
        ------------------------------------------------------------------------
        -- Create clustered index on Source
        SET @ColumnList = '';

        ;WITH CTE_DataLength AS
        (
            SELECT SourceColumn, KeyOrder, SUM(SourceDataLength) OVER (ORDER BY KeyOrder ASC) AS TotalDataLength
            FROM TestAutomation.dbo.ColumnCategory
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND MatchKeyFlag = 1
        )
        SELECT @ColumnList = @ColumnList + '[' + SourceColumn + '], '
        FROM CTE_DataLength
        WHERE TotalDataLength <= 900 -- limit of clustered index
        ORDER BY KeyOrder ASC;

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        SET @SQL = 'CREATE CLUSTERED INDEX [IX_TA_' + REPLACE(@SourceTable, '.', '_') + '] ON ' + @SourceTable + ' (' + @ColumnList + ') WITH (MAXDOP = 2' + CASE WHEN @OptimizedStorageFlag = 1 AND (CONVERT(VARCHAR(100), SERVERPROPERTY('Edition')) LIKE 'Enterprise%' OR CONVERT(VARCHAR(100), SERVERPROPERTY('Edition')) LIKE 'Developer%') THEN ', DATA_COMPRESSION = ROW' ELSE '' END + ');'

        EXEC(@SQL);

        -- Create clustered index on Target
        SET @ColumnList = '';

        ;WITH CTE_DataLength AS
        (
            SELECT TargetColumn, KeyOrder, SUM(TargetDataLength) OVER (ORDER BY KeyOrder ASC) AS TotalDataLength
            FROM TestAutomation.dbo.ColumnCategory
            WHERE ComparisonRequestId = @ComparisonRequestId
            AND MatchKeyFlag = 1
        )
        SELECT @ColumnList = @ColumnList + '[' + TargetColumn + '], '
        FROM CTE_DataLength
        WHERE TotalDataLength <= 900 -- limit of clustered index
        ORDER BY KeyOrder ASC;

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        SET @SQL = 'CREATE CLUSTERED INDEX [IX_TA_' + REPLACE(@TargetTable, '.', '_') + '] ON ' + @TargetTable + ' (' + @ColumnList + ') WITH (MAXDOP = 2' + CASE WHEN @OptimizedStorageFlag = 1 AND (CONVERT(VARCHAR(100), SERVERPROPERTY('Edition')) LIKE 'Enterprise%' OR CONVERT(VARCHAR(100), SERVERPROPERTY('Edition')) LIKE 'Developer%') THEN ', DATA_COMPRESSION = ROW' ELSE '' END + ');'
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Mark the duplicate Keys in Source
        SET @ColumnList = '';

        SELECT @ColumnList = @ColumnList + '[' + SourceColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1
        ORDER BY KeyOrder ASC;

        SET @ColumnList = LTRIM(RTRIM(@ColumnList))
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1)

        SET @SQL =
        '
        WITH CTE_Source
        AS
        (
        SELECT ' + @ColumnList + ', ' + @DuplicateKeyFlag + ', ROW_NUMBER() OVER( PARTITION BY ' + @ColumnList + ' ORDER BY ' + @ColumnList + ') AS RankOrder
        FROM ' + @SourceTable + '
        )
        UPDATE CTE_Source
        SET ' + @DuplicateKeyFlag + ' = (CASE WHEN RankOrder = 1 THEN 0 ELSE 1 END);
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Mark the duplicate Keys in Target
        SET @ColumnList = '';

        SELECT @ColumnList = @ColumnList + '[' + TargetColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory with (NOLOCK)
        WHERE ComparisonRequestId = @ComparisonRequestId
        ORDER BY KeyOrder ASC;

        SET @ColumnList = LTRIM(RTRIM(@ColumnList));
        IF @ColumnList <> '' SET @ColumnList = LEFT(@ColumnList, LEN(@ColumnList) - 1);

        SET @SQL =
        '
        WITH CTE_Target
        AS
        (
        SELECT ' + @ColumnList + ', ' + @DuplicateKeyFlag + ', ROW_NUMBER() OVER( PARTITION BY ' + @ColumnList + ' ORDER BY ' + @ColumnList + ') AS RankOrder
        FROM ' + @TargetTable + '
        )
        UPDATE CTE_Target
        SET ' + @DuplicateKeyFlag + ' = (CASE WHEN RankOrder = 1 THEN 0 ELSE 1 END);
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Find columns with atleast one non-null values.
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT TOP 1 ''' + name + ''' FROM ' + @CombinedView + ' with (NOLOCK) WHERE [' + name + '] IS NOT NULL UNION ALL '
        FROM sys.columns with (NOLOCK)
        WHERE object_id = OBJECT_ID(@CombinedView, 'V');

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        IF @SQL <> ''
        BEGIN
            INSERT INTO #NotAllNullColumn(ColumnName)
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
        -- Find columns with complete null values.
        INSERT INTO #AllNullColumn(ColumnName)
        SELECT A.name
        FROM sys.columns A
            LEFT JOIN #NotAllNullColumn B
                ON A.name = B.ColumnName
        WHERE A.object_id = OBJECT_ID(@CombinedView, 'V')
        AND B.ColumnName IS NULL;
        ------------------------------------------------------------------------
        -- Find columns with one or more null values
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT TOP 1 ''' + name + ''' FROM ' + @CombinedView + ' with (NOLOCK) WHERE [' + name + '] IS NULL UNION ALL '
        FROM sys.columns with (NOLOCK)
        WHERE object_id = OBJECT_ID(@CombinedView, 'V');

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        IF @SQL <> ''
        BEGIN
            INSERT INTO #NullColumn(ColumnName)
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
        -- Find columns with one or more non-number values - likes varchars or dates.
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT TOP 1 ''' + name + ''' FROM ' + @CombinedView + ' with (NOLOCK) WHERE [' + name + '] IS NOT NULL AND TRY_CONVERT(FLOAT, [' + name + ']) IS NULL AND ISNUMERIC([' + name + ']) = 0 UNION ALL '
        FROM sys.columns with (NOLOCK)
        WHERE object_id = OBJECT_ID(@CombinedView, 'V')
        AND name NOT IN (SELECT ColumnName FROM #AllNullColumn);

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        IF @SQL <> ''
        BEGIN
            INSERT INTO #NotNumber(ColumnName)
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
        -- Find columns with Number values - eg: -1, 0, 10, 20.7, 12E-10
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT TOP 1 ''' + name + ''' FROM ' + @CombinedView + ' with (NOLOCK) WHERE [' + name + '] IS NOT NULL AND TRY_CONVERT(FLOAT, [' + name + ']) IS NOT NULL AND ISNUMERIC([' + name + ']) = 1 UNION ALL '
        FROM sys.columns with (NOLOCK)
        WHERE object_id = OBJECT_ID(@CombinedView, 'V')
        AND name NOT IN (SELECT ColumnName FROM #AllNullColumn)
        AND name NOT IN (SELECT ColumnName FROM #NotNumber);

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        IF @SQL <> ''
        BEGIN
            INSERT INTO #Number(ColumnName)
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
        -- Find true Numeric columns - columns with Precision and Scale
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT TOP 1 ''' + ColumnName + ''' FROM ' + @CombinedView + ' with (NOLOCK) WHERE [' + ColumnName + '] IS NOT NULL AND ROUND(REPLACE([' + ColumnName + '], '','', ''''), 15) LIKE ''%.%'' UNION ALL '
        FROM #Number;

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        IF @SQL <> ''
        BEGIN
            INSERT INTO #Numeric(ColumnName)
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
        -- Find Integer columns
        INSERT INTO #Integer(ColumnName)
        SELECT ColumnName
        FROM #Number
        EXCEPT
        SELECT ColumnName
        FROM #Numeric;
        ------------------------------------------------------------------------
        -- Find columns that are non-dates and not all null, and not integer and not numeric
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT TOP 1 ''' + name + ''' FROM ' + @CombinedView + ' with (NOLOCK) WHERE [' + name + '] IS NOT NULL AND TRY_CONVERT(DATE, [' + name + ']) IS NULL AND ISDATE([' + name + ']) = 0 UNION ALL '
        FROM sys.columns with (NOLOCK)
        WHERE object_id = OBJECT_ID(@CombinedView, 'V')
        AND name NOT IN (SELECT ColumnName FROM #AllNullColumn)
        AND name NOT IN (SELECT ColumnName FROM #Integer)
        AND name NOT IN (SELECT ColumnName FROM #Numeric);

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        IF @SQL <> ''
        BEGIN
            INSERT INTO #NonDate(ColumnName)
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
        -- Find Date columns
        SET @SQL = '';

        SELECT @SQL = @SQL + 'SELECT TOP 1 ''' + name + ''' FROM ' + @CombinedView + ' with (NOLOCK) WHERE [' + name + '] IS NOT NULL AND TRY_CONVERT(DATE, [' + name + ']) IS NOT NULL AND ISDATE([' + name + ']) = 1 UNION ALL '
        FROM sys.columns with (NOLOCK)
        WHERE object_id = OBJECT_ID(@CombinedView, 'V')
        AND name NOT IN (SELECT ColumnName FROM #AllNullColumn)
        AND name NOT IN (SELECT ColumnName FROM #Integer)
        AND name NOT IN (SELECT ColumnName FROM #Numeric)
        AND name NOT IN (SELECT ColumnName FROM #NonDate);

        SET @SQL = LTRIM(RTRIM(@SQL));
        IF @SQL <> '' SET @SQL = LEFT(@SQL, LEN(@SQL) - 9);

        IF @SQL <> ''
        BEGIN
            INSERT INTO #Date(ColumnName)
            EXEC(@SQL);
        END;
        ------------------------------------------------------------------------
        UPDATE A
        SET A.Category = 'DATE'
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN #Date B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND A.SourceColumn = B.ColumnName
                AND A.SourceExcludedFlag = 0
                AND A.TargetExcludedFlag = 0
                AND A.SkippedDataTypeFlag = 0;

        UPDATE A
        SET A.Category = 'INTEGER'
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN #Integer B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND A.SourceColumn = B.ColumnName
                AND A.SourceExcludedFlag = 0
                AND A.TargetExcludedFlag = 0
                AND A.SkippedDataTypeFlag = 0;

        UPDATE A
        SET A.Category = 'NUMERIC'
        FROM TestAutomation.dbo.ColumnCategory A
            JOIN #Numeric B
                ON A.ComparisonRequestId = @ComparisonRequestId
                AND A.SourceColumn = B.ColumnName
                AND A.SourceExcludedFlag = 0
                AND A.TargetExcludedFlag = 0
                AND A.SkippedDataTypeFlag = 0;

        UPDATE A
        SET A.Category = 'STRING'
        FROM TestAutomation.dbo.ColumnCategory A
        WHERE A.ComparisonRequestId = @ComparisonRequestId
        AND A.Category IS NULL
        AND A.SourceExcludedFlag = 0
        AND A.TargetExcludedFlag = 0
        AND A.SkippedDataTypeFlag = 0;

        UPDATE A
        SET A.Category = NULL
        FROM TestAutomation.dbo.ColumnCategory A
        WHERE A.ComparisonRequestId = @ComparisonRequestId
        AND (
            A.SourceExcludedFlag = 1 OR
            A.TargetExcludedFlag = 1 OR
            A.SkippedDataTypeFlag = 1
            );
        ------------------------------------------------------------------------
        SET @ColumnListA = '';
        SET @ColumnListB = '';

        SELECT  @ColumnListA = @ColumnListA + 'A.[' + SourceColumn + '], ',
                @ColumnListB = @ColumnListB + 'B.[' + TargetColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category IS NOT NULL
        ORDER BY ISNULL(KeyDisplayOrder, 9999) ASC, ColumnOrder ASC;

        SET @ColumnListA = LTRIM(RTRIM(@ColumnListA));
        SET @ColumnListB = LTRIM(RTRIM(@ColumnListB));

        IF @ColumnListA <> '' SET @ColumnListA = LEFT(@ColumnListA, LEN(@ColumnListA) - 1);
        IF @ColumnListB <> '' SET @ColumnListB = LEFT(@ColumnListB, LEN(@ColumnListB) - 1);
        ------------------------------------------------------------------------
        SET @KeyListA = '';
        SET @KeyListB = '';

        SELECT  @KeyListA = @KeyListA + 'A.[' + SourceColumn + '] AS [' + SourceColumn + ' (KEY)], ',
                @KeyListB = @KeyListB + 'B.[' + TargetColumn + '] AS [' + TargetColumn + ' (KEY)], '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND Category IS NOT NULL
        ORDER BY KeyDisplayOrder ASC;

        SET @KeyListA = LTRIM(RTRIM(@KeyListA));
        SET @KeyListB = LTRIM(RTRIM(@KeyListB));

        IF @KeyListA <> '' SET @KeyListA = LEFT(@KeyListA, LEN(@KeyListA) - 1);
        IF @KeyListB <> '' SET @KeyListB = LEFT(@KeyListB, LEN(@KeyListB) - 1);
        ------------------------------------------------------------------------
        SET @DisplayOnlyListA = '';
        SET @DisplayOnlyListB = '';

        SELECT  @DisplayOnlyListA = @DisplayOnlyListA + 'A.[' + SourceColumn + '] AS [' + SourceColumn + ' (' + @SourceMoniker + ' DisplayOnly)], '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND SourceDisplayOnlyFlag = 1
        AND SourceColumn IS NOT NULL
        ORDER BY ColumnOrder ASC;

        SELECT @DisplayOnlyListB = @DisplayOnlyListB + 'B.[' + TargetColumn + '] AS [' + TargetColumn + ' (' + @TargetMoniker + ' DisplayOnly)], '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND TargetDisplayOnlyFlag = 1
        AND TargetColumn IS NOT NULL
        ORDER BY ColumnOrder ASC;

        SET @DisplayOnlyListA = LTRIM(RTRIM(@DisplayOnlyListA));
        SET @DisplayOnlyListB = LTRIM(RTRIM(@DisplayOnlyListB));

        IF @DisplayOnlyListA <> '' SET @DisplayOnlyListA = LEFT(@DisplayOnlyListA, LEN(@DisplayOnlyListA) - 1);
        IF @DisplayOnlyListB <> '' SET @DisplayOnlyListB = LEFT(@DisplayOnlyListB, LEN(@DisplayOnlyListB) - 1);
        ------------------------------------------------------------------------
        SET @NonKeyListAB = ''

        SELECT
        @NonKeyListAB = @NonKeyListAB +
        '
        A.[' + SourceColumn + '] AS [' + SourceColumn + ' (' + @SourceMoniker + ')],
        B.[' + TargetColumn + '] AS [' + TargetColumn + ' (' + @TargetMoniker + ')], '
        +
        CASE
        WHEN Category = 'STRING' THEN
        '
        CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ' + CASE WHEN @CaseSensitiveFlag = 1 THEN 'CONVERT(VARBINARY(MAX), A.[' + SourceColumn + ']) = CONVERT(VARBINARY(MAX), B.[' + TargetColumn + ']))' ELSE 'UPPER(CONVERT(VARCHAR(MAX), A.[' + SourceColumn + '])) = UPPER(CONVERT(VARCHAR(MAX), B.[' + TargetColumn + '])))' END + ' THEN ''True'' ELSE ''False'' END AS [' + SourceColumn + ' (Match)],'

        WHEN Category = 'INTEGER' THEN
        '
        CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND A.[' + SourceColumn + '] = B.[' + TargetColumn + ']) THEN ''True'' ELSE ''False'' END AS [' + SourceColumn + ' (Match)],'

        WHEN Category = 'DATE' THEN
        '
        CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND CONVERT(DATETIME, A.[' + SourceColumn + ']) = CONVERT(DATETIME, B.[' + TargetColumn + '])) THEN ''True'' ELSE ''False'' END AS [' + SourceColumn + ' (Match)],'

        WHEN Category = 'NUMERIC' THEN
        '
        CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ABS(ROUND(A.[' + SourceColumn + '], 4) - ROUND(B.[' + TargetColumn + '], 4)) <= ' + CONVERT(VARCHAR(30), @NumericTolerance) + ') THEN ''True'' ELSE ''False'' END AS [' + SourceColumn + CASE WHEN @NumericTolerance <> 0 THEN ' (Match~)' ELSE ' (Match)' END + '],
        ROUND(A.[' + SourceColumn + '], 4) - ROUND(B.[' + TargetColumn + '], 4) AS [' + SourceColumn + ' (Diff)],
        ABS(ROUND(A.[' + SourceColumn + '], 4) - ROUND(B.[' + TargetColumn + '], 4)) AS [' + SourceColumn + ' (ABS Diff)],'
        END
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 0
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category IS NOT NULL
        ORDER BY ColumnOrder ASC;

        SET @NonKeyListAB = LTRIM(RTRIM(@NonKeyListAB));
        IF @NonKeyListAB <> '' SET @NonKeyListAB = LEFT(@NonKeyListAB, LEN(@NonKeyListAB) - 1);
        ------------------------------------------------------------------------
        -- "Smell" List
        SET @SmellList = ''
        SET @NonKeySourceList = ''

        SELECT
        @NonKeySourceList = @NonKeySourceList + '[' + SourceColumn + '], ',
        @SmellList = @SmellList +
        CASE
        WHEN Category = 'STRING' THEN
        '
        SUM(CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ' + CASE WHEN @CaseSensitiveFlag = 1 THEN 'CONVERT(VARBINARY(MAX), A.[' + SourceColumn + ']) = CONVERT(VARBINARY(MAX), B.[' + TargetColumn + ']))' ELSE 'UPPER(CONVERT(VARCHAR(MAX), A.[' + SourceColumn + '])) = UPPER(CONVERT(VARCHAR(MAX), B.[' + TargetColumn + '])))' END + ' THEN 0 ELSE 1 END) AS [' + SourceColumn + '],'

        WHEN Category = 'INTEGER' THEN
        '
        SUM(CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND A.[' + SourceColumn + '] = B.[' + TargetColumn + ']) THEN 0 ELSE 1 END) AS [' + SourceColumn + '],'

        WHEN Category = 'DATE' THEN
        '
        SUM(CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND CONVERT(DATETIME, A.[' + SourceColumn + ']) = CONVERT(DATETIME, B.[' + TargetColumn + '])) THEN 0 ELSE 1 END) AS [' + SourceColumn + '],'

        WHEN Category = 'NUMERIC' THEN
        '
        SUM(CASE WHEN (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ABS(ROUND(A.[' + SourceColumn + '], 4) - ROUND(B.[' + TargetColumn + '], 4)) <= ' + CONVERT(VARCHAR(30), @NumericTolerance) + ') THEN 0 ELSE 1 END) AS [' + SourceColumn + '],'
        END
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 0
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category IS NOT NULL
        ORDER BY ColumnOrder ASC;

        SET @NonKeySourceList = LTRIM(RTRIM(@NonKeySourceList));
        SET @SmellList = LTRIM(RTRIM(@SmellList));

        IF @NonKeySourceList <> '' SET @NonKeySourceList = LEFT(@NonKeySourceList, LEN(@NonKeySourceList) - 1);
        IF @SmellList <> '' SET @SmellList = LEFT(@SmellList, LEN(@SmellList) - 1);
        ------------------------------------------------------------------------
        -- Filter - NUMERIC
        SET @MismatchFilterListNumericAB = '';
        SET @MatchFilterListNumericAB = '';

        SELECT
        @MismatchFilterListNumericAB = @MismatchFilterListNumericAB +
        '
        ((A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NOT NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ABS(ROUND(REPLACE(A.[' + SourceColumn + '], '','', ''''), 4) - ROUND(REPLACE(B.[' + TargetColumn + '], '','', ''''), 4)) > ' + CONVERT(VARCHAR(30), ABS(@NumericTolerance)) + '))' +
        ' OR ',
        @MatchFilterListNumericAB = @MatchFilterListNumericAB +
        '
        ((A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ABS(ROUND(REPLACE(A.[' + SourceColumn + '], '','', ''''), 4) - ROUND(REPLACE(B.[' + TargetColumn + '], '','', ''''), 4)) <= ' + CONVERT(VARCHAR(30), ABS(@NumericTolerance)) + '))' +
        ' AND '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 0
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category = 'NUMERIC'
        ORDER BY ColumnOrder ASC;

        SET @MismatchFilterListNumericAB = LTRIM(RTRIM(@MismatchFilterListNumericAB));
        SET @MatchFilterListNumericAB = LTRIM(RTRIM(@MatchFilterListNumericAB));

        IF @MismatchFilterListNumericAB <> '' SET @MismatchFilterListNumericAB = LEFT(@MismatchFilterListNumericAB, LEN(@MismatchFilterListNumericAB) - 2);
        IF @MatchFilterListNumericAB <> '' SET @MatchFilterListNumericAB = LEFT(@MatchFilterListNumericAB, LEN(@MatchFilterListNumericAB) - 3);
        ------------------------------------------------------------------------
        -- Filter - INTEGER
        SET @MismatchFilterListIntegerAB = ''
        SET @MatchFilterListIntegerAB = ''

        SELECT
        @MismatchFilterListIntegerAB = @MismatchFilterListIntegerAB +
        '
        ((A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NOT NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND CONVERT(BIGINT, A.[' + SourceColumn + ']) <> CONVERT(BIGINT, B.[' + TargetColumn + ']) ))' +
        ' OR ',
        @MatchFilterListIntegerAB = @MatchFilterListIntegerAB +
        '
        ((A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND CONVERT(BIGINT, A.[' + SourceColumn + ']) = CONVERT(BIGINT, B.[' + TargetColumn + ']) ))' +
        ' AND '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 0
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category = 'INTEGER'
        ORDER BY ColumnOrder ASC;

        SET @MismatchFilterListIntegerAB = LTRIM(RTRIM(@MismatchFilterListIntegerAB));
        SET @MatchFilterListIntegerAB = LTRIM(RTRIM(@MatchFilterListIntegerAB));

        IF @MismatchFilterListIntegerAB <> '' SET @MismatchFilterListIntegerAB = LEFT(@MismatchFilterListIntegerAB, LEN(@MismatchFilterListIntegerAB) - 2);
        IF @MatchFilterListIntegerAB <> '' SET @MatchFilterListIntegerAB = LEFT(@MatchFilterListIntegerAB, LEN(@MatchFilterListIntegerAB) - 3);
        ------------------------------------------------------------------------
        -- Filter - DATE
        SET @MismatchFilterListDateAB = ''
        SET @MatchFilterListDateAB = ''

        SELECT
        @MismatchFilterListDateAB = @MismatchFilterListDateAB +
        '
        ((A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NOT NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND CONVERT(DATETIME2, A.[' + SourceColumn + ']) <> CONVERT(DATETIME2, B.[' + TargetColumn + ']) ))' +
        ' OR ',
        @MatchFilterListDateAB = @MatchFilterListDateAB +
        '
        ((A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND CONVERT(DATETIME2, A.[' + SourceColumn + ']) = CONVERT(DATETIME2, B.[' + TargetColumn + ']) ))' +
        ' AND '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 0
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category = 'DATE'
        ORDER BY ColumnOrder ASC;

        SET @MismatchFilterListDateAB = LTRIM(RTRIM(@MismatchFilterListDateAB));
        SET @MatchFilterListDateAB = LTRIM(RTRIM(@MatchFilterListDateAB));

        IF @MismatchFilterListDateAB <> '' SET @MismatchFilterListDateAB = LEFT(@MismatchFilterListDateAB, LEN(@MismatchFilterListDateAB) - 2);
        IF @MatchFilterListDateAB <> '' SET @MatchFilterListDateAB = LEFT(@MatchFilterListDateAB, LEN(@MatchFilterListDateAB) - 3);
        ------------------------------------------------------------------------
        -- Filter - STRING
        SET @MismatchFilterListStringAB = ''
        SET @MatchFilterListStringAB = ''

        SELECT
        @MismatchFilterListStringAB = @MismatchFilterListStringAB  +
        '
        ((A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NOT NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ' + CASE WHEN @CaseSensitiveFlag = 1 THEN 'CONVERT(VARBINARY(MAX), A.[' + SourceColumn + ']) <> CONVERT(VARBINARY(MAX), B.[' + TargetColumn + '])' ELSE 'UPPER(CONVERT(VARCHAR(MAX), A.[' + SourceColumn + '])) <> UPPER(CONVERT(VARCHAR(MAX), B.[' + TargetColumn + ']))'  END + '))' +
        ' OR ',
        @MatchFilterListStringAB = @MatchFilterListStringAB  +
        '
        ((A.[' + SourceColumn + '] IS NULL AND B.[' + TargetColumn + '] IS NULL) OR (A.[' + SourceColumn + '] IS NOT NULL AND B.[' + TargetColumn + '] IS NOT NULL AND ' + CASE WHEN @CaseSensitiveFlag = 1 THEN 'CONVERT(VARBINARY(MAX), A.[' + SourceColumn + ']) = CONVERT(VARBINARY(MAX), B.[' + TargetColumn + '])' ELSE 'UPPER(CONVERT(VARCHAR(MAX), A.[' + SourceColumn + '])) = UPPER(CONVERT(VARCHAR(MAX), B.[' + TargetColumn + ']))'  END + '))' +
        ' AND '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 0
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category = 'STRING'
        ORDER BY ColumnOrder ASC;

        SET @MismatchFilterListStringAB = LTRIM(RTRIM(@MismatchFilterListStringAB));
        SET @MatchFilterListStringAB = LTRIM(RTRIM(@MatchFilterListStringAB));

        IF @MismatchFilterListStringAB <> '' SET @MismatchFilterListStringAB = LEFT(@MismatchFilterListStringAB, LEN(@MismatchFilterListStringAB) - 2);
        IF @MatchFilterListStringAB <> '' SET @MatchFilterListStringAB = LEFT(@MatchFilterListStringAB, LEN(@MatchFilterListStringAB) - 3);

        ------------------------------------------------------------------------
        -- set fail-safe values
        SET @MismatchFilterListNumericAB = CASE WHEN ISNULL(@MismatchFilterListNumericAB, '') = '' THEN '1 = 2' ELSE @MismatchFilterListNumericAB END
        SET @MismatchFilterListIntegerAB = CASE WHEN ISNULL(@MismatchFilterListIntegerAB, '') = '' THEN '1 = 2' ELSE @MismatchFilterListIntegerAB END
        SET @MismatchFilterListStringAB = CASE WHEN ISNULL(@MismatchFilterListStringAB, '') = '' THEN '1 = 2' ELSE @MismatchFilterListStringAB END
        SET @MismatchFilterListDateAB = CASE WHEN ISNULL(@MismatchFilterListDateAB, '') = '' THEN '1 = 2' ELSE @MismatchFilterListDateAB END

        SET @MatchFilterListNumericAB = CASE WHEN ISNULL(@MatchFilterListNumericAB, '') = '' THEN '1 = 1' ELSE @MatchFilterListNumericAB END
        SET @MatchFilterListIntegerAB = CASE WHEN ISNULL(@MatchFilterListIntegerAB, '') = '' THEN '1 = 1' ELSE @MatchFilterListIntegerAB END
        SET @MatchFilterListStringAB = CASE WHEN ISNULL(@MatchFilterListStringAB, '') = '' THEN '1 = 1' ELSE @MatchFilterListStringAB END
        SET @MatchFilterListDateAB = CASE WHEN ISNULL(@MatchFilterListDateAB, '') = '' THEN '1 = 1' ELSE @MatchFilterListDateAB END
        ------------------------------------------------------------------------
        SET @JoinAB = '';

        SELECT  @JoinAB = @JoinAB  + 'A.[' + SourceColumn + '] = B.[' + TargetColumn + '] AND '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND MatchKeyFlag = 1
        AND SourceColumn IS NOT NULL
        AND TargetColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND TargetExcludedFlag = 0
        AND SourceDisplayOnlyFlag = 0
        AND TargetDisplayOnlyFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category IS NOT NULL
        ORDER BY KeyOrder ASC;

        SET @JoinAB = LTRIM(RTRIM(@JoinAB));
        IF @JoinAB <> '' SET @JoinAB = LEFT(@JoinAB, LEN(@JoinAB) - 3);
        ------------------------------------------------------------------------
        -- Source
        SET @SQL =
        '
        CREATE VIEW ' + @Source + '
        AS
        SELECT ' + @ColumnListA + '
        FROM ' + @SourceTable + ' A with (NOLOCK);
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Target
        SET @SQL =
        '
        CREATE VIEW ' + @Target + '
        AS
        SELECT ' + @ColumnListB + '
        FROM ' + @TargetTable + ' B with (NOLOCK);
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Duplicates in Source
        SET @SQL =
        '
        CREATE VIEW ' + @SourceDuplicate + '
        AS
        SELECT ' + @ColumnListA + '
        FROM ' + @SourceTable + ' A with (NOLOCK)
        WHERE [' + @DuplicateKeyFlag + '] = 1;
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Duplicates in Target
        SET @SQL =
        '
        CREATE VIEW ' + @TargetDuplicate + '
        AS
        SELECT ' + @ColumnListB + '
        FROM ' + @TargetTable + ' B with (NOLOCK)
        WHERE [' + @DuplicateKeyFlag + '] = 1;
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Surplus in Source
        SET @SQL =
        '
        CREATE VIEW ' + @SourceSurplus + '
        AS
        SELECT ' + @ColumnListA + '
        FROM ' + @SourceTable + ' A with (NOLOCK)
            LEFT JOIN ' + @TargetTable + ' B with (NOLOCK)
                ON ' + @JoinAB + '
        WHERE A.[' + @DuplicateKeyFlag + '] = 0
        AND B.[' + @DuplicateKeyFlag + '] IS NULL;
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Surplus in Target
        SET @SQL =
        '
        CREATE VIEW ' + @TargetSurplus + '
        AS
        SELECT ' + @ColumnListB + '
        FROM ' + @SourceTable + ' A with (NOLOCK)
            RIGHT JOIN ' + @TargetTable + ' B with (NOLOCK)
                ON ' + @JoinAB + '
        WHERE B.[' + @DuplicateKeyFlag + '] = 0
        AND A.[' + @DuplicateKeyFlag + '] IS NULL;
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Mismatch
        SET @SQL =
        '
        CREATE VIEW ' + @Mismatch + '
        AS
        SELECT ' + @KeyListA + ', ' + @NonKeyListAB + CASE WHEN @DisplayOnlyListA <> '' THEN ', ' + @DisplayOnlyListA ELSE '' END + CASE WHEN @DisplayOnlyListB <> '' THEN ', ' + @DisplayOnlyListB ELSE '' END + '
        FROM ' + @SourceTable + ' A with (NOLOCK)
            INNER JOIN ' + @TargetTable + ' B with (NOLOCK)
                ON ' + @JoinAB + '
                AND A.[' + @DuplicateKeyFlag + '] = 0
                AND B.[' + @DuplicateKeyFlag + '] = 0
        WHERE (' + @MismatchFilterListNumericAB + ')
        OR  (' + @MismatchFilterListIntegerAB + ')
        OR  (' + @MismatchFilterListStringAB + ')
        OR  (' + @MismatchFilterListDateAB + ')
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- MismatchSmell
        SET @SQL =
        '
        SELECT ' + @SmellList + '
        FROM ' + @SourceTable + ' A with (NOLOCK)
            INNER JOIN ' + @TargetTable + ' B with (NOLOCK)
                ON ' + @JoinAB + '
                AND A.[' + @DuplicateKeyFlag + '] = 0
                AND B.[' + @DuplicateKeyFlag + '] = 0
        WHERE (' + @MismatchFilterListNumericAB + ')
        OR  (' + @MismatchFilterListIntegerAB + ')
        OR  (' + @MismatchFilterListStringAB + ')
        OR  (' + @MismatchFilterListDateAB + ')
        '

        SET @SQL =
        '
        CREATE VIEW ' + @MismatchSmell + '
        AS
        SELECT ColumnName, MismatchCount
        FROM (' + @SQL + ') AS X
        UNPIVOT
        (
            MismatchCount FOR ColumnName IN (' + @NonKeySourceList + ')
        ) U
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Match
        SET @SQL =
        '
        CREATE VIEW ' + @Match + '
        AS
        SELECT ' + @KeyListA + ', ' + @NonKeyListAB + CASE WHEN @DisplayOnlyListA <> '' THEN ', ' + @DisplayOnlyListA ELSE '' END + CASE WHEN @DisplayOnlyListB <> '' THEN ', ' + @DisplayOnlyListB ELSE '' END + '
        FROM ' + @SourceTable + ' A with (NOLOCK)
            INNER JOIN ' + @TargetTable + ' B with (NOLOCK)
                ON ' + @JoinAB + '
                AND A.[' + @DuplicateKeyFlag + '] = 0
                AND B.[' + @DuplicateKeyFlag + '] = 0
        WHERE (' + @MatchFilterListNumericAB + ')
        AND (' + @MatchFilterListIntegerAB + ')
        AND (' + @MatchFilterListStringAB + ')
        AND (' + @MatchFilterListDateAB + ')
        '
        EXEC(@SQL);
        ------------------------------------------------------------------------
        -- Count
        ------------------------------------------------------------------------
        -- Get SourceDuplicate record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @SourceDuplicate + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @SourceDuplicateRecordCount = RecordCount
        FROM #RecordCount;
        ------------------------------------------------------------------------
        -- Get TargetDuplicate record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @TargetDuplicate + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @TargetDuplicateRecordCount = RecordCount
        FROM #RecordCount;
        ------------------------------------------------------------------------
        -- Get SourceSurplus record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @SourceSurplus + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @SourceSurplusRecordCount = RecordCount
        FROM #RecordCount;
        ------------------------------------------------------------------------
        -- Get TargetSurplus record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @TargetSurplus + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @TargetSurplusRecordCount = RecordCount
        FROM #RecordCount;
        ------------------------------------------------------------------------
        -- Get Mismatch record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @Mismatch + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @MismatchRecordCount = RecordCount
        FROM #RecordCount;
        ------------------------------------------------------------------------
        -- Get TargetSurplus record count
        TRUNCATE TABLE #RecordCount;

        SET @SQL =
        '
        SELECT COUNT_BIG(1) AS RecordCount
        FROM ' + @Match + ' with (NOLOCK);
        '
        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        SELECT @MatchRecordCount = RecordCount
        FROM #RecordCount;
        ------------------------------------------------------------------------
        UPDATE TestAutomation.dbo.ComparisonRequest
        SET SourceDuplicateRecordCount = @SourceDuplicateRecordCount,
            TargetDuplicateRecordCount = @TargetDuplicateRecordCount,
            SourceSurplusRecordCount = @SourceSurplusRecordCount,
            TargetSurplusRecordCount = @TargetSurplusRecordCount,
            MismatchRecordCount = @MismatchRecordCount,
            MatchRecordCount = @MatchRecordCount,
            ComparisonStatus = 'Completed',
            EndTime = SYSDATETIME()
        WHERE ComparisonRequestId = @ComparisonRequestId;
        ------------------------------------------------------------------------
        IF OBJECT_ID(@CombinedView, 'V') IS NOT NULL
        BEGIN
            SET @SQL = 'DROP VIEW ' + @CombinedView + ';'
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
    END TRY

    BEGIN CATCH
        SET @ErrorMessage = ERROR_MESSAGE();

        UPDATE TestAutomation.dbo.ComparisonRequest
        SET ErrorMessage = @ErrorMessage,
            ComparisonStatus = 'Failed',
            EndTime = SYSDATETIME()
        WHERE ComparisonRequestId = @ComparisonRequestId;
        ------------------------------------------------------------------------
        IF OBJECT_ID(@CombinedView, 'V') IS NOT NULL
        BEGIN
            SET @SQL = 'DROP VIEW ' + @CombinedView + ';'
            EXEC(@SQL);
        END
        ------------------------------------------------------------------------
        SET ANSI_WARNINGS ON;

        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH;
END;



