USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1079]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt1079]
as
begin

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt1079
--  Author:         Yi Yang
--  Date Created:   20190815
--  Description:    This script is for RPT1079 - Medibank Sales Dashboard Report
--
--  Parameters:
--
--  Change History:	20190815 - YY - Created
--                  
/****************************************************************************************************/
if object_id('tempdb..#tmpMB') is not null
    drop table #tmpMB

if object_id('tempdb..#dates') is not null
        drop table #dates

select
    d.[Date],
    d.CurMonthStart
into 
	#dates
from
    [db-au-cmdwh].[dbo].[Calendar] d
where
   	d.[Date] >=convert(date, (convert(varchar, year(dateadd(day, -1, getdate())) - 2) + '07'+'01')) and 
    d.[Date] <= eomonth(dateadd(day, -1, getdate()))
    --d.[Date] >= '2019-01-01' and d.[Date] < '2019-02-01'

select 
	*
into 
	#tmpMB
from 
(
-------- Get Sales data -----------------------------------
SELECT
    convert(date, pt.PostingDate) as Date,
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.BDMName,
    p.Area [Area],

    case
        when p.TripDuration between 1 and 7 then 'Under 1 Week'
        when p.TripDuration between 8 and 14 then '1-2 Weeks'
        when p.TripDuration between 15 and 28 then '2-4 Weeks'
        when p.TripDuration between 29 and 60 then '1-2 Months'
        when p.TripDuration between 61 and 90 then '2-3 Months'
        when p.TripDuration between 91 and 180 then '3-6 Months'
        when p.TripDuration between 181 and 366 then '6-12 Months'
        when p.TripDuration >= 367 then 'Greater than 12 Months'
        else 'UNKNOWN'
    end [Trip Duration],
    case
        when t.Age between 0 and 16 then '0-16'
        when t.Age between 17 and 24 then '17-24'
        when t.Age between 25 and 34 then '25-34'
        when t.Age between 35 and 49 then '35-49'
        when t.Age between 50 and 59 then '50-59'
        when t.Age between 60 and 64 then '60-64'
        when t.Age between 65 and 69 then '65-69'
        when t.Age between 70 and 74 then '70-74'
        when t.Age >= 75 then '75+'
        else 'UNKNOWN'
    end [Age Group],
    p.PrimaryCountry as Destination,
    isnull(u.FirstName + ' ' + u.LastName, '') as [Consultant Name],
	pt.UserKey,
    p.Excess [Excess],
    case
        when isnull(t.MemberNumber, '') <> ''  then 1
        else 0
    end [Is Member],
	
    isnull(pt.StoreCode, '') as StoreCode,
    isnull(os.StoreName, '') as StoreName,
    isnull(pp.PromoCode, '') as PromoCode,
    sum(pt.BasePolicyCount) as PolicySold,
    sum(pt.GrossPremium) as Sales,
    sum(pt.TaxAmountGST) as TaxAmount,
    sum(pt.Commission) as Commission,
    0 QuoteCount
FROM
    penOutlet o
    inner join penPolicyTransSummary pt ON (pt.OutletAlphaKey = o.OutletAlphaKey and o.OutletStatus = 'Current')
    inner join penPolicy p on (p.PolicyKey = pt.PolicyKey)
    inner join penPolicyTraveller t on (p.PolicyKey=t.PolicyKey and t.isPrimary  =  1)
    left join penUser u on (pt.UserKey = u.UserKey and u.UserStatus = 'Current')
    outer apply
	(
		select top 1 
			PromoCode
		from
			penPolicyTransactionPromo pp 
		where (pt.PolicyTransactionKey=pp.PolicyTransactionKey and pp.isApplied = 1)
	) pp
    outer apply
        (select top 1
            StoreName
        from
            penOutletStore os
        where
            os.OutletAlphaKey = o.OutletAlphaKey
            and os.StoreCode = pt.StoreCode) os
WHERE
  (
   o.CountryKey  =  'AU'
    and
   convert(date, pt.PostingDate) in
        (
            select
                [Date]
            from
                #dates
        )
   AND
   o.SuperGroupName = 'Medibank'
  )


GROUP BY
	convert(date, pt.PostingDate),
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.BDMName,
    p.[Area],
    case
        when p.TripDuration between 1 and 7 then 'Under 1 Week'
        when p.TripDuration between 8 and 14 then '1-2 Weeks'
        when p.TripDuration between 15 and 28 then '2-4 Weeks'
        when p.TripDuration between 29 and 60 then '1-2 Months'
        when p.TripDuration between 61 and 90 then '2-3 Months'
        when p.TripDuration between 91 and 180 then '3-6 Months'
        when p.TripDuration between 181 and 366 then '6-12 Months'
        when p.TripDuration >= 367 then 'Greater than 12 Months'
        else 'UNKNOWN'
    end,
    case
        when t.Age between 0 and 16 then '0-16'
        when t.Age between 17 and 24 then '17-24'
        when t.Age between 25 and 34 then '25-34'
        when t.Age between 35 and 49 then '35-49'
        when t.Age between 50 and 59 then '50-59'
        when t.Age between 60 and 64 then '60-64'
        when t.Age between 65 and 69 then '65-69'
        when t.Age between 70 and 74 then '70-74'
        when t.Age >= 75 then '75+'
        else 'UNKNOWN'
    end,
    p.PrimaryCountry,
    isnull(u.FirstName + ' ' + u.LastName, ''),
	pt.UserKey,
    p.[Excess],
    case
        when isnull(t.MemberNumber, '') <> ''  then 1
        else 0
    end,
	
    isnull(pt.StoreCode, ''),
    isnull(os.StoreName, ''),
    isnull(pp.PromoCode, '')

union
-------- Quote Count -----------------------------------------
select
    convert(date, dd.date) as Date,
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.BDMName,
    da.AreaName [Area],
    du.ABSDurationBand [Trip Duration],
    dg.ABSAgeBand [Age Group],
    ds.Destination,
    u.FirstName + ' ' + u.LastName as [Consultant Name],
	'' userKey,
    '' [Excess],
    '' [Is Member],
    '' StoreCode,
    '' StoreName,
    '' PromoCode,
    0 PolicySold,
    0 Sales,
    0 TaxAmount,
    0 Commission,
    sum(
        (case
                when ir.OutletSK is not null then q.QuoteCount
                when cw.ConsultantSK is not null then q.QuoteSessionCount
                else q.QuoteCount
                end)) QuoteCount
from
    [db-au-star].dbo.factQuoteSummary q
    inner join [db-au-star].dbo.Dim_Date dd with(nolock) on
        dd.Date_SK = q.DateSK
    inner join [db-au-star].dbo.dimOutlet do with(nolock) on
        do.OutletSK = q.OutletSK
    inner join [db-au-star].dbo.dimConsultant dc with(nolock) on
        dc.ConsultantSK = q.ConsultantSK
    join penuser u on
        (u.OutletAlphaKey=do.OutletAlphaKey and u.Login=dc.UserName and u.UserStatus='Current')
    join penoutlet o on
        (o.OutletAlphaKey = u.OutletAlphaKey and o.OutletStatus = 'Current')
    join [db-au-star].dbo.DimArea da on
        da.AreaSK = q.AreaSK
    join [db-au-star].dbo.DimDestination ds on
        ds.DestinationSK = q.DestinationSK
    join [db-au-star].dbo.DimDuration du on
        du.DurationSK = q.DurationSK
    join [db-au-star].dbo.dimAgeBand dg on
        dg.AgeBandSK = q.AgeBandSK
    outer apply
        (select
                r.OutletSK
            from
                [db-au-star]..dimIntegratdOutlet r
            where
                r.OutletSK = q.OutletSK
            ) ir
    outer apply
        (select
                c.ConsultantSK
            from
                [db-au-star].dbo.dimConsultant c
            where
                c.ConsultantSK = q.ConsultantSK and
                c.ConsultantName like '%webuser%'
        ) cw

where
    o.SuperGroupName = 'Medibank'
    and
    convert(date, dd.date) in
        (
            select
                [Date]
            from
                #dates
        )
group by
    convert(date, dd.date),
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.BDMName,
    da.AreaName,
    du.ABSDurationBand,
    dg.ABSAgeBand,
    ds.Destination,
    u.FirstName + ' ' + u.LastName

union
------- Quote Count Bot --------------------
select
    convert(date, dd.date) as Date,
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.BDMName,
    da.AreaName [Area],
    du.ABSDurationBand [Trip Duration],
    dg.ABSAgeBand [Age Group],
    ds.Destination,
    u.FirstName + ' ' + u.LastName as [Consultant Name],
	'' userKey,
    '' [Excess],
    '' [Is Member],
    '' StoreCode,
    '' StoreName,
    '' PromoCode,
    0 PolicySold,
    0 Sales,
    0 TaxAmount,
    0 Commission,
    sum(
        (case
                when ir.OutletSK is not null then q.QuoteCount
                when cw.ConsultantSK is not null then q.QuoteSessionCount
                else q.QuoteCount
                end)) QuoteCount
from
    [db-au-star].dbo.factQuoteSummaryBot q
    inner join [db-au-star].dbo.Dim_Date dd with(nolock) on
        dd.Date_SK = q.DateSK
    inner join [db-au-star].dbo.dimOutlet do with(nolock) on
        do.OutletSK = q.OutletSK
    inner join [db-au-star].dbo.dimConsultant dc with(nolock) on
        dc.ConsultantSK = q.ConsultantSK
    join penuser u on
        (u.OutletAlphaKey=do.OutletAlphaKey and u.Login=dc.UserName and u.UserStatus='Current')
    join penoutlet o on
        (o.OutletAlphaKey = u.OutletAlphaKey and o.OutletStatus = 'Current')
    join [db-au-star].dbo.DimArea da on
        da.AreaSK = q.AreaSK
    join [db-au-star].dbo.DimDestination ds on
        ds.DestinationSK = q.DestinationSK
    join [db-au-star].dbo.DimDuration du on
        du.DurationSK = q.DurationSK
    join [db-au-star].dbo.dimAgeBand dg on
        dg.AgeBandSK = q.AgeBandSK
    outer apply
        (select
                r.OutletSK
            from
                [db-au-star]..dimIntegratdOutlet r
            where
                r.OutletSK = q.OutletSK
            ) ir
    outer apply
        (select
                c.ConsultantSK
            from
                [db-au-star].dbo.dimConsultant c
            where
                c.ConsultantSK = q.ConsultantSK and
                c.ConsultantName like '%webuser%'
        ) cw

where
    o.SuperGroupName = 'Medibank'
    and
    convert(date, dd.date) in
        (
            select
                [Date]
            from
                #dates
        )
group by
    convert(date, dd.date),
    o.GroupName,
    o.SubGroupName,
    o.AlphaCode,
    o.OutletName,
    o.BDMName,
    da.AreaName,
    du.ABSDurationBand,
    dg.ABSAgeBand,
    ds.Destination,
    u.FirstName + ' ' + u.LastName
) tmp

---- Get Day of Month and populate output columns
select 
	convert(date, convert(varchar(7), d.date, 120) + '-01') MonthStart,
	day(d.date) as DayOfMonth,
	m.* 
from 
	#dates d 
	left join #tmpMB m on (d.Date = m.Date)

end
GO
