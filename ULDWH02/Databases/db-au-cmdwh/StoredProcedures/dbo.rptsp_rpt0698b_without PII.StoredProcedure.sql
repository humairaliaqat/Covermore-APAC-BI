USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0698b_without PII]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[rptsp_rpt0698b_without PII]	@DateRange varchar(30),
										@StartDate varchar(10),
										@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           rptsp_rpt0698b
--  Author:         Linus Tor
--  Date Created:   20151106
--  Description:    This stored procedure outputs data files for Medibank datalake (RADAR) project.
--					The stored proc will be called from Crystal Reports (RPT0698b) and outputs the following files
--
--					Filename convention: [Source]_[BatchID]_[FileContent]_YYYYMMDD.[Extension]
--					1. TIP_1_QuoteTraveller_YYYYMMDD.ctl
--					2. TIP_1_QuoteTraveller_YYYYMMDD.dat
--					3. TIP_1_QuoteTraveller_YYYYMMDD.eot
--
--  Parameters:		@DateRange:		Required. Standard date range or _User Defined
--					@StartDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--					@EndDate:		Required if _User Defined. Format: YYYY-MM-DD hh:mm:ss eg. 2015-01-01 00:00:00
--   
--  Change History: 20151106 - LT - Created
--					20160830 - PZ - Include AHM (groupcode = 'AH')
--                  20170403 - LT - Changed NULL values to ''
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
declare @FilenameQuoteTraveller varchar(200)
declare @FilenameEOT varchar(200)
declare @OutputPath varchar(200)
declare @FormatDate varchar(8)
declare @FormatTime varchar(6)

declare @BatchNumber varchar(2)

--get batch number. if value is null, batch number = 1
select @BatchNumber = convert(int,isnull(max(xDataValuex),1))
from [db-au-cmdwh].dbo.usrRPT0698b
where
	xOutputFileNamex like '%QuoteTraveller%' and
	convert(date,DataTimeStamp) = convert(date,getdate())

--build filename format: TIP_<batchno>_<source>_YYYYMMDD_HHMMSS.<ext>
select @FormatDate = convert(varchar(20),getdate(),112)
select @FormatTime = replace(convert(varchar(8),getdate(),108),':','')
select @FilenameControl = 'TIP_' + @BatchNumber + '_QuoteTraveller_' + @FormatDate + '_' + @FormatTime + '.ctl'
select @FilenameQuoteTraveller = 'TIP_' + @BatchNumber + '_QuoteTraveller_' +  @FormatDate + '_' + @FormatTime + '.dat'
select @FilenameEOT = 'TIP_' + @BatchNumber + '_QuoteTraveller_' +  @FormatDate + '_' + @FormatTime + '.eot'
select @OutputPath = '\\ulwibs01.aust.dmz.local\sftpshares\MB_RADAR\'

/* initialise dates */
if @DateRange = '_User Defined'
	select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
	select @dataStartDate = StartDate, @dataEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


if object_id('[db-au-cmdwh].dbo.usrRPT0698b') is null
begin
	create table [db-au-cmdwh].dbo.usrRPT0698b
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[xOutputFileNamex] [varchar](64) NULL,
		[xDataIDx] [varchar](41) NULL,				--use to store PolicyTransactionKey
		[xDataValuex] [money] NOT NULL,				--use to store BatchNumber
		[Data] [nvarchar](max) NULL,
		[xFailx] [bit] NOT NULL,
		[DataTimeStamp] [datetime] NOT NULL
	)
	create clustered index idx_usrRPT0698b_BIRowID on [db-au-cmdwh].dbo.usrRPT0698b(BIRowID)
	create index idx_usrRPT0698b_DataTimeStamp on [db-au-cmdwh].dbo.usrRPT0698b(DataTimeStamp)
	create index idx_usrRPT0698b_xDataIDx on [db-au-cmdwh].dbo.usrRPT0698b(xDataIDx)
	create index idx_usrRPT0698b_xOutputFileNamex on [db-au-cmdwh].dbo.usrRPT0698b(xOutputFilenamex)
end


/* get all transaction policykeys from dataStartDate to dataEndDate			*/
if object_id('[db-au-workspace].dbo.RPT0698b_QuoteTransaction') is not null drop table [db-au-workspace].dbo.RPT0698b_QuoteTransaction
select
	q.QuoteKey
