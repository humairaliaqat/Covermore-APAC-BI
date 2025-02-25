USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penAddOnGroup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_penAddOnGroup]
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

    if object_id('etl_penAddOnGroup') is not null
        drop table etl_penAddOnGroup

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AddOnGroupID) as AddOnGroupKey,
        a.AddOnGroupID,
        a.GroupName,
        a.Comments,
        a.Code GroupCode
    into etl_penAddOnGroup
    from
        penguin_tblAddOnGroup_aucm a
        cross apply dbo.fn_GetDomainKeys(null, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AddOnGroupID) as AddOnGroupKey,
        a.AddOnGroupID,
        a.GroupName,
        a.Comments,
        a.Code GroupCode
    from
        penguin_tblAddOnGroup_autp a
        cross apply dbo.fn_GetDomainKeys(null, 'TIP', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AddOnGroupID) as AddOnGroupKey,
        a.AddOnGroupID,
        a.GroupName,
        a.Comments,
        a.Code GroupCode
    from
        penguin_tblAddOnGroup_ukcm a
        cross apply dbo.fn_GetDomainKeys(null, 'CM', 'UK') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AddOnGroupID) as AddOnGroupKey,
        a.AddOnGroupID,
        a.GroupName,
        a.Comments,
        a.Code GroupCode
    from
        penguin_tblAddOnGroup_uscm a
        cross apply dbo.fn_GetDomainKeys(null, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penAddOnGroup') is null
    begin

        create table [db-au-cmdwh].dbo.[penAddOnGroup]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [AddOnGroupKey] varchar(41) null,
            [AddOnGroupID] int null,
            [GroupName] nvarchar(50) null,
            [Comments] nvarchar(50) null,
            [GroupCode] varchar(10) null
        )

        create clustered index idx_penAddOnGroup_AddOnGroupKey on [db-au-cmdwh].dbo.penAddOnGroup(AddOnGroupKey)
        create nonclustered index idx_penAddOnGroup_CountryKey on [db-au-cmdwh].dbo.penAddOnGroup(CountryKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penAddonGroup a
            inner join etl_penAddonGroup b on
                a.AddonGroupKey = b.AddonGroupKey

    end



    insert [db-au-cmdwh].dbo.penAddOnGroup with(tablockx)
    (
        CountryKey,
        CompanyKey,
        AddOnGroupKey,
        AddOnGroupID,
        GroupName,
        Comments,
        GroupCode
    )
    select
        CountryKey,
        CompanyKey,
        AddOnGroupKey,
        AddOnGroupID,
        GroupName,
        Comments,
        GroupCode
    from
        etl_penAddOnGroup

end


GO
