USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0698a_FDCLId_20231113]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE procedure [dbo].[rptsp_rpt0698a_FDCLId_20231113]	@DateRange varchar(30),
									@StartDate varchar(10),
									@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0698a
--  Author:         Linus Tor
--  Date Created:   20151104
--  Description:    This stored procedure outputs data files for Medibank datalake (RADAR) project.
--					The stored proc will be called from Crystal Reports (RPT0698a) and output the following files
--
--					Filename convention: [Source]_[BatchID]_[FileContent]_YYYYMMDD.[Extension]
--					1. TIP_1_PolicyTraveller_YYYYMMDD.ctl
--					2. TIP_1_PolicyTraveller_YYYYMMDD.dat
--					3. TIP_1_PolicyTraveller_YYYYMMDD.eot
--
--
--  Parameters:		@DateRange:		Required. Standard date range or _User Defined
--					@StartDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--					@EndDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--   
--  Change History: 20151104 - LT - Created
--					20160527 - LT - TFS 24964, Set PolicyComment to null
--					20160830 - PZ - Include AHM (groupcode = 'AH')
--					20170403 - LT - Streamlined columns with NULL values to blanks.
--                  
/****************************************************************************************************/


--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = 'Yesterday', @StartDate = '', @EndDate = ''
*/

declare @dataStartDate date
declare @dataEndDate date
declare @ControlExtension varchar(4)
declare @EoTExtension varchar(4)
declare @DataExtension varchar(4)
declare @FilenameControl varchar(200)
declare @FilenamePolicyTraveller varchar(200)
declare @FilenameEOT varchar(200)
declare @OutputPath varchar(200)
declare @FormatDate varchar(8)
declare @FormatTime varchar(6)

declare @BatchNumber varchar(2)

--get batch number. if value is null, batch number = 1
select @BatchNumber = convert(int,isnull(max(xDataValuex),1))
from [db-au-workspace].dbo.usrRPT0698a_fdclid
where
	xOutputFileNamex like '%PolicyTraveller%' and
	convert(date,DataTimeStamp) = convert(date,getdate())

--build filename format: TIP_<batchno>_<source>_YYYYMMDD_HHMMSS.<ext>
select @FormatDate = convert(varchar(20),getdate(),112)
select @FormatTime = replace(convert(varchar(8),getdate(),108),':','')
select @FilenameControl = 'TIP_' + @BatchNumber + '_PolicyTraveller_' + @FormatDate + '_' + @FormatTime + '.ctl'
select @FilenamePolicyTraveller = 'TIP_' + @BatchNumber + '_PolicyTraveller_' +  @FormatDate + '_' + @FormatTime + '.dat'
select @FilenameEOT = 'TIP_' + @BatchNumber + '_PolicyTraveller_' +  @FormatDate + '_' + @FormatTime + '.eot'
select @OutputPath = '\\Uldwh02\etl\Surya\MAS\DEV_MBRADAR\Policy_fdclid\'

/* initialise dates */
if @DateRange = '_User Defined'
	select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
	select @dataStartDate = StartDate, @dataEndDate = EndDate
	from [DEVULDWH02].[db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


if object_id('[db-au-workspace].dbo.usrRPT0698a_fdclid') is null
begin
	create table [db-au-workspace].dbo.usrRPT0698a_fdclid
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[xOutputFileNamex] [varchar](64) NULL,
		[xDataIDx] [varchar](41) NULL,				--use to store PolicyTransactionKey
		[xDataValuex] [money] NOT NULL,				--use to store BatchNumber
		[Data] [nvarchar](max) NULL,
		[xFailx] [bit] NOT NULL,
		[DataTimeStamp] [datetime] NOT NULL
	)
	create clustered index idx_usrRPT0698a_fdclid_BIRowID on  [db-au-workspace].dbo.usrRPT0698a_fdclid(BIRowID)
	create index idx_usrRPT0698a_fdclid_DataTimeStamp on [db-au-workspace].dbo.usrRPT0698a_fdclid(DataTimeStamp)
	create index idx_usrRPT0698a_fdclid_xDataIDx on [db-au-workspace].dbo.usrRPT0698a_fdclid(xDataIDx)
	create index idx_usrRPT0698a_fdclid_xOutputFileNamex on [db-au-workspace].dbo.usrRPT0698a_fdclid(xOutputFilenamex)
end


/* get all transaction policykeys from dataStartDate to dataEndDate			*/
if object_id('[db-au-workspace].dbo.RPT0698a_PolicyTransaction') is not null drop table [db-au-workspace].dbo.RPT0698a_PolicyTransaction
select
	pts.PolicyKey,
    pts.PolicyTransactionKey
into [db-au-workspace].dbo.RPT0698a_PolicyTransaction
from
	[DEVULDWH02].[db-au-cmdwh].dbo.penPolicyTransSummary pts
	join [DEVULDWH02].[db-au-cmdwh].dbo.penOutlet o on pts.OutletSKey = o.OutletSKey
