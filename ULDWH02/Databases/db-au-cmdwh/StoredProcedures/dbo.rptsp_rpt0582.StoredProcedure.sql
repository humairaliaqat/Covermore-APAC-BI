USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0582]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0582]
	@Country varchar(10),
	@AgencyGroupName varchar (100),			
	@DateRange varchar(50),
	@StartDate datetime,
	@EndDate datetime,
	@ReferenceDate varchar(50)
as
begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0582
--  Author:         Saurabh Date
--  Date Created:   20180412
--  Description:    This script is for RPT0582 - Medibank Demographic Report
--
--  Parameters:     
--					@Country: Valid Outlet Country
--					@AgencyGroupName: Valid Agenc Group Name
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--					@ReferenceDate: Posting Date or Issue Date for the policy
--                  
--  Change History: 
--                  20180412 - SD - Created
/****************************************************************************************************/


--uncomment to debug
/*
declare 
	@Country varchar(10),
	@AgencyGroupName varchar (100),			
	@DateRange varchar(50),
	@StartDate datetime,
	@EndDate datetime,
	@ReferenceDate varchar(50)
select 
	@Country = 'AU',
	@AgencyGroupName = 'Medibank',
	@DateRange = 'Month-To-Date',
	@StartDate = null,
	@EndDate = null,
	@ReferenceDate = 'Posting Date'
*/

                                    
DECLARE @rptStartDate datetime
DECLARE	@rptEndDate datetime


--get reporting dates
if @DateRange = '_User Defined'
    select 
        @rptStartDate = @StartDate,
        @rptEndDate = @EndDate

else
    select 
        @rptStartDate = StartDate, 
        @rptEndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange


SELECT
	convert(datetime, c.CurMonthStart) [Month Start],
	o.OutletName [Agency Name],
	p.ProductDisplayName [Product Name],
	p.Area [Area],
	p.AreaType [Area Type],
	p.Excess [Excess],
	p.TripDuration [Trip Duration],
	case 
		when t.Age between 0 and 19 then '0 - 19'
		when t.Age between 20 and 29 then '20 - 29'
		when t.Age between 30 and 39 then '30 - 39'
		when t.Age between 40 and 49 then '40 - 49'
		when t.Age between 50 and 59 then '50 - 59'
		when t.Age between 60 and 69 then '60 - 69'
		when t.Age between 70 and 74 then '70 - 74'
		when t.Age between 75 and 79 then '75 - 79'
		when t.Age between 80 and 84 then '80 - 84'
		else '85+'
	end [Age Group],
	case
		when isnull(t.MemberNumber, '') <> '' or isnull(ptp.PromoCodeCount, 0) > 0 then 1
		else 0
	end [Is Member],
	p.TripType [Trip Type],
	p.MaxDuration [Max Duration],
	case 
		when isnull(t.AssessmentType, 'Not Applicable') = 'Not Applicable' then 'No EMC' 
		else 'EMC' 
	end [EMC Group],
	t.State [State],
	sum(pt.BasePolicyCount) [Policy Count],
	sum(vp."Sell Price") [Sell Price],
	sum(pt.AdultsCount) [Adults Count],
	0 [Quote Count],
	@rptStartDate [Start Date],
	@rptEndDate [End Date]
FROM
	penPolicyTraveller t 
	INNER JOIN penPolicy p 
		ON p.PolicyKey=t.PolicyKey
	INNER JOIN penPolicyTransSummary pt 
		ON pt.PolicyKey=p.PolicyKey
	INNER JOIN penOutlet o 
		ON pt.OutletAlphaKey=o.OutletAlphaKey
	INNER JOIN Calendar c 
		ON (
				(
					@ReferenceDate = 'Issue Date' and
					pt.IssueDate = c.Date
				) 
				or
				(
					@ReferenceDate = 'Posting Date' and
					pt.PostingDate = c.Date
				)
			)
	INNER JOIN vDateRange vd 
		ON c.Date between vd.StartDate and vd.EndDate
	INNER JOIN vPenguinPolicyPremiums vp 
		ON vp.PolicyTransactionKey=pt.PolicyTransactionKey
	outer apply
	(
		select
			count(ptp.PromoCode) PromoCodeCount
		From
			penPolicyTransactionPromo ptp
		where
			ptp.PolicyTransactionKey = pt.PolicyTransactionKey 
			AND
			ptp.PromoCode = 'MEMPRO'
	) ptp
WHERE
	o.CountryKey  =  @Country
	AND
	o.SuperGroupName  =  'Medibank'
	AND
	vd.DateRange  =  @DateRange
	AND
	t.isPrimary  =  1
	AND
	c.Date  BETWEEN  @rptStartDate  AND  @rptEndDate
	AND
	o.GroupName  = @AgencyGroupName
	AND
	o.OutletStatus = 'Current' 
GROUP BY
	c.CurMonthStart,
	o.OutletName,
	p.ProductDisplayName,
	p.Area,
	p.AreaType,
	p.Excess,
	p.TripDuration,
	case 
		when t.Age between 0 and 19 then '0 - 19'
		when t.Age between 20 and 29 then '20 - 29'
		when t.Age between 30 and 39 then '30 - 39'
		when t.Age between 40 and 49 then '40 - 49'
		when t.Age between 50 and 59 then '50 - 59'
		when t.Age between 60 and 69 then '60 - 69'
		when t.Age between 70 and 74 then '70 - 74'
		when t.Age between 75 and 79 then '75 - 79'
		when t.Age between 80 and 84 then '80 - 84'
		else '85+'
	end,
	case
		when isnull(t.MemberNumber, '') <> '' or isnull(ptp.PromoCodeCount, 0) > 0 then 1
		else 0
	end,
	p.TripType,
	p.MaxDuration,
	case 
		when isnull(t.AssessmentType, 'Not Applicable') = 'Not Applicable' then 'No EMC' 
		else 'EMC' 
	end,
	t.State

