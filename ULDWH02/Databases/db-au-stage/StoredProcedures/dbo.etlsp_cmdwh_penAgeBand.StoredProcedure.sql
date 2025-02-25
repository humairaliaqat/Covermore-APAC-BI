USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penAgeBand]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penAgeBand]
as
begin

/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
20140617 - LS - TFS 12416, schema and index cleanup
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
20160321 - LT - Penguin 18.0, added US Penguin instance
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penAgeBand') is not null
        drop table etl_penAgeBand

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, ab.AgeBandID) AgeBandKey,
        abset.DomainID,
        abset.AgeBandSetID,
        abset.[Name] as AgeBandSetName,
        ab.AgeBandID,
        ab.StartAge,
        ab.EndAge
    into etl_penAgeBand
    from
        penguin_tblAgeBand_aucm ab
        inner join penguin_tblAgeBandSet_aucm abset on
            ab.AgeBandSetID = abset.AgeBandSetID
        cross apply dbo.fn_GetDomainKeys(abset.DomainId, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, ab.AgeBandID) AgeBandKey,
        abset.DomainID,
        abset.AgeBandSetID,
        abset.[Name] as AgeBandSetName,
        ab.AgeBandID,
        ab.StartAge,
        ab.EndAge
    from
        penguin_tblAgeBand_autp ab
        inner join penguin_tblAgeBandSet_autp abset on
            ab.AgeBandSetID = abset.AgeBandSetID
        cross apply dbo.fn_GetDomainKeys(abset.DomainId, 'TIP', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, ab.AgeBandID) AgeBandKey,
        abset.DomainID,
        abset.AgeBandSetID,
        abset.[Name] as AgeBandSetName,
        ab.AgeBandID,
        ab.StartAge,
        ab.EndAge
    from
        penguin_tblAgeBand_ukcm ab
        inner join penguin_tblAgeBandSet_ukcm abset on
            ab.AgeBandSetID = abset.AgeBandSetID
        cross apply dbo.fn_GetDomainKeys(abset.DomainId, 'CM', 'UK') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, ab.AgeBandID) AgeBandKey,
        abset.DomainID,
        abset.AgeBandSetID,
        abset.[Name] as AgeBandSetName,
        ab.AgeBandID,
        ab.StartAge,
        ab.EndAge
    from
        penguin_tblAgeBand_uscm ab
        inner join penguin_tblAgeBandSet_uscm abset on
            ab.AgeBandSetID = abset.AgeBandSetID
        cross apply dbo.fn_GetDomainKeys(abset.DomainId, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penAgeBand') is null
    begin

        create table [db-au-cmdwh].dbo.[penAgeBand]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [AgeBandKey] varchar(41) null,
            [AgeBandSetID] int null,
            [AgeBandSetName] nvarchar(50) null,
            [AgeBandID] int null,
            [StartAge] int null,
            [EndAge] int null,
            [DomainKey] varchar(41) null,
            [DomainID] int null
        )

        create clustered index idx_penAgeBand_AgeBandKey on [db-au-cmdwh].dbo.penAgeBand(AgeBandKey)
        create nonclustered index idx_penAgeBand_CountryKey on [db-au-cmdwh].dbo.penAgeBand(CountryKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penAgeBand a
            inner join etl_penAgeBand b on
                a.AgeBandKey = b.AgeBandKey

    end

    insert [db-au-cmdwh].dbo.penAgeBand with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        AgeBandKey,
        DomainID,
        AgeBandSetID,
        AgeBandSetName,
        AgeBandID,
        StartAge,
        EndAge
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        AgeBandKey,
        DomainID,
        AgeBandSetID,
        AgeBandSetName,
        AgeBandID,
        StartAge,
        EndAge
    from
        etl_penAgeBand

end


GO
