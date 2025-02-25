USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSanctionedDOB_Link3_New]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
CREATE procedure [dbo].[etlsp_cmdwh_entSanctionedDOB_Link3_New]  
as  
begin  
  
set nocount on  
  
if object_id('[db-au-workspace].dbo.entSanctionedDOB_New') is null  
begin  
CREATE TABLE entSanctionedDOB_New(  
 [Country] [varchar](2) NOT NULL,  
 [SanctionID] [varchar](50) NULL,  
    [Reference] [varchar](61) NULL,  
 [DOBString] [nvarchar](max) NULL,  
 [DOB] date NULL,  
    [MOB] int NULL,  
 [YOBStart] bigint NULL,  
    [YOBEnd] bigint NULL,  
    [InsertionDate] datetime  
)  
end  
  
--if object_id('[db-au-workspace].dbo.entSanctionedDOB_New') is not null  
--    truncate table [db-au-workspace].dbo.entSanctionedDOB_New  
  
if object_id('tempdb..#entSanctionedDOB_New') is not null  
    drop table #entSanctionedDOB_New  
      
CREATE TABLE #entSanctionedDOB_New(  
 [Country] [varchar](2) NOT NULL,  
 [SanctionID] [varchar](50) NULL,  
 [DOBString] [nvarchar](max) NULL,  
 [DOB] [varchar](50) NULL,  
    [MOB] [varchar](50) NULL,  
 [YOBStart] [varchar](4) NULL,  
    [YOBEnd] [varchar](4) NULL  
    )  
      
  
BULK INSERT #entSanctionedDOB_New  
FROM 'E:\ETL\Sanctioned\Converted Files\entDOB_link3.csv'  
WITH   
(  
FIRSTROW = 2,  
FIELDTERMINATOR = ',',  
ROWTERMINATOR = '\n',  
ERRORFILE = 'E:\ETL\Sanctioned\Converted Files\ErrorFiles\entDOB_link3_ErrorRows.csv',  
TABLOCK  
)  
  
INSERT INTO entSanctionedDOB_New  
select Country, SanctionID, SanctionID 'Reference', NULLIF(DOBString,'null') 'DOBString'  
, case when DOB <> 'NaT' then 
convert(varchar,DOB) 
else NULLIF(DOB,'NaT') end 'DOB'  
, NULLIF(MOB,'0') 'MOB', NULLIF(YOBStart,'0') 'YOBStart', NULLIF(YOBEnd,'0') 'YOBEnd', GETDATE()  
from #entSanctionedDOB_New  
  
  
  
end  
  
  

  
GO
