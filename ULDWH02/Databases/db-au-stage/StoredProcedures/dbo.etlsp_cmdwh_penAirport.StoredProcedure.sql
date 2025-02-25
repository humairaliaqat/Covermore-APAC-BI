USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penAirport]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penAirport]
as
begin
/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
20140617 - LS - TFS 12416, schema and index cleanup
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
20160321 - LT - Penguin 18.0, added US penguin instance
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penAirport') is not null
        drop table etl_penAirport

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AirportID) AirportKey,
        a.AirportID,
        a.CountryID,
        a.AirportCode,
        a.Airport as AirportName
    into etl_penAirport
    from
        penguin_tblAirport_aucm a
        cross apply dbo.fn_GetDomainKeys(null, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AirportID) AirportKey,
        a.AirportID,
        a.CountryID,
        a.AirportCode,
        a.Airport as AirportName
    from
        penguin_tblAirport_autp a
        cross apply dbo.fn_GetDomainKeys(null, 'TIP', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AirportID) AirportKey,
        a.AirportID,
        a.CountryID,
        a.AirportCode,
        a.Airport as AirportName
    from
        penguin_tblAirport_ukcm a
        cross apply dbo.fn_GetDomainKeys(null, 'CM', 'UK') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, a.AirportID) AirportKey,
        a.AirportID,
        a.CountryID,
        a.AirportCode,
        a.Airport as AirportName
    from
        penguin_tblAirport_uscm a
        cross apply dbo.fn_GetDomainKeys(null, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penAirport') is null
    begin

        create table [db-au-cmdwh].dbo.[penAirport]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [AirportKey] varchar(41) null,
            [AirportID] int null,
            [CountryID] int null,
            [AirportCode] nvarchar(50) null,
            [AirportName] nvarchar(255) null
        )

        create clustered index idx_penAirport_AirportKey on [db-au-cmdwh].dbo.penAirport(AirportKey)
        create nonclustered index idx_penAirport_CountryKey on [db-au-cmdwh].dbo.penAirport(CountryKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penAirport a
            inner join etl_penAirport b on
                a.AirportKey = b.AirportKey

    end


    insert [db-au-cmdwh].dbo.penAirport with(tablockx)
    (
        CountryKey,
        CompanyKey,
        AirportKey,
        AirportID,
        CountryID,
        AirportCode,
        AirportName
    )
    select
        CountryKey,
        CompanyKey,
        AirportKey,
        AirportID,
        CountryID,
        AirportCode,
        AirportName
    from
        etl_penAirport

end


GO
