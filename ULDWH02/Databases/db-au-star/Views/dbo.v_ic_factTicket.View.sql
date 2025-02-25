USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_factTicket]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[v_ic_factTicket] as
select --top 100 
    t.DateSK,
    case
        when ddd.[Date] < '2011-01-01' then '2011-01-01'
        when ddd.[Date] > convert(varchar(10), convert(varchar(4), year(getdate()) + 3) + '-12-31') then convert(varchar(10), convert(varchar(4), year(getdate()) + 3) + '-12-31')
        else ddd.[Date]
    end DepartureDateSK, 
    t.DomainSK, 
    t.OutletSK, 
    t.DestinationSK, 
    t.DurationSK, 
    t.OriginSK,
    t.TicketCount InternationalTicketCount,
    t.InternationalTravellersCount,
    t.DomesticTicketCount,
    t.DomesticTravellersCount,
    t.Source,
    t.Gross_Fare GrossFare,
    t.Net_Fare NetFare,
    r.OutletReference,
    case
        when lt.LeadTime < -1 then -1
        when lt.LeadTime > 2000 then -1
        else lt.LeadTime
    end LeadTime
from
    factTicket t with(nolock)
    outer apply
    (
        select top 1 
            [Date]
        from
            Dim_Date id
        where
            id.Date_SK = t.DateSK
    ) id
    outer apply
    (
        select top 1
            ddd.[Date]
        from
            Dim_Date ddd
        where
            ddd.Date_SK = t.DepartureDateSK
    ) ddd
    outer apply
    (
        select  
            isnull(datediff(day, id.[Date], ddd.[Date]), -1) LeadTime
    ) lt
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) r
where
    t.DateSK >= 20170101

GO
