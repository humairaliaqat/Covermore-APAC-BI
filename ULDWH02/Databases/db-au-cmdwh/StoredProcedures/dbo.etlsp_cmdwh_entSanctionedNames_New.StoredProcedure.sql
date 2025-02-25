USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_entSanctionedNames_New]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
        
        
        
        
        
CREATE procedure [dbo].[etlsp_cmdwh_entSanctionedNames_New]        
as        
begin        
        
set nocount on        
        
if object_id('[db-au-cmdwh].dbo.entSanctionedNames') is null        
begin        
CREATE TABLE entSanctionedNames(        
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
        
if object_id('tempdb..#entSanctionNames') is not null          
    drop table #entSanctionNames                
          
        
select convert(varchar(2),Country) 'Country', SanctionID, Reference, Name, NULLIF(convert(nvarchar(256),NameFragment),'null') 'NameFragment',convert(int,LastName) 'LastName'        
, NULLIF(convert(varchar(50),COB),'null') 'COB', NULLIF(Address,'null') 'Address', Insertion_Date        
into #entSanctionNames        
from entSanctionNames_Temp        
        
Merge entSanctionedNames as Target        
Using #entSanctionNames as Source        
on Source.Country = Target.Country and ISNULL(Source.SanctionID,0) = ISNULL(Target.SanctionID,0) and ISNULL(Source.Reference,0) = ISNULL(Target.Reference,0) and Source.Name = Target.Name        
When Not Matched By Target Then        
 Insert ([Country],[SanctionID],[Reference],[Name],[NameFragment],[LastName],[COB],[Address],[InsertionDate])        
 Values (Source.[Country],Source.[SanctionID],Source.[Reference],Source.[Name],Source.[NameFragment],Source.[LastName],Source.[COB],Source.[Address],getdate());        
          
        
        
        
end        
GO
