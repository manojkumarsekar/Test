USE TestAutomation;
IF OBJECT_ID('TestAutomation.dbo.ColumnCategory', 'U') IS NOT NULL DROP TABLE TestAutomation.dbo.ColumnCategory;
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
CREATE UNIQUE CLUSTERED INDEX IX_ColumnCategory ON TestAutomation.dbo.ColumnCategory(ComparisonRequestId, ColumnOrder, SourceColumn, TargetColumn);