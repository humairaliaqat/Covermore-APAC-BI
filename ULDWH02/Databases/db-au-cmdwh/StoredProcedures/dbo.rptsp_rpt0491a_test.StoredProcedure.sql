USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0491a_test]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[rptsp_rpt0491a_test]	@DateRange varchar(30),
										@StartDate varchar(10) = null,
										@EndDate varchar(10) = null
as

SET NOCOUNT ON

								 
/****************************************************************************************************/
--  Name:          rptsp_rpt0491aa - IAL Marketing Data Extract
--  Author:        Linus Tor
--  Date Created:  20150520
--  Description:   This stored procedure extract malaysia domain policy data for given parameters
--  Parameters:    @DateRange:	Value is valid date range
--                 @StartDate:	if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate:	if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History: 20150520 - LT - Created
--					20160609 - LT - T25227 - exclude auto-AMT quotes from data extract
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
select @FileName = 'CAS_TEST_COVERMORE_POLICY_' + convert(varchar(10),dateadd(d,-1,getdate()),112) + '.txt'	--file date value is always the previous day


/* get all transaction policykeys from dataStartDate to dataEndDate			*/
if object_id('[db-au-workspace].dbo.tmp_rpt0491a_transactions') is not null drop table [db-au-workspace].dbo.tmp_rpt0491a_transactions
select
    pts.PolicyKey,
    pts.PolicyNoKey, 
    pts.PolicyTransactionKey, 
    pts.IssueDate,  
    sum(pts.TravellersCount) as TravellersCount
into [db-au-workspace].dbo.tmp_rpt0491a_transactions
from
	[db-au-cmdwh].dbo.penPolicyTransSummary pts
	join [db-au-cmdwh].dbo.penOutlet o on pts.OutletSKey = o.OutletSKey
where
	pts.CountryKey = 'AU' and
	o.GroupCode in ('NI','SO','SE') and														 --IAL group codes								
	(	pts.PostingDate between @dataStartDate and @dataEndDate 
		OR
		(
			pts.PostingDate >= '2015-06-01' and			---missing policy handling process
			pts.PostingDate < @dataStartDate and
			not exists(select null
					   from usrRPT0491a
					   where xDataIDx = pts.PolicyTransactionKey and 
							 xFailx = 0 and
							 xDataIDx not in ('Header','ColumnName','Footer')
					   )
		)
	)									
group by
	pts.PolicyKey,
	pts.PolicyNoKey,
	pts.PolicyTransactionKey,
	pts.IssueDate
order by 3,1


/* get all quote QuoteCountryKeys from dataStartDate to dataEndDate			*/
if object_id('[db-au-workspace].dbo.tmp_rpt0491a_quotes') is not null drop table [db-au-workspace].dbo.tmp_rpt0491a_quotes
select
    q.QuoteCountryKey,
    q.PolicyKey,  
    q.QuoteKey,
    q.CreateDate,  
    sum(q.NumberOfPersons) as TravellersCount
into [db-au-workspace].dbo.tmp_rpt0491a_quotes
from
	[db-au-cmdwh].dbo.penQuote q
	join [db-au-cmdwh].dbo.penOutlet o on q.OutletSKey = o.OutletSKey
where
	q.CountryKey = 'AU' and
	o.GroupCode in ('NI','SO','SE') and	
	(													 --IAL group codes
		convert(varchar(10),q.CreateDate,120) between @DataStartDate and @DataEndDate 
		or															---missing quotes handling process
		(
			convert(varchar(10),q.CreateDate,120) >= '2015-06-01' and
			convert(varchar(10),q.CreateDate,120) < @dataStartDate and
			not exists(select null
					   from usrRPT0491a
					   where xDataIDx = q.QuoteCountryKey and
						     xFailx = 0 and
						     xDataIDx not in ('Header','ColumnName','Footer')
					   )
		)							 
	) and
	q.PreviousPolicyNumber is null					--LT - Exclude auto-AMT quotes
group by
	q.QuoteCountryKey,
	q.PolicyKey,
	q.QuoteKey,
	q.CreateDate
order by 3,1


