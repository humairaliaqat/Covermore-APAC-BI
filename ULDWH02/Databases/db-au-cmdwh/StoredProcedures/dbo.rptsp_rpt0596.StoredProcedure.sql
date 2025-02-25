USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0596]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0596]  @DateRange varchar(30)
as

SET NOCOUNT ON



/****************************************************************************************************/
--  Name             :    rptsp_rpt0596
--  Description      :    for RPT0596 - Flight Centre Kicker
--  Author           :    Linus Tor
--  Date Created     :    20150717
--  Description      :    This view captures flight centre policy and quote sales and apply kicker incentives
--                        as defined by kicker definitions
--  Parameters       :    @DateRange: one of Month-To-Date or Last Month
--  Change History   :    20150717 - LT - Created
--                        20150825 - LT - removed area code filtering
--                        20160713 - GP - 1) added CMBCount and CMBSellPrice in OptionsMixPolicy and OptionsMixSales respectively (Task 25848)
--                        20160713 - GP - 2) additional columns - STYCount & STYSellPrice and FPGCount & FPGSellPrice and FPPCount & FPPSellPrice (Task 25848)
--                        20160901 - LT - Added Cruiseabout product
--                        20170208 - RL - correct calculation of @rptEndDateLY
--						  20170703 - LL - date range
--						  20170816 - SD - Added nations 'SA' and 'WANT' in filter condition along with other nations
--						  20171108 - RL - 4 columns were added: FYECount, FYESellPrice, FYPCount, FYPSellPrice
--						  20171113 - RL - 2 columns were added: Your Cover Mix ($), Your Cover Mix (#)
--						  20180327 - SD - Incorporated Latest outlet lineage
--						  20180424 - ME - Added T3Code Column to Report	
/****************************************************************************************************/


--uncomment to debug

/*
declare @DateRange varchar(30)
select @DateRange = 'Month-To-Date'
*/


declare @rptStartDate datetime
declare @rptEndDate datetime
declare @rptStartDateLY datetime
declare @rptEndDateLY datetime

--if @DateRange in ('Month-To-Date')
--begin
--       select
--              @rptStartDate = StartDate,
--              @rptEndDate = EndDate
--              from
--                     dbo.vDateRange
--              where
--                     DateRange = 'Month-To-Date'

--       select
--              @rptStartDateLY = dateadd(year,-1,@rptStartDate),
--              @rptEndDateLY = EOMONTH(dateadd(year,-1,convert(datetime,convert(varchar(8),@rptStartDate,120)+'01')))
--end
--else if @DateRange in ('Last Month','Last Fiscal Month')
--begin
--       select
--              @rptStartDate = StartDate,
--              @rptEndDate = EndDate
--              from
--                     dbo.vDateRange
--              where
--                     DateRange = 'Last Fiscal Month'

--       select
--              @rptStartDateLY = dateadd(year,-1,@rptStartDate),
--              @rptEndDateLY = EOMONTH(dateadd(year,-1,convert(datetime,convert(varchar(8),@rptStartDate,120)+'01')))
--end


select
    @rptStartDate = StartDate,
    @rptEndDate = EndDate
from
    dbo.vDateRange
where
    DateRange = @DateRange

select
    @rptStartDateLY = dateadd(year,-1,@rptStartDate),
    @rptEndDateLY = EOMONTH(dateadd(year,-1,convert(datetime,convert(varchar(8),@rptStartDate,120)+'01')))


if object_id('tempdb..#Outlet') is not null drop table #Outlet
select distinct
	o.OutletAlphaKey,
	lo.AlphaCode, 
	lo.ExtID,
	lo.OutletName,
	lo.FCNation [Nation],
	lo.FCArea [Area],
	lo.FCAreaCode [AreaCode],
	case 
		when datediff(month,lo.CommencementDate,@rptEndDate) <= 6 then '1-6months'
        when datediff(month,lo.CommencementDate,@rptEndDate) between 7 and 12 then '7-12mths'
        else '>12mths'
	end [TradingAge],
	lo.StateSalesArea [State],
	lo.OutletType [SalesChannel],
	lo.BDMName	
into #Outlet	
from 
	penOutlet o
	outer apply
	(
		select top 1 
			SuperGroupName,		
			GroupName,
			GroupCode,
			SubGroupCode,
			SubGroupName,
			AlphaCode,
			OutletName,
			OutletType,
			ContactState,
			Branch,
			BDMName,
			SalesSegment,
			TradingStatus,
			EGMNation,
			FCNation,
			FCArea,
			FCAreaCode,
			CommencementDate,
			StateSalesArea,
			ExtID			
		from penOutlet
		where 
			OutletKey = o.LatestOutletKey and
			OutletStatus = 'Current'
	) lo
where 
	o.CountryKey = 'AU' and
	lo.GroupCode  =  'FL' and
    lo.FCNation in ('NSW/ACT','7th Wonder','Heartland','North Star','SANT','Southern Revolution','VIC Mania','WA','Student Flights','Escape Travel','Cruiseabout','Travel Associates', 'SA', 'WANT') and
    lo.TradingStatus = 'Stocked'


--get current year sales
if object_id('tempdb..#cyp') is not null drop table #cyp
select
       pts.OutletAlphaKey,
       sum(pts.GrossPremium) as SellPrice,
       sum(pts.NewPolicyCount) as PolicyCount,
       sum(case when p.ProductCode = 'FCO' then pts.BasePolicyCount else 0 end) as FCOCount,
       sum(case when p.ProductCode = 'FCO' then pts.GrossPremium else 0 end) as FCOSellPrice,
       sum(case when p.ProductCode = 'FCT' then pts.BasePolicyCount else 0 end) as FCTCount,
       sum(case when p.ProductCode = 'FCT' then pts.GrossPremium else 0 end) as FCTSellPrice,

       sum(case when p.ProductCode = 'FYE' then pts.BasePolicyCount else 0 end) as FYECount,
       sum(case when p.ProductCode = 'FYE' then pts.GrossPremium else 0 end) as FYESellPrice,
       sum(case when p.ProductCode = 'FYP' then pts.BasePolicyCount else 0 end) as FYPCount,
       sum(case when p.ProductCode = 'FYP' then pts.GrossPremium else 0 end) as FYPSellPrice,

       sum(case when p.ProductCode = 'CMB' then pts.BasePolicyCount else 0 end) as CMBCount,
       sum(case when p.ProductCode = 'CMB' then pts.GrossPremium else 0 end) as CMBSellPrice,

       sum(case when p.ProductCode = 'STY' then pts.BasePolicyCount else 0 end) as STYCount,
       sum(case when p.ProductCode = 'STY' then pts.GrossPremium else 0 end) as STYSellPrice,

       sum(case when p.ProductCode = 'FPG' then pts.BasePolicyCount else 0 end) as FPGCount,
       sum(case when p.ProductCode = 'FPG' then pts.GrossPremium else 0 end) as FPGSellPrice,

       sum(case when p.ProductCode = 'FPP' then pts.BasePolicyCount else 0 end) as FPPCount,
       sum(case when p.ProductCode = 'FPP' then pts.GrossPremium else 0 end) as FPPSellPrice,

       sum(case when p.ProductCode = 'FCC' then pts.BasePolicyCount else 0 end) as FCCCount,
       sum(case when p.ProductCode = 'FCC' then pts.GrossPremium else 0 end) as FCCSellPrice
into #cyp
from
       [db-au-cmdwh].dbo.penPolicy p
       join [db-au-cmdwh].dbo.penPolicyTransSummary pts on p.PolicyKey = pts.PolicyKey
       join #Outlet o on
              p.OutletAlphaKey = o.OutletAlphaKey
where
       pts.PostingDate between @rptStartDate and @rptEndDate
group by
       pts.OutletAlphaKey


--get converted consultant count
if object_id('tempdb..#cyc') is not null drop table #cyc
select
       pts.OutletAlphaKey,
       count(distinct case when pts.TransactionType = 'Base' and pts.TransactionStatus = 'Active' and u.ConsultantType = 'External' then pts.UserKey else null end) as ConsultantCount
into #cyc
from
       [db-au-cmdwh].dbo.penPolicyTransSummary pts
       join [db-au-cmdwh].dbo.penUser u on pts.UserKey = u.UserKey and u.UserStatus = 'Current'
where
       pts.OutletAlphaKey in (select distinct OutletAlphaKey from #Outlet) and
       pts.PostingDate between @rptStartDate and @rptEndDate
group by
       pts.OutletAlphaKey


--get full month last year sales
if object_id('tempdb..#pyp') is not null drop table #pyp
select
       pts.OutletAlphaKey,
       sum(pts.GrossPremium) as SellPrice
into #pyp
from
       [db-au-cmdwh].dbo.penPolicyTransSummary pts
where
       pts.OutletAlphaKey in (select distinct OutletAlphaKey from #Outlet) and
       pts.PostingDate between @rptStartDateLY and @rptEndDateLY
group by
       pts.OutletAlphaKey


if object_id('tempdb..#main') is not null drop table #main
select
  case when o.Nation in ('NSW/ACT','7th Wonder','Heartland','North Star','SANT','Southern Revolution','VIC Mania','WA', 'SA', 'WANT') then 'Red & White'
          when o.Nation = 'Student Flights' then 'Student Flights'
          when o.Nation = 'Escape Travel' then 'Escape Travel'
          when o.Nation = 'Cruiseabout' then 'Cruiseabout'
          when o.Nation = 'Travel Associates' then 'Travel Associates'
          else 'Unknown'
  end as FlightCentreGroup,
  o.Nation,
  o.Area,
  o.AlphaCode,
  o.ExtID,
  o.OutletName,
  o.[State],
  o.TradingAge,
  o.SalesChannel,
  o.BDMName,
  cyp.SellPrice,
  cyp.PolicyCount,
  cyc.ConsultantCount,
  cyp.FCOCount,
  cyp.FCOSellPrice,
  cyp.FCTCount,
  cyp.FCTSellPrice,

  cyp.FYECount,
  cyp.FYESellPrice,
  cyp.FYPCount,
  cyp.FYPSellPrice,

  cyp.CMBCount,
  cyp.CMBSellPrice,
  cyp.STYCount,
  cyp.STYSellPrice,
  cyp.FPGCount,
  cyp.FPGSellPrice,
  cyp.FPPCount,
  cyp.FCCCount,
  cyp.FCCSellPrice,
  cyp.FPPSellPrice,
  case when cyc.ConsultantCount <> 0 then cyp.PolicyCount / cyc.ConsultantCount else 0 end as PolicyPerCons,
  case when cyc.ConsultantCount <> 0 then cyp.SellPrice / cyc.ConsultantCount else 0 end as SellPricePerCons,
  case when (convert(float,cyp.FCOCount) + convert(float,cyp.FCTCount) + convert(float,cyp.CMBCount)) <> 0
        then convert(float,cyp.FCOCount) / (convert(float,cyp.FCOCount) + convert(float,cyp.FCTCount) + convert(float,cyp.CMBCount)) else 0
    end as OptionsMixPolicy,
  case when (convert(float,cyp.FCOSellPrice) + convert(float,cyp.FCTSellPrice) + convert(float,cyp.CMBSellPrice)) <> 0
        then convert(float,cyp.FCOSellPrice) / (convert(float,cyp.FCOSellPrice) + convert(float,cyp.FCTSellPrice) + convert(float,cyp.CMBSellPrice)) else 0
    end as OptionsMixSales,
  case when (convert(float,cyp.FYPCount) + convert(float,cyp.FYECount) + convert(float,cyp.CMBCount)) <> 0
        then convert(float,cyp.FYPCount) / (convert(float,cyp.FYPCount) + convert(float,cyp.FYECount) + convert(float,cyp.CMBCount)) else 0
    end as YourCoverMixPolicy,
  case when (convert(float,cyp.FYPSellPrice) + convert(float,cyp.FYESellPrice) + convert(float,cyp.CMBSellPrice)) <> 0
        then convert(float,cyp.FYPSellPrice) / (convert(float,cyp.FYPSellPrice) + convert(float,cyp.FYESellPrice) + convert(float,cyp.CMBSellPrice)) else 0
    end as YourCoverMixSales,
  pyp.SellPrice as SellPriceLY,
  pyp.SellPrice * 1.05 as SellPriceLY05,
  pyp.SellPrice * 1.1 as SellPriceLY10,
  pyp.SellPrice * 1.15 as SellPriceLY15
into #main
from
       #outlet o
       outer apply
       (
              select
                     sum(p.SellPrice) as SellPrice,
                     sum(p.PolicyCount) as PolicyCount,
                     sum(p.FCOCount) as FCOCount,
                     sum(p.FCOSellPrice) as FCOSellPrice,
                     sum(p.FCTCount) as FCTCount,
                     sum(p.FCTSellPrice) as FCTSellPrice,
                     sum(p.FYECount) as FYECount,
                     sum(p.FYESellPrice) as FYESellPrice,
                     sum(p.FYPCount) as FYPCount,
                     sum(p.FYPSellPrice) as FYPSellPrice,
                     sum(p.CMBCount) as CMBCount,
                     sum(p.CMBSellPrice) as CMBSellPrice,
                     sum(p.STYCount) as STYCount,
                     sum(p.STYSellPrice) as STYSellPrice,
                     sum(p.FPGCount) as FPGCount,
                     sum(p.FPGSellPrice) as FPGSellPrice,
                     sum(p.FPPCount) as FPPCount,
                     sum(p.FPPSellPrice) as FPPSellPrice,
                     sum(p.FCCCount) as FCCCount,
                     sum(p.FCCSellPrice) as FCCSellPrice
              from
                     #cyp p
              where
                     p.OutletAlphaKey = o.OutletAlphaKey
       ) cyp
       outer apply
       (
              select sum(ConsultantCount) as ConsultantCount
              from #cyc
              where OutletAlphaKey = o.OutletAlphaKey
       ) cyc
       outer apply
       (
              select sum(SellPrice) as SellPrice
              from #pyp
              where OutletAlphaKey = o.OutletAlphaKey
       ) pyp
order by
  o.Nation,
  o.Area,
  o.AlphaCode,
  o.ExtID,
  o.OutletName,
  o.[State],
  o.TradingAge,
  o.SalesChannel,
  o.BDMName


select
  m.FlightCentreGroup,
  m.Nation,
  m.Area,
  m.AlphaCode,
  m.ExtID AS T3Code,
  m.OutletName,
  m.[State],
  m.TradingAge,
  m.SalesChannel,
  m.BDMName,
  m.SellPriceLY,
  m.SellPrice,
  m.PolicyCount,
  m.ConsultantCount,
  m.FCOCount + m.CMBCount as FCOCount,
  m.FCOSellPrice + m.CMBSellPrice as FCOSellPrice,
  m.FCTCount,
  m.FCTSellPrice,
  m.FYECount,
  m.FYESellPrice,
  m.FYPCount,
  m.FYPSellPrice,
  m.CMBCount,
  m.CMBSellPrice,
  m.STYCount,
  m.STYSellPrice,
  m.FPGCount,
  m.FPGSellPrice,
  m.FPPCount,
  m.FPPSellPrice,
  m.FCCCount,
  m.FCCSellPrice,
  m.PolicyPerCons,
  m.SellPricePerCons,
  m.OptionsMixPolicy,
  m.OptionsMixSales,
  m.YourCoverMixPolicy,
  m.YourCoverMixSales,
  m.SellPriceLY05,
  m.SellPriceLY10,
  m.SellPriceLY15,
  @rptStartDate as StartDate,
  @rptEndDate as EndDate,
  @rptStartDateLY as StartDateLY,
  @rptEndDateLY as EndDateLY,


  --kicker calculations
  --Red & White: 10% up to LY gross sales.
  --                 15% of growth in gross sales.
  --                 Conditional on 80% options achieved. 80% options based on Heartland (Policy), NSW (Sales), Vicmania (Sales),
  --                 SANT (Sales), WA (Policy), 7th Wonder (Sales)

  case when (
                           m.FlightCentreGroup = 'Red & White' and
                           m.Nation in ('Heartland','WA', 'WANT') and
                           m.OptionsMixPolicy >= 0.8 and
                           m.SellPrice >= m.SellPriceLY10
                     )     then m.SellPriceLY * 0.1
              when (
                           m.FlightCentreGroup = 'Red & White' and
                           m.Nation not in ('Heartland','WA', 'WANT') and
                           m.OptionsMixSales >= 0.8 and
                           m.SellPrice >= m.SellPriceLY10
                     )     then m.SellPriceLY * 0.1
              else 0
  end as RedWhiteTier1,
  case when (
                           m.FlightCentreGroup = 'Red & White' and
                           m.Nation in ('Heartland','WA', 'WANT') and
                           m.OptionsMixPolicy >= 0.8 and
                           m.SellPrice >= m.SellPriceLY15
                      )     then (m.SellPrice - m.SellPriceLY) * 0.15
              when (
                           m.FlightCentreGroup = 'Red & White' and
                           m.Nation not in ('Heartland','WA', 'WANT') and
                           m.OptionsMixSales >= 0.8 and
                           m.SellPrice >= m.SellPriceLY15
                     )  then (m.SellPrice - m.SellPriceLY) * 0.15
              else 0
  end as RedWhiteTier2,

  --Student Flights
  --Tier1:    5% kicker for 5% growth
  --Tier2:    10% kicker for 10% growth
  --          OR
  --          15% kicker for $4000 gross per cons

  --new stores
  --Tier1:    10% kicker for ???
  --Tier2:    15% kicker for $4000 gross per cons

  case when (
                           m.FlightCentreGroup = 'Student Flights' and
                           m.TradingAge = '>12mths' and
                           m.SellPrice >= m.SellPriceLY05
                     )     then m.SellPrice * 0.05
              else 0
  end as StudentFlightsTier1,
  case when (
                           m.FlightCentreGroup = 'Student Flights' and
                           m.TradingAge = '>12mths' and
                           m.SellPricePerCons >= 4000
                     )  then m.SellPrice * 0.15
              when (
                           m.FlightCentreGroup = 'Student Flights' and
                           m.TradingAge = '>12mths' and
                           m.SellPrice >= m.SellPriceLY10
                     )     then m.SellPrice * 0.1
              else 0
  end as StudentFlightsTier2,

  --Escape Travel
  --Tier1: 10% kicker for (10% growth OR $3800 gross per cons)
  --Tier2: 5% kicker for achieving 75% options ($)

  --New stores:
  --Tier1:
  --Tier2:

  case when (
                           m.FlightCentreGroup = 'Escape Travel' and
                           m.TradingAge = '>12mths' and
                           (m.SellPrice >= m.SellPriceLY10 or m.SellPricePerCons >= 3800)
                     )     then m.SellPrice * 0.1
              else 0
  end as EscapeTravelTier1,
  case when (
                           m.FlightCentreGroup = 'Escape Travel' and
                           m.TradingAge = '>12mths' and
                           m.OptionsMixSales >= 0.75
                     )     then m.SellPrice * 0.05
              else 0
  end as EscapeTravelTier2,

  --Cruiseabout
  --Tier1: 5% kicker for 5% growth
  --Tier2: 10% kicker for (10% growth or $3000 gross per cons)
  --Tier3: 5% kicker for achieving 75% options (#)

  --New stores 1-6 months:
  --Tier1: 5% kicker for $1000 gross sales per cons
  --Tier2: 10% kicker for $2000 gross sales per cons
  --Tier3: 5% kicker for achieving 75% options (#)

  --New stores: 7-12:
  --Tier1: 5% kicker for $1500 gross sales per cons
  --Tier2: 10% kicker for $2500 gross sales per cons
  --Tier3: 5% kicker for achieving 75% options (#)

  case when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '>12mths' and
                           m.SellPrice >= m.SellPriceLY05
                     )     then m.SellPrice * 0.05
              when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '1-6months' and
                           m.SellPricePerCons >= 1000
                     )     then m.SellPrice * 0.05
              when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '7-12mths' and
                           m.SellPricePerCons >= 1500
                     )     then m.SellPrice * 0.05
              else 0
  end as CruiseaboutTier1,
  case when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '>12mths' and
                           (m.SellPrice >= m.SellPriceLY10 or m.SellPricePerCons >= 3000)
                     )     then m.SellPrice * 0.1
              when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '1-6months' and
                           m.SellPricePerCons >= 2000
                     )     then m.SellPrice * 0.1
              when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '7-12mths' and
                           m.SellPricePerCons >= 2500
                     )     then m.SellPrice * 0.1
              else 0
  end as CruiseaboutTier2,
  case when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '>12mths' and
                           m.OptionsMixPolicy >= 0.75
                     )     then m.SellPrice * 0.05
              when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '1-6months' and
                           m.OptionsMixPolicy >= 0.75
                     )     then m.SellPrice * 0.05
              when (
                           m.FlightCentreGroup = 'Cruiseabout' and
                           m.TradingAge = '7-12mths' and
                           m.OptionsMixPolicy >= 0.75
                     )     then m.SellPrice * 0.05
              else 0
  end as CruiseaboutTier3,

  --Travel Associates
  --Tier1: 5% kicker on gross sales

  0.000000 as TravelAssociatesTier1
from
       #main m
order by
       m.Nation,
       m.Area,
       m.AlphaCode,
	   m.ExtID


--drop temp tables
drop table #Outlet
drop table #cyp
drop table #pyp
drop table #cyc
drop table #main
GO
