USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_factQuoteTransaction]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_factQuoteTransaction]    
    @DateRange varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
    
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131115
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penQuote table available
Description:    factQuoteTransaction dimension table contains Quote attributes.
Parameters:     @DateRange:     Required. Standard date range or _User Defined
                @StartDate:     Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
                @EndDate:       Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
Change History:
                20131115 - LT - Procedure created
                20140905 - LS - refactoring
                                load missing consultant, replacing aggresive load
                                add ProductSK (only relatively reliable after 2014-07-01)
                                add auto identity, ease up delete process removing the need to physically re-sort data
                20140909 - LS - change penUser join to left join, server can't find better query plan
                                no duplicates found for outletkey and username in penUser
                20150204 - LS - replace batch codes with standard batch logging
                                disable this, superseeded by factQuoteSummary
                                look at impossible where clause below (1 = 0) and the commented delete - insert block
                                
*************************************************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
    @DateRange = '_User Defined', 
    @StartDate = '2011-07-01', 
    @EndDate = '2011-07-01'
*/

    set nocount on

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @rptStartDate date,
        @rptEndDate date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    select
        @name = object_name(@@procid)

    begin try
    
        --check if this is running on batch

        exec syssp_getrunningbatch
            @SubjectArea = 'Policy Star',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Running'

        select 
            @rptStartDate = @start, 
            @rptEndDate = @end

    end try
    
    begin catch
    
        --or manually
    
        set @batchid = -1

        --get date range
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

    end catch


    if object_id('[db-au-stage].dbo.etl_factQuoteTransactionTemp') is not null 
        drop table [db-au-stage].dbo.etl_factQuoteTransactionTemp
        
    select
        q.CountryKey,
        q.QuoteKey,
        q.PolicyKey,
        qp.PromoKey as PromotionKey,
        isnull(o.OutletSK,-1) as OutletSK,
        isnull(q.CountryKey,'') + '-' + isnull(q.CompanyKey,'') + '' + convert(varchar,isnull(q.DomainID,0)) + '-' + isnull(q.ProductCode,'') + '-' + isnull(q.ProductName,'') + '-' + isnull(q.ProductDisplayName,'') + '-' + isnull(q.PlanName,'') as ProductKey,
        q.OutletAlphaKey,
        q.QuoteID,
        q.SessionID,
        q.ConsultantName,
        q.UserName,
        q.CreateDate,
        q.CreateTime,
        q.YAGOCreateDate,
        q.UpdateTime,
        q.Area,
        isnull(qc.Age,0) as Age,
        isnull(qc.HasEMC,0) as HasEMC,
        q.Destination,
        q.DepartureDate,
        q.ReturnDate,
        q.isExpo,
        q.isAgentSpecial,
        q.PromoCode,
        q.CANXFlag,
        q.PolicyNo,
        q.NumberOfChildren,
        q.NumberofAdults,
        q.NumberOfPersons as NumberOfTravellers,
        q.Duration,
        q.isSaved,
        q.SaveStep,
        q.AgentReference,
        q.QuoteSaveDate,
        q.StoreCode,
        q.ProductCode,
        q.DomainID,
        q.UserName CRMUserName,
        DerivedConsultantKey,
        q.AgencyCode
    into [db-au-stage].dbo.etl_factQuoteTransactionTemp
    from
        [db-au-cmdwh].dbo.penQuote q
        outer apply
        (
            select top 1    
                qc.Age,
                qc.HasEMC
            from    
                [db-au-cmdwh].dbo.penQuoteCustomer qc
            where
                q.QuoteCountryKey = qc.QuoteCountryKey and
                qc.isPrimary = 1
        ) qc
        outer apply
        (
            select top 1
                qp.PromoKey 
            from
                [db-au-cmdwh].dbo.penQuotePromo qp
            where
                q.PromoCode = qp.PromoCode and
                q.QuoteCountryKey = qp.QuoteCountryKey and
                qp.isApplied = 1
        ) qp
        outer apply
        (
            select top 1
                o.OutletSK,
                o.OutletKey
            from
                [db-au-star].dbo.dimOutlet o
            where
                q.OutletAlphaKey = o.OutletAlphaKey and
                q.CreateDate >= o.ValidStartDate and 
                q.CreateDate <  dateadd(day, 1, o.ValidEndDate)
        ) o
        left join [db-au-cmdwh]..penUser u on
            u.OutletKey = o.OutletKey and
            u.UserStatus = 'Current' and
            u.[Login] = q.UserName
        --outer apply
        --(
        --    select top 1
        --        u.UserKey,
        --        u.UserID
        --    from
        --        [db-au-cmdwh]..penUser u
        --    where
        --        u.OutletKey = o.OutletKey and
        --        u.UserStatus = 'Current' and
        --        u.[Login] = q.UserName
        --) u
        outer apply
        (
            select top 1
                ua.UserKey,
                ua.UserID
            from
                [db-au-cmdwh]..penUserAudit ua
            where
                ua.OutletKey = o.OutletKey and
                ua.[Login] = q.UserName
        ) ua
        outer apply
        (
            select 
                case
                    when u.UserKey is not null then u.UserKey
                    when ua.UserKey is not null then ua.UserKey
                    else q.CountryKey + isnull(q.AgencyCode, '') + isnull(q.UserName, '') 
                end DerivedConsultantKey
        ) dc
    where
    
        /* DISABLING THIS STORED PROCEDURE */
        1 = 0 and
    
        q.CreateDate >= @rptStartDate and 
        q.CreateDate <  dateadd(day, 1, @rptEndDate) and
        q.QuoteKey not like 'AU-CM-%' and        --excludes duplicate quotekey records
        q.QuoteKey not like 'AU-TIP-%'

    --load missing consultant, replacing aggresive load on dimConsultant
    insert [db-au-star]..dimConsultant with(tablock)
    (
        Country,
        ConsultantKey,
        OutletAlphaKey,
        Firstname,
        Lastname,
        ConsultantName,
        UserName,
        ASICNumber,
        AgreementDate,
        [Status],
        InactiveDate,
        RefereeName,
        AccreditationDate,
        DeclaredDate,
        PreviouslyKnownAs,
        YearsOfExperience,
        DateOfBirth,
        ASICCheck,
        Email,
        FirstSellDate,
        LastSellDate,
        LoadDate,
        updateDate,
        LoadID,
        UpdateID,
        HashKey
    )
    select distinct
        CountryKey,
        tt.ConsultantKey,
        tt.OutletAlphaKey,
        tt.FirstName,
        tt.LastName,
        tt.ConsultantName,
        tt.UserName,
        0 ASICNumber,
        null AgreementDate,
        '' [Status],
        null InactiveDate,
        '' RefereeName,
        null AccreditationDate,
        null DeclaredDate,
        '' PreviouslyKnownAs,
        '' YearsOfExperience,
        null DateOfBirth,
        '' ASICCheck,
        '' Email,
        null FirstSellDate,
        null LastSellDate,
        getdate() LoadDate,
        null UpdateDate,
        @batchid LoadID,
        null updateID,
        binary_checksum(
            CountryKey, 
            tt.ConsultantKey,
            tt.OutletAlphaKey,
            tt.FirstName,
            tt.LastName,
            tt.ConsultantName,
            tt.UserName,
            0,
            null,
            '',
            null,
            '',
            null,
            null,
            '',
            '',
            null,
            '',
            '',
            null,
            null
        ) HashKey
    from
        [db-au-stage].dbo.etl_factQuoteTransactionTemp t
        outer apply
        (
            select top 1
                crm.FirstName,
                crm.LastName,
                crm.FirstName + ' ' + crm.LastName ConsultantName
            from
                [db-au-cmdwh]..penCRMUser crm
            where
                crm.UserName = t.CRMUserName
        ) crm
        outer apply
        (
            select
                DerivedConsultantKey ConsultantKey,
                isnull(OutletAlphaKey, CountryKey + isnull(AgencyCode, '')) OutletAlphaKey,
                isnull(crm.FirstName, isnull(CRMUserName, 'UNKNOWN')) FirstName,
                isnull(crm.LastName, isnull(CRMUserName, 'UNKNOWN')) LastName,
                isnull(crm.ConsultantName, isnull(CRMUserName, 'UNKNOWN')) ConsultantName,
                isnull(CRMUserName, '') UserName
        ) tt
    where
        not exists
        (
            select null
            from
                [db-au-star].dbo.dimConsultant con
            where
                con.ConsultantKey = t.DerivedConsultantKey
        ) 

    if object_id('[db-au-stage].dbo.etl_factQuoteTransaction') is not null 
        drop table [db-au-stage].dbo.etl_factQuoteTransaction
        
    select
        dt.Date_SK as DateSK,
        isnull(dom.DomainSK,-1) as DomainSK,
        qts.OutletSK,
        isnull(pol.PolicySK,-1) as PolicySK,
        isnull(con.ConsultantSK,-1) as ConsultantSK,
        isnull(area.AreaSK,-1) as AreaSK,
        isnull(dest.DestinationSK,-1) as DestinationSK,
        isnull(duration.DurationSK,-1) as DurationSK,
        isnull(age.AgeBandSK,-1) as AgeBandSK,
        isnull(promo.PromotionSK,-1) as PromotionSK,
        isnull(product.ProductSK,-1) as ProductSK,
        qts.QuoteID,
        qts.SessionID,
        qts.CreateDate,
        qts.CreateTime,
        qts.DepartureDate,
        qts.ReturnDate,
        case when qts.isExpo = 1 then 'Y' else 'N' end as isExpo,
        case when qts.isAgentSpecial = 1 then 'Y' else 'N' end as isAgentSpecial,
        case when qts.CANXFlag = 1 then 'Y' else 'N' end as isCancellation,
        case when qts.isSaved = 1 then 'Y' else 'N' end as isSaved,
        qts.SaveStep,
        case when qts.hasEMC = 1 then 'Y' else 'N' end as hasEMC,
        qts.AgentReference,
        qts.QuoteSaveDate,
        count(distinct qts.QuoteID) as QuoteCount,
        sum(case when qts.isSaved = 1 then 1 else 0 end) as SavedQuoteCount,
        count(distinct qts.SessionID) as SessionQuoteCount,
        sum(qts.NumberOfChildren) as ChildrenCount,
        sum(qts.NumberOfAdults) as AdultsCount,
        sum(qts.NumberOfTravellers) as TravellersCount
    into [db-au-stage].dbo.etl_factQuoteTransaction
    from
        [db-au-stage].dbo.etl_factQuoteTransactionTemp qts
        outer apply
        (
            select top 1
                dt.Date_SK
            from
                [db-au-star].dbo.Dim_Date dt
            where
                dt.[Date] = convert(date, qts.CreateDate)
        ) dt
        outer apply
        (
            select top 1
                dom.DomainSK
            from
                [db-au-star].dbo.dimDomain dom
            where
                qts.DomainID = dom.DomainID
        ) dom
        outer apply
        (
            select top 1
                pol.PolicySK
            from 
                [db-au-star].dbo.dimPolicy pol
            where
                qts.PolicyKey = pol.PolicyKey
        ) pol
        outer apply
        (
            select top 1
                area.AreaSK
            from
                [db-au-star].dbo.dimArea area
            where
                qts.CountryKey = area.Country and
                qts.Area = area.AreaName
        ) area
        outer apply
        (
            select top 1
                dest.DestinationSK
            from
                [db-au-star].dbo.dimDestination dest
            where
                qts.Destination = dest.Destination
            order by
                dest.DestinationSK desc
        ) dest
        outer apply
        (
            select top 1
                duration.DurationSK
            from
                [db-au-star].dbo.dimDuration duration
            where
                qts.Duration = duration.Duration
        ) duration
        outer apply
        (
            select top 1
                age.AgeBandSK
            from
                [db-au-star].dbo.dimAgeBand age
            where
                qts.Age = age.Age
        ) age
        outer apply
        (
            select top 1
                product.ProductSK
            from
                [db-au-star].dbo.dimProduct product
            where
                qts.CountryKey = product.Country and
                qts.ProductKey = product.ProductKey
        ) product
        outer apply
        (
            select top 1
                promo.PromotionSK
            from
                [db-au-star].dbo.dimPromotion promo
            where
                qts.PromotionKey = promo.PromotionKey
        ) promo
        outer apply
        (
            select top 1
                con.ConsultantSK
            from
                [db-au-star].dbo.dimConsultant con
            where
                con.ConsultantKey = qts.DerivedConsultantKey
        ) con
    group by
        dt.Date_SK,
        isnull(dom.DomainSK,-1),
        qts.OutletSK,
        isnull(pol.PolicySK,-1),
        isnull(con.ConsultantSK,-1),
        isnull(area.AreaSK,-1),
        isnull(dest.DestinationSK,-1),
        isnull(duration.DurationSK,-1),
        isnull(age.AgeBandSK,-1),
        isnull(promo.PromotionSK,-1),
        isnull(product.ProductSK,-1),
        qts.QuoteID,
        qts.SessionID,
        qts.CreateDate,
        qts.CreateTime,
        qts.DepartureDate,
        qts.ReturnDate,
        case when qts.isExpo = 1 then 'Y' else 'N' end,
        case when qts.isAgentSpecial = 1 then 'Y' else 'N' end,
        case when qts.CANXFlag = 1 then 'Y' else 'N' end,
        case when qts.isSaved = 1 then 'Y' else 'N' end,
        qts.SaveStep,
        case when qts.hasEMC = 1 then 'Y' else 'N' end,
        qts.AgentReference,
        qts.QuoteSaveDate



    --create factQuoteTransaction if table does not exist
    if object_id('[db-au-star].dbo.factQuoteTransaction') is null
    begin
    
        create table [db-au-star].dbo.factQuoteTransaction
        (
            BIRowID bigint not null identity(1,1),
            DateSK int not null,
            DomainSK int not null,
            OutletSK int not null,
            PolicySK int not null,
            ConsultantSK int not null,
            AreaSK int not null,
            DestinationSK int not null,
            DurationSK int not null,
            AgeBandSK int not null,
            PromotionSK int not null,
            ProductSK int not null,
            QuoteID int null,
            SessionID varchar(255) not null,
            CreateDate datetime null,
            CreateTime datetime null,
            DepartureDate datetime null,
            ReturnDate datetime null,
            isExpo varchar(1) not null,
            isAgentSpecial varchar(1) not null,
            isCancellation varchar(1) not null,
            isSaved varchar(1) not null,
            SaveStep int null,
            QuoteSaveDate datetime null,
            hasEMC varchar(1) not null,
            AgentReference varchar(100) null,
            QuoteCount int null,
            SavedQuoteCount int null,
            SessionQuoteCount int null,
            ChildrenCount int null,
            AdultsCount int null,
            TravellersCount int null,
            LoadDate datetime not null,
            LoadID int not null,
            updateDate datetime null,
            updateID int null
        )
        
        create clustered index idx_factQuoteTransaction_BIRowID on [db-au-star].dbo.factQuoteTransaction(BIRowID)
        create nonclustered index idx_factQuoteTransaction_DateSK on [db-au-star].dbo.factQuoteTransaction(DateSK) include(DomainSK)
        create nonclustered index idx_factQuoteTransaction_DomainSK on [db-au-star].dbo.factQuoteTransaction(DomainSK)
        create nonclustered index idx_factQuoteTransaction_OutletSK on [db-au-star].dbo.factQuoteTransaction(OutletSK)
        create nonclustered index idx_factQuoteTransaction_PolicySK on [db-au-star].dbo.factQuoteTransaction(PolicySK)
        create nonclustered index idx_factQuoteTransaction_ConsultantSK on [db-au-star].dbo.factQuoteTransaction(ConsultantSK)
        create nonclustered index idx_factQuoteTransaction_AreaSK on [db-au-star].dbo.factQuoteTransaction(AreaSK)
        create nonclustered index idx_factQuoteTransaction_DestinationSK on [db-au-star].dbo.factQuoteTransaction(DestinationSK)
        create nonclustered index idx_factQuoteTransaction_DurationSK on [db-au-star].dbo.factQuoteTransaction(DurationSK)
        create nonclustered index idx_factQuoteTransaction_AgeBandSK on [db-au-star].dbo.factQuoteTransaction(AgeBandSK)
        create nonclustered index idx_factQuoteTransaction_PromotionSK on [db-au-star].dbo.factQuoteTransaction(PromotionSK)
        create nonclustered index idx_factQuoteTransaction_CreateDate on [db-au-star].dbo.factQuoteTransaction(CreateDate)
        create nonclustered index idx_factQuoteTransaction_ProductSK on [db-au-star].dbo.factQuoteTransaction(ProductSK)
        
    end
    
    
    
    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_factQuoteTransaction

    begin transaction
    begin try
    
        --delete [db-au-star].dbo.factQuoteTransaction
        --from
        --    [db-au-star].dbo.factQuoteTransaction b
        --    inner join [db-au-stage].dbo.etl_factQuoteTransaction a on
        --        b.DateSK = a.DateSK and
        --        b.DomainSK = a.DomainSK


        --insert into [db-au-star].dbo.factQuoteTransaction with (tablockx)
        --(
        --    DateSK,
        --    DomainSK,
        --    OutletSK,
        --    PolicySK,
        --    ConsultantSK,
        --    AreaSK,
        --    DestinationSK,
        --    DurationSK,
        --    AgeBandSK,
        --    PromotionSK,
        --    ProductSK,
        --    QuoteID,
        --    SessionID,
        --    CreateDate,
        --    CreateTime,
        --    DepartureDate,
        --    ReturnDate,
        --    isExpo,
        --    isAgentSpecial,
        --    isCancellation,
        --    isSaved,
        --    SaveStep,
        --    QuoteSaveDate,
        --    hasEMC,
        --    AgentReference,
        --    QuoteCount,
        --    SavedQuoteCount,
        --    SessionQuoteCount,
        --    ChildrenCount,
        --    AdultsCount,
        --    TravellersCount,
        --    LoadDate,
        --    LoadID,
        --    updateDate,
        --    updateID
        --)
        --select
        --    DateSK,
        --    DomainSK,
        --    OutletSK,
        --    PolicySK,
        --    ConsultantSK,
        --    AreaSK,
        --    DestinationSK,
        --    DurationSK,
        --    AgeBandSK,
        --    PromotionSK,
        --    ProductSK,
        --    QuoteID,
        --    SessionID,
        --    CreateDate,
        --    CreateTime,
        --    DepartureDate,
        --    ReturnDate,
        --    isExpo,
        --    isAgentSpecial,
        --    isCancellation,
        --    isSaved,
        --    SaveStep,
        --    QuoteSaveDate,
        --    hasEMC,
        --    AgentReference,
        --    QuoteCount,
        --    SavedQuoteCount,
        --    SessionQuoteCount,
        --    ChildrenCount,
        --    AdultsCount,
        --    TravellersCount,
        --    getdate() as LoadDate,
        --    @batchid as LoadID,
        --    null as updateDate,
        --    null as updateID
        --from
        --    [db-au-stage].dbo.etl_factQuoteTransaction
                
        if @batchid <> - 1
            exec syssp_genericerrorhandler
                @LogToTable = 1,
                @ErrorCode = '0',
                @BatchID = @batchid,
                @PackageID = @name,
                @LogStatus = 'Finished',
                @LogSourceCount = @sourcecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        if @batchid <> - 1
            exec syssp_genericerrorhandler
                @SourceInfo = 'data refresh failed',
                @LogToTable = 1,
                @ErrorCode = '-100',
                @BatchID = @batchid,
                @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
