USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penTax]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penTax]
as
begin
/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
20140617 - LS - TFS 12416, schema and index cleanup
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
20160321 - LT - Penguin 18.0, added US penguin instance
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penTax') is not null
        drop table etl_penTax

    --get GST
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        null as RegionID,
        null as Region,
        tt.TaxId,
        tt.TaxName,
        tt.TaxRate,
        ttt.TaxType
    into etl_penTax
    from
        penguin_tblTax_aucm tt
        inner join penguin_tblDomain_aucm td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_aucm ttt on
            ttt.DomainId = td.DomainId and ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'CM', 'AU')
    where
        tt.TaxRate is not null

    union

    --get stamp duty for all regions
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        tr.RegionID,
        tr.Region,
        tt.TaxId,
        tt.TaxName,
        ttr.Rate,
        ttt.TaxType
    from
        penguin_tblTax_aucm tt
        inner join penguin_tblTaxRegion_aucm ttr on
            ttr.TaxId = tt.TaxId
        inner join penguin_tblRegion_aucm tr on
            tr.RegionId = ttr.RegionId
        inner join penguin_tblDomain_aucm td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_aucm ttt on
            ttt.DomainId = td.DomainId and
            ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'CM', 'AU')
    where
        tt.TaxRate is null

    union

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        null as RegionID,
        null as Region,
        tt.TaxId,
        tt.TaxName,
        tt.TaxRate,
        ttt.TaxType
    from
        penguin_tblTax_autp tt
        inner join penguin_tblDomain_autp td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_autp ttt on
            ttt.DomainId = td.DomainId and ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'TIP', 'AU')
    where
        tt.TaxRate is not null

    union

    --get stamp duty for all regions
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        tr.RegionID,
        tr.Region,
        tt.TaxId,
        tt.TaxName,
        ttr.Rate,
        ttt.TaxType
    from
        penguin_tblTax_autp tt
        inner join penguin_tblTaxRegion_autp ttr on
            ttr.TaxId = tt.TaxId
        inner join penguin_tblRegion_autp tr on
            tr.RegionId = ttr.RegionId
        inner join penguin_tblDomain_autp td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_autp ttt on
            ttt.DomainId = td.DomainId and
            ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'TIP', 'AU')
    where
        tt.TaxRate is null

    union

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        null as RegionID,
        null as Region,
        tt.TaxId,
        tt.TaxName,
        tt.TaxRate,
        ttt.TaxType
    from
        penguin_tblTax_ukcm tt
        inner join penguin_tblDomain_ukcm td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_ukcm ttt on
            ttt.DomainId = td.DomainId and ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'CM', 'UK')
    where
        tt.TaxRate is not null

    union

    --get stamp duty for all regions
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        tr.RegionID,
        tr.Region,
        tt.TaxId,
        tt.TaxName,
        ttr.Rate,
        ttt.TaxType
    from
        penguin_tblTax_ukcm tt
        inner join penguin_tblTaxRegion_ukcm ttr on
            ttr.TaxId = tt.TaxId
        inner join penguin_tblRegion_ukcm tr on
            tr.RegionId = ttr.RegionId
        inner join penguin_tblDomain_ukcm td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_ukcm ttt on
            ttt.DomainId = td.DomainId and
            ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'CM', 'UK')
    where
        tt.TaxRate is null

    union

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        null as RegionID,
        null as Region,
        tt.TaxId,
        tt.TaxName,
        tt.TaxRate,
        ttt.TaxType
    from
        penguin_tblTax_uscm tt
        inner join penguin_tblDomain_uscm td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_uscm ttt on
            ttt.DomainId = td.DomainId and ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'CM', 'US')
    where
        tt.TaxRate is not null

    union

    --get stamp duty for all regions
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, tt.TaxID) TaxKey,
        td.DomainID,
        tr.RegionID,
        tr.Region,
        tt.TaxId,
        tt.TaxName,
        ttr.Rate,
        ttt.TaxType
    from
        penguin_tblTax_uscm tt
        inner join penguin_tblTaxRegion_uscm ttr on
            ttr.TaxId = tt.TaxId
        inner join penguin_tblRegion_uscm tr on
            tr.RegionId = ttr.RegionId
        inner join penguin_tblDomain_uscm td on
            td.DomainId = tt.DomainId
        inner join penguin_tblTaxType_uscm ttt on
            ttt.DomainId = td.DomainId and
            ttt.TaxTypeId = tt.TaxTypeId
        cross apply dbo.fn_GetDomainKeys(td.DomainID, 'CM', 'US')
    where
        tt.TaxRate is null


    if object_id('[db-au-cmdwh].dbo.penTax') is null
    begin

        create table [db-au-cmdwh].dbo.[penTax]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [TaxKey] varchar(41) null,
            [DomainID] int not null,
            [RegionID] int null,
            [Region] nvarchar(50) null,
            [TaxId] int not null,
            [TaxName] nvarchar(50) null,
            [TaxRate] numeric(18,5) null,
            [TaxType] nvarchar(50) null,
            [DomainKey] varchar(41) null
        )

        create clustered index idx_penTax_TaxKey on [db-au-cmdwh].dbo.penTax(TaxKey)
        create nonclustered index idx_penTax_CountryKey on [db-au-cmdwh].dbo.penTax(CountryKey)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.penTax
        where
            TaxKey in
            (
                select
                    TaxKey
                from
                    etl_penTax
            )

    end

    insert [db-au-cmdwh].dbo.penTax with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        TaxKey,
        DomainID,
        RegionID,
        Region,
        TaxId,
        TaxName,
        TaxRate,
        TaxType
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        TaxKey,
        DomainID,
        RegionID,
        Region,
        TaxId,
        TaxName,
        TaxRate,
        TaxType
    from
        etl_penTax

end


GO
