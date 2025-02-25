USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0698a_Test007]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE procedure [dbo].[rptsp_rpt0698a_Test007]	@DateRange varchar(30),
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
from [db-au-cmdwh].dbo.usrRPT0698a
where
	xOutputFileNamex like '%PolicyTraveller%' and
	convert(date,DataTimeStamp) = convert(date,getdate())

--build filename format: TIP_<batchno>_<source>_YYYYMMDD_HHMMSS.<ext>
select @FormatDate = convert(varchar(20),getdate(),112)
select @FormatTime = replace(convert(varchar(8),getdate(),108),':','')
select @FilenameControl = 'TIP_' + @BatchNumber + '_PolicyTraveller_' + @FormatDate + '_' + @FormatTime + '.ctl'
select @FilenamePolicyTraveller = 'TIP_' + @BatchNumber + '_PolicyTraveller_' +  @FormatDate + '_' + @FormatTime + '.dat'
select @FilenameEOT = 'TIP_' + @BatchNumber + '_PolicyTraveller_' +  @FormatDate + '_' + @FormatTime + '.eot'
--select @OutputPath = '\\ulwibs01.aust.dmz.local\sftpshares\MB_RADAR\'
select @OutputPath = '\\ulwibs01.aust.dmz.local\rpt698atest\MB_RADAR\'

/* initialise dates */
if @DateRange = '_User Defined'
	select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
	select @dataStartDate = StartDate, @dataEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


if object_id('[db-au-cmdwh].dbo.usrRPT0698a') is null
begin
	create table [db-au-cmdwh].dbo.usrRPT0698a
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[xOutputFileNamex] [varchar](64) NULL,
		[xDataIDx] [varchar](41) NULL,				--use to store PolicyTransactionKey
		[xDataValuex] [money] NOT NULL,				--use to store BatchNumber
		[Data] [nvarchar](max) NULL,
		[xFailx] [bit] NOT NULL,
		[DataTimeStamp] [datetime] NOT NULL
	)
	create clustered index idx_usrRPT0698a_BIRowID on [db-au-cmdwh].dbo.usrRPT0698a(BIRowID)
	create index idx_usrRPT0698a_DataTimeStamp on [db-au-cmdwh].dbo.usrRPT0698a(DataTimeStamp)
	create index idx_usrRPT0698a_xDataIDx on [db-au-cmdwh].dbo.usrRPT0698a(xDataIDx)
	create index idx_usrRPT0698a_xOutputFileNamex on [db-au-cmdwh].dbo.usrRPT0698a(xOutputFilenamex)
end


/* get all transaction policykeys from dataStartDate to dataEndDate			*/
if object_id('[db-au-workspace].dbo.RPT0698a_PolicyTransaction') is not null drop table [db-au-workspace].dbo.RPT0698a_PolicyTransaction
select
	pts.PolicyKey,
    pts.PolicyTransactionKey
into [db-au-workspace].dbo.RPT0698a_PolicyTransaction
from
	[db-au-cmdwh].dbo.penPolicyTransSummary pts
	join [db-au-cmdwh].dbo.penOutlet o on pts.OutletSKey = o.OutletSKey
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
					   from [db-au-cmdwh].dbo.usrRPT0698a
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


if object_id('[db-au-workspace].dbo.RPT0698a_PolicyTraveller') is not null drop table [db-au-workspace].dbo.RPT0698a_PolicyTraveller
select
	pts.PolicyTransactionKey,
	@BatchNumber as BatchNumber,
	o.GroupName,
	o.SubGroupName,
	o.AlphaCode,
	o.OutletName,
	o.OutletType,
	p.PolicyID,
	p.PolicyNumber,
	p.IssueDate,
	p.StatusDescription as PolicyStatus,
	p.CancelledDate,
	p.ProductDisplayName,
	p.ProductCode,
	p.PlanName,
	p.AreaType,
	p.Area,
	p.PrimaryCountry as Destination,
	p.TripStart,
	p.TripEnd,
	p.Excess,
	rc.RentalCarPremiumCovered,	
	'' as PolicyComment,
	p.DaysCovered,
	p.TripType,
	p.EmailConsent,
	pts.PolicyTransactionID,
	pts.PolicyNumber as TransactionNumber,
	pts.IssueDate as TransactionDate,
	pts.TransactionType,
	pts.TransactionStatus,	
	u.Username,
	u.ConsultantName,
	pts.StoreCode,
	pts.CRMUserName as CoverMoreCSR,
	pts.TaxAmountSD,
	pts.TaxOnAgentCommissionSD,
	pts.TaxAmountGST,
	pts.TaxOnAgentCommissionGST,
	pts.GrossPremium as SellPrice,
	pts.Commission + pts.GrossAdminFee as AgencyCommission,	
	pts.AdjustedNet as NetPrice,
	pts.BasePolicyCount,
	pts.AddonPolicyCount,
	pts.ExtensionPolicyCount,
	pts.TravellersCount as TravellerCount,
	pts.AdultsCount as AdultCount,
	pts.ChildrenCount as ChildCount,
	pts.ChargedAdultsCount as ChargedAdultCount,
	pts.LuggageCount,
	pts.MedicalCount,
	pts.MotorcycleCount,
	pts.RentalCarCount,
	pts.WintersportCount,
	pts.EMCCount,
	promo.PromoCode,
	promo.PromoName,
	promo.PromoType,
	promo.PromoDiscount,
	ptrav.PolicyTravellerID,
	'' as Title,
	'' as FirstName,
	'' as LastName,
	'' as DOB,
	'' as Age,
	'' as Gender,
	ptrav.isAdult,
	ptrav.AdultCharge,
	ptrav.isPrimary,
	ptrav.MemberNumber,
	'' as AddressLine1,
	'' as AddressLine2,
	'' as Suburb,
	'' as Postcode,
	ptrav.[State],
	ptrav.Country,
	'' as HomePhone,
	'' as WorkPhone,
	'' as MobilePhone,
	'' as EmailAddress,
	'' as EMCType,
	'' as EMCReference,
	ptrav.OptFurtherContact,
	ptrav.MarketingConsent 
