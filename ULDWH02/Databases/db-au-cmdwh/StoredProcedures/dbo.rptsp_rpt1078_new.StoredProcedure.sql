USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1078_new]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt1078_new]	@DateRange varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null
as

SET NOCOUNT ON


declare @dataStartDate date
declare @dataEndDate date

--declare variables for outputting text file
declare @SQL varchar(8000)
declare @OutputPath varchar(200)
declare @FileName varchar(13)


/* initialise dates and file output details */
if @DateRange = '_User Defined'
	select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
	select @dataStartDate = StartDate, @dataEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange



if object_id('[db-au-workspace].dbo.RPT1078_Output_new') is not null drop table [db-au-workspace].dbo.RPT1078_Output_new
create table [db-au-workspace].dbo.RPT1078_Output_new
(
	BIRowID bigint identity(1,1) not null,
	[Data] varchar(8000) null
)

--insert header record
--number of characters must equal 26
insert [db-au-workspace].dbo.RPT1078_Output_new
select
	'1'+																							--Record Type					char(1)
	'MHI' +																							--Sending System ID				char(3)
	'MHINSURE  ' +																					--Supplier ID					char(10)
	replace(convert(varchar(8),getdate(),5),'-','') +												--File Creation Date			char(6)			ddmmyy
	'LFS' +																							--Type Of Delivery				char(3)
	'000'																							--Sequence Number				char(3)


if object_id('[db-au-workspace].dbo.RPT1078_Policy_new') is not null drop table [db-au-workspace].dbo.RPT1078_Policy_new

select
	pt.CountryKey,
	pt.PolicyKey,
	p.PolicyNumber,
	p.IssueDate,
	replace(ltrim(rtrim(pt.MemberNumber)),' ','') as MemberNumber,
	substring(replace(ltrim(rtrim(pt.MemberNumber)),' ',''),3,8) as NumericBody,
	right(replace(ltrim(rtrim(pt.MemberNumber)),' ',''),1) as CheckDigit,
	case when left(replace(ltrim(rtrim(pt.MemberNumber)),' ',''),2) = 'MH' and right(replace(ltrim(rtrim(pt.MemberNumber)),' ',''),1) > '' and right(replace(ltrim(rtrim(pt.MemberNumber)),' ',''),1) = try_convert(int,substring(replace(ltrim(rtrim(pt.MemberNumber)),' ',''),3,8)) % 7 then 1 else 0 end as isValidMember,
	pt.isPrimary,
	pt.LastName,
	pt.FirstName,
	pr.GrossPremium
into [db-au-workspace].dbo.RPT1078_Policy_new
from
	penPolicy p with(nolock)
	inner join penPolicyTraveller pt with(nolock) on p.PolicyKey = pt.PolicyKey
	inner join penOutlet o with(nolock) on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	outer apply
	(
		select sum(GrossPremium) as GrossPremium
		from
			penPolicyTransSummary with(nolock)
		where
			PolicyKey = p.PolicyKey and
			TransactionType = 'Base' and
			TransactionStatus = 'Active' 
	) pr
where
	p.TripType = 'Annual Multi Trip' and
	pt.MemberNumber > '' and
	pt.isPrimary = 1 and
	p.PolicyKey in 
	(
		select distinct pts.PolicyKey 
		from 
			[db-au-cmdwh].dbo.penPolicyTransSummary pts with(nolock)
			inner join penOutlet oo with(nolock) on pts.OutletAlphaKey = oo.OutletAlphaKey and oo.OutletStatus = 'Current'
		where
			o.CountryKey = 'MY' and
			o.GroupCode = 'MA' and
			o.SalesSegment like '%White%Label%' and
			pts.TransactionType = 'Base' and
			pts.TransactionStatus = 'Active' and
			pts.PostingDate >= @dataStartDate and 
			pts.PostingDate < dateadd(d,1,@dataEndDate)
	)


