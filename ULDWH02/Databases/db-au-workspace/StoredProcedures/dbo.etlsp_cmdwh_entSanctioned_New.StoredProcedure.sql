USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSanctioned_New]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
    
    
      
      
CREATE procedure [dbo].[etlsp_cmdwh_entSanctioned_New]      
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
    [Control Date] datetime NULL,    
    [InsertionDate] date NULL      
)      
end      
      
      
--INSERT INTO entSanctioned_New      
--select convert(varchar(2),Country), SanctionID, SanctionID 'Reference', Name, NULLIF(DOBString,'null') 'DOBString',[Control Date], insertion_date    
--select * from entSanctioned_Temp      
    
Merge entSanctioned_New as Target    
Using entSanctioned_Temp as Source    
on Source.Country = Target.Country and ISNULL(Source.SanctionID,0) = ISNULL(Target.SanctionID,0) and ISNULL(Source.Reference,0) = ISNULL(Target.Reference,0) and Source.Name = Target.Name    
When Not Matched By Target Then    
 Insert ([Country],[SanctionID],[Reference],[Name],[DOBString],[Control Date],[InsertionDate])    
 Values (convert(varchar(2),Source.Country),Source.SanctionID,Source.Reference,Source.Name,NULLIF(Source.DOBString,'null'),Source.[Control Date],getdate());    
    
end      

GO
