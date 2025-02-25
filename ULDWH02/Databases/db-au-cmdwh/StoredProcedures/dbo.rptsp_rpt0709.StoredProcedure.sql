USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0709]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0709]		@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON

										
/****************************************************************************************************/
--  Name:           rptsp_rpt0709
--  Author:         Linus Tor
--  Date Created:   20170628
--  Description:    This stored procedure returns Westpac Staff sales.
--
--  Date Range:     @DateRange: Standard Date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2015-01-01
--   
--  Change History: 20170628 - LT - Created
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2017-01-01', @EndDate = '2017-06-01'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime


--get reporting dates
if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate,
		   @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, 
		   @rptEndDate = EndDate
	from [db-au-cmdwh].dbo.vDateRange
	where DateRange = @DateRange

select
  o.GroupName,
  o.AlphaCode,
  o.OutletName,
  p.PolicyNumber,
  convert(datetime,p.IssueDate) as IssueDate,
  p.StatusDescription as PolicyStatus,
  pts.PolicyNumber as TransactionNumber,
  convert(datetime,pts.IssueDate) as TransactionDate,
  pts.TransactionType,
  pts.TransactionStatus,
  prem.Discount,
  prem.SellPrice,
  prem.RRP,
  pcount.PolicyCount,
  ptr.Title,
  ptr.FirstName,
  ptr.LastName,
  ptr.EmailAddress,
  ptr.PIDValue,
  ptr.PIDType,
  ptr.isPrimary,
  promo.PromoCode,
  promo.PromoType,
  promo.DiscountPct,
  @rptStartDate as rptStartDate,
  @rptEndDate as rptEndDate
from
	penPolicy p
	inner join penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
	inner join penOutlet o on p.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current'
	inner join penPolicyTraveller ptr on p.PolicyKey = ptr.PolicyKey
	outer apply
	(
		select sum(NewPolicyCount) as PolicyCount
		from penPolicyTransSummary
		where PolicyTransactionKey = pts.PolicyTransactionKey
	) pcount
	outer apply
	(
		select
			sum("Unadjusted Sell Price") as RRP,
			sum("Sell Price") as SellPrice,
			sum("Discount on Sell Price") as Discount
		from
			vPenguinPolicyPremiums
		where
			PolicyTransactionKey = pts.PolicyTransactionKey
	) prem
	outer apply
	(
		select top 1
			p.PolicyKey,
			pro.PromoCode,
			pro.PromoType,
			pro.Discount as DiscountPct
		from
			penPolicy p
			inner join penPolicyTransSummary pt on p.PolicyKey = pt.PolicyKey
			inner join penPolicyTransactionPromo pro on pt.PolicyTransactionKey = pro.PolicyTransactionKey
			inner join penOutlet a on pt.OutletAlphaKey = a.OutletAlphaKey and a.OutletStatus = 'Current'
		where
			a.CountryKey = 'NZ' and
			a.SuperGroupName = 'Westpac NZ' and
			pro.PromoCode = 'WPACSTAFF' and
			pro.isApplied = 1 and
			pt.PolicyKey = pts.PolicyKey
	) promo
where
	o.CountryKey = 'NZ' and
	o.SuperGroupName = 'Westpac NZ' and
	pts.PostingDate >= @rptStartDate and
	pts.PostingDate < dateadd(day,1,@rptEndDate) and
	promo.PolicyKey is not null



GO
