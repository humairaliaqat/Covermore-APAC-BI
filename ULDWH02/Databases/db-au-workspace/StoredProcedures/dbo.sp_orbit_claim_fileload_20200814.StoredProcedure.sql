USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[sp_orbit_claim_fileload_20200814]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_orbit_claim_fileload_20200814]
as
DECLARE @filename varchar(256)  
DECLARE @filecount int  
DECLARE @sql nvarchar(4000)  

BEGIN  

if OBJECT_ID('tempdb..#FileName') is not null
drop table #Filename

CREATE TABLE #FileName ([FileName] varchar(256));  

INSERT INTO #FileName  
EXEC xp_cmdshell 'dir "H:\Orbit_Data_Files\Incoming File\*.csv" /b';  
    --take count of files to make sure only a single file gets processed  

    SELECT  
      @filecount = COUNT(*)  
    FROM #FileName  
    WHERE FileName LIKE 'claims%';  
     
     --count number of claim files present in the directory
    print(@filecount)  

    --stop if multiple files found in the directory  

    IF @filecount > 1  
      RAISERROR ('Multiple Claims files present', -- Message text.  
      16, -- Severity.  
      1 -- State.  
      );  
    ELSE  
      SELECT  
        @filename = [FileName]  
      FROM #FileName  
      WHERE FileName LIKE 'claims%';  

    PRINT ('Processing file:' + @filename)  

    --DROP TABLE #fx;  
    if object_id('tempdb..#orbit_claims') is not null
        drop table #orbit_claims

CREATE TABLE #orbit_claims(
	"Claim Number" [varchar](20) NULL,
	"Claim Created" [varchar](20) NULL,
	"Customer Name" [varchar](100) NULL,
	"Date of Birth" [varchar](20) NULL,
	"Country" [varchar](50) NULL,
	"Transaction Type" [varchar](10) NULL
)


SET @sql = 'Bulk Insert #orbit_claims
from ''H:\Orbit_Data_Files\Incoming File\' + @filename + '''  
with  
(
FIRSTROW = 2,
FIELDTERMINATOR = '','',
ROWTERMINATOR = ''\n'',
ERRORFILE = ''H:\Orbit_Data_Files\'+@filename+'_error.csv''
)'  

EXEC (@sql)  

update #orbit_claims
set [Claim Number] = REPLACE([Claim Number],CHAR(34),''),
[Claim Created] = REPLACE([Claim Created],CHAR(34),''),
[Customer Name] = REPLACE([Customer Name],CHAR(34),''),
[Date of Birth] = REPLACE([Date of Birth],CHAR(34),''),
Country = REPLACE(Country,CHAR(34),''),
[Transaction Type] = REPLACE([Transaction Type],CHAR(34),'')

delete from orbit_claims where convert(varchar(20),insertion_date,23) = convert(varchar(20),GETDATE(),23)

insert into orbit_claims
select [Claim Number],
SUBSTRING([Claim Created],7,4)+'-'+SUBSTRING([Claim Created],4,2)+'-'+ SUBSTRING([Claim Created],1,2) 'Claim Created',
[Customer Name]
,SUBSTRING([Date of Birth],7,4)+'-'+SUBSTRING([Date of Birth],4,2)+'-'+ SUBSTRING([Date of Birth],1,2) 'Date of Birth'
,Country
,[Transaction Type]
,getdate()
from #orbit_claims
end

GO
