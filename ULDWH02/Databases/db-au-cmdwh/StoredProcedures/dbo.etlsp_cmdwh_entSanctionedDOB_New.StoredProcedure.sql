USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSanctionedDOB_New]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
          
          
            
            
CREATE procedure [dbo].[etlsp_cmdwh_entSanctionedDOB_New]            
as            
begin            
            
set nocount on            
            
if object_id('[db-au-cmdwh].dbo.entSanctionedDOB') is null            
begin            
CREATE TABLE entSanctionedDOB(            
 [Country] [varchar](2) NOT NULL,            
 [SanctionID] [varchar](50) NULL,            
    [Reference] [varchar](61) NULL,            
 [DOBString] [nvarchar](max) NULL,            
 [DOB] Date NULL,            
    [MOB] int NULL,            
 [YOBStart] bigint NULL,            
    [YOBEnd] bigint NULL,            
    [InsertionDate] datetime           
)           
end            
            
 if object_id('tempdb..#entSanctionedDOB') is not null            
    drop table #entSanctionedDOB                  
            
          
select convert(varchar(2),Country) 'Country', SanctionID, Reference, NULLIF(DOBString,'null') 'DOBString'            
, case when DOB <> 'NaT' then           
cast(DOB as date)           
else NULLIF(DOB,'NaT') end 'DOB'            
, cast(MOB as int) 'MOB', cast(YOBStart as bigint) 'YOBStart', cast(YOBEnd as bigint) 'YOBEnd', Insertion_Date    
into #entSanctionedDOB          
from entSanctionedDOB_Temp           
            
Merge entSanctionedDOB as Target          
Using #entSanctionedDOB as Source          
on Source.Country = Target.Country and ISNULL(Source.SanctionID,0) = ISNULL(Target.SanctionID,0) and ISNULL(Source.Reference,0) = ISNULL(Target.Reference,0) and ISNULL(Source.[DOBString],0) = ISNULL(Target.[DOBString],0)  
When Not Matched By Target Then          
 Insert ([Country],[SanctionID],[Reference],[DOBString],[DOB],[MOB],[YOBStart],[YOBEnd],[InsertionDate])          
 Values (Source.[Country],Source.[SanctionID],Source.[Reference],Source.[DOBString],Source.[DOB],Source.[MOB],Source.[YOBStart],Source.[YOBEnd],getdate());          
            
            
end            
            
GO