into [db-au-workspace].dbo.RPT0698b_QuoteTransaction
from
	[db-au-cmdwh].dbo.penQuote q
	join [db-au-cmdwh].dbo.penOutlet o on q.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
where
	q.CountryKey = 'AU' and
	o.GroupCode in ('MB','AH') and													--Medibank group code
	(	q.CreateDate between @dataStartDate and @dataEndDate 
	OR
		(
			q.CreateDate >= '2017-04-03' and								---data extract went live on this date
			q.CreateDate < @dataStartDate and
			not exists(select null
					   from [db-au-cmdwh].dbo.usrRPT0698b
					   where
							xOutputFileNamex like '%QuoteTraveller%' and 
							xDataIDx = q.QuoteKey and 
							xFailx = 0 and
							xDataIDx not in ('Header')
					   )
		)
	)									
group by
    q.QuoteKey
order by 1


if object_id('[db-au-workspace].dbo.RPT0698b_QuoteTraveller') is not null drop table [db-au-workspace].dbo.RPT0698b_QuoteTraveller
select
	q.QuoteKey,
	@BatchNumber as BatchNumber,
	q.QuoteID,
	q.SessionID,
	q.AgencyCode as AlphaCode,
	q.UserName,
	q.ConsultantName,
	q.StoreCode,
	q.CreateDate as QuoteDate,
	q.CreateTime as QuoteTime,
	q.Area,
	q.Destination,
	q.DepartureDate,
	q.ReturnDate,
	q.PolicyNo as PolicyNumber,
	q.NumberOfChildren as ChildCount,
	q.NumberofAdults as AdultCount,
	q.NumberofPersons as TravellerCount,
	1 as QuoteCount,
	q.Duration,
	q.isSaved,
	q.QuoteSaveDate,
	q.QuotedPrice as QuotePrice,
	q.ProductCode,
	q.ProductDisplayName as ProductName,
	q.PlanName,
	q.PlanType,
	q.Excess,
	q.isSelected,
	promo.PromoCode,
	promo.PromoName,
	promo.PromoType,
	promo.PromoDiscount,
	c.CustomerID,
	'' as Title ,
	'' as FirstName,
	'' as LastName,
	'' as DOB,
	'' as Age,
	'' as Gender,
	c.isAdult,
	c.isPrimary,
	c.MemberNumber,
	'' as AddressLine1,
	'' as AddressLine2,
	'' as Suburb,
	'' as Postcode,
	c.[State],
	c.Country,
	'' as HomePhone,
	'' as WorkPhone,
	'' as MobilePhone,
	'' as EmailAddress,
	'' as hasEMC,
	c.OptFurtherContact,
	c.MarketingConsent 
into [db-au-workspace].dbo.RPT0698b_QuoteTraveller
from
	[db-au-cmdwh].dbo.penQuote q
	join [db-au-cmdwh].dbo.penOutlet o on 
		q.OutletAlphaKey = o.OutletAlphaKey and 
		o.OutletStatus = 'Current'
	outer apply
	(
		select top 1
			PromoCode,
			PromoName,
			PromoType,
			Discount as PromoDiscount,
			GoBelowNet
		from
			[db-au-cmdwh].dbo.penQuotePromo
		where
			isApplied = 1 and
			QuoteCountryKey = q.QuoteCountryKey
	) promo			
	outer apply
	(
		select 
			c.CustomerID,
            --c.Title,
			--c.FirstName,
			--c.LastName,
			--c.DOB,
			--qc.Age,
			--c.Gender,
			qc.PersonIsAdult as isAdult,
			qc.isPrimary,
			c.MemberNumber,
			--c.AddressLine1,
			--c.AddressLine2,
			--c.Town as Suburb,
			--c.Postcode,
			c.[State],
			c.Country,
			--c.HomePhone,
			--c.WorkPhone,
			--c.MobilePhone,
			--c.EmailAddress,
			--qc.hasEMC,
			c.OptFurtherContact,
			c.MarketingConsent 
		from 
			[db-au-cmdwh].dbo.penQuoteCustomer qc
			inner join [db-au-cmdwh].dbo.penCustomer c on qc.CustomerKey = c.CustomerKey	
		where
			qc.QuoteCountryKey = q.QuoteCountryKey
	) c
where
	q.QuoteKey in (select QuoteKey from [db-au-workspace].dbo.RPT0698b_QuoteTransaction)
	

