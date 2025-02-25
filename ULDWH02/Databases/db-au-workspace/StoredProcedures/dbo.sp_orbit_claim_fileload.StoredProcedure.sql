USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[sp_orbit_claim_fileload]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_orbit_claim_fileload]
as
DECLARE @filename varchar(256)  
DECLARE @filecount int  
DECLARE @sql nvarchar(4000)  

BEGIN  

if OBJECT_ID('tempdb..#FileName') is not null
drop table #Filename

CREATE TABLE #FileName ([FileName] varchar(256));  

INSERT INTO #FileName  
EXEC xp_cmdshell 'dir "\\ULWIBS01.aust.dmz.local\SFTPShares\Orbit Protect\Incoming\*.xlsx" /b';  
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
	"Claim Number" [nvarchar](20) NULL,
	"Claim Created" [nvarchar](20) NULL,
	"Customer Name" [nvarchar](100) NULL,
	"Date of Birth" [nvarchar](20) NULL,
	"Country" [nvarchar](50) NULL,
	"Transaction Type" [nvarchar](10) NULL
)

set @sql = 
'insert into #orbit_claims
select
[Claim Number],
[Claim Created],
[Customer Name],
[Date Of Birth],
Country,
TransactionType
from
    openrowset
    (
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0 Xml;HDR=YES;IMEX=1;Database=Y:\Orbit Protect\Incoming\'+ @filename +''',
        ''
        select 
            *
        from 
            [Claims$]
        ''
    )
'

EXEC (@sql)  

--update #orbit_claims
--set [Claim Number] = REPLACE([Claim Number],CHAR(34),''),
--[Claim Created] = REPLACE([Claim Created],CHAR(34),''),
--[Customer Name] = REPLACE([Customer Name],CHAR(34),''),
--[Date of Birth] = REPLACE([Date of Birth],CHAR(34),''),
--Country = REPLACE(Country,CHAR(34),''),
--[Transaction Type] = REPLACE([Transaction Type],CHAR(34),'')

delete from orbit_claims where convert(varchar(20),insertion_date,23) = convert(varchar(20),GETDATE(),23)

insert into orbit_claims
select [Claim Number],
[Claim Created],
--SUBSTRING([Claim Created],7,4)+'-'+SUBSTRING([Claim Created],4,2)+'-'+ SUBSTRING([Claim Created],1,2) 'Claim Created',
[Customer Name]
,[Date of Birth]
--,SUBSTRING([Date of Birth],7,4)+'-'+SUBSTRING([Date of Birth],4,2)+'-'+ SUBSTRING([Date of Birth],1,2) 'Date of Birth'
,Country
,[Transaction Type]
,getdate()
from #orbit_claims
end

GO
