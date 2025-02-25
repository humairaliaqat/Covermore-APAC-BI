USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbAddress]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cbAddress]
as
begin
/*
20131014, LS,   schema changes
                extra contact info (passport)
20131202, LS,   schema changes
                address history
20140714, LS,   TFS12109
                drop unused columns
                enlarge column size
20140715, LS,   use transaction (as carebase has intra-day refreshes)
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('[db-au-cmdwh].dbo.cbAddress') is null
    begin

        create table [db-au-cmdwh].dbo.cbAddress
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) not null,
            [AddressKey] nvarchar(20) not null,
            [CaseNo] nvarchar(15) not null,
            [AddressID] int not null,
            [CreateDate] datetime null,
            [CreateDateUTC] datetime null,
            [AddressType] nvarchar(25) null,
            [IsOverwrite] bit null,
            [IsDefault] bit null,
            [IsConsent] bit null,
            [FirstName] varbinary(500) null,
            [Surname] varbinary(500) null,
            [DOB] varbinary(200) null,
            [Company] varbinary(500) null,
            [Street] varbinary(500) null,
            [Town] varbinary(500) null,
            [Country] varbinary(500) null,
            [PostCode] varbinary(500) null,
            [Phone] varbinary(500) null,
            [Mobile] varbinary(500) null,
            [Fax] varbinary(500) null,
            [Telex] varbinary(500) null,
            [Email] varbinary(500) null,
            [CreatedBy] nvarchar(50) null,
            [ModifiedBy] nvarchar(50) null,
            [ModifiedByID] nvarchar(30) null,
            [ModifiedDate] datetime null,
            [isCurrentLocation] bit null,
            [ArrivedDate] date null,
            [CountryCode] nvarchar(3) null,
            [CountryName] nvarchar(25) null,
            [CreatedByID] nvarchar(30) null
        )

        create clustered index idx_cbAddress_BIRowID on [db-au-cmdwh].dbo.cbAddress(BIRowID)
        create nonclustered index idx_cbAddress_AddressID on [db-au-cmdwh].dbo.cbAddress(AddressID)
        create nonclustered index idx_cbAddress_AddressKey on [db-au-cmdwh].dbo.cbAddress(AddressKey)
        create nonclustered index idx_cbAddress_AddressType on [db-au-cmdwh].dbo.cbAddress(AddressType,CaseNo)
        create nonclustered index idx_cbAddress_CaseKey on [db-au-cmdwh].dbo.cbAddress(CaseKey, isCurrentLocation)
        create nonclustered index idx_cbAddress_CaseNo on [db-au-cmdwh].dbo.cbAddress(CaseNo,CountryKey)

    end

    if object_id('tempdb..#cbAddress') is not null
        drop table #cbAddress

    select
        'AU' CountryKey,
        left('AU-' + CASE_NO, 20) CaseKey,
        left('AU-' + convert(varchar, ROWID), 20) AddressKey,
        case_no CaseNo,
        ROWID AddressID,
        dbo.xfn_ConvertUTCtoLocal(CREATED_DT, 'AUS Eastern Standard Time') CreateDate,
        CREATED_DT CreateDateUTC,
        descriptn AddressType,
        case
            when overwrite = 'Y' then 1
            else 0
        end IsOverwrite,
        case
            when def_flag = 'B' then 1
            else 0
        end IsDefault,
        case
            when CONSENT = 'Y' then 1
            else 0
        end IsConsent,
        EncryptFirstName FirstName,
        EncryptSurname Surname,
        EncryptDOB DOB,
        EncryptCompany Company,
        EncryptStreet Street,
        EncryptTown Town,
        EncryptCountry Country,
        EncryptPostCode PostCode,
        EncryptPhone Phone,
        EncryptMobile Mobile,
        EncryptFax Fax,
        EncryptTelex Telex,
        EncryptEmail Email,
        CreatedBy,
        CREATED_BY CreatedByID,
        ModifiedBy,
        MODIFIED_BY ModifiedByID,
        dbo.xfn_ConvertUTCtoLocal(MODIFIED_DT, 'AUS Eastern Standard Time') ModifiedDate,
        isCurrentLocation,
        ArrivedDate,
        CNTRY_CODE CountryCode,
        CountryName
    into #cbAddress
    from
        carebase_CAD_ADDRESS_aucm a
        left join carebase_UAT_ADDRTYPE_aucm at on
            at.TYPE = a.TYPE
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME CreatedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = a.CREATED_BY
        ) cb
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME ModifiedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = a.MODIFIED_BY
        ) mb
        outer apply
        (
            select top 1
                CNTRY_DESC CountryName
            from
                carebase_UCO_COUNTRY_aucm co
            where
                co.CNTRY_CODE = a.CNTRY_CODE
        ) co
    where
        CASE_NO is not null


    begin transaction cbAddress

    begin try

        delete
        from
            [db-au-cmdwh].dbo.cbAddress
        where
            AddressKey in
            (
                select
                    left('AU-' + convert(varchar, ROWID), 20) collate database_default
                from
                    carebase_CAD_ADDRESS_aucm
            )

        insert into [db-au-cmdwh].dbo.cbAddress with(tablock)
        (
            CountryKey,
            CaseKey,
            AddressKey,
            CaseNo,
            AddressID,
            CreateDate,
            CreateDateUTC,
            AddressType,
            IsOverwrite,
            IsDefault,
            IsConsent,
            FirstName,
            Surname,
            DOB,
            Company,
            Street,
            Town,
            Country,
            PostCode,
            Phone,
            Mobile,
            Fax,
            Telex,
            Email,
            CreatedBy,
            CreatedByID,
            ModifiedBy,
            ModifiedByID,
            ModifiedDate,
            isCurrentLocation,
            ArrivedDate,
            CountryCode,
            CountryName
        )
        select
            CountryKey,
            CaseKey,
            AddressKey,
            CaseNo,
            AddressID,
            CreateDate,
            CreateDateUTC,
            AddressType,
            IsOverwrite,
            IsDefault,
            IsConsent,
            FirstName,
            Surname,
            DOB,
            Company,
            Street,
            Town,
            Country,
            PostCode,
            Phone,
            Mobile,
            Fax,
            Telex,
            Email,
            CreatedBy,
            CreatedByID,
            ModifiedBy,
            ModifiedByID,
            ModifiedDate,
            isCurrentLocation,
            ArrivedDate,
            CountryCode,
            CountryName
        from
            #cbAddress

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbAddress

        exec syssp_genericerrorhandler 'cbAddress data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbAddress


    --address history
    if object_id('[db-au-cmdwh].dbo.cbAddressHistory') is null
    begin

        create table [db-au-cmdwh].dbo.cbAddressHistory
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) null,
            [AddressKey] nvarchar(20) not null,
            [AddressHistoryKey] nvarchar(20) not null,
            [CaseNo] nvarchar(15) null,
            [AddressHistoryID] int not null,
            [AddressID] int not null,
            [ModifiedBy] nvarchar(50) null,
            [ModifiedByID] nvarchar(30) null,
            [ArrivedDate] datetime null,
            [AddedDate] datetime null
        )

        create clustered index idx_cbAddressHistory_BIRowID on [db-au-cmdwh].dbo.cbAddressHistory(BIRowID)
        create nonclustered index idx_cbAddressHistory_AddressHistoryKey on [db-au-cmdwh].dbo.cbAddressHistory(AddressKey)
        create nonclustered index idx_cbAddressHistory_AddressID on [db-au-cmdwh].dbo.cbAddressHistory(AddressID)
        create nonclustered index idx_cbAddressHistory_AddressKey on [db-au-cmdwh].dbo.cbAddressHistory(AddressKey)
        create nonclustered index idx_cbAddressHistory_CaseKey on [db-au-cmdwh].dbo.cbAddressHistory(CaseKey)
        create nonclustered index idx_cbAddressHistory_CaseNo on [db-au-cmdwh].dbo.cbAddressHistory(CaseNo,CountryKey)

    end

    if object_id('tempdb..#cbAddressHistory') is not null
        drop table #cbAddressHistory

    select
        'AU' CountryKey,
        left('AU-' + CaseNo, 20) CaseKey,
        left('AU-' + convert(varchar, AddressID), 20) AddressKey,
        left('AU-' + convert(varchar, HistoryID), 20) AddressHistoryKey,
        CaseNo CaseNo,
        HistoryID AddressHistoryID,
        AddressID,
        mb.ModifiedBy,
        ah.ModifiedBy ModifiedByID,
        ArrivedDate,
        dbo.xfn_ConvertUTCtoLocal(AddedDate, 'AUS Eastern Standard Time') AddedDate
    into #cbAddressHistory
    from
        carebase_tblAddressHistory_aucm ah
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME ModifiedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = ah.ModifiedBy
        ) mb

    begin transaction cbAddressHistory

    begin try

        delete
        from
            [db-au-cmdwh].dbo.cbAddressHistory
        where
            AddressHistoryKey in
            (
                select
                    left('AU-' + convert(varchar, HistoryID), 20) collate database_default
                from
                    carebase_tblAddressHistory_aucm
            )

        insert into [db-au-cmdwh].dbo.cbAddressHistory with(tablock)
        (
            CountryKey,
            CaseKey,
            AddressKey,
            AddressHistoryKey,
            CaseNo,
            AddressHistoryID,
            AddressID,
            ModifiedBy,
            ModifiedByID,
            ArrivedDate,
            AddedDate
        )
        select
            CountryKey,
            CaseKey,
            AddressKey,
            AddressHistoryKey,
            CaseNo,
            AddressHistoryID,
            AddressID,
            ModifiedBy,
            ModifiedByID,
            ArrivedDate,
            AddedDate
        from
            #cbAddressHistory

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbAddressHistory

        exec syssp_genericerrorhandler 'cbAddressHistory data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbAddressHistory


    --extra info

    if object_id('[db-au-cmdwh].dbo.cbAddressPassport') is null
    begin

        create table [db-au-cmdwh].dbo.cbAddressPassport
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) not null,
            [AddressKey] nvarchar(20) not null,
            [CaseNo] nvarchar(15) not null,
            [AddressID] int not null,
            [PassportNumber] nvarchar(500) null,
            [PassportCountry] nvarchar(500) null,
            [PassportExpiryDate] nvarchar(500) null,
            [PassportType] nvarchar(500) null
        )

        create clustered index idx_cbAddressPassport_BIRowID on [db-au-cmdwh].dbo.cbAddressPassport(BIRowID)
        create nonclustered index idx_cbAddressPassport_AddressID on [db-au-cmdwh].dbo.cbAddressPassport(AddressID)
        create nonclustered index idx_cbAddressPassport_AddressKey on [db-au-cmdwh].dbo.cbAddressPassport(AddressKey)
        create nonclustered index idx_cbAddressPassport_CaseKey on [db-au-cmdwh].dbo.cbAddressPassport(CaseKey)
        create nonclustered index idx_cbAddressPassport_CaseNo on [db-au-cmdwh].dbo.cbAddressPassport(CaseNo,CountryKey)
        create nonclustered index idx_cbAddressPassport_PassportNumber on [db-au-cmdwh].dbo.cbAddressPassport(PassportNumber)

    end

    if object_id('tempdb..#cbAddressPassport') is not null
        drop table #cbAddressPassport

    select
        'AU' CountryKey,
        left('AU-' + CASE_NO, 20) CaseKey,
        left('AU-' + convert(varchar, Address_ID), 20) AddressKey,
        CASE_NO CaseNo,
        Address_ID AddressID,
        max(
            case
                when key_id = 1 then Value
                else ''
            end
        ) PassportNumber,
        max(
            case
                when key_id = 2 then Value
                else ''
            end
        ) PassportCountry,
        max(
            case
                when key_id = 3 then Value
                else ''
            end
        ) PassportExpiryDate,
        max(
            case
                when key_id = 4 then Value
                else ''
            end
        ) PassportType
    into #cbAddressPassport
    from
        carebase_tblAddressMaintenance_aucm
    where
        CASE_NO is not null
    group by
        CASE_NO,
        Address_ID


    begin transaction cbAddressPassport

    begin try

        delete
        from
            [db-au-cmdwh].dbo.cbAddressPassport
        where
            AddressKey in
            (
                select
                    left('AU-' + convert(varchar, Address_ID), 20) collate database_default
                from
                    carebase_tblAddressMaintenance_aucm
            )

        insert into [db-au-cmdwh].dbo.cbAddressPassport with(tablock)
        (
            CountryKey,
            CaseKey,
            AddressKey,
            CaseNo,
            AddressID,
            PassportNumber,
            PassportCountry,
            PassportExpiryDate,
            PassportType
        )
        select
            CountryKey,
            CaseKey,
            AddressKey,
            CaseNo,
            AddressID,
            PassportNumber,
            PassportCountry,
            PassportExpiryDate,
            PassportType
        from
            #cbAddressPassport

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbAddressPassport

        exec syssp_genericerrorhandler 'cbAddressPassport data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbAddressPassport


end

GO
