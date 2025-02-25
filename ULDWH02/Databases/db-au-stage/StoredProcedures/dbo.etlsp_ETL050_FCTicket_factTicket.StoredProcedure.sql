USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL050_FCTicket_factTicket]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL050_FCTicket_factTicket]
as
begin

	--20171113 - LT - ticket data is relevant to Flight Centre (AU & NZ) only. This amendment adds Outlet filter to "Flight Centre" only.
    --20180511 - LL - process last 3 years only (maximum cancellation period for a ticket)
	--20180601 - LT - Leo, you forgot to subtract 3 years from the @startdate.
	--20181105 - LT - Excluded Jetstar and Air Asia tickets (airline code not in ('JQ','AK'))
	--20191012 - LT - Changed #factPolicy selection. The new business rule selects policy issued in the month, and any policy cancelled that were issued and cancelled in the month

    set nocount on

    declare @startdate date

    set @startdate = convert(date, convert(varchar(8), dateadd(year,-3,getdate()), 120) + '01')

    delete 
    from
        [db-au-star]..factTicket
    where
        [DateSK] >= convert(int, replace(convert(varchar(10), @startdate, 120), '-', ''))


    if object_id('tempdb..#factTicket') is not null
        drop table #factTicket

    select --top 100 
        Domain,
        IssueDate,
        FirstFlightDate,
        OriginAirportCountryName,
        DestinationAirportCountryName,
        TotalDuration,
        OutletKey,
        sum
        (
            case
                when Domain = 'AU' and OriginAirportCountryName <> 'Australia' then 0
                when Domain = 'NZ' and OriginAirportCountryName <> 'New Zealand' then 0
                when TravelType in ('International', 'TransTasman') then 1
                else 0
            end
        ) InternationalTicketCount,
        sum
        (
            case
                when TravelType in ('International', 'TransTasman') then 0
                else 1
            end
        ) DomesticTicketCount
    into #factTicket
    from
        [db-au-cmdwh].dbo.fltTickets with(nolock)
    where
        IssueDate >= @startdate and
        TicketType = 'Issued' and
        RefundedDate is null and
        (
            (
                Domain = 'NZ' and 
                DocumentType <> 'EMD'
            ) or 
            (
                DocumentType not in ('EMD', 'VMPD')
            )
        ) and
		AirlineCode not in  ('JQ','AK') --exclude Jetstar and Air Asia
    group by
        Domain,
        IssueDate,
        FirstFlightDate,
        OriginAirportCountryName,
        DestinationAirportCountryName,
        TotalDuration,
        OutletKey
    
    insert into [db-au-star]..factTicket
    (
        DateSK,
        DepartureDateSK,
        DomainSK,
        DestinationSK,
        OriginSK,
        DurationSK,
        OutletSK,
        TicketCount,
        InternationalTravellersCount,
        DomesticTicketCount,
        DomesticTravellersCount,
        Source,
        ReferenceNumber,
        LoadDate,
        LoadID,
        BIRowID,
        Gross_Fare,
        Net_Fare
    )
    select 
        isnull(dd.Date_SK, -1) DateSK,
        isnull(ddd.Date_SK, -1) DepartureDateSK,
        isnull(dm.DomainSK, -1) DomainSK,
        isnull(dst.DestinationSK, -1) DestinationSK,
        isnull(org.DestinationSK, -1) OriginSK,
        isnull(dur.DurationSK, -1) DurationSK,
        isnull(do.OutletSK, -1) OutletSK,
        InternationalTicketCount TicketCount,
        0 InternationalTravellersCount,
        DomesticTicketCount,
        0 DomesticTravellersCount,
        'FL' Source,
        '' ReferenceNumber,
        getdate() LoadDate,
        -1 LoadID,
        -1 BIRowID,
        0 Gross_Fare,
        0 Net_Fare
    from
        #factTicket t
        outer apply
        (
            select top 1 
                dd.Date_SK
            from
                [db-au-star].dbo.Dim_Date dd
            where
                dd.[Date] = convert(date, t.IssueDate)
        ) dd
        outer apply
        (
            select top 1 
                ddd.Date_SK
            from
                [db-au-star].dbo.Dim_Date ddd
            where
                ddd.[Date] = convert(date, t.FirstFlightDate)
        ) ddd
        outer apply
        (
            select top 1 
                dm.DomainSK
            from
                [db-au-star].dbo.dimDomain dm
            where
                dm.CountryCode = t.Domain
        ) dm
        outer apply
        (
            select top 1 
                dst.DestinationSK
            from
                [db-au-star].dbo.dimDestination dst
            where
                dst.Destination = t.DestinationAirportCountryName
        ) dst
        outer apply
        (
            select top 1 
                org.DestinationSK
            from
                [db-au-star].dbo.dimDestination org
            where
                org.Destination = t.OriginAirportCountryName
        ) org
        outer apply
        (
            select top 1 
                dur.DurationSK
            from
                [db-au-star].dbo.dimDuration dur
            where
                dur.Duration = t.TotalDuration
        ) dur
        outer apply
        (
            select top 1
                do.OutletSK
            from
                [db-au-star].dbo.dimOutlet do
            where
                do.OutletKey = t.OutletKey and
                do.isLatest = 'Y' and
				do.SuperGroupName = 'Flight Centre'
        ) do

    if object_id('tempdb..#factPolicy') is not null
        drop table #factPolicy

    select --top 100 
        isnull(dd.Date_SK, -1) DateSK,
        isnull(ddd.Date_SK, -1) DepartureDateSK,
        fpt.DomainSK,
        fpt.DestinationSK,
        isnull(org.DestinationSK, -1) OriginSK,
        fpt.DurationSK,
        fpt.OutletSK,
        sum(fpt.InternationalTravellersCount) InternationalTravellersCount,
        sum(fpt.DomesticTravellersCount) DomesticTravellersCount
    into #factPolicy
    from
        [db-au-star].dbo.factPolicyTransaction fpt with(nolock)
        inner join [db-au-star].dbo.dimPolicy dp with(nolock) on
            dp.PolicySK = fpt.PolicySK
		inner join [db-au-star].dbo.dimOutlet o with(nolock) on
			fpt.OutletSK = o.OutletSK
        outer apply
        (
            select top 1 
                dd.Date_SK,
				CurMonthStart,
				CurMonthEnd
            from
                [db-au-star].dbo.Dim_Date dd
            where
                dd.[Date] = convert(date, dp.IssueDate)
        ) dd
        outer apply
        (
            select top 1 
                ddd.Date_SK
            from
                [db-au-star].dbo.Dim_Date ddd
            where
                ddd.[Date] = convert(date, dp.TripStart)
        ) ddd
        outer apply
        (
            select top 1 
                org.DestinationSK
            from
                [db-au-star].dbo.dimDestination org
            where
                org.Destination = 
                    case
                        when dp.Country = 'AU' then 'Australia'
                        when dp.Country = 'NZ' then 'New Zealand'
                    end
        ) org		
    where
        dp.Country in ('AU', 'NZ') and
		o.SuperGroupName = 'Flight Centre' and
        dp.IssueDate >= @startdate and
		(
			(
				dp.IssueDate >= dd.CurMonthStart and
				dp.IssueDate < dateadd(d,1,dd.CurMonthEnd) and
				dp.PolicyStatus = 'Active' and
				fpt.TransactionType = 'Base'
			) or
			(
				dp.IssueDate >= dd.CurMonthStart and
				dp.IssueDate < dd.CurMonthEnd and
				dp.PolicyStatus = 'Cancelled' and
				fpt.TransactionType = 'Base'
			)
		)
    group by
        isnull(dd.Date_SK, -1),
        isnull(ddd.Date_SK, -1),
        fpt.DomainSK,
        fpt.DestinationSK,
        isnull(org.DestinationSK, -1),
        fpt.DurationSK,
        fpt.OutletSK


    insert into [db-au-star]..factTicket
    (
        DateSK,
        DepartureDateSK,
        DomainSK,
        DestinationSK,
        OriginSK,
        DurationSK,
        OutletSK,
        TicketCount,
        InternationalTravellersCount,
        DomesticTicketCount,
        DomesticTravellersCount,
        Source,
        ReferenceNumber,
        LoadDate,
        LoadID,
        BIRowID,
        Gross_Fare,
        Net_Fare
    )
    select 
        DateSK,
        DepartureDateSK,
        DomainSK,
        DestinationSK,
        OriginSK,
        DurationSK,
        OutletSK,
        0 TicketCount,
        sum(InternationalTravellersCount) InternationalTravellersCount,
        0 DomesticTicketCount,
        sum(DomesticTravellersCount) DomesticTravellersCount,
        'Penguin' Source,
        '' ReferenceNumber,
        getdate() LoadDate,
        -1 LoadID,
        -1 BIRowID,
        0 Gross_Fare,
        0 Net_Fare
    from
        #factPolicy
    group by
        DateSK,
        DepartureDateSK,
        DomainSK,
        DestinationSK,
        OriginSK,
        DurationSK,
        OutletSK

end
GO