Union All

SELECT
	convert(datetime, qca.CurMonthStart) [Month Start],
	o.OutletName [Agency Name],
	q.ProductDisplayName [Product Name],
	q.Area [Area],
	case
		when q.CountryKey = 'AU' and q.Area = 'Australia' then 'Domestic'
		when q.CountryKey = 'CN' and q.Area = 'China' then 'Domestic'
		when q.CountryKey = 'MY' and q.Area = 'Domestic' then 'Domestic'
		when q.CountryKey = 'NZ' and q.Area = 'New Zealand Only' then 'Domestic'
		when q.CountryKey = 'NZ' and q.Area = 'New Zealand' then 'Domestic'
		when q.CountryKey = 'SG' and q.Area = 'Singapore' then 'Domestic'
		when q.CountryKey = 'UK' and q.Area = 'Domestic Dummy' then 'Domestic'
		else 'International'
	end [Area Type],
	q.Excess [Excess],
	q.Duration [Trip Duration],
	case 
		when qc.Age between 0 and 19 then '0 - 19'
		when qc.Age between 20 and 29 then '20 - 29'
		when qc.Age between 30 and 39 then '30 - 39'
		when qc.Age between 40 and 49 then '40 - 49'
		when qc.Age between 50 and 59 then '50 - 59'
		when qc.Age between 60 and 69 then '60 - 69'
		when qc.Age between 70 and 74 then '70 - 74'
		when qc.Age between 75 and 79 then '75 - 79'
		when qc.Age between 80 and 84 then '80 - 84'
		else '85+'
	end [Age Group],
	case
		when isnull(pc.MemberNumber, '') <> '' or isnull(promo.promoCount,0) > 0 then 1
		else 0
	end [Is Member],
	q.PlanType [Trip Type],
	q.MaxDuration [Max Duration],
	case
		when isnull(qc.HasEMC, 0) = 0 then 'No EMC'
		else 'EMC'
	end [EMC Group],
	pc.State [State],
	0 [Policy Count],
	0 [Sell Price],
	0 [Adults Count],
	count(distinct case when q.ParentQuoteID is null then q.QuoteKey else null end) [Quote Count],
	@rptStartDate [Start Date],
	@rptEndDate [End Date]
FROM
	penOutlet o 
	INNER JOIN penQuote q 
		ON (o.OutletAlphaKey=q.OutletAlphaKey)
	INNER JOIN penQuoteCustomer qc 
		ON (q.QuoteCountryKey=qc.QuoteCountryKey)
	INNER JOIN penCustomer pc 
		ON (qc.CustomerKey=pc.CustomerKey)
	INNER JOIN Calendar qca 
		ON (qca.Date=q.CreateDate)
	INNER JOIN vDateRange  vd 
		ON (qca.Date between vd.StartDate and vd.EndDate)
	outer apply
	(
		select	
			count(p.promocode) promoCount
		From
			penQuotePromo p
		where 
			p.QuoteCountryKey = q.QuoteCountryKey
			and 
			p.promocode = 'MEMPRO'
	) promo
WHERE
	vd.DateRange  =  @DateRange
	AND
	o.CountryKey  =  @Country
	AND
	o.SuperGroupName  =  'Medibank'
	AND
	qc.IsPrimary  =  1
	AND
	qca.Date  BETWEEN  @rptStartDate  AND  @rptEndDate
	AND
	o.GroupName  = @AgencyGroupName
	AND
	o.OutletStatus = 'Current'
GROUP BY
	qca.CurMonthStart,
	o.OutletName,
	q.ProductDisplayName,
	q.Area,
	case
		when q.CountryKey = 'AU' and q.Area = 'Australia' then 'Domestic'
		when q.CountryKey = 'CN' and q.Area = 'China' then 'Domestic'
		when q.CountryKey = 'MY' and q.Area = 'Domestic' then 'Domestic'
		when q.CountryKey = 'NZ' and q.Area = 'New Zealand Only' then 'Domestic'
		when q.CountryKey = 'NZ' and q.Area = 'New Zealand' then 'Domestic'
		when q.CountryKey = 'SG' and q.Area = 'Singapore' then 'Domestic'
		when q.CountryKey = 'UK' and q.Area = 'Domestic Dummy' then 'Domestic'
		else 'International'
	end,
	q.Excess,
	q.Duration,
	case 
		when qc.Age between 0 and 19 then '0 - 19'
		when qc.Age between 20 and 29 then '20 - 29'
		when qc.Age between 30 and 39 then '30 - 39'
		when qc.Age between 40 and 49 then '40 - 49'
		when qc.Age between 50 and 59 then '50 - 59'
		when qc.Age between 60 and 69 then '60 - 69'
		when qc.Age between 70 and 74 then '70 - 74'
		when qc.Age between 75 and 79 then '75 - 79'
		when qc.Age between 80 and 84 then '80 - 84'
		else '85+'
	end,
	case
		when isnull(pc.MemberNumber, '') <> '' or isnull(promo.promoCount,0) > 0 then 1
		else 0
	end,
	q.PlanType,
	q.MaxDuration,
	case
		when isnull(qc.HasEMC, 0) = 0 then 'No EMC'
		else 'EMC'
	end,
	pc.State

End
GO
