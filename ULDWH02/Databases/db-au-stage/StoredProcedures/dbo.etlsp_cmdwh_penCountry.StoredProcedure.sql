USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penCountry]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penCountry]
as
begin

/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
20140617 - LS - TFS 12416, schema and index cleanup
20150408 - LS - TFS 15452, add [Is_Part_Of_ISO_Standard]
20150601 - LS - bug fix on [Is_Part_Of_ISO_Standard], not in staging table
20151208 - LT - Penguin 16.5:
					- Multi Destination change - added countrykey, companykey, domainkey, and destinationKey
					- Set default domain to AU and UK for TIP and UK countries when there are null domains
20160321 - LT - Penguin 18.0, Added US Penguin Instance
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('[db-au-stage].dbo.etl_penCountry') is not null
        drop table [db-au-stage].dbo.etl_penCountry

    select
        CountryKey,
        CompanyKey,
        DomainKey,
		PrefixKey + convert(varchar, c.CountryID) DestinationKey,
		c.CountryID,
        c.Country,
        c.ISO3Code,
        c.ISO2Code,
        c.Is_Part_Of_ISO_Standard
    into [db-au-stage].dbo.etl_penCountry
    from
        penguin_tblCountry_aucm c
		outer apply
		(
			select top 1 DomainID
			from
				penguin_tblCountryArea_aucm ca
				inner join penguin_tblArea_aucm a on ca.AreaId = a.AreaID
			where
				ca.CountryID = c.CountryID
		) a
		cross apply dbo.fn_GetDomainKeys(a.DomainID, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
		PrefixKey + convert(varchar, c.CountryID) DestinationKey,
		c.CountryID,
        c.Country,
        c.ISO3Code,
        c.ISO2Code,
        c.Is_Part_Of_ISO_Standard
    from
        penguin_tblCountry_autp c
		outer apply
		(
			select top 1 isnull(DomainID,7) as DomainID			--if null defaults to AU domain
			from
				penguin_tblCountryArea_autp ca
				inner join penguin_tblArea_autp a on ca.AreaId = a.AreaID
			where
				ca.CountryID = c.CountryID
		) a
		cross apply dbo.fn_GetDomainKeys(isnull(a.DomainID,7), 'TIP', 'AU') dk		--if null then domain is AU

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
		PrefixKey + convert(varchar, c.CountryID) DestinationKey,
		c.CountryID,
        c.Country,
        c.ISO3Code,
        c.ISO2Code,
        c.Is_Part_Of_ISO_Standard
    from
        penguin_tblCountry_ukcm c
		outer apply
		(
			select top 1 isnull(DomainID,11) as DomainID		--if null set default to UK domain
			from
				penguin_tblCountryArea_ukcm ca
				inner join penguin_tblArea_ukcm a on ca.AreaId = a.AreaID
			where
				ca.CountryID = c.CountryID
		) a
		cross apply dbo.fn_GetDomainKeys(a.DomainID, 'CM', 'UK') dk		

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
		PrefixKey + convert(varchar, c.CountryID) DestinationKey,
		c.CountryID,
        c.Country,
        c.ISO3Code,
        c.ISO2Code,
        c.Is_Part_Of_ISO_Standard
    from
        penguin_tblCountry_uscm c
		outer apply
		(
			select top 1 isnull(DomainID,14) as DomainID		--if null set default to US domain
			from
				penguin_tblCountryArea_uscm ca
				inner join penguin_tblArea_ukcm a on ca.AreaId = a.AreaID
			where
				ca.CountryID = c.CountryID
		) a
		cross apply dbo.fn_GetDomainKeys(a.DomainID, 'CM', 'US') dk		


    if object_id('[db-au-cmdwh].dbo.penCountry') is null
    begin

        create table [db-au-cmdwh].dbo.[penCountry]
        (
			[CountryKey] varchar(2) null,
			[CompanyKey] varchar(5) null,
			[DomainKey] varchar(41) null,
			[DestinationKey] varchar(41) null,
            [CountryID] int null,
            [CountryName] nvarchar(50) null,
            [ISO3Code] varchar(3) null,
            [ISO2Code] varchar(2) null,
            [Is_Part_Of_ISO_Standard] bit null default 1
        )

        create clustered index idx_penCountry_DestinationKey on [db-au-cmdwh].dbo.penCountry(DestinationKey)
		create nonclustered index idx_penCountry_CountryID on [db-au-cmdwh].dbo.penCountry(CountryID)
        create nonclustered index idx_penCountry_CountryName on [db-au-cmdwh].dbo.penCountry(CountryName)
        create nonclustered index idx_penCountry_ISO2Code on [db-au-cmdwh].dbo.penCountry(ISO2Code)
        create nonclustered index idx_penCountry_ISO3Code on [db-au-cmdwh].dbo.penCountry(ISO3Code)

    end
    else
		delete a
		from [db-au-cmdwh].dbo.penCountry a
			join [db-au-stage].dbo.etl_penCountry b on
				a.DestinationKey = b.DestinationKey
		

		
    insert [db-au-cmdwh].dbo.penCountry with(tablockx)
    (
		[CountryKey],
		[CompanyKey],
		[DomainKey],
		[DestinationKey],
        [CountryID],
        [CountryName],
        [ISO3Code],
        [ISO2Code],
        [Is_Part_Of_ISO_Standard]
    )
    select
		[CountryKey],
		[CompanyKey],
		[DomainKey],
		[DestinationKey],
        [CountryID],
        [Country] as CountryName,
        [ISO3Code],
        [ISO2Code],
        [Is_Part_Of_ISO_Standard]
    from
      [db-au-stage].dbo.etl_penCountry

end

GO
