USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSanctionedNames_Link3_New]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[etlsp_cmdwh_entSanctionedNames_Link3_New]
as
begin

set nocount on

if object_id('[db-au-workspace].dbo.entSanctionedNames_New') is null
begin
CREATE TABLE entSanctionedNames_New(
	[Country] [varchar](2) NOT NULL,
	[SanctionID] [varchar](50) NULL,
    [Reference] [varchar](61) NULL,
	[Name] [nvarchar](max) NULL,
	[NameFragment] [nvarchar](256) NULL,
	[LastName] int NULL,
    [COB] [varchar](50) NULL,
    [Address] [nvarchar](max) NULL,
    [InsertionDate] Datetime
)
end

--if object_id('[db-au-workspace].dbo.entSanctionedNames_New') is not null
--    truncate table [db-au-workspace].dbo.entSanctionedNames_New

if object_id('tempdb..#entSanctionedNames_New') is not null
    drop table #entSanctionedNames_New
    
CREATE TABLE #entSanctionedNames_New(
	[Country] [varchar](2) NOT NULL,
	[SanctionID] [varchar](50) NULL,
	[Name] [nvarchar](max) NULL,
	[NameFragment] [nvarchar](256) NULL,
	[LastName] [nvarchar](2) NULL,
    [COB] [varchar](50) NULL,
    [Address] [nvarchar](max) NULL)
    

BULK INSERT #entSanctionedNames_New
FROM 'E:\ETL\Sanctioned\Converted Files\entNames_link3.csv'
WITH 
(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n',
ERRORFILE = 'E:\ETL\Sanctioned\Converted Files\ErrorFiles\entNames_link3_ErrorRows.csv',
TABLOCK
)

INSERT INTO entSanctionedNames_New
select Country, SanctionID, SanctionID 'Reference', Name, NULLIF(NameFragment,'null') 'NameFragment',LastName
, NULLIF(COB,'null') 'COB', NULLIF(Address,'null') 'Address', GETDATE()
from #entSanctionedNames_New


end





GO
