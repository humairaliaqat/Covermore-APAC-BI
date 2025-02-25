USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vFCUSASales]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vFCUSASales] as
with 
cte_py as
(
    select --top 1
        lo.AlphaCode [Alpha Code],
        lo.OutletName [Store],
        lo.SubGroupName [Brand],
        lo.EGMNation [EGM],
        lo.FCNation [FC Nation],
        lo.FCArea [FC Area],
        lo.BDMName [BDM],
        lo.StateSalesArea [Sales Area],
        convert(date, py.[Policy Sale Date]) [Issue Date],
        py.[Agent Initials] [Consultant],
        py.[Product Name],
        py.[Product Plan Name] [Plan Name],
        py.City [Customer City],
        py.State [Customer State],
        py.[Destination],
        py.[Departure Date],
        datediff(day, py.[Departure Date], py.[Return Date]) + 1 [Duration],
        datediff(day, py.[Policy Sale Date], py.[Departure Date]) [Lead Time],
        case
            when py.[Trip Cost] <= 1000 then '$1 - $1,000'
            when py.[Trip Cost] <= 2000 then '$1,001 - $2,000'
            when py.[Trip Cost] <= 3000 then '$2,001 - $3,000'
            when py.[Trip Cost] <= 4000 then '$3,001 - $4,000'
            when py.[Trip Cost] <= 5000 then '$4,001 - $5,000'
            when py.[Trip Cost] <= 6000 then '$5,001 - $6,000'
            when py.[Trip Cost] <= 7000 then '$6,001 - $7,000'
            when py.[Trip Cost] <= 8000 then '$7,001 - $8,000'
            when py.[Trip Cost] <= 9000 then '$8,001 - $9,000'
            when py.[Trip Cost] <= 10000 then '$9,001 - $10,000'
            when py.[Trip Cost] <= 15000 then '$10,001 - $15,000'
            when py.[Trip Cost] <= 20000 then '$15,001 - $20,000'
            when py.[Trip Cost] <= 25000 then '$20,001 - $25,000'
            when py.[Trip Cost] <= 30000 then '$25,001 - $30,000'
            when py.[Trip Cost] <= 50000 then '$30,001 - $50,000'
            else '$50,001+'
        end [Trip Cost],
        sum(
            case
                when py.[Status] = 'Purchase' then 1
                when py.[Status] = 'Cancel' then -1
                else 0
            end
        ) [Policy Count],
        sum(py.[Number of Insureds]) [Traveller Count],
        sum(py.[Gross Premium]) [Sell Price]
    from
        [db-au-cmdwh]..usrFCUSAPolicyFY16 py
        inner join [db-au-cmdwh]..penOutlet o with(nolock) on
            o.OutletAlphaKey = py.OutletAlphaKey and
            o.OutletStatus = 'Current'
        inner join [db-au-cmdwh]..penOutlet lo with(nolock) on
            lo.OutletKey = o.LatestOutletKey and
            lo.OutletStatus = 'Current'
    group by
        lo.AlphaCode,
        lo.OutletName,
        lo.SubGroupName,
        lo.EGMNation,
        lo.FCNation,
        lo.FCArea,
        lo.BDMName,
        lo.StateSalesArea,
        py.[Policy Sale Date],
        py.[Agent Initials],
        py.[Product Name],
        py.[Product Plan Name],
        py.City,
        py.State,
        py.Destination,
        py.[Departure Date],
        datediff(day, py.[Departure Date], py.[Return Date]) + 1,
        datediff(day, py.[Policy Sale Date], py.[Departure Date]),
        case
            when py.[Trip Cost] <= 1000 then '$1 - $1,000'
            when py.[Trip Cost] <= 2000 then '$1,001 - $2,000'
            when py.[Trip Cost] <= 3000 then '$2,001 - $3,000'
            when py.[Trip Cost] <= 4000 then '$3,001 - $4,000'
            when py.[Trip Cost] <= 5000 then '$4,001 - $5,000'
            when py.[Trip Cost] <= 6000 then '$5,001 - $6,000'
            when py.[Trip Cost] <= 7000 then '$6,001 - $7,000'
            when py.[Trip Cost] <= 8000 then '$7,001 - $8,000'
            when py.[Trip Cost] <= 9000 then '$8,001 - $9,000'
            when py.[Trip Cost] <= 10000 then '$9,001 - $10,000'
            when py.[Trip Cost] <= 15000 then '$10,001 - $15,000'
            when py.[Trip Cost] <= 20000 then '$15,001 - $20,000'
            when py.[Trip Cost] <= 25000 then '$20,001 - $25,000'
            when py.[Trip Cost] <= 30000 then '$25,001 - $30,000'
            when py.[Trip Cost] <= 50000 then '$30,001 - $50,000'
            else '$50,001+'
        end 
),
cte_cy as
(
    select --top 1000 
        lo.AlphaCode [Alpha Code],
        lo.OutletName [Store],
        lo.SubGroupName [Brand],
        lo.EGMNation [EGM],
        lo.FCNation [FC Nation],
        lo.FCArea [FC Area],
        lo.BDMName [BDM],
        lo.StateSalesArea [Sales Area],
        convert(date, [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(pt.TransactionDateTime, 'Eastern Standard Time')) [Issue Date],
        u.FirstName + ' ' + u.LastName collate database_default [Consultant],
        pp.ProductDisplayName  collate database_default [Product Name],
        pd.PlanName collate database_default [Plan Name],
        ptv.Suburb collate database_default [Customer City],
        ptv.State collate database_default [Customer State],
        p.PrimaryCountry collate database_default [Destination],
        convert(date, [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(p.TripStart, 'Eastern Standard Time')) [Departure Date],
        pd.TripDuration [Duration],
        datediff(day, pt.TransactionDateTime, p.TripStart) [Lead Time],
        case
            when ptv.TripCost <= 1000 then '$1 - $1,000'
            when ptv.TripCost <= 2000 then '$1,001 - $2,000'
            when ptv.TripCost <= 3000 then '$2,001 - $3,000'
            when ptv.TripCost <= 4000 then '$3,001 - $4,000'
            when ptv.TripCost <= 5000 then '$4,001 - $5,000'
            when ptv.TripCost <= 6000 then '$5,001 - $6,000'
            when ptv.TripCost <= 7000 then '$6,001 - $7,000'
            when ptv.TripCost <= 8000 then '$7,001 - $8,000'
            when ptv.TripCost <= 9000 then '$8,001 - $9,000'
            when ptv.TripCost <= 10000 then '$9,001 - $10,000'
            when ptv.TripCost <= 15000 then '$10,001 - $15,000'
            when ptv.TripCost <= 20000 then '$15,001 - $20,000'
            when ptv.TripCost <= 25000 then '$20,001 - $25,000'
            when ptv.TripCost <= 30000 then '$25,001 - $30,000'
            when ptv.TripCost <= 50000 then '$30,001 - $50,000'
            else '$50,001+'
        end [Trip Cost],
        sum(
            case
                when pt.TransactionType = 1 and pt.TransactionStatus = 1 then 1
                when pt.TransactionType = 1 and pt.TransactionStatus <> 1 then -1
                else 0
            end
        ) [Policy Count],
        sum(
            case
                when pt.TransactionType = 1 and pt.TransactionStatus = 1 then TravellerCount
                when pt.TransactionType = 1 and pt.TransactionStatus <> 1 then -TravellerCount
                else 0
            end
        ) [Traveller Count],
        sum(pt.GrossPremium) [Sell Price]
    from
        bhdwh02.[US_PenguinSharp_Active].dbo.tblPolicy p with(nolock)
        inner join bhdwh02.[US_PenguinSharp_Active].dbo.tblOutlet o with(nolock) on
            o.DomainID = p.DomainID and
            o.AlphaCode = p.AlphaCode
        inner join [db-au-cmdwh]..penOutlet dwo with(nolock) on
            dwo.CountryKey = 'US' and
            dwo.AlphaCode = o.AlphaCode collate database_default and
            dwo.OutletStatus = 'Current'
        inner join [db-au-cmdwh]..penOutlet lo with(nolock) on
            lo.OutletKey = dwo.LatestOutletKey and
            lo.OutletStatus = 'Current'
        inner join bhdwh02.[US_PenguinSharp_Active].dbo.tblPolicyDetails pd with(nolock) on
            pd.PolicyID = p.PolicyID
        inner join bhdwh02.[US_PenguinSharp_Active].dbo.tblProduct pp with(nolock) on
            pp.ProductID = pd.ProductId
        inner join bhdwh02.[US_PenguinSharp_Active].dbo.tblPolicyTransaction pt with(nolock) on
            pt.PolicyID = p.PolicyID
        outer apply
        (
            select 
                max(ptv.Suburb) Suburb,
                max(ptv.State) State,
                sum(isnull(convert(float, replace(replace(pta.AddOnText, '$', ''), ',', '')), 0)) TripCost,
                count(ptv.ID) TravellerCount
            from 
                bhdwh02.[US_PenguinSharp_Active].dbo.tblPolicyTraveller ptv with(nolock)
                inner join bhdwh02.[US_PenguinSharp_Active].dbo.tblPolicyTravellerTransaction ptt with(nolock) on
                    ptt.PolicyTravellerID = ptv.ID
                inner join bhdwh02.[US_PenguinSharp_Active].dbo.tblPolicyTravellerAddOn pta with(nolock) on
                    pta.PolicyTravellerTransactionID = ptt.ID
            where
                ptv.PolicyID = p.PolicyID
        ) ptv
        left join bhdwh02.[US_PenguinSharp_Active].dbo.tblUser u with(nolock) on
            u.UserID = pt.ConsultantID and
            u.OutletID = o.OutletID
    where
        pt.TransactionDateTime >= '2016-06-29' and
        [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(pt.TransactionDateTime, 'Eastern Standard Time') >= '2016-07-01' and
        o.AlphaCode like 'FL%'
    group by
        lo.AlphaCode,
        lo.OutletName,
        lo.SubGroupName,
        lo.EGMNation,
        lo.FCNation,
        lo.FCArea,
        lo.BDMName,
        lo.StateSalesArea,
        convert(date, [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal(pt.TransactionDateTime, 'Eastern Standard Time')),
        u.FirstName + ' ' + u.LastName collate database_default,
        pp.ProductDisplayName,
        pd.PlanName,
        ptv.Suburb,
        ptv.State,
        p.PrimaryCountry,
        p.TripStart,
        pd.TripDuration,
        datediff(day, pt.TransactionDateTime, p.TripStart),
        case
            when ptv.TripCost <= 1000 then '$1 - $1,000'
            when ptv.TripCost <= 2000 then '$1,001 - $2,000'
            when ptv.TripCost <= 3000 then '$2,001 - $3,000'
            when ptv.TripCost <= 4000 then '$3,001 - $4,000'
            when ptv.TripCost <= 5000 then '$4,001 - $5,000'
            when ptv.TripCost <= 6000 then '$5,001 - $6,000'
            when ptv.TripCost <= 7000 then '$6,001 - $7,000'
            when ptv.TripCost <= 8000 then '$7,001 - $8,000'
            when ptv.TripCost <= 9000 then '$8,001 - $9,000'
            when ptv.TripCost <= 10000 then '$9,001 - $10,000'
            when ptv.TripCost <= 15000 then '$10,001 - $15,000'
            when ptv.TripCost <= 20000 then '$15,001 - $20,000'
            when ptv.TripCost <= 25000 then '$20,001 - $25,000'
            when ptv.TripCost <= 30000 then '$25,001 - $30,000'
            when ptv.TripCost <= 50000 then '$30,001 - $50,000'
            else '$50,001+'
        end
)
select 
    py.*,
    d.[Date],
    d.CurMonthStart,
    convert(date, [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal([db-au-cmdwh].dbo.xfn_ConvertLocalToUTC(getdate(), 'AUS Eastern Standard Time'), 'Eastern Standard Time')) [US Today],
    datepart(day, d.CurMonthEnd) DayCount
from
    [db-au-cmdwh]..Calendar d
    left join cte_py py on
        py.[Issue Date] = d.[Date]
where
    d.[Date] between '2015-07-01' and '2016-06-30'

union all

select 
    cy.*,
    d.[Date],
    d.CurMonthStart,
    convert(date, [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal([db-au-cmdwh].dbo.xfn_ConvertLocalToUTC(getdate(), 'AUS Eastern Standard Time'), 'Eastern Standard Time')) [US Today],
    datepart(day, d.CurMonthEnd) DayCount
from
    [db-au-cmdwh]..Calendar d
    left join cte_cy cy on
        cy.[Issue Date] = d.[Date]
where
    d.[Date] between '2016-07-01' and '2017-06-30'

union all

select distinct
    AlphaCode [Alpha Code],
    OutletName [Store],
    SubGroupName [Brand],
    EGMNation [EGM],
    FCNation [FC Nation],
    FCArea [FC Area],
    BDMName [BDM],
    StateSalesArea [Sales Area],
    d.[Date] [Issue Date],
    '' [Consultant],
    '' [Product Name],
    '' [Plan Name],
    '' [Customer City],
    '' [Customer State],
    '' [Destination],
    d.[Date] [Departure Date],
    1 [Duration],
    0 [Lead Time],
    '$1 - $1,000' [Trip Cost],
    0 [Policy Count],
    0 [Traveller Count],
    0 [Sell Price],
    d.[Date],
    d.CurMonthStart,
    convert(date, [db-au-cmdwh].dbo.xfn_ConvertUTCtoLocal([db-au-cmdwh].dbo.xfn_ConvertLocalToUTC(getdate(), 'AUS Eastern Standard Time'), 'Eastern Standard Time')) [US Today],
    datepart(day, d.CurMonthEnd) DayCount
from
    [db-au-cmdwh]..penOutlet o
    inner join [db-au-cmdwh]..Calendar d on
        d.[Date] between '2016-07-01' and '2017-06-30'
where
    CountryKey = 'US' and
    OutletStatus = 'Current' and
    GroupCode = 'FL'


GO
