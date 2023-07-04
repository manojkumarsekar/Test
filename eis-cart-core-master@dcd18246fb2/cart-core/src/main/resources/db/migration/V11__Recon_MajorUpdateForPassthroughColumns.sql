--------------------------------------------
USE TestAutomation
GO
---------------------------------------------------
SET NOCOUNT ON;
SET XACT_ABORT ON;


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
--  SS              19/02/2018      Minor enhancements
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
        AND MatchKeyFlag = 1
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

        SELECT  @ColumnListA = @ColumnListA + 'A.[' + SourceColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND SourceColumn IS NOT NULL
        AND SourceExcludedFlag = 0
        AND SkippedDataTypeFlag = 0
        AND Category IS NOT NULL
        ORDER BY ISNULL(KeyDisplayOrder, 9999) ASC, ColumnOrder ASC;

        SELECT  @ColumnListB = @ColumnListB + 'B.[' + TargetColumn + '], '
        FROM TestAutomation.dbo.ColumnCategory
        WHERE ComparisonRequestId = @ComparisonRequestId
        AND TargetColumn IS NOT NULL
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




----------------------------
-- SECURITY LEVEL Wrapper --
----------------------------
GO

---------------------------------------------------
IF OBJECT_ID('dbo.Security_ISIN', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Security_ISIN;
END;
GO

---------------------------------------------------
IF OBJECT_ID('dbo.AttributionModelMapping', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.AttributionModelMapping;
END;
GO

---------------------------------------------------
IF OBJECT_ID('dbo.PortfolioMaster', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PortfolioMaster;
END;
GO

--------------------------------------------------
IF OBJECT_ID('dbo.KDrive_EQ_Security_Raw_20180117105031653', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.KDrive_EQ_Security_Raw_20180117105031653
END
GO

---------------------------------------------------
IF OBJECT_ID('dbo.DNA_EQ_Security_Raw_20180117105031653', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.DNA_EQ_Security_Raw_20180117105031653
END;
GO
---------------------------------------------------
CREATE TABLE dbo.Security_ISIN
(
    PortfolioCode VARCHAR(50) NOT NULL,
    AttributionModelCode VARCHAR(50) NOT NULL,
    ReportEndDate DATE NOT NULL,
    SecurityFlag VARCHAR(1) NOT NULL,
    PARENT_SECURITY_NAME VARCHAR(200) NULL,
    SECURITY_NAME VARCHAR(200) NOT NULL,
    ISIN VARCHAR(200)
);
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
---------------------------------------------------
CREATE TABLE dbo.PortfolioMaster
(
    PortfolioCode VARCHAR(50) NOT NULL,
    PortfolioName VARCHAR(200) NOT NULL
);
GO
---------------------------------------------------
CREATE TABLE dbo.KDrive_EQ_Security_Raw_20180117105031653
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
    SECURITY_WEIGHTING NUMERIC(20, 6),
    ASSET_WEIGHTING NUMERIC(20, 6),
    SECURITY_TIMING NUMERIC(20, 6),
    SECURITY_SELECTION NUMERIC(20, 6),
    CURRENCY_EFFECT NUMERIC(20, 6)
);
GO
---------------------------------------------------
CREATE TABLE dbo.DNA_EQ_Security_Raw_20180117105031653
(
    FileID VARCHAR(400) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    ISIN VARCHAR(200),
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


---------------------------------------------------
-- Load ISIN Reference Data
TRUNCATE TABLE TestAutomation.dbo.Security_ISIN;
GO
BULK INSERT TestAutomation.dbo.Security_ISIN
FROM 'C:\Equity_Security\Data\Security_ISIN.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO
---------------------------------------------------
-- Load DNA Breakdown Reference Data
TRUNCATE TABLE TestAutomation.dbo.AttributionModelMapping;
GO
BULK INSERT TestAutomation.dbo.AttributionModelMapping
FROM 'C:\Equity_Security\Data\DNA_Breakdown.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO
---------------------------------------------------
-- Load PortfolioMastern Reference Data
TRUNCATE TABLE TestAutomation.dbo.PortfolioMaster;
GO
BULK INSERT TestAutomation.dbo.PortfolioMaster
FROM 'C:\Equity_Security\Data\PortfolioMaster.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO
---------------------------------------------------
-- Mimic KDrive Data load
TRUNCATE TABLE TestAutomation.dbo.KDrive_EQ_Security_Raw_20180117105031653;
GO
BULK INSERT TestAutomation.dbo.KDrive_EQ_Security_Raw_20180117105031653
FROM 'C:\Equity_Security\Data\KDrive_EQ_Security_Raw_20180117105031653.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO
---------------------------------------------------
GO
-- Mimic DNA_Raw Data load
TRUNCATE TABLE TestAutomation.dbo.DNA_EQ_Security_Raw_20180117105031653;
GO
BULK INSERT TestAutomation.dbo.DNA_EQ_Security_Raw_20180117105031653
FROM 'C:\Equity_Security\Data\DNA_EQ_Security_Raw_20180117105031653.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO
---------------------------------------------------


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
    -- SankaranS    07-Feb-2018    Reset the empty strings to NULL
    -- SankaranS    10-Feb-2018    Enhancement to the logic that use SOUNDEX. SOUNDEX('COUNTRY GARDEN HOLDINGS ORD SHS') = SOUNDEX('CHINATRUST')
    -- SankaranS    10-Feb-2018    Added FileID to the output
    -- SankaranS    10-Feb-2018    Added Validation for missing DNA_Breakdown, PortfolioCode
    -- SankaranS    19-Feb-2018    Added Confidence Level indicators, added ParentTree

--    EXEC TestAutomation.dbo.Compare_Equity_Security
--        @KDriveTable = 'TestAutomation.dbo.KDrive_EQ_Security_Raw_20180117105031653',
--        @DNATable = 'TestAutomation.dbo.DNA_EQ_Security_Raw_20180117105031653',
--        @NumericTolerance = 0.0001,
--        @RowReturnCount = 100000,
--        @SourceMoniker = 'Legacy',
--        @TargetMoniker = 'DNA'

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
        IF OBJECT_ID('tempdb..#RecordCount', 'U') IS NOT NULL DROP TABLE #RecordCount;

        CREATE TABLE #RecordCount
        (
            RecordCount INT
        );
        --------------------------------------------------------------------
        -- Validate whether two or more files are contributing to the same report.

        SET @SQL =
        '
        SELECT TOP(1) 1
        FROM ' + @KDriveTable + '
        GROUP BY PortfolioCode, AttributionModelCode, AttributionMethodName, ReportEndDate
        HAVING COUNT(DISTINCT FileID) > 1
        '

        TRUNCATE TABLE #RecordCount;

        INSERT INTO #RecordCount(RecordCount)
        EXEC(@SQL);

        IF EXISTS(SELECT * FROM #RecordCount)
        BEGIN
            SET @ErrorMessage = 'Error: @KDriveTable has two or more files contributing to the same report (PortfolioCode/ AttributionModelCode/ AttributionMethodName/ ReportEndDate)'
            RAISERROR(@ErrorMessage, 16, 1)
        END
        --------------------------------------------------------------------
        IF OBJECT_ID('tempdb..#DuplicateSecurityNameInLegacy', 'U') IS NOT NULL DROP TABLE #DuplicateSecurityNameInLegacy;

        SELECT DISTINCT PortfolioCode, AttributionModelCode, ReportEndDate, ISNULL(PARENT_SECURITY_NAME, 'TOTAL') AS PARENT_SECURITY_NAME, SECURITY_NAME
        INTO #DuplicateSecurityNameInLegacy
        FROM TestAutomation.dbo.Security_ISIN with (NOLOCK)
        WHERE SecurityFlag = 'Y'
        GROUP BY PortfolioCode, AttributionModelCode, ReportEndDate, ISNULL(PARENT_SECURITY_NAME, 'TOTAL'), SECURITY_NAME
        HAVING COUNT(*) > 1
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
                        CONVERT(VARCHAR(10), NULL) AS ISIN_MatchType,
                        CONVERT(VARCHAR(10), NULL) AS ConfidenceLevel,
                        CONVERT(VARCHAR(200), NULL) AS ConfidenceLevelComment,
                        CONVERT(INT, NULL) AS Level3CounterId,
                        CONVERT(INT, NULL) AS Level2CounterId,
                        CONVERT(INT, NULL) AS Level1CounterId,
                        CONVERT(VARCHAR(2000), NULL) AS ParentTree
                    INTO ' + @SourceInternalTable + '
                    FROM ' + @KDriveTable + '  with (NOLOCK)'

        EXEC(@SQL)

        SET @SQL = 'SELECT *,
                           CONVERT(VARCHAR(50), NULL) AS PortfolioCode,
                           CONVERT(VARCHAR(200), NULL) AS SECURITY_NAME_Enriched,
                           CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Enriched,
                           CONVERT(VARCHAR(400), NULL) AS ISIN_Enriched,
                           CONVERT(VARCHAR(2000), NULL) AS ParentTree
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

        CREATE CLUSTERED INDEX CIX_Security_ISIN ON dbo.Security_ISIN(PortfolioCode, AttributionModelCode, ReportEndDate, SecurityFlag, PARENT_SECURITY_NAME, SECURITY_NAME) WITH (MAXDOP = 2);
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

        EXEC(@SQL);
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
            SecurityName = CASE WHEN LTRIM(RTRIM(SecurityName)) = '''' THEN NULL ELSE SecurityName END,
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
        -- Set Parent Tree for DNA
        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET ParentTree =    ''TOTAL>>'' +
                            CASE WHEN Level1 <> ''TOTAL'' THEN Level1 + ''>>'' ELSE '''' END +
                            CASE WHEN Level1 <> Level2 THEN Level2 + ''>>''ELSE '''' END
        '
        EXEC(@SQL)
        --------------------------------------------------------
        SET @SQL =
        '
        UPDATE ' + @SourceInternalTable + '
        SET SECURITY_NAME_Natural = LTRIM(RTRIM(AssetClass_TAB)),
            SECURITY_NAME_Enriched = CASE
                                        WHEN LTRIM(RTRIM(AssetClass_TAB)) = ''Liquids'' THEN ''Liquids (Cash and Equivalents)''
                                        WHEN LTRIM(RTRIM(AssetClass_TAB)) = ''Korea'' THEN ''Korea (South Korea)''
                                        ELSE LTRIM(RTRIM(AssetClass_TAB))
                                     END;
         '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = CASE
                                        WHEN SecurityName = ''fund'' AND UPPER(Level1) = ''TOTAL'' THEN ''TOTAL''
                                        WHEN SecurityName = ''Cash and Equivalents'' THEN ''Liquids (Cash and Equivalents)''
                                        WHEN SecurityName = ''South Korea'' THEN ''Korea (South Korea)''
                                        ELSE SECURITY_NAME_Enriched
                                     END,
            PARENT_SECURITY_Enriched =  CASE
                                            WHEN SecurityName = ''fund'' AND UPPER(Level1) = ''TOTAL'' THEN ''TOTAL''
                                            WHEN COALESCE(Level3, Level2, Level1) = ''Cash and Equivalents'' THEN ''Liquids (Cash and Equivalents)''
                                            WHEN COALESCE(Level3, Level2, Level1) = ''South Korea'' THEN ''Korea (South Korea)''
                                            WHEN PARENT_SECURITY_Enriched = ''South Korea'' THEN ''Korea (South Korea)''
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
            LeafInd BIT,
            Level3CounterId INT,
            Level2CounterId INT,
            Level1CounterId INT,
            ParentTree VARCHAR(2000)
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
                    CONVERT(BIT, NULL) AS LeafInd,
                    CONVERT(INT, NULL) AS Level3CounterId,
                    CONVERT(INT, NULL) AS Level2CounterId,
                    CONVERT(INT, NULL) AS Level1CounterId,
                    CONVERT(VARCHAR(2000), NULL) AS ParentTree
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
                LeafInd,
                Level3CounterId,
                Level2CounterId,
                Level1CounterId,
                ParentTree
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
            --------------------------------------------------------
            -- Process the Parent Tree
            UPDATE A
            SET A.Level3CounterId =
            (
                SELECT MAX(B.CounterId) AS ParentCounterId
                FROM #KDrive B
                WHERE B.CounterId < A.CounterId
                AND B.SpaceCount < A.SpaceCount
            )
            FROM #KDrive A

            UPDATE A
            SET A.Level2CounterId = B.Level3CounterId
            FROM #KDrive A
                LEFT JOIN #KDrive B
                    ON A.Level3CounterId = B.CounterId

            UPDATE A
            SET A.Level1CounterId = B.Level3CounterId
            FROM #KDrive A
                LEFT JOIN #KDrive B
                    ON A.Level2CounterId = B.CounterId

            UPDATE A
            SET A.ParentTree =
                ISNULL((SELECT B.SECURITY_NAME_Natural + '>>'
                        FROM #KDrive B
                        WHERE A.Level1CounterId = B.CounterId), '') +

                ISNULL((SELECT B.SECURITY_NAME_Natural + '>>'
                        FROM #KDrive B
                        WHERE A.Level2CounterId = B.CounterId), '') +

                ISNULL((SELECT B.SECURITY_NAME_Natural + '>>'
                        FROM #KDrive B
                        WHERE A.Level3CounterId = B.CounterId), '') +

                CASE WHEN LeafInd = 0 AND SECURITY_NAME_Natural <> '' THEN SECURITY_NAME_Natural + '>>' ELSE '' END
            FROM #KDrive A
            --------------------------------------------------------

            SET @SQL =
            '
            UPDATE A
            SET A.PARENT_SECURITY_Natural = B.PARENT_SECURITY_Natural,
                A.PARENT_SECURITY_Enriched = B.PARENT_SECURITY_Enriched,
                A.LeafInd = B.LeafInd,
                A.Level3CounterId = B.Level3CounterId,
                A.Level2CounterId = B.Level2CounterId,
                A.Level1CounterId = B.Level1CounterId,
                A.ParentTree = B.ParentTree
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
            AND LEFT(REPLACE(REPLACE(SECURITY_NAME, '' '', ''''), ''.'', ''''), 4) = LEFT(REPLACE(REPLACE(''' + @SECURITY_NAME_Natural + ''', '' '', '''' ), ''.'', ''''), 4)
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
            AND LEFT(REPLACE(REPLACE(PARENT_SECURITY_Enriched, '' '', ''''), ''.'', ''''), 4) = LEFT(REPLACE(REPLACE(''' + @PARENT_SECURITY_Enriched + ''', '' '', '''' ), ''.'', ''''), 4)
            AND SOUNDEX(SECURITY_NAME_Enriched) = SOUNDEX(''' + @SECURITY_NAME_Enriched + ''')
            AND LEFT(SECURITY_NAME_Enriched, 4) = LEFT(''' + @SECURITY_NAME_Enriched + ''', 4)
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
        -- Stamp Confidence Levels
        SET @SQL =
        '
        UPDATE A
        SET A.ConfidenceLevel = ''Negative'',
            A.ConfidenceLevelComment = ''ISIN could not be positively identified. Duplicate Security Name in the Legacy Report. This usually indicates two or more securities within a Sector/Pocket has the same Security Name''
        FROM ' + @SourceInternalTable + ' A
            JOIN #DuplicateSecurityNameInLegacy B
                ON A.PortfolioCode = B.PortfolioCode
                AND A.AttributionModelCode = B.AttributionModelCode
                AND A.ReportEndDate = B.ReportEndDate
                AND A.PARENT_SECURITY_Natural = B.PARENT_SECURITY_NAME
                AND A.SECURITY_NAME_Natural = B.SECURITY_NAME
        WHERE ConfidenceLevel IS NULL
        '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @SourceInternalTable + '
        SET ConfidenceLevel =
                CASE
                    WHEN LeafInd = 0 THEN ''Positive''
                    WHEN ISIN_Source = ''DMP'' AND ISIN_MatchType = ''Exact'' THEN ''Positive''
                    WHEN ISIN_Source = ''DMP'' AND ISIN_MatchType = ''Soundex'' THEN ''Fair''
                    WHEN ISIN_Source = ''DNA'' AND ISIN_MatchType = ''Soundex'' THEN ''Negative''
                    WHEN ISIN_Source IS NULL THEN ''Negative''
                END,
            ConfidenceLevelComment =
                CASE
                    WHEN LeafInd = 0 THEN ''Sector / Pocket Level''
                    WHEN ISIN_Source = ''DMP'' AND ISIN_MatchType = ''Exact'' THEN ''ISIN identified''
                    WHEN ISIN_Source = ''DMP'' AND ISIN_MatchType = ''Soundex'' THEN ''ISIN could not be positively identified, but a fair attempt is made''
                    WHEN ISIN_Source = ''DNA'' AND ISIN_MatchType = ''Soundex'' THEN ''ISIN could not be positively identified. Result likely to be in-accurate''
                    WHEN ISIN_Source IS NULL THEN ''ISIN could not be identified''
                END
         WHERE ConfidenceLevel IS NULL
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
            FileID,
            ISNULL(PORTFOLIO_ROR, 0) AS PORTFOLIO_ROR,
            ISNULL(INDEX_ROR, 0) AS INDEX_ROR,
            ISNULL(PORTFOLIO_WEIGHT_END, 0) AS PORTFOLIO_WEIGHT_END,
            ISNULL(PORTFOLIO_WEIGHT_AVERAGE, 0) AS PORTFOLIO_WEIGHT_AVERAGE,
            ISNULL(INDEX_WEIGHT_END, 0) AS INDEX_WEIGHT_END,
            ISNULL(INDEX_WEIGHT_AVERAGE, 0) AS INDEX_WEIGHT_AVERAGE,
            ISNULL(PORTFOLIO_CONTRIBUTION, 0) AS PORTFOLIO_CONTRIBUTION,
            ISNULL(INDEX_CONTRIBUTION, 0) AS INDEX_CONTRIBUTION,
            ISNULL(SECURITY_WEIGHTING, 0) AS ALLOCATION_EFFECT,
            ISNULL(SECURITY_TIMING, 0) AS SELECTION_EFFECT,
            ISNULL(CURRENCY_EFFECT, 0) AS CURRENCY_EFFECT,
            ParentTree,
            ConfidenceLevel,
            ConfidenceLevelComment
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
            FileID,
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
            100.0  * [CurrencyEffect] as CURRENCY_EFFECT,
            ParentTree
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
            @MatchKeySourceList = 'PortfolioCode, ReportEndDate, DNA_Breakdown, PARENT_SECURITY, ISIN',
            @ExcludedColumnSourceList = NULL,
            @ExcludedColumnTargetList = NULL,
            @DisplayOnlyColumnSourceList = 'ParentTree, ConfidenceLevel, ConfidenceLevelComment, FileID',
            @DisplayOnlyColumnTargetList = 'ParentTree, FileID',
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






--------------------------
-- POCKET LEVEL Wrapper --
--------------------------

IF OBJECT_ID('dbo.AttributionModelMapping', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.AttributionModelMapping;
END;
---------------------------------------------------
IF OBJECT_ID('dbo.PortfolioMaster', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PortfolioMaster;
END;
--------------------------------------------------
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
---------------------------------------------------
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



---------------------------------------------------
-- Load DNA Breakdown Reference Data
TRUNCATE TABLE TestAutomation.dbo.AttributionModelMapping;
GO
BULK INSERT TestAutomation.dbo.AttributionModelMapping
FROM 'C:\Equity_Pocket\Data\DNA_Breakdown.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO
---------------------------------------------------
-- Load PortfolioMastern Reference Data
TRUNCATE TABLE TestAutomation.dbo.PortfolioMaster;
GO
BULK INSERT TestAutomation.dbo.PortfolioMaster
FROM 'C:\Equity_Pocket\Data\PortfolioMaster.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO

---------------------------------------------------
-- Mimic KDrive Data load
TRUNCATE TABLE TestAutomation.dbo.KDrive_EQ_Pocket_Raw_20180117105031653;
GO
BULK INSERT TestAutomation.dbo.KDrive_EQ_Pocket_Raw_20180117105031653
FROM 'C:\Equity_Pocket\Data\KDrive_EQ_Pocket_Raw_20180117105031653.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
    );
GO
---------------------------------------------------
GO
-- Mimic DNA_Raw Data load
TRUNCATE TABLE TestAutomation.dbo.DNA_EQ_Pocket_Raw_20180117105031653;
GO
BULK INSERT TestAutomation.dbo.DNA_EQ_Pocket_Raw_20180117105031653
FROM 'C:\Equity_Pocket\Data\DNA_EQ_Pocket_Raw_20180117105031653.psv'
WITH
    (
        FIELDTERMINATOR ='|',
        ROWTERMINATOR ='\n',
        FIRSTROW = 2
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
    -- SankaranS    19-Feb-2018    Added Confidence Level indicators, added ParentTree

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
        IF OBJECT_ID('tempdb..#RecordCount', 'U') IS NOT NULL DROP TABLE #RecordCount;

        CREATE TABLE #RecordCount
        (
            RecordCount INT
        );
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
                        CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Enriched,
                        CONVERT(BIT, 0) AS LeafInd,
                        CONVERT(INT, NULL) AS Level3CounterId,
                        CONVERT(INT, NULL) AS Level2CounterId,
                        CONVERT(INT, NULL) AS Level1CounterId,
                        CONVERT(VARCHAR(2000), NULL) AS ParentTree
                    INTO ' + @SourceInternalTable + '
                    FROM ' + @KDriveTable + '  with (NOLOCK)'

        EXEC(@SQL)

        SET @SQL = 'SELECT *,
                           CONVERT(VARCHAR(50), NULL) AS PortfolioCode,
                           CONVERT(VARCHAR(200), NULL) AS SECURITY_NAME_Enriched,
                           CONVERT(VARCHAR(200), NULL) AS PARENT_SECURITY_Enriched,
                           CONVERT(VARCHAR(2000), NULL) AS ParentTree
                    INTO ' + @TargetInternalTable + '
                    FROM ' + @DNATable + ' with (NOLOCK)
                    WHERE DATEDIFF(dd, StartDate, EndDate) IN (28, 29, 30, 31)
                    '
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
        -- Set Parent Tree for DNA
        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET ParentTree =    ''TOTAL>>'' +
                            CASE WHEN Level1 <> ''TOTAL'' THEN Level1 + ''>>'' ELSE '''' END +
                            CASE WHEN Level1 <> Level2 THEN Level2 + ''>>''ELSE '''' END
        '
        EXEC(@SQL)
        --------------------------------------------------------
        SET @SQL =
        '
        UPDATE ' + @SourceInternalTable + '
        SET SECURITY_NAME_Natural = LTRIM(RTRIM(AssetClass_TAB)),
            SECURITY_NAME_Enriched = CASE
                                        WHEN LTRIM(RTRIM(AssetClass_TAB)) = ''Liquids'' THEN ''Liquids (Cash and Equivalents)''
                                        WHEN LTRIM(RTRIM(AssetClass_TAB)) = ''Korea'' THEN ''Korea (South Korea)''
                                        ELSE LTRIM(RTRIM(AssetClass_TAB))
                                     END;
         '
        EXEC(@SQL)

        SET @SQL =
        '
        UPDATE ' + @TargetInternalTable + '
        SET SECURITY_NAME_Enriched = CASE
                                        WHEN SecurityName = ''fund'' AND UPPER(Level1) = ''TOTAL'' THEN ''TOTAL''
                                        WHEN SecurityName = ''Cash and Equivalents'' THEN ''Liquids (Cash and Equivalents)''
                                        WHEN SecurityName = ''South Korea'' THEN ''Korea (South Korea)''
                                        ELSE SECURITY_NAME_Enriched
                                     END,
            PARENT_SECURITY_Enriched =  CASE
                                            WHEN SecurityName = ''fund'' AND UPPER(Level1) = ''TOTAL'' THEN ''TOTAL''
                                            WHEN COALESCE(Level3, Level2, Level1) = ''Cash and Equivalents'' THEN ''Liquids (Cash and Equivalents)''
                                            WHEN COALESCE(Level3, Level2, Level1) = ''South Korea'' THEN ''Korea (South Korea)''
                                            WHEN PARENT_SECURITY_Enriched = ''South Korea'' THEN ''Korea (South Korea)''
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
            PARENT_SECURITY_Enriched VARCHAR(200),
            LeafInd BIT,
            Level3CounterId INT,
            Level2CounterId INT,
            Level1CounterId INT,
            ParentTree VARCHAR(2000)
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
                    CONVERT(VARCHAR(1000), NULL) AS PARENT_SECURITY_Enriched,
                    CONVERT(BIT, 0) AS LeafInd,
                    CONVERT(INT, NULL) AS Level3CounterId,
                    CONVERT(INT, NULL) AS Level2CounterId,
                    CONVERT(INT, NULL) AS Level1CounterId,
                    CONVERT(VARCHAR(2000), NULL) AS ParentTree
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
                PARENT_SECURITY_Enriched,
                LeafInd,
                Level3CounterId,
                Level2CounterId,
                Level1CounterId,
                ParentTree
            )
            EXEC(@SQL)

            CREATE CLUSTERED INDEX IX_KDrive ON #KDrive(CounterId, FileId);

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
            --------------------------------------------------------
            -- Process the Parent Tree
            UPDATE A
            SET A.Level3CounterId =
            (
                SELECT MAX(B.CounterId) AS ParentCounterId
                FROM #KDrive B
                WHERE B.CounterId < A.CounterId
                AND B.SpaceCount < A.SpaceCount
            )
            FROM #KDrive A

            UPDATE A
            SET A.Level2CounterId = B.Level3CounterId
            FROM #KDrive A
                LEFT JOIN #KDrive B
                    ON A.Level3CounterId = B.CounterId

            UPDATE A
            SET A.Level1CounterId = B.Level3CounterId
            FROM #KDrive A
                LEFT JOIN #KDrive B
                    ON A.Level2CounterId = B.CounterId

            UPDATE A
            SET A.ParentTree =
                ISNULL((SELECT B.SECURITY_NAME_Natural + '>>'
                        FROM #KDrive B
                        WHERE A.Level1CounterId = B.CounterId), '') +

                ISNULL((SELECT B.SECURITY_NAME_Natural + '>>'
                        FROM #KDrive B
                        WHERE A.Level2CounterId = B.CounterId), '') +

                ISNULL((SELECT B.SECURITY_NAME_Natural + '>>'
                        FROM #KDrive B
                        WHERE A.Level3CounterId = B.CounterId), '') +

                CASE WHEN LeafInd = 0 AND SECURITY_NAME_Natural <> '' THEN SECURITY_NAME_Natural + '>>' ELSE '' END
            FROM #KDrive A
            SET @SQL =
            '
            UPDATE A
            SET A.PARENT_SECURITY_Natural = B.PARENT_SECURITY_Natural,
                A.PARENT_SECURITY_Enriched = B.PARENT_SECURITY_Enriched,
                A.LeafInd = B.LeafInd,
                A.Level3CounterId = B.Level3CounterId,
                A.Level2CounterId = B.Level2CounterId,
                A.Level1CounterId = B.Level1CounterId,
                A.ParentTree = B.ParentTree
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
            ISNULL(CURRENCY_EFFECT, 0) AS CURRENCY_EFFECT,
            ParentTree
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
            100.0  * [CurrencyEffect] as CURRENCY_EFFECT,
            ParentTree
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
            @DisplayOnlyColumnSourceList = 'ParentTree, FileID',
            @DisplayOnlyColumnTargetList = 'ParentTree, FileID',
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




