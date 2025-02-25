USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_Export]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL054_RedshiftQuote_Export]
    @DateRange varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)

as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20150909
Description:    export following tables to CSV with pipe (|) delimiter:
                [db-au-cmdwh].dbo.cdgQuote
                [db-au-cmdwh].dbo.penQuote
                [db-au-cmdwh].dbo.penQuoteCustomer
                [db-au-cmdwh].dbo.penQuoteAddon
                [db-au-cmdwh].dbo.penOutlet
                [db-au-cmdwh].dbo.penCustomer
Parameters:     @DateRange: required.
                @StartDate: optional. if _User Defined enter StartDate (Format: yyyy-mm-dd eg. 2015-01-01)
                @EndDate: optional. if _User Defined enter EndDate (Format: yyyy-mm-dd eg. 2015-01-01)
Change History:
                20150909 - LT - Procedure created
                20151230 - LS - refactoring

*************************************************************************************************************************************/

--uncomment to debug
/*
declare
    @DateRange varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
select
    @DateRange = 'Last 30 days',
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


    --cdgQuote
    if object_id('tempdb..##cdgQuote') is not null
        drop table ##cdgQuote

    select
        BIRowID,
        AnalyticsSessionID,
        TransactionTime,
        CampaignID,
        Campaign,
        CampaignSessionID,
        BusinessUnitID,
        Domain,
        BusinessUnit,
        ChannelID,
        Channel,
        Currency,
        TravellerID,
        ImpressionID,
        TransactionType,
        PathType,
        ConstructID,
        Construct,
        OfferID,
        Offer,
        ProductID,
        Product,
        ProductCode,
        PlanCode,
        StartDate,
        EndDate,
        RegionID,
        Region,
        DestinationType,
        DestinationCountryID,
        DestinationCountryCode,
        case
            when DestinationCountryCode = 'STP' then 'Sao Tome and Principe'
            else DestinationCountry
        end DestinationCountry,
        TripType,
        IsSessionClosed,
        IsOfferPurchased,
        PoliciesPerTrip,
        PolicyCurrency,
        GrossIncludingTax,
        GrossExcludingTax,
        NumAdults,
        NumChildren,
        TravellerAge,
        IsAdult,
        TravellerGender,
        IsPrimaryTraveller,
        AlphaCode,
        PolicyNumber,
        PolicyID,
        TripCost,
        CreateBatchID,
        UpdateBatchID,
        isDeleted
    into ##cdgQuote
    from
        [db-au-cmdwh].dbo.cdgQuote with(index(idx_cdgQuote_TransactionTime), nolock)
    where
        TransactionTime >= @rptStartDate and
        TransactionTime <  dateadd(day, 1, @rptEndDate)

    exec master..xp_cmdshell 'bcp ##cdgQuote out e:\ETL\Data\RedShift\out\cdgQuote.csv -c -t "|" -T -S ULDWH02'


    --penQuote
    if object_id('tempdb..##penQuote') is not null
        drop table ##penQuote

    select
        CountryKey,
        CompanyKey,
        QuoteKey,
        QuoteCountryKey,
        PolicyKey,
        OutletSKey,
        OutletAlphaKey,
        QuoteID,
        SessionID,
        AgencyCode,
        case
            when ConsultantName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(ConsultantName)
        end ConsultantName,
        case
            when UserName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(UserName)
        end UserName,
        CreateDate,
        CreateTime,
        case
            when Area = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(Area)
        end Area,
        case
            when Destination like 'Sǯ Tom¥' then 'Sao Tome and Principe'
            when Destination = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(Destination)
        end Destination,
        DepartureDate,
        ReturnDate,
        IsExpo,
        IsAgentSpecial,
        case
            when PromoCode = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(PromoCode)
        end PromoCode,
        CanxFlag,
        PolicyNo,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        Duration,
        IsSaved,
        SaveStep,
        case
            when AgentReference = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(AgentReference)
        end AgentReference,
        UpdateTime,
        StoreCode,
        QuotedPrice,
        ProductCode,
        DomainKey,
        DomainID,
        CreateDateUTC,
        CreateTimeUTC,
        UpdateTimeUTC,
        YAGOCreateDate,
        PurchasePath,
        QuoteSaveDate,
        QuoteSaveDateUTC,
        case
            when CRMUserName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(CRMUserName)
        end CRMUserName,
        case
            when CRMFullName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(CRMFullName)
        end CRMFullName,
        PreviousPolicyNumber,
        QuoteImportDateUTC,
        CurrencyCode,
        AreaCode,
        CultureCode,
        ProductName,
        PlanID,
        PlanName,
        case
            when PlanCode = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(PlanCode)
        end PlanCode,
        PlanType,
        IsUpSell,
        Excess,
        IsDefaultExcess,
        PolicyStart,
        PolicyEnd,
        DaysCovered,
        MaxDuration,
        GrossPremium,
        PDSUrl,
        SortOrder,
        PlanDisplayName,
        RiskNet,
        PlanProductPricingTierID,
        VolumeCommission,
        Discount,
        CommissionTier,
        COI,
        UniquePlanID,
        case
            when TripCost = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(TripCost)
        end TripCost,
        PolicyID,
        IsPriceBeat,
        CancellationValueText,
        ProductDisplayName,
        AreaID,
        AgeBandID,
        DurationID,
        ExcessID,
        LeadTimeID,
        RateCardID,
        IsSelected,
        ParentQuoteID
    into ##penQuote
    from
        [db-au-cmdwh].dbo.penQuote with(nolock)
    where
        CreateDate >= @rptStartDate and
        CreateDate <  dateadd(day, 1, @rptEndDate)

    exec master..xp_cmdshell 'bcp ##penQuote out e:\ETL\Data\RedShift\out\penQuote.csv -c -t "|" -T -S ULDWH02'


    --penQuoteAddon
    if object_id('tempdb..##penQuoteAddon') is not null
        drop table ##penQuoteAddon

    select
        qa.CountryKey,
        qa.CompanyKey,
        qa.QuoteCountryKey,
        qa.CustomerKey,
        qa.QuoteID,
        qa.CustomerID,
        qa.QuoteAddOnID,
        qa.AddOnName,
        qa.AddOnGroup,
        case
            when qa.AddOnItem = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(qa.AddonItem)
        end AddOnItem,
        qa.PremiumIncrease,
        qa.CoverIncrease,
        qa.CoverIsPercentage,
        qa.IsRateCardBased,
        qa.IsActive
    into ##penQuoteAddon
    from
        [db-au-cmdwh].dbo.penQuote q
        inner join [db-au-cmdwh].dbo.penQuoteAddOn qa on
            q.QuoteCountryKey = qa.QuoteCountryKey
    where
        q.CreateDate >= @rptStartDate and
        q.CreateDate <  dateadd(day, 1, @rptEndDate)

    exec master..xp_cmdshell 'bcp ##penQuoteAddon out e:\ETL\Data\RedShift\out\penQuoteAddon.csv -c -t "|" -T -S ULDWH02'

    --penQuoteCustomer
    if object_id('tempdb..##penQuoteCustomer') is not null
        drop table ##penQuoteCustomer

    select
        qc.CountryKey,
        qc.CompanyKey,
        qc.QuoteCountryKey,
        qc.CustomerKey,
        qc.QuoteID,
        qc.CustomerID,
        qc.QuoteCustomerID,
        qc.Age,
        qc.IsPrimary,
        qc.PersonIsAdult,
        qc.HasEMC,
        qc.DomainKey,
        qc.DomainID
    into ##penQuoteCustomer
    from
        [db-au-cmdwh].dbo.penQuote q
        inner join [db-au-cmdwh].dbo.penQuoteCustomer qc on
            q.QuoteCountryKey = qc.QuoteCountryKey
    where
        q.CreateDate >= @rptStartDate and
        q.CreateDate <  dateadd(day, 1, @rptEndDate)

    exec master..xp_cmdshell 'bcp ##penQuoteCustomer out e:\ETL\Data\RedShift\out\penQuoteCustomer.csv -c -t "|" -T -S ULDWH02'

    --penCustomer
    if object_id('tempdb..##penCustomer') is not null
        drop table ##penCustomer

    select
        c.CountryKey,
        c.CompanyKey,
        c.CustomerKey,
        c.CustomerID,
        case
            when c.Title = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.Title)
        end Title,
        case
            when c.FirstName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.FirstName)
        end FirstName,
        case
            when c.LastName = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.LastName)
        end LastName,
        c.DOBUTC,
        case
            when c.AddressLine1 = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.AddressLine1)
        end AddressLine1,
        case
            when c.AddressLine2 = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.AddressLine2)
        end AddressLine2,
        case
            when c.PostCode = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.PostCode)
        end PostCode,
        case
            when c.Town = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.Town)
        end Town,
        case
            when c.[State] = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.[State])
        end [State],
        case
            when c.Country = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.Country)
        end Country,
        case
            when c.HomePhone = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.HomePhone)
        end HomePhone,
        case
            when c.WorkPhone = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.WorkPhone)
        end WorkPhone,
        case
            when c.MobilePhone = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.MobilePhone)
        end MobilePhone,
        case
            when c.EmailAddress = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.EmailAddress)
        end EmailAddress,
        c.OptFurtherContact,
        case
            when c.MemberNumber = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.MemberNumber)
        end MemberNumber,
        c.DomainKey,
        c.DomainID,
        c.MarketingConsent,
        case
            when c.Gender = '' then null
            else c.Gender
        end Gender,
        case
            when c.PIDType = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.PIDType)
        end PIDType,
        case
            when c.PIDCode = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.PIDCode)
        end PIDCode,
        case
            when c.PIDValue = '' then null
            else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(c.PIDValue)
        end PIDValue,
        c.DOB
    into ##penCustomer
    from
        [db-au-cmdwh].dbo.penQuote q
        inner join [db-au-cmdwh].dbo.penQuoteCustomer qc on
            q.QuoteCountryKey = qc.QuoteCountryKey
        inner join [db-au-cmdwh].dbo.penCustomer c on
            qc.CustomerKey = c.CustomerKey
    where
        q.CreateDate >= @rptStartDate and
        q.CreateDate <  dateadd(day, 1, @rptEndDate)

    exec master..xp_cmdshell 'bcp ##penCustomer out e:\ETL\Data\RedShift\out\penCustomer.csv -c -t "|" -T -S ULDWH02'

    --penOutlet - Current records only
    if object_id('tempdb..##penOutlet') is not null
        drop table ##penOutlet

    select
        CountryKey,
        CompanyKey,
        OutletKey,
        upper(OutletAlphaKey) OutletAlphaKey,
        [db-au-cmdwh].dbo.fn_RemoveSpecialChars(OutletName) OutletName,
        OutletType,
        AlphaCode,
        [db-au-cmdwh].dbo.fn_RemoveSpecialChars(SuperGroupName) SuperGroupName,
        [db-au-cmdwh].dbo.fn_RemoveSpecialChars(GroupName) GroupName,
        [db-au-cmdwh].dbo.fn_RemoveSpecialChars(SubGroupName) SubGroupName
    into ##penOutlet
    from
        [db-au-cmdwh].dbo.penOutlet
    where
        OutletStatus = 'Current'

    exec master..xp_cmdshell 'bcp ##penOutlet out e:\ETL\Data\RedShift\out\penOutlet.csv -c -t "|" -T -S ULDWH02'

    if object_id('tempdb..##cdgQuote') is not null
        drop table ##cdgQuote

    if object_id('tempdb..##penQuote') is not null
        drop table ##penQuote

    if object_id('tempdb..##penQuoteAddon') is not null
        drop table ##penQuoteAddon

    if object_id('tempdb..##penQuoteCustomer') is not null
        drop table ##penQuoteCustomer

    if object_id('tempdb..##penCustomer') is not null
        drop table ##penCustomer

    if object_id('tempdb..##penOutlet') is not null
        drop table ##penOutlet

end

GO