/* select and build the policy extraction data and file */
-- get travellers
if object_id('[db-au-workspace].dbo.tmp_rpt0491a_pivot') is not null drop table [db-au-workspace].dbo.tmp_rpt0491a_pivot
select
	row_number() over(partition by a.PolicyKey order by a.isPrimary desc) as Row,
	a.*
into [db-au-workspace].dbo.tmp_rpt0491a_pivot	
from
(	
	select distinct
		ptr.PolicyKey, 
		ptr.isPrimary, 
		ptr.FirstName,
		ptr.LastName, 
		ptr.DOB,
		ptr.MemberNumber,
		ptr.[State],
		ptr.Age,
		ptr.Postcode,
		ptr.HomePhone,
		ptr.MobilePhone,
		ptr.EmailAddress,
		ptr.OptFurtherContact,
		ptr.Title
	from
		[db-au-cmdwh].dbo.penPolicyTraveller ptr
	where
		ptr.PolicyKey in (select PolicyKey from [db-au-workspace].dbo.tmp_rpt0491a_transactions)
) a


if object_id('[db-au-workspace].dbo.tmp_rpt0491a_pivotquote') is not null drop table [db-au-workspace].dbo.tmp_rpt0491a_pivotquote
select
	row_number() over(partition by a.QuoteCountryKey order by a.isPrimary desc) as Row,
	a.*
into [db-au-workspace].dbo.tmp_rpt0491a_pivotquote
from
(	
	select distinct
		qc.QuoteCountryKey, 
		qc.isPrimary, 
		c.FirstName,
		c.LastName, 
		c.DOB,
		c.MemberNumber,
		c.[State],
		qc.Age,
		c.PostCode,
		c.HomePhone,
		c.MobilePhone,
		c.EmailAddress,
		c.OptFurtherContact,
		c.Title
	from
		[db-au-cmdwh].dbo.penQuoteCustomer qc
		left join [db-au-cmdwh].dbo.penCustomer c on qc.CustomerKey = c.CustomerKey		
	where
		qc.QuoteCountryKey in (select QuoteCountryKey from [db-au-workspace].dbo.tmp_rpt0491a_quotes)
) a


