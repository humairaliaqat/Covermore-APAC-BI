USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penBenefit]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penBenefit]
as
begin
/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
20140612 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
20140617 - LS - TFS 12416, schema and index cleanup
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
20160321 - LT - Penguin 18.0, added US penguin instance
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penBenefit') is not null
        drop table etl_penBenefit

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, BenefitID) BenefitKey,
        a.BenefitID,
        a.SortOrder,
        a.DomainID,
        a.DisplayName,
        a.HelpText,
        a.BenefitCodeId,
        a.BenefitCoverTypeId,
        a.IsClaimsBenefit,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, dk.TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, dk.TimeZone) UpdateDateTime,
        a.Status
    into etl_penBenefit
    from
        penguin_tblBenefit_aucm a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, BenefitID) BenefitKey,
        a.BenefitID,
        a.SortOrder,
        a.DomainID,
        a.DisplayName,
        a.HelpText,
        a.BenefitCodeId,
        a.BenefitCoverTypeId,
        a.IsClaimsBenefit,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, dk.TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, dk.TimeZone) UpdateDateTime,
        a.Status
    from
        penguin_tblBenefit_autp a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'TIP', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, BenefitID) BenefitKey,
        a.BenefitID,
        a.SortOrder,
        a.DomainID,
        a.DisplayName,
        a.HelpText,
        a.BenefitCodeId,
        a.BenefitCoverTypeId,
        a.IsClaimsBenefit,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, dk.TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, dk.TimeZone) UpdateDateTime,
        a.Status
    from
        penguin_tblBenefit_ukcm a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'CM', 'UK') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, BenefitID) BenefitKey,
        a.BenefitID,
        a.SortOrder,
        a.DomainID,
        a.DisplayName,
        a.HelpText,
        a.BenefitCodeId,
        a.BenefitCoverTypeId,
        a.IsClaimsBenefit,
        dbo.xfn_ConvertUTCtoLocal(a.CreateDateTime, dk.TimeZone) CreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(a.UpdateDateTime, dk.TimeZone) UpdateDateTime,
        a.Status
    from
        penguin_tblBenefit_uscm a
        cross apply dbo.fn_GetDomainKeys(a.DomainId, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penBenefit') is null
    begin

        create table [db-au-cmdwh].dbo.[penBenefit]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [BenefitKey] varchar(41) null,
            [BenefitID] int null,
            [SortOrder] int null,
            [DomainID] int null,
            [DisplayName] nvarchar(200) null,
            [HelpText] nvarchar(max) null,
            [DomainKey] varchar(41) null,
            [BenefitCodeId] int not null,
            [BenefitCoverTypeId] int null,
            [IsClaimsBenefit] bit null,
            [CreateDateTime] datetime null,
            [UpdateDateTime] datetime null,
            [Status] varchar(15) null
        )

        create clustered index idx_penBenefit_BenefitKey on [db-au-cmdwh].dbo.penBenefit(BenefitKey)
        create nonclustered index idx_penBenefit_CountryKey on [db-au-cmdwh].dbo.penBenefit(CountryKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penBenefit a
            inner join etl_penBenefit b on
                a.BenefitKey = b.BenefitKey

    end


    insert [db-au-cmdwh].dbo.penBenefit with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        BenefitKey,
        BenefitID,
        SortOrder,
        DomainID,
        DisplayName,
        HelpText,
        BenefitCodeId,
        BenefitCoverTypeId,
        IsClaimsBenefit,
        CreateDateTime,
        UpdateDateTime,
        Status
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        BenefitKey,
        BenefitID,
        SortOrder,
        DomainID,
        DisplayName,
        HelpText,
        BenefitCodeId,
        BenefitCoverTypeId,
        IsClaimsBenefit,
        CreateDateTime,
        UpdateDateTime,
        Status
    from
        etl_penBenefit

end


GO