into [db-au-workspace].dbo.RPT0698a_PolicyTraveller
from
	[db-au-cmdwh].dbo.penPolicy p
	join [db-au-cmdwh].dbo.penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	join [db-au-cmdwh].dbo.penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
	outer apply
	(
		select
			pt.PolicyTravellerID,
			pt.PolicyID,
			--pt.Title,
			--pt.FirstName,
			--pt.LastName,
			--pt.DOB,
			--pt.Age,
			--pt.Gender,
			pt.isAdult,
			pt.AdultCharge,
			pt.isPrimary,
			pt.MemberNumber,
			--pt.AddressLine1,
			--pt.AddressLine2,
			--pt.Suburb,
			--pt.Postcode,
			pt.[State],
			pt.Country,
			--pt.HomePhone,
			--pt.WorkPhone,
			--pt.MobilePhone,
			--pt.EmailAddress,
			--pt.DisplayName as EMCType,
			--pt.EMCRef as EMCReference,
			pt.OptFurtherContact,
			pt.MarketingConsent 
		from 
			[db-au-cmdwh].dbo.penPolicyTraveller pt
		where
			pt.PolicyKey = p.PolicyKey
	) ptrav
	outer apply
	(
		select top 1
			[Login] as UserName,
			FirstName + ' ' + LastName as ConsultantName
		from
			[db-au-cmdwh].dbo.penUser
		where
			UserKey = pts.UserKey
	) u
	outer apply
	(
		select top 1
			PromoCode,
			PromoName,
			PromoType,
			Discount as PromoDiscount
		from
			[db-au-cmdwh].dbo.penPolicyTransactionPromo
		where
			PolicyTransactionKey = pts.PolicyTransactionKey and
			IsApplied = 1
	) promo			
    outer apply
    (
        select top 1
            CoverIncrease as RentalCarPremiumCovered
        from
            [db-au-cmdwh].dbo.penPolicyTransAddOn pta
        where
            pta.PolicyTransactionKey = pts.PolicyTransactionKey and
            AddOnGroup = 'Rental Car'
    ) rc
where
	p.CountryKey = 'AU' and
	o.SuperGroupName = 'Medibank' and
	pts.PolicyTransactionKey in (select PolicyTransactionKey from [db-au-workspace].dbo.RPT0698a_PolicyTransaction)


--build data output
if object_id('[db-au-workspace].dbo.RPT0698a_Control') is null
begin
	create table [db-au-workspace].dbo.RPT0698a_Control
	(
		ID int identity(1,1) not null,
		data varchar(max) null,
		xDataIDx varchar(41) null,
		xDataValuex money null
	)
end
else
	truncate table [db-au-workspace].dbo.RPT0698a_Control

if object_id('[db-au-workspace].dbo.RPT0698a_Output') is null
begin
	create table [db-au-workspace].dbo.RPT0698a_Output
	(
		ID int identity(1,1) not null,
		data varchar(max) null,
		xDataIDx varchar(41) null,
		xDataValuex money null
	)
end
else
	truncate table [db-au-workspace].dbo.RPT0698a_Output

--insert control data
insert [db-au-workspace].dbo.RPT0698a_Control
select
	isnull(convert(varchar,count(1)),'NULL') + '|' + @FormatDate + @FormatTime + '|' + @FilenamePolicyTraveller as Data,
	null as xDataIDx,
	null as xDataValuex
from [db-au-workspace].dbo.RPT0698a_PolicyTraveller	

