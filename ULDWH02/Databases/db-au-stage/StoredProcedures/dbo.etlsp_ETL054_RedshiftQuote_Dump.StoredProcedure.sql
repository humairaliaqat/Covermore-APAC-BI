USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_Dump]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL054_RedshiftQuote_Dump]
    @DateRange varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null

as
begin


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20150909
Description:    export following tables to CSV with pipe (|) delimiter:
                [db-au-cmdwh].dbo.cdgQuote
                [db-au-cmdwh].dbo.penQuote
Parameters:     @DateRange: required.
                @StartDate: optional. if _User Defined enter StartDate (Format: yyyy-mm-dd eg. 2015-01-01)
                @EndDate: optional. if _User Defined enter EndDate (Format: yyyy-mm-dd eg. 2015-01-01)
Change History:
                20150909 - LT - Procedure created
                20151230 - LS - refactoring
                20160122 - LS - tweak
                20160131 - LS - rewrite
				20180418 - LT - Removed Impulse2 Version1 quote data, added Impulse2 Version2 quote data to dump
				
*************************************************************************************************************************************/

--uncomment to debug
/*
declare
    @DateRange varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
select
    @DateRange = 'Last February',
    @StartDate = null,
    @EndDate = null
*/

    set nocount on

    declare
        @rptStartDate datetime,
        @rptEndDate datetime

    if @DateRange = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange


	--Impulse2 version2

	--get offers and quotes in period
	if object_id('tempdb..#quotes') is not null drop table #quotes

	select distinct
		'Offer' as QuoteType,
		o.SessionID,
		o.OfferDateTime as QuoteDateTime,
		o.CampaignID,
		convert(varchar(128), o.SessionID) CampaignSessionID,
		convert(varchar(128),o.factOfferID) ImpressionID,
		o.factOfferID as QuoteID,
		convert(varchar(256),o.Destination) as Destination,
		datediff(day, convert(date, o.OfferDateTime), convert(date, o.TripStart)) LeadTime,
		datediff(day, convert(date, o.TripStart), convert(date, o.TripEnd)) + 1 Duration,
		o.ProductID,
		o.TripStart as StartDate,
		o.TripEnd as EndDate,
		o.RegionID,
		o.AdultCount,
		o.ChildCount,
		o.InfantCount,
		t.Age TravellerAge,
		convert(varchar(128),t.TravelerID) as TravellerID,
		convert(int,null) as DestinationCountryID,
		convert(numeric,o.TotalGrossPremium) as GrossIncludingTax,
		convert(numeric,o.TotalGrossPremium) as GrossExcludingTax,
		o.AdultCount NumAdults,
		o.ChildCount + o.InfantCount as NumChildren,
		t.IsAdult,
		convert(int,1) IsPrimaryTraveller,
		convert(varchar(128), case when p.factPolicyID is null then '' else p.factPolicyID end) PolicyID
	into #quotes
	from
		[db-au-cmdwh].dbo.cdgfactSession s
		inner join [db-au-cmdwh].dbo.cdgfactOffer o on s.factSessionID = o.SessionID
		outer apply
		(
			select top 1 factPolicyID
			from [db-au-cmdwh].dbo.cdgfactPolicy
			where SessionID = o.SessionID
		) p	
		outer apply
		(
			select top 1 Age, factTravelerID as TravelerID, isAdult
			from [db-au-cmdwh].dbo.cdgfactTraveler
			where
				SessionID = o.SessionID
			order by SessionID, factTravelerID							--first row is treated as IsPrimary traveller
		) t
	where
		s.SessionCreateDate >= @rptStartDate and
		s.SessionCreateDate <  dateadd(d,1,@rptEndDate)

	insert into #quotes
	select distinct
		'Quote' as QuoteType,
		o.SessionID,
		o.QuoteDateTime as QuoteDateTime,
		o.CampaignID,
		convert(varchar(128), o.SessionID) CampaignSessionID,
		convert(varchar(128),o.factQuoteID) ImpressionID,
		o.factQuoteID as QuoteID,
		convert(varchar(256),o.Destination) as Destination,
		datediff(day, convert(date, o.QuoteDateTime), convert(date, o.TripStart)) LeadTime,
		datediff(day, convert(date, o.TripStart), convert(date, o.TripEnd)) + 1 Duration,
		o.ProductID,
		o.TripStart as StartDate,
		o.TripEnd as EndDate,
		o.RegionID,
		o.AdultCount,
		o.ChildCount,
		o.InfantCount,
		t.Age TravellerAge,
		convert(varchar(128),t.TravelerID) as TravellerID,
		convert(int,null) as DestinationCountryID,
		convert(numeric,o.TotalGrossPremium) as GrossIncludingTax,
		convert(numeric,case when o.TotalAdjustedGrossPremium = 0 then o.TotalGrossPremium else o.TotalAdjustedGrossPremium end) as GrossExcludingTax,
		o.AdultCount NumAdults,
		o.ChildCount + o.InfantCount as NumChildren,
		t.IsAdult,
		convert(int,1) IsPrimaryTraveller,
		convert(varchar(128), case when p.factPolicyID is null then '' else p.factPolicyID end) PolicyID
	from
		[db-au-cmdwh].dbo.cdgfactSession s
		inner join [db-au-cmdwh].dbo.cdgfactQuote o on s.factSessionID = o.SessionID
		outer apply
		(
			select top 1 factPolicyID
			from [db-au-cmdwh].dbo.cdgfactPolicy
			where SessionID = o.SessionID
		) p	
		outer apply
		(
			select top 1 Age, factTravelerID as TravelerID, isAdult
			from [db-au-cmdwh].dbo.cdgfactTraveler
			where
				SessionID = o.SessionID
			order by SessionID, factTravelerID							--first row is treated as IsPrimary traveller
		) t
	where
		s.SessionCreateDate >= @rptStartDate and
		s.SessionCreateDate <  dateadd(d,1,@rptEndDate)


	update #quotes
	set Destination = case when Destination = 'São Tomé and Príncipe' then 'Sao Tome and Principe'
							else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(Destination)
						end

	--get sessions in period
	if object_id('tempdb..#sessions') is not null drop table #sessions
	select
		convert(int,3) as PlatformVersion,
		convert(bigint,s.factSessionID) as AnalyticsSessionID,
		convert(nvarchar(255),bu.BusinessUnit) as OutletGroup,
		datepart(hh, s.SessionCreateDate) TransactionHour,    
		case when s.IsPolicyPurchased = 1 then 1 else 0 end as ConvertedFlag,
		s.SessionCreateDate as TransactionTime,
		s.BusinessUnitID
	into #sessions
	from
		[db-au-cmdwh].dbo.cdgfactSession s with(index(idx_cdgfactSession_SessionCreateDate), nolock)
		inner join [db-au-cmdwh].dbo.cdgBusinessUnit bu on s.BusinessUnitID = bu.BusinessUnitID
	where
		s.SessionCreateDate >= @rptStartDate and
		s.SessionCreateDate <  dateadd(d,1,@rptEndDate)


	--combine sessions and quotes
	if object_id('tempdb..##cdgQuotes') is not null drop table ##cdgQuotes
	select
		3 as PlatformVersion,
		s.AnalyticsSessionID,
		s.OutletGroup,
		s.TransactionHour,
		q.Destination,
		q.LeadTime,
		q.Duration,
		q.TravellerAge,
		s.ConvertedFlag,
		s.TransactionTime,
		q.CampaignID,
		q.CampaignSessionID,
		s.BusinessUnitID,
		null as ChannelID,									--Impulse2 Ver2 does not have channel info
		q.TravellerID,
		q.ImpressionID,
		q.ProductID,
		q.StartDate,
		q.EndDate,
		q.RegionID,
		null as DestinationCountryID,
		q.GrossIncludingTax,
		q.GrossExcludingTax,
		q.NumAdults,
		q.NumChildren,
		q.IsAdult,
		q.IsPrimaryTraveller,
		q.PolicyID,
		0 as isDeleted
	into ##cdgQuotes
	from
		#sessions s
		outer apply
		(
			select top 1 *
			from #quotes
			where 
				QuoteType = 'Offer' and
				SessionID = s.AnalyticsSessionID

			union

			select top 1 *
			from #quotes
			where
				QuoteType = 'Quote' and
				SessionID = s.AnalyticsSessionID
		) q


	--Impulse1
	insert ##cdgQuotes
    select
        1 PlatformVersion,
        AnalyticsSessionID,
        Channel OutletGroup,
        datepart(hh, TransactionTime) TransactionHour,
        case
            when DestinationCountryCode = '' then null
            when DestinationCountryCode = 'STP' then 'Sao Tome and Principe'
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(DestinationCountry)
        end Destination,
        datediff(day, convert(date, TransactionTime), convert(date, StartDate)) LeadTime,
        datediff(day, convert(date, StartDate), convert(date, EndDate)) + 1 Duration,
        TravellerAge,
        isnull(IsOfferPurchased, 0) ConvertedFlag,
        TransactionTime,
        CampaignID,
        convert(varchar(128), CampaignSessionID) CampaignSessionID,
        BusinessUnitID,
        ChannelID,
        convert(varchar(128), TravellerID) TravellerID,
        convert(varchar(128), ImpressionID) ImpressionID,
        ProductID,
        StartDate,
        EndDate,
        RegionID,
        DestinationCountryID,
        GrossIncludingTax,
        GrossExcludingTax,
        NumAdults,
        NumChildren,
        IsAdult,
        IsPrimaryTraveller,
        convert(varchar(128), PolicyID) PolicyID,
        isDeleted
    from
        [db-au-cmdwh].dbo.cdgQuote with(index(idx_cdgQuote_TransactionTime), nolock)
    where
        TransactionTime >= @rptStartDate and
        TransactionTime <  dateadd(day, 1, @rptEndDate)



    exec master..xp_cmdshell 'bcp ##cdgQuotes out e:\ETL\Data\RedShift\out\cdgQuote.csv -c -t "|" -T -S ULDWH02'


    --penQuote
    if object_id('tempdb..##penQuote') is not null
        drop table ##penQuote

    select
        QuoteKey,
        CreateTime,
        o.GroupName OutletGroup,
        datepart(hh, CreateTime) TransactionHour,
        case
            when Destination = '' then null
            when Destination like 'Sǯ Tom¥' then 'Sao Tome and Principe'
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(Destination)
        end Destination,
        datediff(day, convert(date, CreateTime), convert(date, DepartureDate)) LeadTime,
        datediff(day, convert(date, DepartureDate), convert(date, ReturnDate)) + 1 Duration,
        qc.TravellerAge,
        case
            when isnull(PolicyKey, '') = '' then 0
            else 1
        end ConvertedFlag,
        SessionID,
        DepartureDate,
        ReturnDate,
        IsExpo,
        IsAgentSpecial,
        case
            when PromoCode = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(PromoCode)
        end PromoCode,
        NumberOfAdults,
        NumberOfChildren,
        IsSaved,
        case
            when AgentReference = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(AgentReference)
        end AgentReference,
        QuotedPrice,
        ProductCode,
        case
            when CRMUserName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(CRMUserName)
        end CRMUserName,
        PreviousPolicyNumber,
        IsPriceBeat,
        ParentQuoteID
    into ##penQuote
    from
        [db-au-cmdwh].dbo.penQuote q with(nolock)
        inner join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
            o.OutletAlphaKey = q.OutletAlphaKey and
            o.OutletStatus = 'Current'
        outer apply
        (
            select top 1
                qc.Age TravellerAge
            from
                [db-au-cmdwh].dbo.penQuoteCustomer qc with(nolock)
            where
                qc.QuoteCountryKey = q.QuoteCountryKey
            order by
                qc.QuoteCustomerID
        ) qc
    where
        CreateDate >= @rptStartDate and
        CreateDate <  dateadd(day, 1, @rptEndDate) and
        UserName = 'webuser'

    exec master..xp_cmdshell 'bcp ##penQuote out e:\ETL\Data\RedShift\out\penQuote.csv -c -t "|" -T -S ULDWH02'


    if object_id('tempdb..##cdgQuote') is not null
        drop table ##cdgQuote

    if object_id('tempdb..##penQuote') is not null
        drop table ##penQuote


end

GO
