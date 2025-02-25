USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penCRMCallComments]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penCRMCallComments]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20120430
Prerequisite:   Requires Penguin Data Model ETL successfully run.
Description:    CRM Call Comments table contains comment details
                This transformation adds essential key fields
Change History:
                20120430 - LT - Procedure created
                20121105 - LS - refactoring & domain related changes
                20130617 - LS - TFS 7664/8556/8557, UK Penguin
                20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window
                20130903 - LT - Added AgencyCallID column to penCRMCallComments
                20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
                20140617 - LS - TFS 12416, schema and index cleanup
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
				20160321 - LT - Penguin 18.0, added US Penguin Instance
*************************************************************************************************************************************/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penCRMCallComments') is not null
        drop table etl_penCRMCallComments

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, CRMCallID) CRMCallKey,
        PrefixKey + convert(varchar, OutletID) OutletKey,
        PrefixKey + convert(varchar, ConsultantID) UserKey,
        PrefixKey + convert(varchar, CRMUserID) CRMUserKey,
        DomainID,
        c.CRMCallID,
        c.OutletID,
        c.CRMUserID,
        c.AlphaCode,
        c.ConsultantID as UserID,
        dbo.fn_GetReferenceValueByID(c.CategoryID, CompanyKey, CountrySet) Category,
        dbo.fn_GetReferenceValueByID(c.SubCategoryID, CompanyKey, CountrySet) SubCategory,
        c.Duration,
        dbo.xfn_ConvertUTCtoLocal(c.CallDate, TimeZone) CallDate,
        c.CallDate CallDateUTC,
        dbo.xfn_ConvertUTCtoLocal(c.ActualCallDate, TimeZone) ActualCallDate,
        c.ActualCallDate ActualCallDateUTC,
        convert(varchar(max),c.CallComments) as CallComments,
        c.isXora,
        c.AgencyCallID
    into etl_penCRMCallComments
    from
        penguin_tblCRMCallComments_aucm c
        cross apply dbo.fn_GetOutletDomainKeys(c.OutletID, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, CRMCallID) CRMCallKey,
        PrefixKey + convert(varchar, OutletID) OutletKey,
        PrefixKey + convert(varchar, ConsultantID) UserKey,
        PrefixKey + convert(varchar, CRMUserID) CRMUserKey,
        DomainID,
        c.CRMCallID,
        c.OutletID,
        c.CRMUserID,
        c.AlphaCode,
        c.ConsultantID as UserID,
        dbo.fn_GetReferenceValueByID(c.CategoryID, CompanyKey, CountrySet) Category,
        dbo.fn_GetReferenceValueByID(c.SubCategoryID, CompanyKey, CountrySet) SubCategory,
        c.Duration,
        dbo.xfn_ConvertUTCtoLocal(c.CallDate, TimeZone) CallDate,
        dbo.xfn_ConvertUTCtoLocal(c.ActualCallDate, TimeZone) ActualCallDate,
        c.CallDate CallDateUTC,
        c.ActualCallDate ActualCallDateUTC,
        convert(varchar(max),c.CallComments) as CallComments,
        c.isXora,
        c.AgencyCallID
    from
        penguin_tblCRMCallComments_autp c
        cross apply dbo.fn_GetOutletDomainKeys(c.OutletID, 'TIP', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, CRMCallID) CRMCallKey,
        PrefixKey + convert(varchar, OutletID) OutletKey,
        PrefixKey + convert(varchar, ConsultantID) UserKey,
        PrefixKey + convert(varchar, CRMUserID) CRMUserKey,
        DomainID,
        c.CRMCallID,
        c.OutletID,
        c.CRMUserID,
        c.AlphaCode,
        c.ConsultantID as UserID,
        dbo.fn_GetReferenceValueByID(c.CategoryID, CompanyKey, CountrySet) Category,
        dbo.fn_GetReferenceValueByID(c.SubCategoryID, CompanyKey, CountrySet) SubCategory,
        c.Duration,
        dbo.xfn_ConvertUTCtoLocal(c.CallDate, TimeZone) CallDate,
        c.CallDate CallDateUTC,
        dbo.xfn_ConvertUTCtoLocal(c.ActualCallDate, TimeZone) ActualCallDate,
        c.ActualCallDate ActualCallDateUTC,
        convert(varchar(max),c.CallComments) as CallComments,
        c.isXora,
        c.AgencyCallID
    from
        penguin_tblCRMCallComments_ukcm c
        cross apply dbo.fn_GetOutletDomainKeys(c.OutletID, 'CM', 'UK') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, CRMCallID) CRMCallKey,
        PrefixKey + convert(varchar, OutletID) OutletKey,
        PrefixKey + convert(varchar, ConsultantID) UserKey,
        PrefixKey + convert(varchar, CRMUserID) CRMUserKey,
        DomainID,
        c.CRMCallID,
        c.OutletID,
        c.CRMUserID,
        c.AlphaCode,
        c.ConsultantID as UserID,
        dbo.fn_GetReferenceValueByID(c.CategoryID, CompanyKey, CountrySet) Category,
        dbo.fn_GetReferenceValueByID(c.SubCategoryID, CompanyKey, CountrySet) SubCategory,
        c.Duration,
        dbo.xfn_ConvertUTCtoLocal(c.CallDate, TimeZone) CallDate,
        c.CallDate CallDateUTC,
        dbo.xfn_ConvertUTCtoLocal(c.ActualCallDate, TimeZone) ActualCallDate,
        c.ActualCallDate ActualCallDateUTC,
        convert(varchar(max),c.CallComments) as CallComments,
        c.isXora,
        c.AgencyCallID
    from
        penguin_tblCRMCallComments_uscm c
        cross apply dbo.fn_GetOutletDomainKeys(c.OutletID, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penCRMCallComments') is null
    begin

        create table [db-au-cmdwh].dbo.[penCRMCallComments]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(3) not null,
            [CRMCallKey] varchar(41) null,
            [OutletKey] varchar(30) null,
            [UserKey] varchar(41) null,
            [CRMUserKey] varchar(41) null,
            [CRMCallID] int not null,
            [OutletID] int not null,
            [CRMUserID] int not null,
            [AlphaCode] nvarchar(20) not null,
            [UserID] int null,
            [Category] nvarchar(50) null,
            [SubCategory] nvarchar(50) null,
            [Duration] int null,
            [CallDate] datetime not null,
            [ActualCallDate] datetime not null,
            [CallComments] nvarchar(max) null,
            [isXora] bit null,
            [DomainKey] varchar(41) null,
            [DomainID] int null,
            [CallDateUTC] datetime null,
            [ActualCallDateUTC] datetime null,
            [AgencyCallID] varchar(20) null
        )

        create clustered index idx_penCRMCallComments_CallDate on [db-au-cmdwh].dbo.penCRMCallComments(CallDate)
        create nonclustered index idx_penCRMCallComments_ActualCallDate on [db-au-cmdwh].dbo.penCRMCallComments(ActualCallDate,CRMUserKey)
        create nonclustered index idx_penCRMCallComments_Category on [db-au-cmdwh].dbo.penCRMCallComments(Category,CountryKey)
        create nonclustered index idx_penCRMCallComments_CountryKey on [db-au-cmdwh].dbo.penCRMCallComments(CountryKey)
        create nonclustered index idx_penCRMCallComments_CRMCallKey on [db-au-cmdwh].dbo.penCRMCallComments(CRMCallKey)
        create nonclustered index idx_penCRMCallComments_CRMUserKey on [db-au-cmdwh].dbo.penCRMCallComments(CRMUserKey)
        create nonclustered index idx_penCRMCallComments_OutletKey on [db-au-cmdwh].dbo.penCRMCallComments(OutletKey,Category) include (CallDate,CallComments)
        create nonclustered index idx_penCRMCallComments_SubCategory on [db-au-cmdwh].dbo.penCRMCallComments(SubCategory,CountryKey,CompanyKey)
        create nonclustered index idx_penCRMCallComments_UserKey on [db-au-cmdwh].dbo.penCRMCallComments(UserKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penCRMCallComments a
            inner join etl_penCRMCallComments b on
                a.CRMCallKey = b.CRMCallKey

    end


    insert into [db-au-cmdwh].dbo.penCRMCallComments with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        CRMCallKey,
        OutletKey,
        UserKey,
        CRMUserKey,
        DomainID,
        CRMCallID,
        OutletID,
        CRMUserID,
        AlphaCode,
        UserID,
        Category,
        SubCategory,
        Duration,
        CallDate,
        ActualCallDate,
        CallDateUTC,
        ActualCallDateUTC,
        CallComments,
        isXora,
        AgencyCallID
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        CRMCallKey,
        OutletKey,
        UserKey,
        CRMUserKey,
        DomainID,
        CRMCallID,
        OutletID,
        CRMUserID,
        AlphaCode,
        UserID,
        Category,
        SubCategory,
        Duration,
        CallDate,
        ActualCallDate,
        CallDateUTC,
        ActualCallDateUTC,
        CallComments,
        isXora,
        AgencyCallID
    from
        etl_penCRMCallComments

end


GO
