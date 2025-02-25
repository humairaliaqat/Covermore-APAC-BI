USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penBankAccount]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penBankAccount]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20130527
Prerequisite:   Requires Penguin Data Model ETL successfully run.
Description:    BankAccount table contains bank account attributes.
                This transformation adds essential key fields and implemented slow changing dimension technique to track
                changes to the agency attributes.
Change History:
                20130527 - LT - Procedure created
                20130617 - LS - TFS 7664/8556/8557, UK Penguin
                20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
                20130731 - LS - Remove group data, they shouldn't be in the bank account
                20131025 - LS - Case 19444, duplicate data caused by multiple payment process agents
                                limit this to first payment process agent (it shouldn't be in the bank account data anyway)
                20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
                                drop unused columns (group data)
                20140617 - LS - TFS 12416, schema and index cleanup
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
				20160321 - LT - Penguin 18.0, added US Penguin Instance

*************************************************************************************************************************************/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penBankAccount') is not null
        drop table etl_penBankAccount

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, b.BankAccountID) as BankAccountKey,
        b.BankAccountID,
        b.CompanyID,
        c.DomainID,
        b.AccountName,
        b.Code as AccountCode,
        b.BSB as AccountBSB,
        b.AccountNumber,
        b.[Status] as AccountStatus,
        b.StartDate as AccountStartDate,
        b.EndDate as AccountEndDate,
        dbo.xfn_ConvertUTCtoLocal(b.CreateDateTime, TimeZone) as AccountCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(b.UpdateDateTime, TimeZone) as AccountUpdateDateTime,
        b.CreateDateTime as AccountCreateDateTimeUTC,
        b.UpdateDateTime as AccountUpdateDateTimeUTC,
        c.CompanyName,
        c.FullName as CompanyFullName,
        c.Code as CompanyCode,
        c.Underwriter,
        c.ABN as CompanyABN,
        c.Status as CompanyStatus,
        dbo.xfn_ConvertUTCtoLocal(c.CreateDateTime, TimeZone) as CompanyCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(c.UpdateDateTime, TimeZone) as CompanyUpdateDateTime,
        c.CreateDateTime as CompanyCreateDateTimeUTC,
        c.UpdateDateTime as CompanyUpdateDateTimeUTC,
        ppa.PaymentProcessAgentID,
        ppa.[Name] as PaymentProcessAgentName,
        ppa.[Code] as PaymentProcessAgentCode,
        ppa.[Status] as PaymentProcessAgentStatus
    into etl_penBankAccount
    from
        dbo.penguin_tblBankAccount_aucm b
        cross apply
        (
            select top 1
                c.CompanyId,
                c.DomainId,
                c.CompanyName,
                c.FullName,
                c.Code,
                c.Underwriter,
                c.ABN,
                c.Status,
                c.CreateDateTime,
                c.UpdateDateTime
            from
                dbo.penguin_tblCompany_aucm c
            where
                b.CompanyID = c.CompanyID
            order by
                c.CreateDateTime
        ) c
        cross apply
        (
            select top 1
                ppa.PaymentProcessAgentID,
                ppa.[Name],
                ppa.[Code],
                ppa.[Status]
            from
                dbo.penguin_tblPaymentProcessAgent_aucm ppa
            where
                c.CompanyID = ppa.CompanyID
            order by
                ppa.PaymentProcessAgentId
        ) ppa
        cross apply dbo.fn_GetDomainKeys(c.DomainID, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, b.BankAccountID) as BankAccountKey,
        b.BankAccountID,
        b.CompanyID,
        c.DomainID,
        b.AccountName,
        b.Code as AccountCode,
        b.BSB as AccountBSB,
        b.AccountNumber,
        b.[Status] as AccountStatus,
        b.StartDate as AccountStartDate,
        b.EndDate as AccountEndDate,
        dbo.xfn_ConvertUTCtoLocal(b.CreateDateTime, TimeZone) as AccountCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(b.UpdateDateTime, TimeZone) as AccountUpdateDateTime,
        b.CreateDateTime as AccountCreateDateTimeUTC,
        b.UpdateDateTime as AccountUpdateDateTimeUTC,
        c.CompanyName,
        c.FullName as CompanyFullName,
        c.Code as CompanyCode,
        c.Underwriter,
        c.ABN as CompanyABN,
        c.Status as CompanyStatus,
        dbo.xfn_ConvertUTCtoLocal(c.CreateDateTime, TimeZone) as CompanyCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(c.UpdateDateTime, TimeZone) as CompanyUpdateDateTime,
        c.CreateDateTime as CompanyCreateDateTimeUTC,
        c.UpdateDateTime as CompanyUpdateDateTimeUTC,
        ppa.PaymentProcessAgentID,
        ppa.[Name] as PaymentProcessAgentName,
        ppa.[Code] as PaymentProcessAgentCode,
        ppa.[Status] as PaymentProcessAgentStatus
    from
        dbo.penguin_tblBankAccount_autp b
        cross apply
        (
            select top 1
                c.CompanyId,
                c.DomainId,
                c.CompanyName,
                c.FullName,
                c.Code,
                c.Underwriter,
                c.ABN,
                c.Status,
                c.CreateDateTime,
                c.UpdateDateTime
            from
                dbo.penguin_tblCompany_autp c
            where
                b.CompanyID = c.CompanyID
            order by
                c.CreateDateTime
        ) c
        cross apply
        (
            select top 1
                ppa.PaymentProcessAgentID,
                ppa.[Name],
                ppa.[Code],
                ppa.[Status]
            from
                dbo.penguin_tblPaymentProcessAgent_autp ppa
            where
                c.CompanyID = ppa.CompanyID
            order by
                ppa.PaymentProcessAgentId
        ) ppa
        cross apply dbo.fn_GetDomainKeys(c.DomainID, 'TIP', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, b.BankAccountID) as BankAccountKey,
        b.BankAccountID,
        b.CompanyID,
        c.DomainID,
        b.AccountName,
        b.Code as AccountCode,
        b.BSB as AccountBSB,
        b.AccountNumber,
        b.[Status] as AccountStatus,
        b.StartDate as AccountStartDate,
        b.EndDate as AccountEndDate,
        dbo.xfn_ConvertUTCtoLocal(b.CreateDateTime, TimeZone) as AccountCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(b.UpdateDateTime, TimeZone) as AccountUpdateDateTime,
        b.CreateDateTime as AccountCreateDateTimeUTC,
        b.UpdateDateTime as AccountUpdateDateTimeUTC,
        c.CompanyName,
        c.FullName as CompanyFullName,
        c.Code as CompanyCode,
        c.Underwriter,
        c.ABN as CompanyABN,
        c.Status as CompanyStatus,
        dbo.xfn_ConvertUTCtoLocal(c.CreateDateTime, TimeZone) as CompanyCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(c.UpdateDateTime, TimeZone) as CompanyUpdateDateTime,
        c.CreateDateTime as CompanyCreateDateTimeUTC,
        c.UpdateDateTime as CompanyUpdateDateTimeUTC,
        ppa.PaymentProcessAgentID,
        ppa.[Name] as PaymentProcessAgentName,
        ppa.[Code] as PaymentProcessAgentCode,
        ppa.[Status] as PaymentProcessAgentStatus
    from
        dbo.penguin_tblBankAccount_ukcm b
        cross apply
        (
            select top 1
                c.CompanyId,
                c.DomainId,
                c.CompanyName,
                c.FullName,
                c.Code,
                c.Underwriter,
                c.ABN,
                c.Status,
                c.CreateDateTime,
                c.UpdateDateTime
            from
                dbo.penguin_tblCompany_ukcm c
            where
                b.CompanyID = c.CompanyID
            order by
                c.CreateDateTime
        ) c
        cross apply
        (
            select top 1
                ppa.PaymentProcessAgentID,
                ppa.[Name],
                ppa.[Code],
                ppa.[Status]
            from
                dbo.penguin_tblPaymentProcessAgent_ukcm ppa
            where
                c.CompanyID = ppa.CompanyID
            order by
                ppa.PaymentProcessAgentId
        ) ppa
        cross apply dbo.fn_GetDomainKeys(c.DomainID, 'CM', 'UK') dk

    union all

    select
        CountryKey,
        CompanyKey,
        DomainKey,
        PrefixKey + convert(varchar, b.BankAccountID) as BankAccountKey,
        b.BankAccountID,
        b.CompanyID,
        c.DomainID,
        b.AccountName,
        b.Code as AccountCode,
        b.BSB as AccountBSB,
        b.AccountNumber,
        b.[Status] as AccountStatus,
        b.StartDate as AccountStartDate,
        b.EndDate as AccountEndDate,
        dbo.xfn_ConvertUTCtoLocal(b.CreateDateTime, TimeZone) as AccountCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(b.UpdateDateTime, TimeZone) as AccountUpdateDateTime,
        b.CreateDateTime as AccountCreateDateTimeUTC,
        b.UpdateDateTime as AccountUpdateDateTimeUTC,
        c.CompanyName,
        c.FullName as CompanyFullName,
        c.Code as CompanyCode,
        c.Underwriter,
        c.ABN as CompanyABN,
        c.Status as CompanyStatus,
        dbo.xfn_ConvertUTCtoLocal(c.CreateDateTime, TimeZone) as CompanyCreateDateTime,
        dbo.xfn_ConvertUTCtoLocal(c.UpdateDateTime, TimeZone) as CompanyUpdateDateTime,
        c.CreateDateTime as CompanyCreateDateTimeUTC,
        c.UpdateDateTime as CompanyUpdateDateTimeUTC,
        ppa.PaymentProcessAgentID,
        ppa.[Name] as PaymentProcessAgentName,
        ppa.[Code] as PaymentProcessAgentCode,
        ppa.[Status] as PaymentProcessAgentStatus
    from
        dbo.penguin_tblBankAccount_uscm b
        cross apply
        (
            select top 1
                c.CompanyId,
                c.DomainId,
                c.CompanyName,
                c.FullName,
                c.Code,
                c.Underwriter,
                c.ABN,
                c.Status,
                c.CreateDateTime,
                c.UpdateDateTime
            from
                dbo.penguin_tblCompany_uscm c
            where
                b.CompanyID = c.CompanyID
            order by
                c.CreateDateTime
        ) c
        cross apply
        (
            select top 1
                ppa.PaymentProcessAgentID,
                ppa.[Name],
                ppa.[Code],
                ppa.[Status]
            from
                dbo.penguin_tblPaymentProcessAgent_uscm ppa
            where
                c.CompanyID = ppa.CompanyID
            order by
                ppa.PaymentProcessAgentId
        ) ppa
        cross apply dbo.fn_GetDomainKeys(c.DomainID, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penBankAccount') is null
    begin

        create table [db-au-cmdwh].dbo.[penBankAccount]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [DomainKey] varchar(41) null,
            [BankAccountKey] varchar(41) null,
            [BankAccountID] int null,
            [CompanyID] int null,
            [DomainID] int null,
            [AccountName] nvarchar(255) null,
            [AccountCode] varchar(6) null,
            [AccountBSB] varchar(10) null,
            [AccountNumber] varchar(30) null,
            [AccountStatus] varchar(15) null,
            [AccountStartDate] datetime null,
            [AccountEndDate] datetime null,
            [AccountCreateDateTime] datetime null,
            [AccountUpdateDateTime] datetime null,
            [AccountCreateDateTimeUTC] datetime null,
            [AccountUpdateDateTimeUTC] datetime null,
            [CompanyName] nvarchar(255) null,
            [CompanyFullName] nvarchar(255) null,
            [CompanyCode] varchar(3) null,
            [Underwriter] nvarchar(255) null,
            [CompanyABN] nvarchar(50) null,
            [CompanyStatus] varchar(15) null,
            [CompanyCreateDateTime] datetime null,
            [CompanyUpdateDateTime] datetime null,
            [CompanyCreateDateTimeUTC] datetime null,
            [CompanyUpdateDateTimeUTC] datetime null,
            [PaymentProcessAgentID] int null,
            [PaymentProcessAgentName] nvarchar(55) null,
            [PaymentProcessAgentCode] nvarchar(3) null,
            [PaymentProcessAgentStatus] varchar(15) null
        )

        create clustered index idx_penBankAccount_BankAccountKey on [db-au-cmdwh].dbo.penBankAccount(BankAccountKey)
        create nonclustered index idx_penBankAccount_CountryKey on [db-au-cmdwh].dbo.penBankAccount(CountryKey)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penBankAccount a
            inner join etl_penBankAccount b on
                a.BankAccountKey = b.BankAccountKey
    end

    insert [db-au-cmdwh].dbo.penBankAccount with(tablockx)
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        BankAccountKey,
        BankAccountID,
        CompanyID,
        DomainID,
        AccountName,
        AccountCode,
        AccountBSB,
        AccountNumber,
        AccountStatus,
        AccountStartDate,
        AccountEndDate,
        AccountCreateDateTime,
        AccountUpdateDateTime,
        AccountCreateDateTimeUTC,
        AccountUpdateDateTimeUTC,
        CompanyName,
        CompanyFullName,
        CompanyCode,
        Underwriter,
        CompanyABN,
        CompanyStatus,
        CompanyCreateDateTime,
        CompanyUpdateDateTime,
        CompanyCreateDateTimeUTC,
        CompanyUpdateDateTimeUTC,
        PaymentProcessAgentID,
        PaymentProcessAgentName,
        PaymentProcessAgentCode,
        PaymentProcessAgentStatus
    )
    select
        CountryKey,
        CompanyKey,
        DomainKey,
        BankAccountKey,
        BankAccountID,
        CompanyID,
        DomainID,
        AccountName,
        AccountCode,
        AccountBSB,
        AccountNumber,
        AccountStatus,
        AccountStartDate,
        AccountEndDate,
        AccountCreateDateTime,
        AccountUpdateDateTime,
        AccountCreateDateTimeUTC,
        AccountUpdateDateTimeUTC,
        CompanyName,
        CompanyFullName,
        CompanyCode,
        Underwriter,
        CompanyABN,
        CompanyStatus,
        CompanyCreateDateTime,
        CompanyUpdateDateTime,
        CompanyCreateDateTimeUTC,
        CompanyUpdateDateTimeUTC,
        PaymentProcessAgentID,
        PaymentProcessAgentName,
        PaymentProcessAgentCode,
        PaymentProcessAgentStatus
    from
        etl_penBankAccount

end


GO
