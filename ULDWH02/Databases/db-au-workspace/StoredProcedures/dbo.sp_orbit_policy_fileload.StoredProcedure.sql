USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[sp_orbit_policy_fileload]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_orbit_policy_fileload]
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
    WHERE FileName LIKE 'policies%';  
     
     --count number of polciy files present in the directory
    print(@filecount)  

    --stop if multiple files found in the directory  

    IF @filecount > 1  
      RAISERROR ('Multiple Policy files present', -- Message text.  
      16, -- Severity.  
      1 -- State.  
      );  
    ELSE  
      SELECT  
        @filename = [FileName]  
      FROM #FileName  
      WHERE FileName LIKE 'policies%';  

    PRINT ('Processing file:' + @filename)  

    --DROP TABLE #fx;  
    if object_id('tempdb..#orbit_policies') is not null
        drop table #orbit_policies

CREATE TABLE #orbit_policies(
	"Policy Number" [varchar](20) NULL,
	"Policy Start Date" [varchar](20) NULL,
	"Customer Name" [varchar](100) NULL,
	"Date of Birth" [varchar](20) NULL,
	"Country" [varchar](50) NULL,
	"TransactionType" [varchar](10) NULL
)

SET @sql = 
'insert into #orbit_policies
select
[Policy Number],
[Policy Start Date],
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
            [Policies$]
        ''
    )
' 

EXEC (@sql)  

--update #orbit_policies
--set [Policy Number] = REPLACE([Policy Number],CHAR(34),''),
--[Policy Start Date] = REPLACE([Policy Start Date],CHAR(34),''),
--[Customer Name] = REPLACE([Customer Name],CHAR(34),''),
--[Date of Birth] = REPLACE([Date of Birth],CHAR(34),''),
--Country = REPLACE(Country,CHAR(34),''),
--[TransactionType] = REPLACE([TransactionType],CHAR(34),'')

delete from orbit_policies where convert(varchar(20),insertion_date,23) = convert(varchar(20),GETDATE(),23)

insert into orbit_policies
select [Policy Number],
[Policy Start Date],
--SUBSTRING([Policy Start Date],7,4)+'-'+SUBSTRING([Policy Start Date],4,2)+'-'+ SUBSTRING([Policy Start Date],1,2) 'Claim Created',
[Customer Name],
[Date of Birth]
--,SUBSTRING([Date of Birth],7,4)+'-'+SUBSTRING([Date of Birth],4,2)+'-'+ SUBSTRING([Date of Birth],1,2) 'Date of Birth'
,Country
,[TransactionType]
,getdate()
from #orbit_policies

end

GO
