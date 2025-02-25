USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0491]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0491]	@DateRange varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null
as

SET NOCOUNT ON

								 
/****************************************************************************************************/
--  Name:          rptsp_rpt0491 - IAL Policy Extract
--  Author:        Linus Tor
--  Date Created:  20131218
--  Description:   This stored procedure extract malaysia domain policy data for given parameters
--  Parameters:    @DateRange:	Value is valid date range
--                 @StartDate:	if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate:	if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20131218 - LT - Created
--					20140204 - LT - Modified stored procedure to be compatible with Raw Data Extractor Engine (Leo's flexible robust data extract utility)
--									Scheduling is now performed by BI with appropriate event conditions.
--					20140213 - LT - Added quote transactions to the extract
--					20151318 - LT - Applied isApplied = 1 filter to penPolicyTransactionPromo and penQuotePromo.
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select @DateRange = 'Yesterday', @StartDate = null, @EndDate = null
*/

declare @dataStartDate date
declare @dataEndDate date
declare @OutputPath varchar(200)
declare @FileName varchar(50)
declare @NumberOfRecords int
declare @SQL varchar(8000)


/* initialise dates and file output details */
if @DateRange = '_User Defined'
	select @dataStartDate = @StartDate, @dataEndDate = @EndDate
else
	select @dataStartDate = StartDate, @dataEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange


				 
/* set output path and filename */	       									 
select @OutputPath = '\\ulwibs01.aust.dmz.local\sftpshares\IA\'
select @FileName = 'IAL.' + convert(varchar(10),dateadd(d,-1,getdate()),112)	--file date value is always the previous day


			 
/* get all transaction policykeys from dataStartDate to dataEndDate			*/
if object_id('[db-au-workspace].dbo.tmp_rpt0491_transactions') is not null drop table [db-au-workspace].dbo.tmp_rpt0491_transactions
select
    pts.PolicyKey,
    pts.PolicyNoKey,
    pts.IssueDate,
    pts.PolicyTransactionKey,
    sum(pts.TravellersCount) as TravellersCount
into [db-au-workspace].dbo.tmp_rpt0491_transactions
from
	[db-au-cmdwh].dbo.penPolicyTransSummary pts
	join [db-au-cmdwh].dbo.penOutlet o on pts.OutletSKey = o.OutletSKey
where
	pts.CountryKey = 'AU' and
	o.GroupCode in ('NI','SO','SE') and														 --IAL group codes								
	(	pts.PostingDate between @dataStartDate and @dataEndDate OR
		(
			pts.PostingDate >= '2014-02-02' and			---new missing policy handling process commenced
			pts.PostingDate < @dataStartDate and
			not exists(select null
					   from usrRPT0491
					   where xDataIDx = pts.PolicyTransactionKey and 
							 xFailx = 0 and
							 xDataIDx not in ('Header','ColumnName','Footer')
					   )
		)
	)									
group by
	pts.PolicyKey,
	pts.PolicyNoKey,
	pts.IssueDate,
	pts.PolicyTransactionKey
order by 3,1


/* get all quote QuoteCountryKeys from dataStartDate to dataEndDate			*/
if object_id('[db-au-workspace].dbo.tmp_rpt0491_quotes') is not null drop table [db-au-workspace].dbo.tmp_rpt0491_quotes
select
    q.QuoteCountryKey,
    q.PolicyKey,  
    q.QuoteKey,
    q.CreateDate,  
    sum(q.NumberOfPersons) as TravellersCount
into [db-au-workspace].dbo.tmp_rpt0491_quotes
from
	[db-au-cmdwh].dbo.penQuote q
	join [db-au-cmdwh].dbo.penOutlet o on q.OutletSKey = o.OutletSKey
where
	q.CountryKey = 'AU' and
	o.GroupCode in ('NI','SO','SE') and	
	(													 --IAL group codes
		convert(varchar(10),q.CreateDate,120) between @DataStartDate and @DataEndDate or	--new policies/transactions	
		(
			convert(varchar(10),q.CreateDate,120) >= '2014-02-02' and
			convert(varchar(10),q.CreateDate,120) < @dataStartDate and
			not exists(select null
					   from usrRPT0491
					   where xDataIDx = q.QuoteCountryKey and
						     xFailx = 0 and
						     xDataIDx not in ('Header','ColumnName','Footer')
					   )
		)							 
	)							 
group by
	q.QuoteCountryKey,
	q.PolicyKey,
	q.QuoteKey,
	q.CreateDate
order by 3,1


/* select and build the policy extraction data and file */
-- get travellers
if object_id('[db-au-workspace].dbo.tmp_rpt0491_pivot') is not null drop table [db-au-workspace].dbo.tmp_rpt0491_pivot
select
	row_number() over(partition by a.PolicyKey order by a.isPrimary desc) as Row,
	a.*
into [db-au-workspace].dbo.tmp_rpt0491_pivot	
from
(	
	select distinct
		ptr.PolicyKey, 
		ptr.isPrimary, 
		ptr.FirstName,
		ptr.LastName, 
		ptr.DOB,
		ptr.MemberNumber,
		ptr.[State]
	from
		[db-au-cmdwh].dbo.penPolicyTraveller ptr
	where
		ptr.PolicyKey in (select PolicyKey from [db-au-workspace].dbo.tmp_rpt0491_transactions)
) a


if object_id('[db-au-workspace].dbo.tmp_rpt0491_pivotquote') is not null drop table [db-au-workspace].dbo.tmp_rpt0491_pivotquote
select
	row_number() over(partition by a.QuoteCountryKey order by a.isPrimary desc) as Row,
	a.*
into [db-au-workspace].dbo.tmp_rpt0491_pivotquote
from
(	
	select distinct
		qc.QuoteCountryKey, 
		qc.isPrimary, 
		c.FirstName,
		c.LastName, 
		c.DOB,
		c.MemberNumber,
		c.[State]
	from
		[db-au-cmdwh].dbo.penQuoteCustomer qc
		left join [db-au-cmdwh].dbo.penCustomer c on qc.CustomerKey = c.CustomerKey		
	where
		qc.QuoteCountryKey in (select QuoteCountryKey from [db-au-workspace].dbo.tmp_rpt0491_quotes)
) a


--transpose travellers to columns
if object_id('[db-au-workspace].dbo.tmp_rpt0491_travellers') is not null drop table [db-au-workspace].dbo.tmp_rpt0491_travellers
select 
	PolicyKey,
	max(case when [Row] = 1 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName1,
	max(case when [Row] = 1 then convert(varchar(100),LastName) else '' end) as CustomerSurname1,
	max(case when [Row] = 1 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB1,					--dd/mm/yyyy
	max(case when [Row] = 1 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber1,
	max(case when [Row] = 1 then convert(varchar(25),[State]) else '' end) as CustomerState1,
	max(case when [Row] = 2 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName2,
	max(case when [Row] = 2 then convert(varchar(100),LastName) else '' end) as CustomerSurname2,
	max(case when [Row] = 2 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB2,					--dd/mm/yyyy
	max(case when [Row] = 2 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber2,
	max(case when [Row] = 2 then convert(varchar(25),[State]) else '' end) as CustomerState2,	
	max(case when [Row] = 3 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName3,
	max(case when [Row] = 3 then convert(varchar(100),LastName) else '' end) as CustomerSurname3,
	max(case when [Row] = 3 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB3,					--dd/mm/yyyy
	max(case when [Row] = 3 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber3,
	max(case when [Row] = 3 then convert(varchar(25),[State]) else '' end) as CustomerState3,
	max(case when [Row] = 4 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName4,
	max(case when [Row] = 4 then convert(varchar(100),LastName) else '' end) as CustomerSurname4,
	max(case when [Row] = 4 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB4,					--dd/mm/yyyy
	max(case when [Row] = 4 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber4,
	max(case when [Row] = 4 then convert(varchar(25),[State]) else '' end) as CustomerState4,
	max(case when [Row] = 5 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName5,
	max(case when [Row] = 5 then convert(varchar(100),LastName) else '' end) as CustomerSurname5,
	max(case when [Row] = 5 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB5,					--dd/mm/yyyy
	max(case when [Row] = 5 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber5,
	max(case when [Row] = 5 then convert(varchar(25),[State]) else '' end) as CustomerState5
into [db-au-workspace].dbo.tmp_rpt0491_travellers	
from [db-au-workspace].dbo.tmp_rpt0491_pivot
where [Row] <= 5
group by
	PolicyKey
order by PolicyKey	


--transpose travellers to columns
if object_id('[db-au-workspace].dbo.tmp_rpt0491_travellersquote') is not null drop table [db-au-workspace].dbo.tmp_rpt0491_travellersquote
select 
	QuoteCountryKey,
	max(case when [Row] = 1 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName1,
	max(case when [Row] = 1 then convert(varchar(100),LastName) else '' end) as CustomerSurname1,
	max(case when [Row] = 1 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB1,					--dd/mm/yyyy
	max(case when [Row] = 1 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber1,
	max(case when [Row] = 1 then convert(varchar(25),[State]) else '' end) as CustomerState1,
	max(case when [Row] = 2 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName2,
	max(case when [Row] = 2 then convert(varchar(100),LastName) else '' end) as CustomerSurname2,
	max(case when [Row] = 2 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB2,					--dd/mm/yyyy
	max(case when [Row] = 2 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber2,
	max(case when [Row] = 2 then convert(varchar(25),[State]) else '' end) as CustomerState2,	
	max(case when [Row] = 3 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName3,
	max(case when [Row] = 3 then convert(varchar(100),LastName) else '' end) as CustomerSurname3,
	max(case when [Row] = 3 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB3,					--dd/mm/yyyy
	max(case when [Row] = 3 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber3,
	max(case when [Row] = 3 then convert(varchar(25),[State]) else '' end) as CustomerState3,
	max(case when [Row] = 4 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName4,
	max(case when [Row] = 4 then convert(varchar(100),LastName) else '' end) as CustomerSurname4,
	max(case when [Row] = 4 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB4,					--dd/mm/yyyy
	max(case when [Row] = 4 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber4,
	max(case when [Row] = 4 then convert(varchar(25),[State]) else '' end) as CustomerState4,
	max(case when [Row] = 5 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName5,
	max(case when [Row] = 5 then convert(varchar(100),LastName) else '' end) as CustomerSurname5,
	max(case when [Row] = 5 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB5,					--dd/mm/yyyy
	max(case when [Row] = 5 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber5,
	max(case when [Row] = 5 then convert(varchar(25),[State]) else '' end) as CustomerState5
into [db-au-workspace].dbo.tmp_rpt0491_travellersquote	
from [db-au-workspace].dbo.tmp_rpt0491_pivotquote
where [Row] <= 5
group by
	QuoteCountryKey
order by QuoteCountryKey	


--main data extract
if object_id('[db-au-workspace].dbo.tmp_rpt0491_main') is null
begin
	CREATE TABLE [db-au-workspace].dbo.tmp_rpt0491_main
	(
		[xDataIDx] [varchar](41)NULL,
		[DATA_FILENAME] [varchar](50) NULL,
		[DATA_DATE] [varchar](10) NULL,
		[POSTING_DATE] [datetime] NULL,
		[Data_Status] [int] NULL,
		[RecordIdentifier] [varchar](11)NULL,
		[TransactionDate] [varchar](10) NULL,
		[ReferrerID] [varchar](100)NULL,
		[ReferenceNumber] [varchar](100) NULL,
		[Product] [varchar](50) NULL,
		[UserForReport] [varchar](50)NULL,
		[QuoteReferenceNumber] [varchar](100) NULL,
		[QuoteSavedDate] [varchar](26)NULL,
		[PolicySavedDate] [varchar](26)NULL,
		[PolicyNumber] [varchar](25) NULL,
		[UserID] [varchar](50)NULL,
		[UserName] [varchar](101)NULL,
		[SalesLead] [varchar](50) NULL,
		[BranchID] [int]NULL,
		[BranchName] [varchar](60) NULL,
		[SchemePromotion] [varchar](250)NULL,
		[TransactionType] [varchar](50) NULL,
		[CallType] [varchar](7)NULL,
		[CustomerGivenName1] [varchar](100) NULL,
		[CustomerSurname1] [varchar](100) NULL,
		[CustomerDOB1] [varchar](10) NULL,
		[CustomerMemberNumber1] [varchar](25) NULL,
		[CustomerGivenName2] [varchar](100) NULL,
		[CustomerSurname2] [varchar](100) NULL,
		[CustomerDOB2] [varchar](10) NULL,
		[CustomerMemberNumber2] [varchar](25) NULL,
		[CustomerGivenName3] [varchar](100) NULL,
		[CustomerSurname3] [varchar](100) NULL,
		[CustomerDOB3] [varchar](10) NULL,
		[CustomerMemberNumber3] [varchar](25) NULL,
		[CustomerGivenName4] [varchar](100) NULL,
		[CustomerSurname4] [varchar](100) NULL,
		[CustomerDOB4] [varchar](10) NULL,
		[CustomerMemberNumber4] [varchar](25) NULL,
		[CustomerGivenName5] [varchar](100) NULL,
		[CustomerSurname5] [varchar](100) NULL,
		[CustomerDOB5] [varchar](10) NULL,
		[CustomerMemberNumber5] [varchar](25) NULL,
		[RiskState] [varchar](25) NULL,
		[RiskType] [varchar](50) NULL,
		[CoverType] [varchar](9)NULL,
		[Quote1ProductName] [varchar](50) NULL,
		[Quote1Premium] [money] NULL,
		[Quote1Excess] [money]NULL,
		[Quote2ProductName] [varchar](1)NULL,
		[Quote2Premium] [int]NULL,
		[Quote2Excess] [int]NULL,
		[Quote3ProductName] [varchar](1)NULL,
		[Quote3Premium] [int]NULL,
		[Quote3Excess] [int]NULL,
		[PolicyExcess] [money]NULL,
		[Destination] [varchar](100) NULL,
		[PlanType] [varchar](100) NULL,
		[PaymentType] [varchar](15)NULL,
		[PaymentFrequency] [varchar](8)NULL,
		[RiskPremiumGWP] [money] NULL,
		[PolicyPremiumGWP] [money] NULL,
		[PolicyPremiumTotal] [money] NULL
	) 
end
else 
	truncate table [db-au-workspace].dbo.tmp_rpt0491_main

insert [db-au-workspace].dbo.tmp_rpt0491_main
select
	pts.PolicyTransactionKey as xDataIDx,
	@Filename as DATA_FILENAME,
	convert(varchar(10),getdate(),120) as DATA_DATE,
	pts.PostingDate as POSTING_DATE,
	null as Data_Status,
	'TRANSACTION' as RecordIdentifier,
	convert(varchar(10),pts.IssueTime,103) as TransactionDate,
	o.GroupName + o.OutletType as ReferrerID,
	convert(varchar(100),pts.PolicyNumber) as ReferenceNumber,
	p.ProductDisplayName as Product,
	isnull(c.[Login],'') as UserForReport,
	isnull(convert(varchar(100),q.QuoteID),'') as QuoteReferenceNumber,
	isnull(convert(varchar(20),q.QuoteSaveDate,103) + ' ' + convert(varchar(5),q.QuoteSaveDate,14),'') as QuoteSavedDate,
	isnull(convert(varchar(20),pts.IssueTime,103) + ' ' + convert(varchar(5),pts.IssueTime,14),'') as PolicySavedDate,
	convert(varchar(25),p.PolicyNumber) as PolicyNumber,
	isnull(c.[Login],'') as UserID,
	isnull(c.FirstName + ' ' + c.LastName,'') as UserName,
	isnull(q.ConsultantName,'') as SalesLead,
	0 as BranchID,
	o.Branch as BranchName,
	isnull(promo.PromoName,'') as SchemePromotion,
	pts.TransactionType,
	case when o.OutletType = 'B2C' then 'Web'
		 when o.OutletType = 'B2B' then 'Inbound'
	     else 'Unknown'
	end as CallType,
	isnull(tc.CustomerGivenName1,''),
	isnull(tc.CustomerSurname1,''),
	isnull(convert(varchar(10),tc.CustomerDOB1,103),'') as CustomerDOB1,
	isnull(tc.CustomerMemberNumber1,''),
	isnull(tc.CustomerGivenName2,''),
	isnull(tc.CustomerSurname2,''),
	isnull(convert(varchar(10),tc.CustomerDOB2,103),'') as CustomerDOB2,
	isnull(tc.CustomerMemberNumber2,''),
	isnull(tc.CustomerGivenName3,''),
	isnull(tc.CustomerSurname3,''),
	isnull(convert(varchar(10),tc.CustomerDOB3,103),'') as CustomerDOB3,
	isnull(tc.CustomerMemberNumber3,''),
	isnull(tc.CustomerGivenName4,''),
	isnull(tc.CustomerSurname4,''),
	isnull(convert(varchar(10),tc.CustomerDOB4,103),'') as CustomerDOB4,
	isnull(tc.CustomerMemberNumber4,''),
	isnull(tc.CustomerGivenName5,''),
	isnull(tc.CustomerSurname5,''),
	isnull(convert(varchar(10),tc.CustomerDOB5,103),'') as CustomerDOB5,
	isnull(tc.CustomerMemberNumber5,''),	
	isnull(tc.CustomerState1,'') as RiskState,		
	isnull(p.ProductDisplayName,'') as RiskType,
	case pts.SingleFamilyFlag when 0 then 'Single'
							  when 1 then 'Family'
							  when 2 then 'Duo'
							  else 'Undefined'
	end	as CoverType,
	isnull(p.ProductDisplayName,'') as Quote1ProductName,		--Quote Product is same as Policy Product as only converted quotes are stored 
	isnull(pts.GrossPremium,0) as Quote1Premium,				--Quote Premium is same as Policy Gross Premium as only converted quotes are stored
	isnull(p.Excess,0) as Quote1Excess,						--Quote Excess is same as Policy Excess as only converted quotes are stored
	'' as Quote2ProductName,						--Only converted quote is saved
	0 as Quote2Premium,
	0 as Quote2Excess,
	'' as Quote3ProductName,
	0 as Quote3Premium,
	0 as Quote3Excess,	
	isnull(p.Excess,0) as PolicyExcess,
	isnull(p.PrimaryCountry,'') as Destination,
	isnull(p.PlanDisplayName,'') as PlanType,
	case when isNull(pay.PaymentID,0)=0 and len(isnull(pay.CardType,''))=0 then 'Non Credit Card' 
		 else 'Credit Card'
	end as PaymentType,
	case when p.TripType = 'Annual Multi Trip' then 'Yearly'
		 else 'One Time'
	end as PaymentFrequency,
	isnull(pts.BasePremium,0) as RiskPremiumGWP,
	isnull(pts.GrossPremium,0) as PolicyPremiumGWP,
	isnull(pts.GrossPremium,0) as PolicyPremiumTotal
from
	[db-au-cmdwh].dbo.penPolicyTransSummary pts
	left join [db-au-cmdwh].dbo.penUser c on pts.UserSKey = c.UserSKey
	join [db-au-cmdwh].dbo.penOutlet o on	pts.OutletSKey = o.OutletSKey
	join [db-au-cmdwh].dbo.penPolicy p on pts.PolicyKey = p.PolicyKey
	left join [db-au-cmdwh].dbo.penQuote q on p.PolicyKey = q.PolicyKey
	left join [db-au-cmdwh].dbo.penPolicyTransactionPromo promo on 
		pts.PolicyTransactionKey = promo.PolicyTransactionKey and
		promo.isApplied = 1
	left join [db-au-cmdwh].dbo.penPayment pay on pts.PolicyTransactionKey = pay.PolicyTransactionKey
	join [db-au-workspace].dbo.tmp_rpt0491_Travellers tc on pts.PolicyKey = tc.PolicyKey
where
	pts.PolicyTransactionKey in (select PolicyTransactionKey from [db-au-workspace].dbo.tmp_rpt0491_Transactions)


--main quote data extract
insert [db-au-workspace].dbo.tmp_rpt0491_main
select
	q.QuoteCountryKey as xDataIDx,
	@Filename as DATA_FILENAME,
	convert(varchar(10),getdate(),120) as DATA_DATE,
	q.CreateDate as POSTING_DATE,
	null as Data_Status,
	'TRANSACTION' as RecordIdentifier,
	convert(varchar(10),q.CreateDate,103) as TransactionDate,
	o.GroupName + o.OutletType as ReferrerID,
	convert(varchar(100),q.QuoteID) as ReferenceNumber,
	isnull(q.ProductCode,'') as Product,
	isnull(q.UserName,'') as UserForReport,
	convert(varchar(100),q.QuoteID) as QuoteReferenceNumber,
	isnull(convert(varchar(20),q.QuoteSaveDate,103) + ' ' + convert(varchar(5),q.QuoteSaveDate,14),'') as QuoteSavedDate,
	'' as PolicySavedDate,
	'' as PolicyNumber,
	isnull(q.UserName,'') as UserID,
	isnull(q.ConsultantName,'') as UserName,
	isnull(q.ConsultantName,'') as SalesLead,
	0 as BranchID,
	isnull(o.Branch,'') as BranchName,
	isnull(promo.PromoName,'') as SchemePromotion,
	'Quote' as TransactionType,
	case when o.OutletType = 'B2C' then 'Web'
		 when o.OutletType = 'B2B' then 'Inbound'
	     else 'Unknown'
	end as CallType,
	isnull(tc.CustomerGivenName1,''),
	isnull(tc.CustomerSurname1,''),
	isnull(convert(varchar(10),tc.CustomerDOB1,103),'') as CustomerDOB1,
	isnull(tc.CustomerMemberNumber1,''),
	isnull(tc.CustomerGivenName2,''),
	isnull(tc.CustomerSurname2,''),
	isnull(convert(varchar(10),tc.CustomerDOB2,103),'') as CustomerDOB2,
	isnull(tc.CustomerMemberNumber2,''),
	isnull(tc.CustomerGivenName3,''),
	isnull(tc.CustomerSurname3,''),
	isnull(convert(varchar(10),tc.CustomerDOB3,103),'') as CustomerDOB3,
	isnull(tc.CustomerMemberNumber3,''),
	isnull(tc.CustomerGivenName4,''),
	isnull(tc.CustomerSurname4,''),
	isnull(convert(varchar(10),tc.CustomerDOB4,103),'') as CustomerDOB4,
	isnull(tc.CustomerMemberNumber4,''),
	isnull(tc.CustomerGivenName5,''),
	isnull(tc.CustomerSurname5,''),
	isnull(convert(varchar(10),tc.CustomerDOB5,103),'') as CustomerDOB5,
	isnull(tc.CustomerMemberNumber5,''),	
	isnull(tc.CustomerState1,'') as RiskState,		
	isnull(q.ProductCode,'') as RiskType,
	'' as CoverType,
	isnull(q.ProductCode,'') as Quote1ProductName,		
	isnull(q.QuotedPrice,0) as Quote1Premium,			
	0 as Quote1Excess,									
	'' as Quote2ProductName,							
	0 as Quote2Premium,
	0 as Quote2Excess,
	'' as Quote3ProductName,
	0 as Quote3Premium,
	0 as Quote3Excess,	
	0 as PolicyExcess,
	isnull(q.Destination,''),
	'' as PlanType,
	'' as PaymentType,
	'' as PaymentFrequency,
	0 as RiskPremiumGWP,
	0 as PolicyPremiumGWP,
	0 as PolicyPremiumTotal
from
	[db-au-cmdwh].dbo.penQuote q
	join [db-au-cmdwh].dbo.penOutlet o on q.OutletSKey = o.OutletSKey
	left join [db-au-cmdwh].dbo.penQuotePromo promo on 
		q.QuoteCountryKey = promo.QuoteCountryKey and
		promo.isApplied = 1
	join [db-au-workspace].dbo.tmp_rpt0491_Travellersquote tc on q.QuoteCountryKey = tc.QuoteCountryKey
where
	q.QuoteCountryKey in (select QuoteCountryKey from [db-au-workspace].dbo.tmp_rpt0491_quotes)
	

--build data output
if object_id('[db-au-workspace].dbo.tmp_rpt0491_Output') is null
begin
	create table [db-au-workspace].dbo.tmp_rpt0491_Output
	(
		ID int identity(1,1) not null,
		data varchar(max) null,
		xDataIDx varchar(41) null,
		PolicyPremiumGWP money null
	)
end
else
	truncate table [db-au-workspace].dbo.tmp_rpt0491_Output


--insert header record
insert [db-au-workspace].dbo.tmp_rpt0491_Output
(
	data,
	xDataIDx,
	PolicyPremiumGWP
)
select
	'"SUPPLIER"|"COVER-MORE"|"SSMC"|"1"|"' + convert(varchar(10),getdate(),103) + ' ' + convert(varchar(5),getdate(),108) + '"' as data,
	'Header' as xDataIDx,
	0 as PolicyPremiumGWP

--insert transaction column name record
insert [db-au-workspace].dbo.tmp_rpt0491_Output
(
	data,
	xDataIDx,
	PolicyPremiumGWP
)
select
	'"SOH"|"TransactionDate"|"ReferrerID"|"ReferenceNumber"|"Product"|"UserForReport"|"QuoteReferenceNumber"|"QuoteSavedDate"|"PolicySavedDate"|"PolicyNumber"|"UserID"|"UserName"|"SalesLead"|"BranchID"|"BranchName"|"SchemePromotion"|"TransactionType"|"CallType"|"CustomerGivenName1"|"CustomerSurname1"|"CustomerDOB1"|"CustomerMemberNumber1"|"CustomerGivenName2"|"CustomerSurname2"|"CustomerDOB2"|"CustomerMemberNumber2"|"CustomerGivenName3"|"CustomerSurname3"|"CustomerDOB3"|"CustomerMemberNumber3"|"CustomerGivenName4"|"CustomerSurname4"|"CustomerDOB4"|"CustomerMemberNumber4"|"CustomerGivenName5"|"CustomerSurname5"|"CustomerDOB5"|"CustomerMemberNumber5"|"RiskState"|"RiskType"|"CoverType"|"Quote1ProductName"|"Quote1Premium"|"Quote1Excess"|"Quote2ProductName"|"Quote2Premium"|"Quote2Excess"|"Quote3ProductName"|"Quote3Premium"|"Quote3Excess"|"PolicyExcess"|"Destination"|"PlanType"|"PaymentType"|"PaymentFrequency"|"RiskPremiumGWP"|"PolicyPremiumGWP"|"PolicyPremiumTotal"' as Data,
	'ColumnName' as xDataIDx,
	0 as PolicyPremiumGWP	


--insert transaction records
insert [db-au-workspace].dbo.tmp_rpt0491_Output
(
	data,
	xDataIDx,
	PolicyPremiumGWP
)
select
	'"' +
	left(RecordIdentifier,20) + '"|"' +
	left(TransactionDate,10) + '"|"' +
	left(ReferrerID,80) + '"|"' +
	left(ReferenceNumber,100) + '"|"' +
	left(Product,100) + '"|"' +
	left(UserForReport,25) + '"|"' +
	left(QuoteReferenceNumber,50) + '"|"' +
	left(QuoteSavedDate,20) + '"|"' +
	left(PolicySavedDate,20) + '"|"' +
	left(PolicyNumber,25) + '"|"' +
	left(UserID,25) + '"|"' +
	left(UserName,200) + '"|"' +
	left(SalesLead,25) + '"|"' +
	left(BranchID,25) + '"|"' + 
	left(BranchName,200) + '"|"' +
	left(SchemePromotion,100) + '"|"' +
	left(TransactionType,100) + '"|"' +
	left(CallType,25) + '"|"' +
	left(CustomerGivenName1,100) + '"|"' +
	left(CustomerSurname1,100) + '"|"' +
	left(CustomerDOB1,10) + '"|"' +
	left(CustomerMemberNumber1,25) + '"|"' +
	left(CustomerGivenName2,100) + '"|"' +
	left(CustomerSurname2,100) + '"|"' +
	left(CustomerDOB2,10) + '"|"' +
	left(CustomerMemberNumber2,25) + '"|"' +
	left(CustomerGivenName3,100) + '"|"' +
	left(CustomerSurname3,100) + '"|"' +
	left(CustomerDOB3,10) + '"|"' +
	left(CustomerMemberNumber3,25) + '"|"' +
	left(CustomerGivenName4,100) + '"|"' +
	left(CustomerSurname4,100) + '"|"' +
	left(CustomerDOB4,10) + '"|"' +
	left(CustomerMemberNumber4,25) + '"|"' +
	left(CustomerGivenName5,100) + '"|"' +
	left(CustomerSurname5,100) + '"|"' +
	left(CustomerDOB5,10) + '"|"' +
	left(CustomerMemberNumber5,25) + '"|"' +	
	left(RiskState,25) + '"|"' +
	left(RiskType,50) + '"|"' +
	left(CoverType,50) + '"|"' +
	left(Quote1ProductName,100) + '"|"' +
	convert(varchar,Quote1Premium) + '"|"' +
	convert(varchar,Quote1Excess) + '"|"' +
	left(Quote2ProductName,100) + '"|"' +
	convert(varchar,Quote2Premium) + '"|"' +
	convert(varchar,Quote2Excess) + '"|"' +
	left(Quote3ProductName,100) + '"|"' +
	convert(varchar,Quote3Premium) + '"|"' +
	convert(varchar,Quote3Excess) + '"|"' +
	convert(varchar,PolicyExcess) + '"|"' +
	left(Destination,100) + '"|"' +
	left(PlanType,50) + '"|"' +
	left(PaymentType,50) + '"|"' +
	left(PaymentFrequency,50) + '"|"' +
	convert(varchar,RiskPremiumGWP) + '"|"' +
	convert(varchar,PolicyPremiumGWP) + '"|"' +
	convert(varchar,PolicyPremiumTotal) + '"' as Data,
	xDataIDx,
	PolicyPremiumGWP
from
	[db-au-workspace].dbo.tmp_rpt0491_main	

--insert footer record
select @NumberOfRecords = count(*)
from [db-au-workspace].dbo.tmp_rpt0491_main

insert [db-au-workspace].dbo.tmp_rpt0491_Output
(
	data,
	xDataIDx,
	PolicyPremiumGWP	
)
select
	'"FILE-END"|' + convert(varchar,@NumberOfRecords) + '|"EOF"',
	'Footer' as xDataIDx,
	0 as PolicyPremiumGWP	


--return output
select 
    Data,
    @filename xOutputFileNamex,
    xDataIDx,
    PolicyPremiumGWP xDataValuex
from
    [db-au-workspace].dbo.tmp_rpt0491_Output
order by ID


/*
/* 7. output policy extract file */
--export query to text file
select @SQL = 'bcp "select Data from [db-au-workspace].dbo.tmp_rpt0491_Output" queryout "'+ @OutputPath + @FileName + '" -c -t -T -S ULDWH01'
execute master.dbo.xp_cmdshell @SQL
*/

--temp tables needs to be truncated as this stored proc is called from OpenRowSet
--if temp tables are null, OpenRowSet will complain
truncate table [db-au-workspace].dbo.tmp_rpt0491_transactions
truncate table [db-au-workspace].dbo.tmp_rpt0491_quotes
truncate table [db-au-workspace].dbo.tmp_rpt0491_pivot
truncate table [db-au-workspace].dbo.tmp_rpt0491_pivotquote
truncate table [db-au-workspace].dbo.tmp_rpt0491_travellers
truncate table [db-au-workspace].dbo.tmp_rpt0491_travellersquote



GO
