USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penDomain]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penDomain]
as
begin

/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
                Domain localisation
20140617 - LS - TFS 12416, schema and index cleanup
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
20160321 - LT - Penguin 18.0, added US Penguin instance
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penDomain') is not null
        drop table etl_penDomain

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.DomainID) as DomainKey,
        a.DomainID,
        a.DomainName,
        a.CurrencySymbol,
        a.Underwriter,
        a.CalculationRuleID,
        cr.CalculationRule,
        a.AgeCalcFromDeparture,
        a.AddTripDays,
        a.PaymentURLID,
        a.ShowAddOnGroup,
        a.DaysInAdvance,
        a.StartDateLimiter,
        a.EndDateLimiter,
        a.BonusDaysLimiter,
        a.CurrencyCode,
        a.TimeZoneCode,
        a.AgeCompareLimit,
        a.CultureCode
    into etl_penDomain
    from
        penguin_tblDomain_aucm a
        cross apply
        (
            select
                upper(isnull(a.CountryCode, 'AU')) CountryKey,
                'CM' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px
        outer apply
        (
            select top 1
                CalculationRule
            from
                penguin_tblCalculationRule_aucm cr
            where
                cr.CalculationRuleId = a.CalculationRuleId
        ) cr

    union

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.DomainID) as DomainKey,
        a.DomainID,
        a.DomainName,
        a.CurrencySymbol,
        a.Underwriter,
        a.CalculationRuleID,
        cr.CalculationRule,
        a.AgeCalcFromDeparture,
        a.AddTripDays,
        a.PaymentURLID,
        a.ShowAddOnGroup,
        a.DaysInAdvance,
        a.StartDateLimiter,
        a.EndDateLimiter,
        a.BonusDaysLimiter,
        a.CurrencyCode,
        a.TimeZoneCode,
        a.AgeCompareLimit,
        a.CultureCode
    from
        penguin_tblDomain_autp a
        cross apply
        (
            select
                upper(isnull(a.CountryCode, 'AU')) CountryKey,
                'TIP' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px
        outer apply
        (
            select top 1
                CalculationRule
            from
                penguin_tblCalculationRule_autp cr
            where
                cr.CalculationRuleId = a.CalculationRuleId
        ) cr

    union

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.DomainID) as DomainKey,
        a.DomainID,
        a.DomainName,
        a.CurrencySymbol,
        a.Underwriter,
        a.CalculationRuleID,
        cr.CalculationRule,
        a.AgeCalcFromDeparture,
        a.AddTripDays,
        a.PaymentURLID,
        a.ShowAddOnGroup,
        a.DaysInAdvance,
        a.StartDateLimiter,
        a.EndDateLimiter,
        a.BonusDaysLimiter,
        a.CurrencyCode,
        a.TimeZoneCode,
        a.AgeCompareLimit,
        a.CultureCode
    from
        penguin_tblDomain_ukcm a
        cross apply
        (
            select
                upper(isnull(a.CountryCode, 'UK')) CountryKey,
                'CM' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px
        outer apply
        (
            select top 1
                CalculationRule
            from
                penguin_tblCalculationRule_aucm cr
            where
                cr.CalculationRuleId = a.CalculationRuleId
        ) cr

    union

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.DomainID) as DomainKey,
        a.DomainID,
        a.DomainName,
        a.CurrencySymbol,
        a.Underwriter,
        a.CalculationRuleID,
        cr.CalculationRule,
        a.AgeCalcFromDeparture,
        a.AddTripDays,
        a.PaymentURLID,
        a.ShowAddOnGroup,
        a.DaysInAdvance,
        a.StartDateLimiter,
        a.EndDateLimiter,
        a.BonusDaysLimiter,
        a.CurrencyCode,
        a.TimeZoneCode,
        a.AgeCompareLimit,
        a.CultureCode
    from
        penguin_tblDomain_uscm a
        cross apply
        (
            select
                upper(isnull(a.CountryCode, 'US')) CountryKey,
                'CM' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px
        outer apply
        (
            select top 1
                CalculationRule
            from
                penguin_tblCalculationRule_aucm cr
            where
                cr.CalculationRuleId = a.CalculationRuleId
        ) cr


    if object_id('[db-au-cmdwh].dbo.penDomain') is null
    begin

        create table [db-au-cmdwh].dbo.[penDomain]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [DomainKey] varchar(41) null,
            [DomainID] int null,
            [DomainName] nvarchar(50) null,
            [CurrencySymbol] nvarchar(10) null,
            [Underwriter] nvarchar(50) null,
            [CalculationRuleID] int null,
            [CalculationRule] nvarchar(50) null,
            [AgeCalcFromDeparture] bit null,
            [AddTripDays] int null,
            [PaymentURLID] int null,
            [ShowAddOnGroup] bit null,
            [DaysInAdvance] int null,
            [StartDateLimiter] datetime null,
            [EndDateLimiter] datetime null,
            [BonusDaysLimiter] int null,
            [CurrencyCode] varchar(3) null,
            [TimeZoneCode] varchar(50) null,
            [AgeCompareLimit] int null,
            [CultureCode] nvarchar(20) null
        )

        create clustered index idx_penDomain_DomainKey on [db-au-cmdwh].dbo.penDomain(DomainKey)
        create nonclustered index idx_penDomain_CountryKey on [db-au-cmdwh].dbo.penDomain(CountryKey)
        create nonclustered index idx_penDomain_DomainID on [db-au-cmdwh].dbo.penDomain(DomainID,CountryKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penDomain a
            inner join etl_penDomain b on
                a.DomainKey COLLATE DATABASE_DEFAULT = b.DomainKey COLLATE DATABASE_DEFAULT

    end

    insert [db-au-cmdwh].dbo.penDomain with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        DomainID,
        DomainName,
        CurrencySymbol,
        Underwriter,
        CalculationRuleID,
        CalculationRule,
        AgeCalcFromDeparture,
        AddTripDays,
        PaymentURLID,
        ShowAddOnGroup,
        DaysInAdvance,
        StartDateLimiter,
        EndDateLimiter,
        BonusDaysLimiter,
        CurrencyCode,
        TimeZoneCode,
        AgeCompareLimit,
        CultureCode
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        DomainID,
        DomainName,
        CurrencySymbol,
        Underwriter,
        CalculationRuleID,
        CalculationRule,
        AgeCalcFromDeparture,
        AddTripDays,
        PaymentURLID,
        ShowAddOnGroup,
        DaysInAdvance,
        StartDateLimiter,
        EndDateLimiter,
        BonusDaysLimiter,
        CurrencyCode,
        TimeZoneCode,
        AgeCompareLimit,
        CultureCode
    from
        etl_penDomain

    /* domain localisation */
    if object_id('etl_penDomainLocalisation') is not null
        drop table etl_penDomainLocalisation

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, dl.DomainID) as DomainKey,
        PrefixKey + convert(varchar, dll.ID) as LocalisationKey,
        dll.ID LocalisationID,
        dl.DomainID,
        dl.Code CultureCode,
        dl.Name LanguageName,
        DefaultForCatalyst,
        dll.TableName,
        dll.ColumnName,
        dll.DataId,
        dll.StringValue,
        dll.UpdateDateTime,
        dll.DomainLanguageId,
        dll.IsDirty
    into etl_penDomainLocalisation
    from
        penguin_tblDomain_aucm d
        inner join penguin_tblDomainLanguage_aucm dl on
            dl.DomainID = d.DomainID
        inner join penguin_tblDomainLocalisation_aucm dll on
            dll.DomainLanguageId = dl.Id
        cross apply
        (
            select
                upper(isnull(d.CountryCode, 'AU')) CountryKey,
                'CM' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px

    union

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, dl.DomainID) as DomainKey,
        PrefixKey + convert(varchar, dll.ID) as LocalisationKey,
        dll.ID LocalisationID,
        dl.DomainID,
        dl.Code CultureCode,
        dl.Name LanguageName,
        DefaultForCatalyst,
        dll.TableName,
        dll.ColumnName,
        dll.DataId,
        dll.StringValue,
        dll.UpdateDateTime,
        dll.DomainLanguageId,
        dll.IsDirty
    from
        penguin_tblDomain_autp d
        inner join penguin_tblDomainLanguage_autp dl on
            dl.DomainID = d.DomainID
        inner join penguin_tblDomainLocalisation_autp dll on
            dll.DomainLanguageId = dl.Id
        cross apply
        (
            select
                upper(isnull(d.CountryCode, 'AU')) CountryKey,
                'TIP' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px

    union

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, dl.DomainID) as DomainKey,
        PrefixKey + convert(varchar, dll.ID) as LocalisationKey,
        dll.ID LocalisationID,
        dl.DomainID,
        dl.Code CultureCode,
        dl.Name LanguageName,
        DefaultForCatalyst,
        dll.TableName,
        dll.ColumnName,
        dll.DataId,
        dll.StringValue,
        dll.UpdateDateTime,
        dll.DomainLanguageId,
        dll.IsDirty
    from
        penguin_tblDomain_ukcm d
        inner join penguin_tblDomainLanguage_ukcm dl on
            dl.DomainID = d.DomainID
        inner join penguin_tblDomainLocalisation_ukcm dll on
            dll.DomainLanguageId = dl.Id
        cross apply
        (
            select
                upper(isnull(d.CountryCode, 'UK')) CountryKey,
                'CM' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px

    union

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, dl.DomainID) as DomainKey,
        PrefixKey + convert(varchar, dll.ID) as LocalisationKey,
        dll.ID LocalisationID,
        dl.DomainID,
        dl.Code CultureCode,
        dl.Name LanguageName,
        DefaultForCatalyst,
        dll.TableName,
        dll.ColumnName,
        dll.DataId,
        dll.StringValue,
        dll.UpdateDateTime,
        dll.DomainLanguageId,
        dll.IsDirty
    from
        penguin_tblDomain_uscm d
        inner join penguin_tblDomainLanguage_uscm dl on
            dl.DomainID = d.DomainID
        inner join penguin_tblDomainLocalisation_uscm dll on
            dll.DomainLanguageId = dl.Id
        cross apply
        (
            select
                upper(isnull(d.CountryCode, 'US')) CountryKey,
                'CM' CompanyKey
        ) ck
        cross apply
        (
            select
                CountryKey + '-' + CompanyKey + '-' PrefixKey
        ) px

    if object_id('[db-au-cmdwh].dbo.penDomainLocalisation') is null
    begin

        create table [db-au-cmdwh].dbo.penDomainLocalisation
        (
            [BIRowID] bigint not null identity (1,1),
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [DomainKey] varchar(41) null,
            [LocalisationKey] varchar(41) null,
            [LocalisationID] int null,
            [DomainID] int null,
            [DomainLanguageId] int null,
            [CultureCode] nvarchar(20) null,
            [LanguageName] nvarchar(100) null,
            [DefaultForCatalyst] bit null,
            [TableName] varchar(100) null,
            [ColumnName] varchar(100) null,
            [DataId] Int null,
            [StringValue] nvarchar(max) null,
            [UpdateDateTime] datetime null,
            [IsDirty] bit null
        )

        create clustered index idx_penDomain_BIRowID on [db-au-cmdwh].dbo.penDomainLocalisation(BIRowID)
        create nonclustered index idx_penDomain_DomainKey on [db-au-cmdwh].dbo.penDomainLocalisation(DomainKey)
        create nonclustered index idx_penDomain_Translation on [db-au-cmdwh].dbo.penDomainLocalisation(DataId,DomainKey) include (DomainID,CultureCode,LanguageName,TableName,ColumnName,StringValue)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penDomainLocalisation a
            inner join etl_penDomainLocalisation b on
                a.LocalisationKey collate database_default = b.LocalisationKey collate database_default

    end

    insert [db-au-cmdwh].dbo.penDomainLocalisation with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        LocalisationKey,
        LocalisationID,
        DomainID,
        DomainLanguageId,
        CultureCode,
        LanguageName,
        DefaultForCatalyst,
        TableName,
        ColumnName,
        DataId,
        StringValue,
        UpdateDateTime,
        IsDirty
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        LocalisationKey,
        LocalisationID,
        DomainID,
        DomainLanguageId,
        CultureCode,
        LanguageName,
        DefaultForCatalyst,
        TableName,
        ColumnName,
        DataId,
        StringValue,
        UpdateDateTime,
        IsDirty
    from
        etl_penDomainLocalisation

end


GO
