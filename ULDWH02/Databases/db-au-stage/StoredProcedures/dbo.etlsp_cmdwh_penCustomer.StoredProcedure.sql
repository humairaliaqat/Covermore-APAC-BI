USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penCustomer]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[etlsp_cmdwh_penCustomer]
as
begin
/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
20140617 - LS - TFS 12416, schema and index cleanup
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
20150808 - LS - TFS 15452, add Gender & ID
20150629 - LT - Converted DOB to Localtime, and added DOBUTC column
20151027 - DM - Added Column StateOfArrival
20160321 - LT - Penguin 18.0, added US Penguin instance
20161021 - LS - MemberTypeId
20180925 - LT - Increased column PIDValue to varchar(256)
*/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penCustomer') is not null
        drop table etl_penCustomer

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.CustomerID) CustomerKey,
        DomainID,
        a.CustomerID,
        a.Title,
        a.FirstName,
        a.LastName,
        dbo.xfn_ConvertUTCToLocal(a.DOB,TimeZone) as DOB,
        a.AddressLine1,
        a.AddressLine2,
        a.PostCode,
        a.Town,
        a.[State],
        a.Country,
        a.HomePhone,
        a.WorkPhone,
        a.MobilePhone,
        a.EmailAddress,
        a.OptFurtherContact,
        a.MemberNumber,
        a.MarketingConsent,
        a.Gender,
        pid.PIDType,
        pid.PIDCode,
        a.PersonalIdentifierValue PIDValue,
		a.DOB as DOBUTC,
		a.StateOfArrival,
        a.MemberTypeId
    into etl_penCustomer
    from
        penguin_tblCustomer_aucm a
        inner join penguin_tblQuoteCustomer_aucm qc on
            qc.CustomerID = a.CustomerID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'AU') dk
        outer apply
        (
            select top 1
                pid.Type PIDType,
                pid.Code PIDCode
            from
                penguin_tblPersonalIdentifier_aucm pid
            where
                pid.ID = a.PersonalIdentifierID
        ) pid

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.CustomerID) CustomerKey,
        DomainID,
        a.CustomerID,
        a.Title,
        a.FirstName,
        a.LastName,
        dbo.xfn_ConvertUTCToLocal(a.DOB,TimeZone) as DOB,
        a.AddressLine1,
        a.AddressLine2,
        a.PostCode,
        a.Town,
        a.[State],
        a.Country,
        a.HomePhone,
        a.WorkPhone,
        a.MobilePhone,
        a.EmailAddress,
        a.OptFurtherContact,
        a.MemberNumber,
        a.MarketingConsent,
        a.Gender,
        pid.PIDType,
        pid.PIDCode,
        a.PersonalIdentifierValue PIDValue,
		a.DOB as DOBUTC,
		a.StateOfArrival,
        a.MemberTypeId
    from
        penguin_tblCustomer_autp a
        inner join penguin_tblQuoteCustomer_autp qc on
            qc.CustomerID = a.CustomerID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'TIP', 'AU') dk
        outer apply
        (
            select top 1
                pid.Type PIDType,
                pid.Code PIDCode
            from
                penguin_tblPersonalIdentifier_autp pid
            where
                pid.ID = a.PersonalIdentifierID
        ) pid

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.CustomerID) CustomerKey,
        DomainID,
        a.CustomerID,
        a.Title,
        a.FirstName,
        a.LastName,
        dbo.xfn_ConvertUTCToLocal(a.DOB,TimeZone) as DOB,
        a.AddressLine1,
        a.AddressLine2,
        a.PostCode,
        a.Town,
        a.[State],
        a.Country,
        a.HomePhone,
        a.WorkPhone,
        a.MobilePhone,
        a.EmailAddress,
        a.OptFurtherContact,
        a.MemberNumber,
        a.MarketingConsent,
        a.Gender,
        pid.PIDType,
        pid.PIDCode,
        a.PersonalIdentifierValue PIDValue,
		a.DOB as DOBUTC,
		a.StateOfArrival,
        a.MemberTypeId
    from
        penguin_tblCustomer_ukcm a
        inner join penguin_tblQuoteCustomer_ukcm qc on
            qc.CustomerID = a.CustomerID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'UK') dk
        outer apply
        (
            select top 1
                pid.Type PIDType,
                pid.Code PIDCode
            from
                penguin_tblPersonalIdentifier_ukcm pid
            where
                pid.ID = a.PersonalIdentifierID
        ) pid

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, a.CustomerID) CustomerKey,
        DomainID,
        a.CustomerID,
        a.Title,
        a.FirstName,
        a.LastName,
        dbo.xfn_ConvertUTCToLocal(a.DOB,TimeZone) as DOB,
        a.AddressLine1,
        a.AddressLine2,
        a.PostCode,
        a.Town,
        a.[State],
        a.Country,
        a.HomePhone,
        a.WorkPhone,
        a.MobilePhone,
        a.EmailAddress,
        a.OptFurtherContact,
        a.MemberNumber,
        a.MarketingConsent,
        a.Gender,
        pid.PIDType,
        pid.PIDCode,
        a.PersonalIdentifierValue PIDValue,
		a.DOB as DOBUTC,
		a.StateOfArrival,
        a.MemberTypeId
    from
        penguin_tblCustomer_uscm a
        inner join penguin_tblQuoteCustomer_uscm qc on
            qc.CustomerID = a.CustomerID
        cross apply dbo.fn_GetQuoteDomainKeys(qc.QuoteID, 'CM', 'US') dk
        outer apply
        (
            select top 1
                pid.Type PIDType,
                pid.Code PIDCode
            from
                penguin_tblPersonalIdentifier_uscm pid
            where
                pid.ID = a.PersonalIdentifierID
        ) pid


    if object_id('[db-au-cmdwh].dbo.penCustomer') is null
    begin

        create table [db-au-cmdwh].dbo.[penCustomer]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [CustomerKey] varchar(41) null,
            [CustomerID] int null,
            [Title] nvarchar(50) null,
            [FirstName] nvarchar(100) null,
            [LastName] nvarchar(100) null,
            [DOB] datetime null,
            [AddressLine1] nvarchar(100) null,
            [AddressLine2] nvarchar(100) null,
            [PostCode] nvarchar(50) null,
            [Town] nvarchar(50) null,
            [State] nvarchar(100) null,
            [Country] nvarchar(100) null,
            [HomePhone] varchar(50) null,
            [WorkPhone] varchar(50) null,
            [MobilePhone] varchar(50) null,
            [EmailAddress] nvarchar(255) null,
            [OptFurtherContact] bit null,
            [MemberNumber] nvarchar(25) null,
            [DomainKey] varchar(41) null,
            [DomainID] int null,
            [MarketingConsent] bit null,
            [Gender] nchar(2) null,
            [PIDType] nvarchar(100),
            [PIDCode] nvarchar(50),
            [PIDValue] nvarchar(256),
			[DOBUTC] datetime null,
			[StateOfArrival] varchar(100),
            MemberTypeID int null
        )

        create clustered index idx_penCustomer_CustomerKey on [db-au-cmdwh].dbo.penCustomer(CustomerKey)

    end
    else
    begin

        delete from [db-au-cmdwh].dbo.penCustomer
        where
            CustomerKey in
            (
                select CustomerKey
                from
                    etl_penCustomer
            )

    end


    insert [db-au-cmdwh].dbo.penCustomer with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        CustomerKey,
        DomainID,
        CustomerID,
        Title,
        FirstName,
        LastName,
        DOB,
        AddressLine1,
        AddressLine2,
        PostCode,
        Town,
        [State],
        Country,
        HomePhone,
        WorkPhone,
        MobilePhone,
        EmailAddress,
        OptFurtherContact,
        MemberNumber,
        MarketingConsent,
        Gender,
        PIDType,
        PIDCode,
        PIDValue,
		DOBUTC,
		StateOfArrival,
        MemberTypeId
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        CustomerKey,
        DomainID,
        CustomerID,
        Title,
        FirstName,
        LastName,
        DOB,
        AddressLine1,
        AddressLine2,
        PostCode,
        Town,
        [State],
        Country,
        HomePhone,
        WorkPhone,
        MobilePhone,
        EmailAddress,
        OptFurtherContact,
        MemberNumber,
        MarketingConsent,
        Gender,
        PIDType,
        PIDCode,
        PIDValue,
		DOBUTC,
		StateOfArrival,
        MemberTypeId
    from
        etl_penCustomer

end


GO
