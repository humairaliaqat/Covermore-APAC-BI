USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0005]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0005]	@Country varchar(3)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0005
--  Author:         Linus Tor
--  Date Created:   20180403
--  Description:    This stored procedure returns B2B outlets and respective Salesforce call comments
--  Parameters:     @Country: Country code
--   
--  Change History: 20180403 - LT - Created
--					20180410 - LT - Changed call comments to read from sfAgencyCall table instead of penCRMCallComments. It seems Penguin is not loading Salesforce call comments, and
--									it's just too hard to get IT to fix anything these days.
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
select @Country = 'AU'
*/

declare @rptStartDate datetime
declare @rptEndDate datetime

select
	@rptStartDate = StartDate,
	@rptEndDate = EndDate
from
	vDateRange
where
	DateRange = 'Fiscal Year-To-Date'


select
	o.GroupName,
	o.SubGroupName,
	o.AlphaCode,
	o.TradingStatus,
	o.OutletName,
	o.Branch,
	o.ContactStreet,
	o.ContactSuburb,
	o.ContactState,
	o.ContactPostCode,
	o.ContactPhone,
	o.ContactEmail,
	o.BDMCallFrequency,
	o.AcctMgrCallFrequency,
	o.BDMName,
	o.AcctManagerName,
	o.SalesTier,
	o.SalesSegment,
	o.PotentialSales,
	o.OutletType,
	o.ContactTitle,
	o.ContactFirstName,
	o.ContactLastName,
	sfa.Quadrant,
	sfa.QuadrantPotential,
	sfa.SalesQuadrant,
	am.LastAMCall,
	am.LastAMCallDate,
	am.LastAMRemarks,
	sc.LastSalesCall,
	sc.LastSalesCallDate,
	sc.LastSalesRemarks,
	pts.FYTDSellPrice,
	pts.FYTDPolicyCount
from
	penOutlet o
	outer apply
	(
		select
			sum(GrossPremium) as FYTDSellPrice,
			sum(BasePolicyCount) as FYTDPolicyCount
		from
			penPolicyTransSummary
		where
			OutletAlphaKey = o.OutletAlphaKey and
			PostingDate >= @rptStartDate and
			PostingDate < dateadd(d,-1,@rptEndDate)
	) pts
    outer apply
    (
		select top 1
			c.CallID as LastAMCall, 
			c.CallStartTime as LastAMCallDate,
			left(convert(varchar(8000),c.CallComment),8000) as LastAMRemarks			
		from 
			sfAgencyCall c
			inner join sfAccount a on c.AccountID = a.AccountID
		where
			a.DomainCode = o.CountryKey and
			a.AlphaCode = o.AlphaCode and
			c.CallCategory in ('AcctMgr Phone Call', 'Sales Phone Call', 'Activity - Sales Phone Call')
		order by c.CallStartTime desc
    ) am
    outer apply
    (
		select top 1
			c.CallID as LastSalesCall, 
			c.CallStartTime as LastSalesCallDate,
			left(convert(varchar(8000),c.CallComment),8000) as LastSalesRemarks			
		from 
			sfAgencyCall c
			inner join sfAccount a on c.AccountID = a.AccountID
		where
			a.DomainCode = o.CountryKey and
			a.AlphaCode = o.AlphaCode
		order by c.CallStartTime desc
    ) sc
	outer apply
	(
		select top 1
			sf.QuadrantPotential,
			sf.SalesQuadrant,
			sf.Quadrant
		From
			sfAccount sf
		where
			sf.DomainCode = o.CountryKey and
			sf.AlphaCode = o.AlphaCode
		order by
			sf.LastModifiedDate Desc
	) sfa
where
	o.CountryKey = @Country and
	o.CompanyKey = 'CM' and												--exclude TIP outlets
	o.OutletType = 'B2B' and											--include retail outlets only
	o.TradingStatus in ('Stocked','Prospect','Stocks Withdrawn') and
	(isnumeric(substring(o.OutletKey,8,7)) = 1  ) and					--include Penuin Outlets only
	o.OutletStatus = 'Current' and
	o.AlphaCode not in													--exclude test or training alphas
	(
		select AlphaCode
		from penOutlet o
		where
			o.CountryKey = 'AU' and
			o.OutletStatus = 'Current' and
			(
				o.OutletName like '%test %' or
				o.OutletName like '% Test%' or
				o.OutletName like '%tester%' or
				o.OutletName = 'test' or
				o.OutletName like '%test%' or
				o.OutletName like '%training%' or
				o.AlphaCode = 'zzzz999'
			)
	)
GO
