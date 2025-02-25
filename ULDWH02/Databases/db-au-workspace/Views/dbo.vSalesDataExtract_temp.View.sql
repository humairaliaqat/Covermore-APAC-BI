USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vSalesDataExtract_temp]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view 
	[dbo].[vSalesDataExtract_temp] 
--Changed to have latest alpha reference, SD - 06092018
--20191210, EV - Limit to data from 01/09/2018 
as
	select 
		t.BIRowID,
		t.TransactionStatus,
		t.TransactionType,
		t.Date,
		t.Fiscal_Year,
		t.CurFiscalYearStart,
		t.CurFiscalYearEnd,
		t.CurQuarterStart,
		t.CurQuarterEnd,
		t.CurMonthStart,
		t.CurMonthEnd,
		t.LastMonthStart,
		t.LastMonthEnd,
		t.LastFiscalYearStart,
		t.LYCurFiscalMonthStart,
		t.TotalBusinessDays,
		t.RemainingBusinessDays,
		o.CountryCode,
		o.SuperGroupName,
		o.GroupName,
		o.SubGroupName,
		o.AlphaCode,
		o.OutletName,
		o.LatestBDMName,
		o.FCArea,
		o.FCEGMNation,
		o.FCNation,
		t.Duration,
		t.ABSDurationBand,
		t.AreaName,
		t.AreaNumber,
		t.AreaType,
		t.Continent,
		t.Destination,
		t.Age,
		t.ABSAgeBand,
		t.ProductName,
		t.PolicyType,
		t.ProductClassification,
		t.PlanType,
		t.TripType,
		t.CancellationCover,
		t.ConsultantName,
		t.ConsultantType,
		t.FirstSellDate,
		t.ConsultantSK,
		t.Premium,
		t.SellPrice,
		t.Commission,
		t.PolicyCount,
		t.EMCPolicy,
		t.QuoteCount,
		t.QuoteSessionCount,
		t.TicketCount,
		t.InternationalTravellersCount,
		t.InternationalChargedAdultsCount,
		t.InternationalPolicyCount,
		t.DomesticPolicyCount,
		t.LeadTime,
		t.Excess,
		o.StateSalesArea
	from
		SalesDataExtract t with(nolock)
		outer apply
		(
			select top 1 
				ldo.Country CountryCode,
				ldo.SuperGroupName, 
				ldo.GroupName, 
				ldo.SubGroupName, 
				ldo.AlphaCode, 
				ldo.OutletName, 
				ldo.LatestBDMName, 
				ldo.FCArea, 
				ldo.FCEGMNation, 
				ldo.FCNation,
				ldo.StateSalesArea
			from
				--[db-au-star]..dimOutlet do with(nolock)
				--inner join 
				[db-au-star]..dimOutlet ldo with(nolock) 
				--on 					ldo.OutletSK = do.LatestOutletSK
			where
				ldo.Country = t.CountryCode and
				ldo.AlphaCode = t.AlphaCode and
				ldo.isLatest = 'Y'
		) o
	where
		Date >= '2017-01-01' --20191210, EV - Limit to data from 01/09/2018 
        --Date >= '2017-12-31' -- Was '2018-09-01'




GO
