USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[tmpsp_FCTG_Promo_Test]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[tmpsp_FCTG_Promo_Test] @RunPeriod varchar(30)
as

SET NOCOUNT ON


--uncomment to debug
/*
declare @RunPeriod varchar(30)
select @RunPeriod = 'Morning'
*/

declare @rptStartTime datetime
declare @rptEndTime datetime


if @RunPeriod = 'Morning'
begin
	select @rptStartTime = convert(varchar(10),dateadd(d,-1,getdate()),120)+' 13:00:00',
		   @rptEndTime = convert(varchar(10),dateadd(d,-1,getdate()),120)+' 23:59:59'
end
else if @RunPeriod = 'Afternoon'
begin
	select @rptStartTime = convert(varchar(10),getdate(),120) + ' 00:00:00',
		   @rptEndTime = convert(varchar(10),getdate(),120) + ' 12:59:59'
end


if object_id('tempdb..#promo') is not null drop table #promo

create table #promo
(
	AlphaCode varchar(50) null,
	OutletName varchar(200) null,
	TransactionNumber varchar(50) null,
	TransactionDate datetime null,
	PolicyNumber varchar(50) null,
	IssueDate datetime null,
	ConsultantName varchar(200) null,
	PromoCode varchar(50) null,
	PromoName varchar(200) null,
	TransactionTime datetime null,
	SellPrice money null,
	PolicyCount int null,
	rptStartTime datetime null,
	rptEndTime datetime null
)

insert #promo
SELECT
  penOutlet.AlphaCode,
  penOutlet.OutletName,
  penPolicyTransSummary.PolicyNumber as TransactionNumber,
  penPolicyTransSummary.IssueDate as TransactionDate,
  penPolicy.PolicyNumber as PolicyNumber,
  convert(datetime,penPolicy.IssueDate) as IssueDate,
  penUser.FirstName + ' ' + penUser.LastName as ConsultantName,
  penPolicyTransactionPromo.PromoCode,
  penPolicyTransactionPromo.PromoName,
  penPolicyTransSummary.IssueTime as TransactionTime,
  sum(penPolicyTransSummary.GrossPremium) as SellPrice,
  sum(penPolicyTransSummary.BasePolicyCount) as PolicyCount,
  @rptStartTime as rptStartTime,
  @rptEndTime as rptEndTime
FROM
  penPolicy INNER JOIN penPolicyTransSummary ON (penPolicyTransSummary.PolicyKey=penPolicy.PolicyKey)
   INNER JOIN penOutlet ON (penPolicyTransSummary.OutletAlphaKey=penOutlet.OutletAlphaKey)
   LEFT OUTER JOIN penUser ON (penUser.UserKey=penPolicyTransSummary.UserKey and penUser.UserStatus = 'Current')  
   INNER JOIN penPolicyTransactionPromo ON (penPolicyTransSummary.PolicyTransactionKey = penPolicyTransactionPromo.PolicyTransactionKey)
WHERE
  (
   penPolicyTransSummary.CountryKey  =  'AU'
   AND
   penPolicyTransactionPromo.PromoCode in ('TestPol10','TestPol15')
   AND
   penPolicyTransSummary.PostingTime >= @rptStartTime 
   and
   penPolicyTransSummary.PostingTime <= @rptEndTime 
   AND
   ( penOutlet.OutletStatus = 'Current'  )
  )
GROUP BY
  penOutlet.AlphaCode,
  penOutlet.OutletName,
  penPolicyTransSummary.PolicyNumber,
  penPolicyTransSummary.IssueDate,
  penPolicy.PolicyNumber,
  convert(datetime,penPolicy.IssueDate),
  penUser.FirstName + ' ' + penUser.LastName,
  penPolicyTransactionPromo.PromoCode,
  penPolicyTransactionPromo.PromoName,
  penPolicyTransSummary.IssueTime


if (select count(1) from #promo) = 0 or (select count(1) from #promo) is null
	insert #promo
	select
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			@rptStartTime as rptStartTime,
			@rptEndTime as rptEndTime

select * from #promo


drop table #promo
GO