where
	pts.CountryKey = 'AU' and
	o.GroupCode in ('MB','AH') and													--Medibank group code
	(	pts.PostingDate between @dataStartDate and @dataEndDate
	 OR
		(
			pts.PostingDate >= '2017-04-03' 
			and								---data extract went live on this date
			pts.PostingDate < @dataStartDate and
			not exists(select null
					   from [db-au-workspace].dbo.usrRPT0698a_fdclid
					   where
							xOutputFileNamex like '%PolicyTraveller%' and 
							xDataIDx = pts.PolicyTransactionKey and 
							xFailx = 0 and
							xDataIDx not in ('Header')
					   )
		)
	)									
group by
	pts.PolicyKey,
    pts.PolicyTransactionKey
order by 1,2


if object_id('[db-au-workspace].dbo.RPT0698a_PolicyTraveller_fdclid') is not null drop table [db-au-workspace].dbo.RPT0698a_PolicyTraveller_fdclid
select top 10
	pts.PolicyTransactionKey,
	@BatchNumber as BatchNumber,
	p.ExternalReference2,
	p.StatusDescription as PolicyStatus,
	p.IssueDate
into [db-au-workspace].dbo.RPT0698a_PolicyTraveller_fdclid
from
	[DEVULDWH02].[db-au-cmdwh].dbo.penPolicy p
	join [DEVULDWH02].[db-au-cmdwh].dbo.penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	join [DEVULDWH02].[db-au-cmdwh].dbo.penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
where
	p.CountryKey = 'AU' and
	o.SuperGroupName = 'Medibank' and
	pts.PolicyTransactionKey in (select PolicyTransactionKey from [db-au-workspace].dbo.RPT0698a_PolicyTransaction)
	--and p.ExternalReference2 is not null
	and p.AlphaCode in ('MBN0042')


--build data output
--if object_id('[db-au-workspace].dbo.RPT0698a_Control_fdclid') is null
--begin
--	create table [db-au-workspace].dbo.RPT0698a_Control_fdclid
--	(
--		ID int identity(1,1) not null,
--		data varchar(max) null,
--		xDataIDx varchar(41) null,
--		xDataValuex money null
--	)
--end
--else
--	truncate table [db-au-workspace].dbo.RPT0698a_Control_fdclid

if object_id('[db-au-workspace].dbo.RPT0698a_Output_fdclid') is null
begin
	create table [db-au-workspace].dbo.RPT0698a_Output_fdclid
	(
		ID int identity(1,1) not null,
		data varchar(max) null,
		xDataIDx varchar(41) null,
		xDataValuex money null
	)
end
else
	truncate table [db-au-workspace].dbo.RPT0698a_Output_fdclid

--insert control data
---insert [db-au-workspace].dbo.RPT0698a_Control_fdclid
---select
---	isnull(convert(varchar,count(1)),'NULL') + '|' + @FormatDate + @FormatTime + '|' + @FilenamePolicyTraveller as Data,
---	null as xDataIDx,
---	null as xDataValuex
---from [db-au-workspace].dbo.RPT0698a_PolicyTraveller_fdclid	

--insert header row
insert [db-au-workspace].dbo.RPT0698a_Output_fdclid
select
	'FDClid|Policy status|Policy Issue Date' as Data,
	'Header' as xDataIDx,
	@BatchNumber as xDataValuex


--insert data
insert [db-au-workspace].dbo.RPT0698a_Output_fdclid
select
	isnull(convert(varchar(50),ltrim(rtrim([ExternalReference2]))),'') + '|' +	
	isnull(convert(varchar(50),ltrim(rtrim([PolicyStatus]))),'')+ '|' +
	isnull(convert(varchar(20),[IssueDate],120),'')   as Data,
	PolicyTransactionKey,
	BatchNumber
from
	[db-au-workspace].dbo.RPT0698a_PolicyTraveller_fdclid


--log output
insert into [db-au-workspace].dbo.usrRPT0698a_fdclid
select 
	@FilenamePolicyTraveller,
	xDataIDx,
	xDataValuex,
	Data,
	0 as xFailx,
	getdate() as DataTimeStamp
from
    [db-au-workspace].dbo.RPT0698a_Output_fdclid



--export data to files
declare @SQL varchar(8000)

--output data file
select @SQL = 'bcp "select Data from [db-au-workspace].dbo.RPT0698a_Output_fdclid" queryout "'+ @OutputPath + @FilenamePolicyTraveller + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL



select 'Files exported. Output logged' as Result


truncate table [db-au-workspace].dbo.RPT0698a_PolicyTransaction
truncate table [db-au-workspace].dbo.RPT0698a_PolicyTraveller_fdclid
--truncate table [db-au-workspace].dbo.RPT0698a_Control_fdclid
truncate table [db-au-workspace].dbo.RPT0698a_Output_fdclid




GO