--insert header row
insert [db-au-workspace].dbo.RPT0698a_Output
select
	'GroupName|SubGroupName|AlphaCode|OutletName|OutletType|PolicyID|PolicyNumber|IssueDate|PolicyStatus|CancelledDate|ProductDisplayName|ProductCode|PlanName|AreaType|Area|Destination|TripStart|TripEnd|Excess|RentalCarPremiumCovered|PolicyComment|DaysCovered|TripType|EmailConsent|PolicyTransactionID|TransactionNumber|TransactionDate|TransactionType|TransactionStatus|Username|ConsultantName|StoreCode|CoverMoreCSR|TaxAmountSD|TaxOnAgentCommissionSD|TaxAmountGST|TaxOnAgentCommissionGST|SellPrice|AgencyCommission|NetPrice|BasePolicyCount|AddonPolicyCount|ExtensionPolicyCount|TravellerCount|AdultCount|ChildCount|ChargedAdultCount|LuggageCount|MedicalCount|MotorcycleCount|RentalCarCount|WintersportCount|EMCCount|PromoCode|PromoName|PromoType|PromoDiscount|PolicyTravellerID|Title|FirstName|LastName|DOB|Age|Gender|isAdult|AdultCharge|isPrimary|MemberNumber|AddressLine1|AddressLine2|Suburb|Postcode|State|Country|HomePhone|WorkPhone|MobilePhone|EmailAddress|EMCType|EMCReference|OptFurtherContact|MarketingConsent' as Data,
	'Header' as xDataIDx,
	@BatchNumber as xDataValuex


--insert data
insert [db-au-workspace].dbo.RPT0698a_Output
select
	isnull(convert(varchar(50),ltrim(rtrim([GroupName]))),'') + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([SubGroupName]))),'')  + '|' +
	isnull(convert(varchar(20),ltrim(rtrim([AlphaCode]))),'') + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([OutletName]))),'') + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([OutletType]))),'') + '|' +
	isnull(convert(varchar(50),[PolicyID]),'') + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([PolicyNumber]))),'')  + '|' +
	isnull(convert(varchar(20),[IssueDate],120),'') + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([PolicyStatus]))),'')  + '|' +
	isnull(convert(varchar(20),[CancelledDate],120),'')  + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([ProductDisplayName]))),'')  + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([ProductCode]))),'')  + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([PlanName]))),'')  + '|' +
	isnull(convert(varchar(25),ltrim(rtrim([AreaType]))),'')  + '|' +
	isnull(convert(varchar(50),ltrim(rtrim([Area]))),'')  + '|' +
	isnull(convert(varchar(8000),ltrim(rtrim([Destination]))),'')  + '|' +
	isnull(convert(varchar(20),[TripStart],120),'')  + '|' +
	isnull(convert(varchar(20),[TripEnd],120),'')  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[Excess]),''))) + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[RentalCarPremiumCovered]),'')))  + '|' +
	isnull(convert(varchar(1000),[PolicyComment]),'')  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[DaysCovered]),''))) + '|' +
	isnull(convert(varchar(50),[TripType]),'')  + '|' +
	isnull(convert(varchar(50),[EmailConsent]),'')  + '|' +
	isnull(convert(varchar(50),[PolicyTransactionID]),'') + '|' +
	isnull(convert(varchar(50),[TransactionNumber]),'')  + '|' +
	isnull(convert(varchar(20),[TransactionDate],120),'') + '|' +
	isnull(convert(varchar(50),[TransactionType]),'')  + '|' +
	isnull(convert(varchar(50),[TransactionStatus]),'')  + '|' +
	isnull(convert(varchar(100),ltrim(rtrim([Username]))),'')  + '|' +
	isnull(convert(varchar(100),ltrim(rtrim([ConsultantName]))),'')  + '|' +
	isnull(convert(varchar(10),ltrim(rtrim([StoreCode]))),'')  + '|' +
	isnull(convert(varchar(100),ltrim(rtrim(case when [CoverMoreCSR] > '' then [CoverMoreCSR] else '' end))),'')  + '|' +
	isnull(convert(varchar(50),[TaxAmountSD]),'')  + '|' +
	isnull(convert(varchar(50),[TaxOnAgentCommissionSD]),'')  + '|' +
	isnull(convert(varchar(50),[TaxAmountGST]),'')  + '|' +
	isnull(convert(varchar(50),[TaxOnAgentCommissionGST]),'')  + '|' +
	isnull(convert(varchar(50),[SellPrice]),'')  + '|' +
	isnull(convert(varchar(50),[AgencyCommission]),'')  + '|' +
	isnull(convert(varchar(50),[NetPrice]),'')  + '|' +
	isnull(convert(varchar(50),[BasePolicyCount]),'') + '|' +
	isnull(convert(varchar(50),[AddonPolicyCount]),'') + '|' +
	isnull(convert(varchar(50),[ExtensionPolicyCount]),'') + '|' +
	isnull(convert(varchar(50),[TravellerCount]),'') + '|' +
	isnull(convert(varchar(50),[AdultCount]),'') + '|' +
	isnull(convert(varchar(50),[ChildCount]),'') + '|' +
	isnull(convert(varchar(50),[ChargedAdultCount]),'') + '|' +
	isnull(convert(varchar(50),[LuggageCount]),'') + '|' +
	isnull(convert(varchar(50),[MedicalCount]),'') + '|' +
	isnull(convert(varchar(50),[MotorcycleCount]),'') + '|' +
	isnull(convert(varchar(50),[RentalCarCount]),'') + '|' +
	isnull(convert(varchar(50),[WintersportCount]),'') + '|' +
	isnull(convert(varchar(50),[EMCCount]),'') + '|' +
	isnull(convert(varchar(10),[PromoCode]),'')  + '|' +
	isnull(convert(varchar(250),[PromoName]),'')  + '|' +
	isnull(convert(varchar(250),[PromoType]),'')  + '|' +
	isnull(convert(varchar(50),[PromoDiscount]),'')  + '|' +
	isnull(convert(varchar(50),[PolicyTravellerID]),'')  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),case when [Title] > '' then [Title] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),case when [FirstName] > '' then [FirstName] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),case when [LastName] > '' then [LastName] else '' end),'')))  + '|' +
	isnull(convert(varchar(20),[DOB],120),'')  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[Age]),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(10),[Gender]),''))) + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[isAdult]),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[AdultCharge]),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[isPrimary]),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(25),case when [MemberNumber] > '' then [MemberNumber] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),case when [AddressLine1] > '' then [AddressLine1] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),case when [AddressLine2] > '' then [AddressLine2] else '' end),''))) + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),case when [Suburb] > '' then [Suburb] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),case when [Postcode] > '' then [Postcode] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),case when [State] > '' then [State] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),case when [Country] > '' then [Country] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),case when [HomePhone] > '' then [HomePhone] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),case when [WorkPhone] > '' then [WorkPhone] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),case when [MobilePhone] > '' then [MobilePhone] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(255),case when [EmailAddress] > '' then [EmailAddress] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),[EMCType]),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(100),case when [EMCReference] > '' then [EMCReference] else '' end),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[OptFurtherContact]),'')))  + '|' +
	ltrim(rtrim(isnull(convert(varchar(50),[MarketingConsent]),''))) as Data,
	PolicyTransactionKey,
	BatchNumber
