USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_quote_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_quote_rollup]
as
begin

/************************************************************************************************************************************
Author:         Leonardus Setyabudi
Date:
Prerequisite:   Requires Penguin Data Model ETL successfully run.
Description:
Change History:
                20130204 - LS - Case 18219, change QuoteEMC.QuoteID reference
                20130405 - LS - Case 18429 bug fix, set Country reference based on domain id
                20130408 - LS - Case 18440, bug fix on Trip Duration (Trip Dates are left in UTC format)
                20130409 - LS - bug fix, regression on Case 18440, missing '-' from AgencyKey
                20130617 - LS - TFS 7664/8556/8557, UK Penguin

*************************************************************************************************************************************/

    set nocount on

    /* quote customer -------------------------------------------------------------------------------------------------- */
    if object_id('etl_QuoteCustomer') is null
    begin

        create table etl_QuoteCustomer
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteCountryKey varchar(41) null,
            QuoteID  int not null,
            CustomerID int not null,
            QuoteCustomerID int null,
            Title varchar(50) null,
            FirstName varchar(100) null,
            LastName varchar(100) null,
            DOB datetime null,
            AddressStreet varchar(200) null,
            AddressPostCode varchar(50) null,
            AddressSuburb varchar(50) null,
            AddressState varchar(50) null,
            AddressCountry varchar(50) null,
            HomePhone varchar(50) null,
            WorkPhone varchar(50) null,
            MobilePhone varchar(50) null,
            EmailAddress varchar(255) null,
            Age int null,
            IsPrimary bit null,
            PersonIsAdult bit null,
            HasEMC bit null,
            OptFurtherContact bit null,
            MemberNumber varchar(25) null
        )

        create clustered index idx_etlQuoteCustomer_QuoteCountryKey on etl_QuoteCustomer(QuoteCountryKey)

    end
    else
        truncate table etl_QuoteCustomer

    insert etl_QuoteCustomer
    (
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        MemberNumber,
        QuoteCustomerID,
        Title,
        FirstName,
        LastName,
        DOB,
        AddressStreet,
        AddressPostCode,
        AddressSuburb,
        AddressState,
        AddressCountry,
        HomePhone,
        WorkPhone,
        MobilePhone,
        EmailAddress,
        Age,
        IsPrimary,
        PersonIsAdult,
        HasEMC,
        OptFurtherContact
    )
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qc.QuoteID),35) as QuoteCountryKey,
        qc.QuoteID,
        qc.CustomerID,
        c.MemberNumber,
        qc.QuoteCustomerID,
        c.Title,
        c.FirstName,
        c.LastName,
        c.DOB,
        c.AddressLine1 +
        case
            when ltrim(isnull(c.AddressLine2, '')) <> '' then ' ' + c.AddressLine2
            else ''
        end AddressStreet,
        c.PostCode,
        c.Town Suburb,
        c.State,
        c.Country,
        c.HomePhone,
        c.WorkPhone,
        c.MobilePhone,
        c.EmailAddress,
        qc.Age,
        qc.IsPrimary,
        qc.IsAdult,
        qc.HasEMC,
        c.OptFurtherContact
    from
        penguin_tblquotecustomer_aucm qc
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'AU') dk
        left join penguin_tblCustomer_aucm c on
            c.CustomerID = qc.CustomerID

    union all

    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qc.QuoteID),35) as QuoteCountryKey,
        qc.QuoteID,
        qc.CustomerID,
        c.MemberNumber,
        qc.QuoteCustomerID,
        c.Title,
        c.FirstName,
        c.LastName,
        c.DOB,
        c.AddressLine1 +
        case
            when ltrim(isnull(c.AddressLine2, '')) <> '' then ' ' + c.AddressLine2
            else ''
        end AddressStreet,
        c.PostCode,
        c.Town Suburb,
        c.State,
        c.Country,
        c.HomePhone,
        c.WorkPhone,
        c.MobilePhone,
        c.EmailAddress,
        qc.Age,
        qc.IsPrimary,
        qc.IsAdult,
        qc.HasEMC,
        c.OptFurtherContact
    from
        penguin_tblquotecustomer_autp qc
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'TIP', 'AU') dk
        left join penguin_tblCustomer_autp c on
            c.CustomerID = qc.CustomerID
        /* do not roll up pre TIP2 live date, all TIP1 quotes had been moved to TIP2 server and this will cause duplicates due to different Company keys to current rolled up record */
        inner join penguin_tblQuote_autp q on
            q.QuoteID = qc.QuoteID and
            q.QuoteDate >= '2012-03-01'

    union all
    
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qc.QuoteID),35) as QuoteCountryKey,
        qc.QuoteID,
        qc.CustomerID,
        c.MemberNumber,
        qc.QuoteCustomerID,
        c.Title,
        c.FirstName,
        c.LastName,
        c.DOB,
        c.AddressLine1 +
        case
            when ltrim(isnull(c.AddressLine2, '')) <> '' then ' ' + c.AddressLine2
            else ''
        end AddressStreet,
        c.PostCode,
        c.Town Suburb,
        c.State,
        c.Country,
        c.HomePhone,
        c.WorkPhone,
        c.MobilePhone,
        c.EmailAddress,
        qc.Age,
        qc.IsPrimary,
        qc.IsAdult,
        qc.HasEMC,
        c.OptFurtherContact
    from
        penguin_tblquotecustomer_ukcm qc
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'UK') dk
        left join penguin_tblCustomer_ukcm c on
            c.CustomerID = qc.CustomerID
    
    /* delete existing quotecustomer */
    if object_id('[db-au-cmdwh].dbo.QuoteCustomer') is null
    begin

        create table [db-au-cmdwh].dbo.QuoteCustomer
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteCountryKey varchar(30) null,
            QuoteID  int not null,
            CustomerID int not null,
            QuoteCustomerID int null,
            Title varchar(50) null,
            FirstName varchar(100) null,
            LastName varchar(100) null,
            DOB datetime null,
            AddressStreet varchar(200) null,
            AddressPostCode varchar(50) null,
            AddressSuburb varchar(50) null,
            AddressState varchar(50) null,
            AddressCountry varchar(50) null,
            HomePhone varchar(50) null,
            WorkPhone varchar(50) null,
            MobilePhone varchar(50) null,
            EmailAddress varchar(255) null,
            Age int null,
            IsPrimary bit null,
            PersonIsAdult bit null,
            HasEMC bit null,
            OptFurtherContact bit null,
            MemberNumber varchar(25) null
        )

        create clustered index idx_QuoteCustomer_QuoteCountryKey on [db-au-cmdwh].dbo.QuoteCustomer(QuoteCountryKey)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.QuoteCustomer
        where
            QuoteCountryKey in
            (
                select QuoteCountryKey
                from etl_QuoteCustomer
            )

    end

    /* load quotecustomer */
    insert into [db-au-cmdwh].dbo.QuoteCustomer with (tablock)
    (
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        MemberNumber,
        QuoteCustomerID,
        Title,
        FirstName,
        LastName,
        DOB,
        AddressStreet,
        AddressPostCode,
        AddressSuburb,
        AddressState,
        AddressCountry,
        HomePhone,
        WorkPhone,
        MobilePhone,
        EmailAddress,
        Age,
        IsPrimary,
        PersonIsAdult,
        HasEMC,
        OptFurtherContact
    )
    select
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        MemberNumber,
        QuoteCustomerID,
        Title,
        FirstName,
        LastName,
        DOB,
        AddressStreet,
        AddressPostCode,
        AddressSuburb,
        AddressState,
        AddressCountry,
        HomePhone,
        WorkPhone,
        MobilePhone,
        EmailAddress,
        Age,
        IsPrimary,
        PersonIsAdult,
        HasEMC,
        OptFurtherContact
    from
        etl_QuoteCustomer



    /* quote -------------------------------------------------------------------------------------------------- */
    if object_id('etl_Quote') is null
    begin

        create table etl_Quote
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteKey varchar(30) null,
            QuoteCountryKey varchar(30) null,
            PolicyKey varchar(41) null,
            AgencySKey bigint null,
            AgencyKey varchar(10) null,
            QuoteID  int,
            SessionID varchar(255) not null,
            AgencyCode varchar(7) null,
            StoreCode varchar(10) null,
            ConsultantName varchar(50) null,
            UserName varchar(50) null,
            CreateDate datetime null,
            CreateTime datetime null,
            Area varchar(50) null,
            Destination  varchar(100) null,
            DepartureDate datetime null,
            ReturnDate datetime null,
            IsExpo bit null,
            IsAgentSpecial bit null,
            PromoCode varchar(60) null,
            CanxFlag bit null,
            PolicyNo int null,
            NumberOfChildren int null,
            NumberOfAdults int null,
            NumberOfPersons int null,
            Duration int null,
            IsSaved bit null,
            SaveStep int null,
            AgentReference varchar(100) null,
            UpdateTime datetime null,
            QuotedPrice numeric(10, 4) null
        )

        create clustered index idx_etlQuote_QuoteID on etl_Quote(QuoteID)

    end
    else
        truncate table etl_Quote

    insert etl_Quote
    (
        CountryKey,
        CompanyKey,
        QuoteKey,
        QuoteCountryKey,
        PolicyKey,
        AgencySKey,
        AgencyKey,
        QuoteID,
        SessionID,
        AgencyCode,
        StoreCode,
        ConsultantName,
        UserName,
        CreateDate,
        CreateTime,
        Area,
        Destination,
        DepartureDate,
        ReturnDate,
        IsExpo,
        IsAgentSpecial,
        PromoCode,
        CanxFlag,
        PolicyNo,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        Duration,
        IsSaved,
        SaveStep,
        AgentReference,
        UpdateTime,
        QuotedPrice
    )
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + ltrim(rtrim(left(q.AlphaCode, 7))) collate database_default + '-' + convert(varchar, q.QuoteID), 30) as QuoteKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) as QuoteCountryKey,
        left(dk.CountryKey + ltrim(rtrim(left(q.AlphaCode, 7))) collate database_default + '-' + convert(varchar, p.PolicyNumber), 41) as PolicyKey,
        null as AgencySKey,
        dk.CountryKey + '-' + ltrim(rtrim(left(q.AlphaCode, 7))) as AgencyKey,
        q.QuoteID,
        q.UniqueCustomerID as SessionID,
        q.AlphaCode as AgencyCode,
        q.StoreCode,
        cn.ConsultantName,
        q.ConsultantUserName as UserName,
        convert(varchar(10), q.QuoteDate, 120) as CreateDate,
        q.QuoteDate as CreateTime,
        q.Area,
        q.PrimaryCountry as Destination,
        q.TripStart as DepartureDate,
        q.TripEnd as ReturnDate,
        q.IsExpo,
        q.IsAgentSpecial,
        q.PromoCode,
        q.IsCancellation as CanxFlag,
        p.PolicyNumber as PolicyNo,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) and
                qc.PersonIsAdult = 0
        )  as NumberOfChildren,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) and
                qc.PersonIsAdult = 1
        ) as NumberOfAdults,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30)
        ) as NumberOfPersons,
        datediff(day, q.tripstart, q.tripend) + 1 as Duration,
        case
            when qs.QuoteID is null then 0
            else 1
        end IsSaved,
        qs.SaveStep,
        qs.AgentReference,
        qs.UpdateDateTime,
        isnull(p.QuotedPrice, qp.QuotedPrice) QuotedPrice
    from
        penguin_tblquote_aucm q
        cross apply dbo.fn_GetDomainKeys(q.DomainID, 'CM', 'AU') dk
        left join [db-au-cmdwh].dbo.Consultant cn on
            cn.AgencyCode collate database_default = q.AlphaCode collate database_default and
            cn.UserName collate database_default = q.ConsultantUserName collate database_default
        outer apply
        (
            select top 1
                p.PolicyNumber,
                qp.GrossPremium QuotedPrice
            from
                penguin_tblQuotePlan_aucm qp
                inner join penguin_tblPolicy_aucm p on
                    p.QuotePlanID = qp.QuotePlanID
            where
                qp.QuoteID = q.QuoteID
        ) p
        left join penguin_tblquotesave_aucm qs on
            qs.QuoteID = q.QuoteID
        outer apply
        (
            select top 1
                qp.GrossPremium QuotedPrice
            from
                penguin_tblQuotePlan_aucm qp
            where
                qp.QuoteID = q.QuoteID and
                qp.GrossPremium is not null
        ) qp

    union all

    select
        'AU' as CountryKey,
        'TIP' as CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + ltrim(rtrim(left(q.AlphaCode, 7))) collate database_default + '-' + convert(varchar, q.QuoteID), 30) as QuoteKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) as QuoteCountryKey,
        left(dk.CountryKey + ltrim(rtrim(left(q.AlphaCode, 7))) collate database_default + '-' + convert(varchar, p.PolicyNumber), 41) as PolicyKey,
        null as AgencySKey,
        dk.CountryKey + '-' + ltrim(rtrim(left(q.AlphaCode, 7))) as AgencyKey,
        q.QuoteID,
        q.UniqueCustomerID as SessionID,
        q.AlphaCode as AgencyCode,
        q.StoreCode,
        cn.ConsultantName,
        q.ConsultantUserName as UserName,
        convert(varchar(10), q.QuoteDate, 120) as CreateDate,
        q.QuoteDate as CreateTime,
        q.Area,
        q.PrimaryCountry as Destination,
        q.TripStart as DepartureDate,
        q.TripEnd as ReturnDate,
        q.IsExpo,
        q.IsAgentSpecial,
        q.PromoCode,
        q.IsCancellation as CanxFlag,
        p.PolicyNumber as PolicyNo,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) and
                qc.PersonIsAdult = 0
        )  as NumberOfChildren,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) and
                qc.PersonIsAdult = 1
        ) as NumberOfAdults,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30)
        ) as NumberOfPersons,
        datediff(day, q.tripstart, q.tripend) + 1 as Duration,
        case
            when qs.QuoteID is null then 0
            else 1
        end IsSaved,
        qs.SaveStep,
        qs.AgentReference,
        qs.UpdateDateTime,
        isnull(p.QuotedPrice, qp.QuotedPrice) QuotedPrice
    from
        penguin_tblquote_autp q
        cross apply dbo.fn_GetDomainKeys(q.DomainID, 'TIP', 'AU') dk
        left join [db-au-cmdwh].dbo.Consultant cn on
            cn.AgencyCode collate database_default = q.AlphaCode collate database_default and
            cn.UserName collate database_default = q.ConsultantUserName collate database_default
        outer apply
        (
            select top 1
                p.PolicyNumber,
                qp.GrossPremium QuotedPrice
            from
                penguin_tblQuotePlan_autp qp
                inner join penguin_tblPolicy_autp p on
                    p.QuotePlanID = qp.QuotePlanID
            where
                qp.QuoteID = q.QuoteID
        ) p
        left join penguin_tblquotesave_autp qs on
            qs.QuoteID = q.QuoteID
        outer apply
        (
            select top 1
                qp.GrossPremium QuotedPrice
            from
                penguin_tblQuotePlan_autp qp
            where
                qp.QuoteID = q.QuoteID and
                qp.GrossPremium is not null
        ) qp
    /* do not roll up pre TIP2 live date, all TIP1 quotes had been moved to TIP2 server and this will cause duplicates due to different Company keys to current rolled up record */
    where
        q.QuoteDate >= '2012-03-01'

    union all
    
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + ltrim(rtrim(left(q.AlphaCode, 7))) collate database_default + '-' + convert(varchar, q.QuoteID), 30) as QuoteKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) as QuoteCountryKey,
        left(dk.CountryKey + ltrim(rtrim(left(q.AlphaCode, 7))) collate database_default + '-' + convert(varchar, p.PolicyNumber), 41) as PolicyKey,
        null as AgencySKey,
        dk.CountryKey + '-' + ltrim(rtrim(left(q.AlphaCode, 7))) as AgencyKey,
        q.QuoteID,
        q.UniqueCustomerID as SessionID,
        q.AlphaCode as AgencyCode,
        q.StoreCode,
        cn.ConsultantName,
        q.ConsultantUserName as UserName,
        convert(varchar(10), q.QuoteDate, 120) as CreateDate,
        q.QuoteDate as CreateTime,
        q.Area,
        q.PrimaryCountry as Destination,
        q.TripStart as DepartureDate,
        q.TripEnd as ReturnDate,
        q.IsExpo,
        q.IsAgentSpecial,
        q.PromoCode,
        q.IsCancellation as CanxFlag,
        p.PolicyNumber as PolicyNo,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) and
                qc.PersonIsAdult = 0
        )  as NumberOfChildren,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30) and
                qc.PersonIsAdult = 1
        ) as NumberOfAdults,
        (
            select
                count(qc.CustomerID)
            from
                [db-au-cmdwh].dbo.QuoteCustomer qc
            where
                qc.QuoteCountryKey = left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, q.QuoteID), 30)
        ) as NumberOfPersons,
        datediff(day, q.tripstart, q.tripend) + 1 as Duration,
        case
            when qs.QuoteID is null then 0
            else 1
        end IsSaved,
        qs.SaveStep,
        qs.AgentReference,
        qs.UpdateDateTime,
        isnull(p.QuotedPrice, qp.QuotedPrice) QuotedPrice
    from
        penguin_tblquote_ukcm q
        cross apply dbo.fn_GetDomainKeys(q.DomainID, 'CM', 'UK') dk
        left join [db-au-cmdwh].dbo.Consultant cn on
            cn.AgencyCode collate database_default = q.AlphaCode collate database_default and
            cn.UserName collate database_default = q.ConsultantUserName collate database_default
        outer apply
        (
            select top 1
                p.PolicyNumber,
                qp.GrossPremium QuotedPrice
            from
                penguin_tblQuotePlan_ukcm qp
                inner join penguin_tblPolicy_ukcm p on
                    p.QuotePlanID = qp.QuotePlanID
            where
                qp.QuoteID = q.QuoteID
        ) p
        left join penguin_tblquotesave_ukcm qs on
            qs.QuoteID = q.QuoteID
        outer apply
        (
            select top 1
                qp.GrossPremium QuotedPrice
            from
                penguin_tblQuotePlan_ukcm qp
            where
                qp.QuoteID = q.QuoteID and
                qp.GrossPremium is not null
        ) qp
    

    /* update AgencySKey in etl_Quote records for current agencies */
    update etl_Quote
    set AgencySKey = a.AgencySKey
    from
        etl_Quote q
        inner join [db-au-cmdwh].dbo.Agency a on
            q.AgencyKey collate database_default = a.AgencyKey collate database_default and
            a.AgencyStatus = 'Current'

    /* update AgencySKey in etl_Quote records for non current agencies */
    update etl_Quote
    set AgencySKey = a.AgencySKey
    from
        etl_Quote q
        inner join [db-au-cmdwh].dbo.Agency a on
            q.AgencyKey collate database_default = a.AgencyKey collate database_default and
            a.AgencyStatus = 'Not Current' and
            q.CreateDate between a.AgencyStartDate and a.AgencyEndDate


    /* delete existing quote */
    if object_id('[db-au-cmdwh].dbo.Quote') is null
    begin

        create table [db-au-cmdwh].dbo.Quote
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteKey varchar(30) null,
            QuoteCountryKey varchar(30) null,
            PolicyKey varchar(41) null,
            AgencySKey bigint null,
            AgencyKey varchar(10) null,
            QuoteID  int,
            SessionID varchar(255) not null,
            AgencyCode varchar(7) null,
            StoreCode varchar(10) null,
            ConsultantName varchar(50) null,
            UserName varchar(50) null,
            CreateDate datetime null,
            CreateTime datetime null,
            Area varchar(50) null,
            Destination  varchar(100) null,
            DepartureDate datetime null,
            ReturnDate datetime null,
            IsExpo bit null,
            IsAgentSpecial bit null,
            PromoCode varchar(60) null,
            CanxFlag bit null,
            PolicyNo int null,
            NumberOfChildren int null,
            NumberOfAdults int null,
            NumberOfPersons int null,
            Duration int null,
            IsSaved bit null,
            SaveStep int null,
            AgentReference varchar(100) null,
            UpdateTime datetime null,
            QuotedPrice numeric(10, 4) null,
            YAGOCreateDate datetime null
        )

        create clustered index idx_Quote_CreateDate on [db-au-cmdwh].dbo.Quote(CreateDate)
        create index idx_Quote_QuoteID on [db-au-cmdwh].dbo.Quote(QuoteID)
        create index idx_Quote_AgencyKey on [db-au-cmdwh].dbo.Quote(AgencyKey)
        create index idx_Quote_PolicyKey on [db-au-cmdwh].dbo.Quote(PolicyKey)
        create index idx_Quote_YAGOCreateDate on [db-au-cmdwh].dbo.Quote(YAGOCreateDate)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.Quote
        from
            [db-au-cmdwh].dbo.Quote q
            inner join etl_Quote eq on
                eq.CountryKey collate database_default = q.CountryKey collate database_default and
                eq.QuoteID = q.QuoteID

    end


    /* load quote */
    insert into [db-au-cmdwh].dbo.Quote with (tablock)
    (
        CountryKey,
        CompanyKey,
        QuoteKey,
        QuoteCountryKey,
        PolicyKey,
        AgencySKey,
        AgencyKey,
        QuoteID,
        SessionID,
        AgencyCode,
        StoreCode,
        ConsultantName,
        UserName,
        CreateDate,
        YAGOCreateDate,
        CreateTime,
        Area,
        Destination,
        DepartureDate,
        ReturnDate,
        IsExpo,
        IsAgentSpecial,
        PromoCode,
        CanxFlag,
        PolicyNo,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        Duration,
        IsSaved,
        SaveStep,
        AgentReference,
        UpdateTime,
        QuotedPrice
    )
    select
        CountryKey,
        CompanyKey,
        QuoteKey,
        QuoteCountryKey,
        PolicyKey,
        AgencySKey,
        AgencyKey,
        QuoteID,
        SessionID,
        AgencyCode,
        StoreCode,
        ConsultantName,
        UserName,
        CreateDate,
        dateadd(year, 1, CreateDate) YAGOCreateDate,
        CreateTime,
        Area,
        Destination,
        DepartureDate,
        ReturnDate,
        IsExpo,
        IsAgentSpecial,
        PromoCode,
        CanxFlag,
        PolicyNo,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        Duration,
        IsSaved,
        SaveStep,
        AgentReference,
        UpdateTime,
        QuotedPrice
    from
        etl_Quote




    /* quote emc -------------------------------------------------------------------------------------------------- */
    if object_id('etl_QuoteEMC') is null
    begin

        create table etl_QuoteEMC
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteCountryKey varchar(30) null,
            QuoteID  int not null,
            CustomerID int not null,
            EMCScore numeric(10,4) null,
            PremiumIncrease numeric(10,4) null,
            IsPercentage bit null,
            EMCID int null,
            Condition varchar(50) null,
            DeniedAccepted varchar(1) null
        )

    end
    else
        truncate table etl_QuoteEMC

    insert etl_QuoteEMC
    (
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        EMCScore,
        PremiumIncrease,
        IsPercentage,
        EMCID,
        Condition,
        DeniedAccepted
    )
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qp.QuoteID), 30) as QuoteCountryKey,
        qp.QuoteID,
        qc.CustomerID,
        qe.EMCScore,
        qe.PremiumIncrease,
        qe.IsPercentage,
        case
            when qe.EMCRef = 'Not Applicable' then null
            else convert(int, qe.EMCRef)
        end EMCID,
        e.Condition,
        e.StatusCode
    from
        penguin_tblquoteemc_aucm qe
        inner join penguin_tblQuoteCustomer_aucm qc on
            qc.QuoteCustomerID = qe.QuoteCustomerID
        inner join penguin_tblQuotePlan_aucm qp on
            qp.QuotePlanID = qe.QuotePlanID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'AU') dk
        left join [db-au-cmdwh].dbo.EMCApproval e on
            e.PolicyEMCID =
                case
                    when qe.EMCRef = 'Not Applicable' then null
                    else convert(int, qe.EMCRef)
                end

    union all

    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qp.QuoteID), 30) as QuoteCountryKey,
        qp.QuoteID,
        qc.CustomerID,
        qe.EMCScore,
        qe.PremiumIncrease,
        qe.IsPercentage,
        case
            when qe.EMCRef = 'Not Applicable' then null
            else convert(int, qe.EMCRef)
        end EMCID,
        e.Condition,
        e.StatusCode
        from
            penguin_tblquoteemc_autp qe
            inner join penguin_tblQuoteCustomer_autp qc on
                qc.QuoteCustomerID = qe.QuoteCustomerID
            inner join penguin_tblQuotePlan_autp qp on
                qp.QuotePlanID = qe.QuotePlanID
            cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'TIP', 'AU') dk
            left join [db-au-cmdwh].dbo.EMCApproval e on
                e.PolicyEMCID =
                    case
                        when qe.EMCRef = 'Not Applicable' then null
                        else convert(int, qe.EMCRef)
                    end
            /* do not roll up pre TIP2 live date, all TIP1 quotes had been moved to TIP2 server and this will cause duplicates due to different Company keys to current rolled up record */
            inner join penguin_tblQuote_autp q on
                q.QuoteID = qc.QuoteID and
                q.QuoteDate >= '2012-03-01'

    union all
    
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qp.QuoteID), 30) as QuoteCountryKey,
        qp.QuoteID,
        qc.CustomerID,
        qe.EMCScore,
        qe.PremiumIncrease,
        qe.IsPercentage,
        case
            when qe.EMCRef = 'Not Applicable' then null
            else convert(int, qe.EMCRef)
        end EMCID,
        e.Condition,
        e.StatusCode
    from
        penguin_tblquoteemc_ukcm qe
        inner join penguin_tblQuoteCustomer_ukcm qc on
            qc.QuoteCustomerID = qe.QuoteCustomerID
        inner join penguin_tblQuotePlan_ukcm qp on
            qp.QuotePlanID = qe.QuotePlanID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'UK') dk
        left join [db-au-cmdwh].dbo.EMCApproval e on
            e.PolicyEMCID =
                case
                    when qe.EMCRef = 'Not Applicable' then null
                    else convert(int, qe.EMCRef)
                end
    
    /* delete existing QuoteEMC */
    if object_id('[db-au-cmdwh].dbo.QuoteEMC') is null
    begin

        create table [db-au-cmdwh].dbo.QuoteEMC
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteCountryKey varchar(30) null,
            QuoteID  int not null,
            CustomerID int not null,
            EMCScore numeric(10,4) null,
            PremiumIncrease numeric(10,4) null,
            IsPercentage bit null,
            EMCID int null,
            Condition varchar(50) null,
            DeniedAccepted varchar(1) null
        )

        create clustered index idx_QuoteEMC_QuoteCountryKey on [db-au-cmdwh].dbo.QuoteEMC(QuoteCountryKey)
        create index idx_QuoteEMC_EMCID on [db-au-cmdwh].dbo.QuoteEMC(EMCID)
        create index idx_QuoteEMC_CustomerID on [db-au-cmdwh].dbo.QuoteEMC(CustomerID)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.QuoteEMC
        where QuoteCountryKey in
            (
                select QuoteCountryKey
                from
                    etl_QuoteEMC
            )

    end

    /* load QuoteEMC */
    insert into [db-au-cmdwh].dbo.QuoteEMC with (tablock)
    (
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        EMCScore,
        PremiumIncrease,
        IsPercentage,
        EMCID,
        Condition,
        DeniedAccepted
    )
    select
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        EMCScore,
        PremiumIncrease,
        IsPercentage,
        EMCID,
        Condition,
        DeniedAccepted
    from
        etl_QuoteEMC



    /* quote AddOn -------------------------------------------------------------------------------------------------- */
    if object_id('etl_QuoteAddOn') is null
    begin

        create table etl_QuoteAddOn
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteCountryKey varchar(41) null,
            QuoteID  int not null,
            CustomerID int not null,
            QuoteAddOnID int not null,
            AddOnName varchar(50) null,
            AddOnGroup varchar(50) null,
            AddOnItem varchar(500) null,
            PremiumIncrease numeric(10,4) null,
            CoverIncrease numeric(10,4) null,
            CoverIsPercentage bit null,
            IsRateCardBased bit null,
            IsActive bit null
        )

    end
    else
        truncate table etl_QuoteAddOn

    insert etl_QuoteAddOn
    (
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        QuoteAddOnID,
        AddOnName,
        AddOnGroup,
        AddOnItem,
        PremiumIncrease,
        CoverIncrease,
        CoverIsPercentage,
        IsRateCardBased,
        IsActive
    )
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qc.QuoteID),35) as QuoteCountryKey,
        qc.QuoteID,
        qc.CustomerID,
        qa.ID,
        qa.AddOnName,
        qa.AddOnGroup,
        qa.ValueText AddOnItem,
        qa.PremiumIncrease,
        qa.CoverIncrease,
        qa.IsPercentage CoverIsPercentage,
        qa.IsRateCardBased,
        qa.Active IsActive
    from
        penguin_tblquoteAddOn_aucm qa
        inner join penguin_tblQuoteCustomer_aucm qc on
            qc.QuoteCustomerID = qa.QuoteCustomerID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'AU') dk

    union all

    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qc.QuoteID),35) as QuoteCountryKey,
        qc.QuoteID,
        qc.CustomerID,
        qa.ID,
        qa.AddOnName,
        qa.AddOnGroup,
        qa.ValueText AddOnItem,
        qa.PremiumIncrease,
        qa.CoverIncrease,
        qa.IsPercentage CoverIsPercentage,
        qa.IsRateCardBased,
        qa.Active IsActive
    from
        penguin_tblquoteAddOn_autp qa
        inner join penguin_tblQuoteCustomer_autp qc on
            qc.QuoteCustomerID = qa.QuoteCustomerID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'TIP', 'AU') dk
        /* do not roll up pre TIP2 live date, all TIP1 quotes had been moved to TIP2 server and this will cause duplicates due to different Company keys to current rolled up record */
        inner join penguin_tblQuote_autp q on
            q.QuoteID = qc.QuoteID and
            q.QuoteDate >= '2012-03-01'

    union all
    
    select
        dk.CountryKey,
        dk.CompanyKey,
        left(dk.CountryKey + '-' + dk.CompanyKey + '-' + convert(varchar, qc.QuoteID),35) as QuoteCountryKey,
        qc.QuoteID,
        qc.CustomerID,
        qa.ID,
        qa.AddOnName,
        qa.AddOnGroup,
        qa.ValueText AddOnItem,
        qa.PremiumIncrease,
        qa.CoverIncrease,
        qa.IsPercentage CoverIsPercentage,
        qa.IsRateCardBased,
        qa.Active IsActive
    from
        penguin_tblquoteAddOn_ukcm qa
        inner join penguin_tblQuoteCustomer_ukcm qc on
            qc.QuoteCustomerID = qa.QuoteCustomerID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'UK') dk

    
    /* delete existing QuoteAddOn */
    if object_id('[db-au-cmdwh].dbo.QuoteAddOn') is null
    begin

        create table [db-au-cmdwh].dbo.QuoteAddOn
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) not null,
            QuoteCountryKey varchar(41) null,
            QuoteID  int not null,
            CustomerID int not null,
            QuoteAddOnID int not null,
            AddOnName varchar(50) null,
            AddOnGroup varchar(50) null,
            AddOnItem varchar(500) null,
            PremiumIncrease numeric(10,4) null,
            CoverIncrease numeric(10,4) null,
            CoverIsPercentage bit null,
            IsRateCardBased bit null,
            IsActive bit null
        )

        create clustered index idx_QuoteAddOn_QuoteCountryKey on [db-au-cmdwh].dbo.QuoteAddOn(QuoteCountryKey)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.QuoteAddOn
        where QuoteCountryKey in
            (
                select QuoteCountryKey
                from
                    etl_QuoteAddOn
            )

    end

    /* load QuoteAddOn */
    insert into [db-au-cmdwh].dbo.QuoteAddOn with (tablock)
    (
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        QuoteAddOnID,
        AddOnName,
        AddOnGroup,
        AddOnItem,
        PremiumIncrease,
        CoverIncrease,
        CoverIsPercentage,
        IsRateCardBased,
        IsActive
    )
    select
        CountryKey,
        CompanyKey,
        QuoteCountryKey,
        QuoteID,
        CustomerID,
        QuoteAddOnID,
        AddOnName,
        AddOnGroup,
        AddOnItem,
        PremiumIncrease,
        CoverIncrease,
        CoverIsPercentage,
        IsRateCardBased,
        IsActive
    from
        etl_QuoteAddOn

end
GO
