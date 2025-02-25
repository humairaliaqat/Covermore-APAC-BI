USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSanctioned__Link3_New]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
CREATE procedure [dbo].[etlsp_cmdwh_entSanctioned__Link3_New]  
as  
begin  
  
set nocount on  
  
if object_id('[db-au-workspace].dbo.entSanctioned_New') is null  
begin  
CREATE TABLE entSanctioned_New(  
 [Country] [varchar](2) NOT NULL,  
 [SanctionID] [varchar](50) NULL,  
    [Reference] [varchar](61) NULL,  
 [Name] [nvarchar](max) NULL,  
    [DOBString] [nvarchar](max) NULL,  
    [Control Date] datetime NULL  
)  
end  
  
if object_id('tempdb..#entSanctioned_New') is not null  
    drop table #entSanctioned_New  
      
CREATE TABLE #entSanctioned_New(  
 [Country] [varchar](2) NOT NULL,  
 [SanctionID] [varchar](50) NULL,  
 [Name] [nvarchar](max) NULL,  
    [DOBString] [nvarchar](max) NULL,
    [Control Date] date
)  
      
  
BULK INSERT #entSanctioned_New  
FROM 'E:\ETL\Sanctioned\Converted Files\entSanctioned_link3.csv'  
WITH   
(  
FIRSTROW = 2,  
FIELDTERMINATOR = ',',  
ROWTERMINATOR = '\n',  
ERRORFILE = 'E:\ETL\Sanctioned\Converted Files\ErrorFiles\entSanctioned_link3_ErrorRows.csv',  
TABLOCK  
)  
  
INSERT INTO entSanctioned_New  
select Country, SanctionID, SanctionID 'Reference', Name, NULLIF(DOBString,'null') 'DOBString', GETDATE()  
from #entSanctioned_New  

  
end  
  
  
  
GO