from
	[db-au-workspace].dbo.RPT0698a_PolicyTraveller


--log output
insert into [db-au-cmdwh].dbo.usrRPT0698a
select 
	@FilenamePolicyTraveller,
	xDataIDx,
	xDataValuex,
	Data,
	0 as xFailx,
	getdate() as DataTimeStamp
from
    [db-au-workspace].dbo.RPT0698a_Output


/*
--export data to files
declare @SQL varchar(8000)

--output control file
select @SQL = 'bcp "select Data from [db-au-workspace].dbo.RPT0698a_Control" queryout "'+ @OutputPath + @FileNameControl + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL

--output data file
select @SQL = 'bcp "select Data from [db-au-workspace].dbo.RPT0698a_Output" queryout "'+ @OutputPath + @FilenamePolicyTraveller + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL

--output EOT file
select @SQL = 'bcp "select ''eot''" queryout "'+ @OutputPath + @FilenameEOT + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL

--email file
/*
declare @recipientText varchar(200)
declare @cctext varchar(200)
declare @SubjectText varchar(200)
declare @FileAttachmentText varchar(500)

select @recipienttext = 'Thahaseena.Puzhakkara@covermore.com'
select @cctext = 'Thahaseena.Puzhakkara@covermore.com'


select @SubjectText = 're: ' + @FilenamePolicyTraveller
select @FileAttachmentText = '\\ulwibs01.aust.dmz.local\sftpshares\MB_RADAR\' + @FilenamePolicyTraveller

EXEC msdb.dbo.sp_send_dbmail @profile_name='covermorereport',
							 @recipients=@RecipientText,
							 @copy_recipients=@cctext,
							 @subject= @SubjectText,
							 @body='Please find attached MB_RADAR PolicyTraveller file.',
							 @file_attachments=@FileAttachmentText

*/
--select 'hello world' as Greeting



select 'Files exported. Output logged' as Result
*/

truncate table [db-au-workspace].dbo.RPT0698a_PolicyTransaction
truncate table [db-au-workspace].dbo.RPT0698a_PolicyTraveller
truncate table [db-au-workspace].dbo.RPT0698a_Control
truncate table [db-au-workspace].dbo.RPT0698a_Output














GO