--transpose travellers to columns
if object_id('[db-au-workspace].dbo.tmp_rpt0491a_travellers') is not null drop table [db-au-workspace].dbo.tmp_rpt0491a_travellers
select 
	PolicyKey,
	max(case when [Row] = 1 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName1,
	max(case when [Row] = 1 then convert(varchar(100),LastName) else '' end) as CustomerSurname1,
	max(case when [Row] = 1 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB1,					--dd/mm/yyyy
	max(case when [Row] = 1 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber1,
	max(case when [Row] = 1 then convert(varchar(5),Age) else '' end) as CustomerAge1,
	max(case when [Row] = 1 then convert(varchar(25),[State]) else '' end) as CustomerState1,
	max(case when [Row] = 1 then convert(varchar(50),Postcode) else '' end) as CustomerPostcode1,
	max(case when [Row] = 1 then convert(varchar(50),HomePhone) else '' end) as CustomerHomePhone1,
	max(case when [Row] = 1 then convert(varchar(50),MobilePhone) else '' end) as CustomerMobilePhone1,
	max(case when [Row] = 1 then convert(varchar(255),EmailAddress) else '' end) as CustomerEmailAddress1,
	max(case when [Row] = 1 then convert(varchar(1),OptFurtherContact) else '' end) as CustomerOptFurtherContact1,
	max(case when [Row] = 1 then convert(varchar(50),Title) else '' end) as CustomerTitle1
into [db-au-workspace].dbo.tmp_rpt0491a_travellers	
from [db-au-workspace].dbo.tmp_rpt0491a_pivot
where [Row] <= 1
group by
	PolicyKey
order by PolicyKey	


--transpose travellers to columns
if object_id('[db-au-workspace].dbo.tmp_rpt0491a_travellersquote') is not null drop table [db-au-workspace].dbo.tmp_rpt0491a_travellersquote
select 
	QuoteCountryKey,
	max(case when [Row] = 1 then convert(varchar(100),FirstName) else '' end) as CustomerGivenName1,
	max(case when [Row] = 1 then convert(varchar(100),LastName) else '' end) as CustomerSurname1,
	max(case when [Row] = 1 then convert(varchar(10),DOB,103) else '' end) as CustomerDOB1,					--dd/mm/yyyy
	max(case when [Row] = 1 then convert(varchar(25),MemberNumber) else '' end) as CustomerMemberNumber1,
	max(case when [Row] = 1 then convert(varchar(5),Age) else '' end) as CustomerAge1,
	max(case when [Row] = 1 then convert(varchar(25),[State]) else '' end) as CustomerState1,
	max(case when [Row] = 1 then convert(varchar(50),Postcode) else '' end) as CustomerPostcode1,
	max(case when [Row] = 1 then convert(varchar(50),HomePhone) else '' end) as CustomerHomePhone1,
	max(case when [Row] = 1 then convert(varchar(50),MobilePhone) else '' end) as CustomerMobilePhone1,
	max(case when [Row] = 1 then convert(varchar(255),EmailAddress) else '' end) as CustomerEmailAddress1,
	max(case when [Row] = 1 then convert(varchar(1),OptFurtherContact) else '' end) as CustomerOptFurtherContact1,
	max(case when [Row] = 1 then convert(varchar(50),Title) else '' end) as CustomerTitle1
into [db-au-workspace].dbo.tmp_rpt0491a_travellersquote	
from [db-au-workspace].dbo.tmp_rpt0491a_pivotquote
where [Row] <= 1
group by
	QuoteCountryKey
order by QuoteCountryKey	


--main data extract
if object_id('[db-au-workspace].dbo.tmp_rpt0491a_main') is null
begin
	CREATE TABLE [db-au-workspace].dbo.tmp_rpt0491a_main
	(
		[xDataIDx] [varchar](41)NULL,
		[DATA_FILENAME] [varchar](50) NULL,
		[DATA_DATE] [varchar](10) NULL,
		[POSTING_DATE] [datetime] NULL,
		[Data_Status] [int] NULL,
		[RECORD_IDENTIFIER] [VARCHAR](11) NULL,
		[BUSINESS_CHANNEL] [VARCHAR](50) null,
		[CHANNEL_STATE] [VARCHAR](50) NULL,
		[CONSULTANT_ID] [VARCHAR](50) NULL,
		[COVER_TYPE_SS] [VARCHAR](100) NULL,
		[DATE_OF_BIRTH] [VARCHAR](10) NULL,
		[CUSTOMER_BEST_ADDRESS_POSTCODE] [VARCHAR](50) NULL,
		[CUSTOMER_BEST_ADDRESS_STATE] [VARCHAR](50) NULL,
		[CUSTOMER_FIRST_NAME] [VARCHAR](100) NULL,
		[CUSTOMER_LAST_NAME] [VARCHAR](100) NULL,
		[CUSTOMER_TITLE] [VARCHAR](50) NULL,
		[CUSTOMER_TYPE] [VARCHAR](1) NULL,
		[EMAIL_ADDRESS] [VARCHAR](255) NULL,
		[EMAIL_INVITE_BRAND] [VARCHAR](100) NULL,
		[EXTRACTION_DATE] [VARCHAR](10) NULL,
		[HOME_TELEPHONE_NUMBER] [VARCHAR](50) NULL,
		[MARKETING_CONSENT] [VARCHAR](1) NULL,
		[MOBILE_NUMBER] [VARCHAR](50) NULL,
		[SITE_CODE] [VARCHAR](20) NULL,
		[SSBREFERENCE] [VARCHAR](50) NULL,
		[TRANSACTION_DATE] [VARCHAR](10) NULL,
		[TRANSACTION_TYPE] [VARCHAR](50) NULL,
		[SUM_TOTAL_BASIC_PREM] [VARCHAR](50) NULL,
		[PRODUCT NAME] [VARCHAR](100) NULL,
		[SCHEME_PROMOTION] [VARCHAR](100) NULL,
		[DESTINATION] [VARCHAR](200) NULL,
		[FILE_DATE] [VARCHAR](19) NULL,
		[TRANSACTION_STATUS] [VARCHAR](100) NULL,
		[TRANSACTION_NUMBER] [VARCHAR](50) NULL,
		[SITE_DESCRIPTION] [VARCHAR](50) NULL
	) 
end
else 
	truncate table [db-au-workspace].dbo.tmp_rpt0491a_main


insert [db-au-workspace].dbo.tmp_rpt0491a_main
select
	pts.PolicyTransactionKey as xDataIDx,
	@Filename as DATA_FILENAME,
	convert(varchar(10),getdate(),120) as DATA_DATE,
	pts.PostingDate as POSTING_DATE,
	null as Data_Status,
	'TRANSACTION' as [RECORD_IDENTIFIER],
	o.OutletType as [BUSINESS_CHANNEL],
	o.StateSalesArea as [CHANNEL_STATE],
	isnull(c.[Login],'') as [CONSULTANT_ID],
	isnull(p.PlanDisplayName,'') as [COVER_TYPE_SS],
	convert(varchar(10),tc.CustomerDOB1,103) as [DATE_OF_BIRTH],
	tc.CustomerPostcode1 as [CUSTOMER_BEST_ADDRESS_POSTCODE],
	tc.CustomerState1 as [CUSTOMER_BEST_ADDRESS_STATE],
	tc.CustomerGivenName1 as [CUSTOMER_FIRST_NAME],
	tc.CustomerSurname1 as [CUSTOMER_LAST_NAME],
	tc.CustomerTitle1 as [CUSTOMER_TITLE],
	'I' as [CUSTOMER_TYPE],
	tc.CustomerEmailAddress1 as [EMAIL_ADDRESS],
	o.GroupName as [EMAIL_INVITE_BRAND],
	convert(varchar(10),getdate(),103) as [EXTRACTION_DATE],
	tc.CustomerHomePhone1 as [HOME_TELEPHONE_NUMBER],
	tc.CustomerOptFurtherContact1 as [MARKETING_CONSENT],
	tc.CustomerMobilePhone1 as [MOBILE_NUMBER],
	o.AlphaCode as [SITE_CODE],
	p.PolicyNumber as [SSBREFERENCE],
	convert(varchar(10),pts.IssueTime,103) as [TRANSACTION_DATE],
	pts.TransactionType as [TRANSACTION_TYPE],
	isnull(pts.GrossPremium,0) as [SUM_TOTAL_BASIC_PREM],
	p.ProductDisplayName as [PRODUCT NAME],
	promo.PromoName as [SCHEME_PROMOTION],
	p.PrimaryCountry as [DESTINATION],
	convert(varchar(10),getdate(),103) + ' ' + convert(varchar(8),getdate(),108) as [FILE_DATE],
	pts.TransactionStatus as [TRANSACTION_STATUS],
	pts.PolicyNumber as [TRANSACTION_NUMBER],
	o.OutletName as [SITE_DESCRIPTION]
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
	join [db-au-workspace].dbo.tmp_rpt0491a_Travellers tc on pts.PolicyKey = tc.PolicyKey
where
	pts.PolicyTransactionKey in (select PolicyTransactionKey from [db-au-workspace].dbo.tmp_rpt0491a_Transactions)


--main quote data extract
insert [db-au-workspace].dbo.tmp_rpt0491a_main
select
	q.QuoteCountryKey as xDataIDx,
	@Filename as DATA_FILENAME,
	convert(varchar(10),getdate(),120) as DATA_DATE,
	q.CreateDate as POSTING_DATE,
	null as Data_Status,
	'TRANSACTION' as [RECORD_IDENTIFIER],
	o.OutletType as [BUSINESS_CHANNEL],
	o.StateSalesArea as [CHANNEL_STATE],
	isnull(q.[Username],'') as [CONSULTANT_ID],
	isnull(q.PlanDisplayName,'') as [COVER_TYPE_SS],
	convert(varchar(10),tc.CustomerDOB1,103) as [DATE_OF_BIRTH],
	tc.CustomerPostcode1 as [CUSTOMER_BEST_ADDRESS_POSTCODE],
	tc.CustomerState1 as [CUSTOMER_BEST_ADDRESS_STATE],
	tc.CustomerGivenName1 as [CUSTOMER_FIRST_NAME],
	tc.CustomerSurName1 as [CUSTOMER_LAST_NAME],
	tc.CustomerTitle1 as [CUSTOMER_TITLE],
	'I' as [CUSTOMER_TYPE],
	tc.CustomerEmailAddress1 as [EMAIL_ADDRESS],
	o.GroupName as [EMAIL_INVITE_BRAND],
	convert(varchar(10),getdate(),103) as [EXTRACTION_DATE],
	tc.CustomerHomePhone1 as [HOME_TELEPHONE_NUMBER],
	tc.CustomerOptFurtherContact1 as [MARKETING_CONSENT],
	tc.CustomerMobilePhone1 as [MOBILE_NUMBER],
	o.AlphaCode as [SITE_CODE],
	q.QuoteID as [SSBREFERENCE],
	convert(varchar(10),q.CreateDate,103) as [TRANSACTION_DATE],
	'Quote' as [TRANSACTION_TYPE],
	isnull(q.QuotedPrice,0) as [SUM_TOTAL_BASIC_PREM],
	q.ProductDisplayName as [PRODUCT NAME],
	promo.PromoName as [SCHEME_PROMOTION],
	q.Destination as [DESTINATION],
	convert(varchar(10),getdate(),103) + ' ' + convert(varchar(8),getdate(),108) as [FILE_DATE],
	'' as [TRANSACTION_STATUS],
	'' as [TRANSACTION_NUMBER],
	o.OutletName as [SITE_DESCRIPTION]
from
	[db-au-cmdwh].dbo.penQuote q
	join [db-au-cmdwh].dbo.penOutlet o on q.OutletSKey = o.OutletSKey
	left join [db-au-cmdwh].dbo.penQuotePromo promo on 
		q.QuoteCountryKey = promo.QuoteCountryKey and
		promo.isApplied = 1
	join [db-au-workspace].dbo.tmp_rpt0491a_Travellersquote tc on q.QuoteCountryKey = tc.QuoteCountryKey
where
	q.QuoteCountryKey in (select QuoteCountryKey from [db-au-workspace].dbo.tmp_rpt0491a_quotes)



--build data output
if object_id('[db-au-workspace].dbo.tmp_rpt0491a_Output') is null
begin
	create table [db-au-workspace].dbo.tmp_rpt0491a_Output
	(
		ID int identity(1,1) not null,
		data varchar(max) null,
		xDataIDx varchar(41) null,
		PolicyPremiumGWP money null
	)
end
else
	truncate table [db-au-workspace].dbo.tmp_rpt0491a_Output


--insert header record
insert [db-au-workspace].dbo.tmp_rpt0491a_Output
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
insert [db-au-workspace].dbo.tmp_rpt0491a_Output
(
	data,
	xDataIDx,
	PolicyPremiumGWP
)
select
	'"SOH"|"BUSINESS_CHANNEL"|"CHANNEL_STATE"|"CONSULTANT_ID"|"COVER_TYPE_SS"|"DATE_OF_BIRTH"|"CUSTOMER_BEST_ADDRESS_POSTCODE"|"CUSTOMER_BEST_ADDRESS_STATE"|"CUSTOMER_FIRST_NAME"|"CUSTOMER_LAST_NAME"|"CUSTOMER_TITLE"|"CUSTOMER_TYPE"|"EMAIL_ADDRESS"|"EMAIL_INVITE_BRAND"|"EXTRACTION_DATE"|"HOME_TELEPHONE_NUMBER"|"MARKETING_CONSENT"|"MOBILE_NUMBER"|"SITE_CODE"|"SSBREFERENCE"|"TRANSACTION_DATE"|"TRANSACTION_TYPE"|"SUM_TOTAL_BASIC_PREM"|"PRODUCT_NAME"|"SCHEME_PROMOTION"|"DESTINATION"|"FILE_DATE"|"TRANSACTION_STATUS"|"TRANSACTION_NUMBER"|"SITE_DESCRIPTION"' as Data,
	'ColumnName' as xDataIDx,
	0 as PolicyPremiumGWP	


--insert transaction records
insert [db-au-workspace].dbo.tmp_rpt0491a_Output
(
	data,
	xDataIDx,
	PolicyPremiumGWP
)
select
	'"' +
	left(isnull([RECORD_IDENTIFIER],''),11) + '"|"' +
	left(isnull([BUSINESS_CHANNEL],''),50) + '"|"' + 
	left(isnull([CHANNEL_STATE],''),50) + '"|"' + 
	left(isnull([CONSULTANT_ID],''),50) + '"|"' + 
	left(isnull([COVER_TYPE_SS],''),100) + '"|"' + 
	left(isnull([DATE_OF_BIRTH],''),10) + '"|"' + 
	left(isnull([CUSTOMER_BEST_ADDRESS_POSTCODE],''),50) + '"|"' + 
	left(isnull([CUSTOMER_BEST_ADDRESS_STATE],''),50) + '"|"' + 
	left(isnull([CUSTOMER_FIRST_NAME],''),100) + '"|"' + 
	left(isnull([CUSTOMER_LAST_NAME],''),100) + '"|"' + 
	left(isnull([CUSTOMER_TITLE],''),50) + '"|"' + 
	left(isnull([CUSTOMER_TYPE],''),1) + '"|"' + 
	left(isnull([EMAIL_ADDRESS],''),255) + '"|"' + 
	left(isnull([EMAIL_INVITE_BRAND],''),100) + '"|"' + 
	left(isnull([EXTRACTION_DATE],''),10) + '"|"' + 
	left(isnull([HOME_TELEPHONE_NUMBER],''),50) + '"|"' + 
	left(isnull([MARKETING_CONSENT],''),1) + '"|"' + 
	left(isnull([MOBILE_NUMBER],''),50) + '"|"' + 
	left(isnull([SITE_CODE],''),20) + '"|"' + 
	left(isnull([SSBREFERENCE],''),50) + '"|"' + 
	left(isnull([TRANSACTION_DATE],''),10) + '"|"' + 
	left(isnull([TRANSACTION_TYPE],''),50) + '"|"' + 
	left(convert(varchar,[SUM_TOTAL_BASIC_PREM]),50) + '"|"' + 
	left(isnull([PRODUCT NAME],''),100) + '"|"' + 
	left(isnull([SCHEME_PROMOTION],''),100) + '"|"' + 
	left(isnull([DESTINATION],''),200) + '"|"' +
	left(isnull([FILE_DATE],''),19) + '"|"' +
	left(isnull([TRANSACTION_STATUS],''),100) + '"|"' +
	left(isnull([TRANSACTION_NUMBER],''),50)  + '"|"' +
	left(isnull([SITE_DESCRIPTION],''),50) + '"' as Data,
	xDataIDx,
	[SUM_TOTAL_BASIC_PREM]
from
	[db-au-workspace].dbo.tmp_rpt0491a_main	


--insert footer record
select @NumberOfRecords = count(*)
from [db-au-workspace].dbo.tmp_rpt0491a_main


insert [db-au-workspace].dbo.tmp_rpt0491a_Output
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
    [db-au-workspace].dbo.tmp_rpt0491a_Output
order by ID



--export query to text file
select @SQL = 'bcp "select Data from [db-au-workspace].dbo.tmp_rpt0491a_Output" queryout "'+ @OutputPath + @FileName + '" -c -t -T -S ULDWH02'
execute master.dbo.xp_cmdshell @SQL



--temp tables needs to be truncated as this stored proc is called from OpenRowSet
--if temp tables are null, OpenRowSet will complain
truncate table [db-au-workspace].dbo.tmp_rpt0491a_transactions
truncate table [db-au-workspace].dbo.tmp_rpt0491a_quotes
truncate table [db-au-workspace].dbo.tmp_rpt0491a_pivot
truncate table [db-au-workspace].dbo.tmp_rpt0491a_pivotquote
truncate table [db-au-workspace].dbo.tmp_rpt0491a_travellers
truncate table [db-au-workspace].dbo.tmp_rpt0491a_travellersquote








GO