--insert detail records
insert [db-au-workspace].dbo.RPT1078_Output_new
select
	'2' +																								--Record Type					char(1)
	left(MemberNumber,11) + space(11 - len(left(MemberNumber,11))) +									--Member ID						char(11)
	left(upper(LastName),11) + space(11 - len(left(LastName,11))) +										--Member Last Name				char(11)
	left(upper(FirstName),1) +																			--Memeber Initial				char(1)
	replace(convert(varchar(8),IssueDate,5),'-','') +													--Activity Date (Issue Date)	char(6)			ddmmyy
	'MHINSURE  ' +																						--Service Location Code			char(10)		
	'MHINSURE MALAYSIA AIRLINES ENRICH'	+ space(35 - len('MHINSURE MALAYSIA AIRLINES ENRICH')) +		--Location Description			char(35)
	left(CountryKey,2) +																				--ISO Country Code				char(2)
	'       ' +																							--Service Class Code			char(7)			spaces(7)
	right('0000000'+ convert(varchar,cast(GrossPremium as int)), 7) +									--Miles Awarded					char(7)         drop decimals -- reverted to original code on 20200106
	--right('0000000'+ convert(varchar,cast((GrossPremium/2) as int)), 7) +								--Miles Awarded logic (GrossPremium/2) Changed on 20191129
	right('00000000000' + convert(varchar,ROW_NUMBER() OVER(ORDER BY PolicyKey)),11)					--Booking Number (Sequence)		char(11)
from
	[db-au-workspace].dbo.RPT1078_Policy_new
where
	isValidMember = 1


--insert trail record
insert [db-au-workspace].dbo.RPT1078_Output_new
select top 1
	'3' +																								--Record Type					char(1)
	right('00000' + convert(varchar,sum(case when isValidMember = 1 then 1 else 0 end)),6)				--Number of transactions		char(6)
from
	[db-au-workspace].dbo.RPT1078_Policy_new

select [Data] from [db-au-workspace].dbo.RPT1078_Output_new


if object_id('[db-au-cmdwh].dbo.usrRPT1078_InvalidMember_new') is null
begin
	create table [db-au-cmdwh].dbo.usrRPT1078_InvalidMember_new
	(
		CountryKey varchar(2) null,
		PolicyKey varchar(50) null,
		PolicyNumber varchar(50) null,
		IssueDate datetime null,
		MemberNumber varchar(20) null,
		NumericBody varchar(8) null,
		CheckDigit varchar(1) null,
		isValidMember int null,
		isPrimary int null,
		LastName varchar(100) null,
		FirstName varchar(100) null,
		GrossPremium money null,
		[Timestamp] datetime not null
	)
	create clustered index idx_usrRPT1078_InvalidMember_new_PolicyKey on [db-au-cmdwh].dbo.usrRPT1078_InvalidMember_new(PolicyKey)
	create nonclustered index idx_usrRPT1078_InvalidMember_new_IssueDate on [db-au-cmdwh].dbo.usrRPT1078_InvalidMember_new(IssueDate, isValidMember)	
end
else
	delete a
	from 
		[db-au-cmdwh].dbo.usrRPT1078_InvalidMember_new a
		inner join [db-au-workspace].dbo.RPT1078_Policy_new b on a.PolicyKey = b.PolicyKey
	where
		b.isValidMember = 0


--write policy data with invalid member numbers as exceptions
insert [db-au-cmdwh].dbo.usrRPT1078_InvalidMember_new
(
	CountryKey,
	PolicyKey,
	PolicyNumber,
	IssueDate,
	MemberNumber,
	NumericBody,
	CheckDigit,
	isValidMember,
	isPrimary,
	LastName,
	FirstName,
	GrossPremium,
	[Timestamp]
)
select
	CountryKey,
	PolicyKey,
	PolicyNumber,
	IssueDate,
	MemberNumber,
	NumericBody,
	CheckDigit,
	isValidMember,
	isPrimary,
	LastName,
	FirstName,
	GrossPremium,
	getdate() as [TimeStamp]
from 
	[db-au-workspace].dbo.RPT1078_Policy_new
where 
	isValidMember = 0


truncate table [db-au-workspace].dbo.RPT1078_Policy_new
truncate table [db-au-workspace].dbo.RPT1078_Output_new
GO
