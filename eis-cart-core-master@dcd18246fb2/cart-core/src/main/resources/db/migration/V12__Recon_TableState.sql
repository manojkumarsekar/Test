--------------------------------------------
USE TestAutomation
GO
--------------------------------------------
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID('TestAutomation.dbo.LatestFullyLoaded', 'U') IS NOT NULL DROP TABLE TestAutomation.dbo.LatestFullyLoaded;
GO

CREATE TABLE TestAutomation.dbo.LatestFullyLoaded
(
    SECURITY_DNA NVARCHAR(200) NULL,
    SECURITY_LEGACY NVARCHAR(200) NULL,
    POCKET_DNA NVARCHAR(200) NULL,
    POCKET_LEGACY NVARCHAR(200) NULL
);
INSERT INTO TestAutomation.dbo.LatestFullyLoaded VALUES (NULL, NULL, NULL, NULL);

GO

ALTER TABLE TestAutomation.dbo.AttributionModelMapping ADD FundName NVARCHAR(200) NULL;
GO

