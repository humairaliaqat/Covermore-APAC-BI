USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_emcCompanies]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_emcCompanies]
as
begin
/*
    20121026, LS,   bug fix on company key duplicates due to merged subcompanies
    20140217, LS,   base CountryKey on Domain
                    change truncate to delete, prepare for UK
    20140317, LS,   TFS 9410, UK data
*/

    set nocount on

    exec etlsp_StagingIndex_EMC

    if object_id('[db-au-cmdwh].dbo.emcCompanies') is null
    begin

        create table [db-au-cmdwh].dbo.emcCompanies
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(10) not null,
            ParentCompanyID int null,
            CompanyID int not null,
            SubCompanyID int null,
            ParentCompanyCode varchar(3) null,
            CompanyCode varchar(5) null,
            SubCompanyCode varchar(50) null,
            ProductCode varchar(5) null,
            ParentCompanyName varchar(100) null,
            CompanyName varchar(50) null,
            SubCompanyName varchar(250) null,
            ValidFrom datetime null,
            ValidTo datetime null,
            Phone varchar(30) null,
            Fax varchar(30) null,
            Email varchar(255) null,
            BCC varchar(255) null,
            FromEmail varchar(255) null,
            isHealixOnly bit null,
            isSubCompanyActive bit null
        )

        create clustered index idx_emcCompanies_CompanyKey on [db-au-cmdwh].dbo.emcCompanies(CompanyKey)
        create index idx_emcCompanies_CountryKey on [db-au-cmdwh].dbo.emcCompanies(CountryKey)
        create index idx_emcCompanies_ValidDates on [db-au-cmdwh].dbo.emcCompanies(ValidFrom, ValidTo)

    end

    if object_id('etl_emcCompanies') is not null
        drop table etl_emcCompanies

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(4), c.Compid) + '-' + convert(varchar(3), isnull(sc.SubCompid, 0)) CompanyKey,
        c.ParentCompanyID,
        c.Compid CompanyID,
        sc.SubCompid SubCompanyID,
        p.ParentCompanyCode,
        CompanyCode,
        sc.SubCompCode SubCompanyCode,
        ProdCode ProductCode,
        p.ParentCompanyName,
        Product CompanyName,
        sc.SubCompDesc SubCompanyName,
        ValidFrom,
        ValidTo,
        Phone,
        Fax,
        Email,
        BCC,
        FromEmail,
        isnull(HealixOnly, 0) isHealixOnly,
        isnull(sc.active, 0) isSubCompanyActive
    into etl_emcCompanies
    from
        emc_EMC_Companies_AU c
        left join emc_EMC_tblParentCompany_AU p on
            p.ParentCompanyid = c.ParentCompanyid
        left join emc_EMC_tblSubCompanies_AU sc on
            sc.Compid = c.Compid
        outer apply dbo.fn_GetDomainKeys(c.DomainID, 'CM', 'AU') dk

    union

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar(4), c.Compid) + '-' + convert(varchar(3), isnull(sc.SubCompid, 0)) CompanyKey,
        c.ParentCompanyID,
        c.Compid CompanyID,
        sc.SubCompid SubCompanyID,
        p.ParentCompanyCode,
        CompanyCode,
        sc.SubCompCode SubCompanyCode,
        ProdCode ProductCode,
        p.ParentCompanyName,
        Product CompanyName,
        sc.SubCompDesc SubCompanyName,
        ValidFrom,
        ValidTo,
        Phone,
        Fax,
        Email,
        BCC,
        FromEmail,
        isnull(HealixOnly, 0) isHealixOnly,
        isnull(sc.active, 0) isSubCompanyActive
    from
        emc_UKEMC_Companies_UK c
        left join emc_UKEMC_tblParentCompany_UK p on
            p.ParentCompanyid = c.ParentCompanyid
        left join emc_UKEMC_tblSubCompanies_UK sc on
            sc.Compid = c.Compid
        outer apply dbo.fn_GetDomainKeys(c.DomainID, 'CM', 'UK') dk

    delete c
    from
        [db-au-cmdwh].dbo.emcCompanies c
        inner join etl_emcCompanies t on
            t.CompanyKey = c.CompanyKey

    insert into [db-au-cmdwh].dbo.emcCompanies with(tablock)
    (
        CountryKey,
        CompanyKey,
        ParentCompanyID,
        CompanyID,
        SubCompanyID,
        ParentCompanyCode,
        CompanyCode,
        SubCompanyCode,
        ProductCode,
        ParentCompanyName,
        CompanyName,
        SubCompanyName,
        ValidFrom,
        ValidTo,
        Phone,
        Fax,
        Email,
        BCC,
        FromEmail,
        isHealixOnly,
        isSubCompanyActive
    )
    select
        CountryKey,
        CompanyKey,
        ParentCompanyID,
        CompanyID,
        SubCompanyID,
        ParentCompanyCode,
        CompanyCode,
        SubCompanyCode,
        ProductCode,
        rtrim(ltrim(ParentCompanyName)),
        CompanyName,
        SubCompanyName,
        ValidFrom,
        ValidTo,
        Phone,
        Fax,
        Email,
        BCC,
        FromEmail,
        isHealixOnly,
        isSubCompanyActive
    from
        etl_emcCompanies


end
GO