--build data output
if object_id('[db-au-workspace].dbo.RPT0698b_Control') is null
begin
	create table [db-au-workspace].dbo.RPT0698b_Control
	(
		ID int identity(1,1) not null,
		data varchar(max) null,
		xDataIDx varchar(41) null,
		xDataValuex money null
	)
end
else
	truncate table [db-au-workspace].dbo.RPT0698b_Control

if object_id('[db-au-workspace].dbo.RPT0698b_Output') is null
begin
	create table [db-au-workspace].dbo.RPT0698b_Output
	(
		ID int identity(1,1) not null,
		data varchar(max) null,
		xDataIDx varchar(41) null,
		xDataValuex money null
	)
end
else
	truncate table [db-au-workspace].dbo.RPT0698b_Output

--insert control data
insert [db-au-workspace].dbo.RPT0698b_Control
select
	isnull(convert(varchar,count(QuoteID)),'NULL') + '|' + @FormatDate + @FormatTime + '|' + @FilenameQuoteTraveller as Data,
	null as xDataIDx,
	null as xDataValuex
from [db-au-workspace].dbo.RPT0698b_QuoteTraveller	



--insert header row
insert [db-au-workspace].dbo.RPT0698b_Output
select
	'QuoteID|SessionID|AlphaCode|UserName|ConsultantName|StoreCode|QuoteDate|QuoteTime|Area|Destination|DepartureDate|ReturnDate|PolicyNumber|ChildCount|AdultCount|TravellerCount|QuoteCount|Duration|isSaved|QuoteSaveDate|QuotePrice|ProductCode|ProductName|PlanName|PlanType|Excess|isSelected|PromoCode|PromoName|PromoType|PromoDiscount|CustomerID|Title|FirstName|LastName|DOB|Age|Gender|isAdult|isPrimary|MemberNumber|AddressLine1|AddressLine2|Suburb|Postcode|State|Country|HomePhone|WorkPhone|MobilePhone|EmailAddress|hasEMC|OptFurtherContact|MarketingConsent' as Data,
	'Header' as xDataIDx,
	@BatchNumber as xDataValuex


--insert data
insert [db-au-workspace].dbo.RPT0698b_Output
select
	isnull(convert(varchar,QuoteID),'') + '|' +
	convert(varchar(255),isnull(SessionID,'')) + '|' +
	convert(varchar(60),isnull(AlphaCode,'')) + '|' +
	convert(varchar(100),isnull(case when UserName > '' then UserName else '' end,'')) + '|' +
	convert(varchar(101),isnull(case when ConsultantName > '' then ConsultantName else '' end,'')) + '|' +
	convert(varchar(10),isnull(case when StoreCode > '' then StoreCode else '' end,'')) + '|' +
	isnull(convert(varchar(20),QuoteDate,120),'') + '|' +
	isnull(convert(varchar(20),QuoteTime,120),'') + '|' +
	convert(varchar(50),isnull(Area,'')) + '|' +
	convert(varchar(8000),isnull(Destination,'')) + '|' +
	isnull(convert(varchar(20),DepartureDate,120),'') + '|' +
	isnull(convert(varchar(20),ReturnDate,120),'') + '|' +
	convert(varchar(50),isnull(PolicyNumber,'')) + '|' +
	isnull(convert(varchar(50),ChildCount),'') + '|' +
	isnull(convert(varchar(50),AdultCount),'') + '|' +
	isnull(convert(varchar(50),TravellerCount),'') + '|' +
	isnull(convert(varchar(50),QuoteCount),'') + '|' +
	isnull(convert(varchar(50),Duration),'') + '|' +
	isnull(convert(varchar(50),isSaved),'') + '|' +
	isnull(convert(varchar(20),QuoteSaveDate,120),'') + '|' +
	isnull(convert(varchar(50),QuotePrice),'') + '|' +
	convert(varchar(50),isnull(case when ProductCode > '' then ProductCode else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when ProductName > '' then ProductName else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when PlanName > '' then PlanName else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when PlanType > '' then PlanType else '' end,'')) + '|' +
	isnull(convert(varchar(50),Excess),'') + '|' +
	isnull(convert(varchar(50),isSelected),'') + '|' +
	convert(varchar(10),isnull(case when PromoCode > '' then PromoCode else '' end,'')) + '|' +
	convert(varchar(250),isnull(case when PromoName > '' then PromoName else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when PromoType > '' then PromoType else '' end,'')) + '|' +
	isnull(convert(varchar(50),PromoDiscount),'') + '|' +
	isnull(convert(varchar(50),CustomerID),'') + '|' +
	convert(varchar(50),isnull(case when Title > '' then Title else '' end,'')) + '|' +
	convert(varchar(100),isnull(case when FirstName > '' then FirstName else '' end,'')) + '|' +
	convert(varchar(100),isnull(case when LastName > '' then LastName else '' end,'')) + '|' +
	isnull(convert(varchar(20),DOB,120),'') + '|' +
	isnull(convert(varchar(50),Age),'') + '|' +
	convert(varchar(50),isnull(case when Gender > '' then Gender else '' end,'')) + '|' +
	isnull(convert(varchar(50),isAdult),'') + '|' +
	isnull(convert(varchar(50),isPrimary),'') + '|' +
	convert(varchar(50),isnull(case when MemberNumber > '' then MemberNumber else '' end,'')) + '|' +
	convert(varchar(100),isnull(case when AddressLine1 > '' then AddressLine1 else '' end,'')) + '|' +
	convert(varchar(100),isnull(case when AddressLine2 > '' then AddressLine2 else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when Suburb > '' then Suburb else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when Postcode > '' then Postcode else '' end,'')) + '|' +
	convert(varchar(100),isnull(case when State > '' then [State] else '' end,'')) + '|' +
	convert(varchar(100),isnull(case when Country > '' then Country else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when HomePhone > '' then HomePhone else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when WorkPhone > '' then WorkPhone else '' end,'')) + '|' +
	convert(varchar(50),isnull(case when MobilePhone > '' then MobilePhone else '' end,'')) + '|' +
	convert(varchar(255),isnull(case when EmailAddress > '' then EmailAddress else '' end,'')) + '|' +
	isnull(convert(varchar(50),hasEMC),'') + '|' +
	isnull(convert(varchar(50),OptFurtherContact),'') + '|' +
	isnull(convert(varchar(50),MarketingConsent),'') as Data,
	QuoteKey,
	BatchNumber
from
	[db-au-workspace].dbo.RPT0698b_QuoteTraveller


--log output
insert into [db-au-cmdwh].dbo.usrRPT0698b
select 
	@FilenameQuoteTraveller,
	xDataIDx,
	xDataValuex,
	Data,
	0 as xFailx,
	getdate() as DataTimeStamp
from
    [db-au-workspace].dbo.RPT0698b_Output

declare @SQL varchar(8000)

--output EOT file
select @SQL = 'bcp "select ''eot''" queryout "'+ @OutputPath + @FilenameEOT + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL

--output control file
select @SQL = 'bcp "select Data from [db-au-workspace].dbo.RPT0698b_Control" queryout "'+ @OutputPath + @FileNameControl + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL

--output data file
select @SQL = 'bcp "select Data from [db-au-workspace].dbo.RPT0698b_Output" queryout "'+ @OutputPath + @FilenameQuoteTraveller + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL

--email file
/*
declare @recipientText varchar(200)
declare @cctext varchar(200)
declare @SubjectText varchar(200)
declare @FileAttachmentText varchar(500)

select @recipienttext = 'Thahaseena.Puzhakkara@covermore.com'
select @cctext = 'Thahaseena.Puzhakkara@covermore.com'


select @SubjectText = 're: ' + @FilenameQuoteTraveller
select @FileAttachmentText = '\\ulwibs01.aust.dmz.local\sftpshares\MB_RADAR\' + @FilenameQuoteTraveller

EXEC msdb.dbo.sp_send_dbmail @profile_name='covermorereport',
							 @recipients=@RecipientText,
							 @copy_recipients=@cctext,
							 @subject= @SubjectText,
							 @body='Please find attached MB_RADAR QuoteTraveller file.',
							 @file_attachments=@FileAttachmentText
*/

--select 'hello world' as Greeting


select 'Files exported. Output logged' as Result


truncate table [db-au-workspace].dbo.RPT0698b_QuoteTransaction
truncate table [db-au-workspace].dbo.RPT0698b_QuoteTraveller
truncate table [db-au-workspace].dbo.RPT0698b_Control
truncate table [db-au-workspace].dbo.RPT0698b_Output






GO
