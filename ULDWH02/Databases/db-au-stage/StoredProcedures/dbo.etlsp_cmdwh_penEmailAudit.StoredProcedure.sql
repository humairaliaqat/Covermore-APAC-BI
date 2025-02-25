USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penEmailAudit]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penEmailAudit]
as
begin
/*
20130617 - LS - TFS 7664/8556/8557, UK Penguin
20130726 - LT - Amended proceudre to cater for UK Penguin ETL/Refresh window.
20140217 - LT - Added ExtraData column
20140613 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
20140617 - LS - TFS 12416, schema and index cleanup
20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
20140805 - LT - TFS 13021, changed AuditReference from varchar(20) to varchar(50)
20160321 - LT - Penguin 18, added US penguin instance
*/

    set nocount on

    if object_id('etl_penEmailAudit') is not null
        drop table etl_penEmailAudit

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, ID) as EmailAuditKey,
        ID as EmailAuditID,
        dbo.xfn_ConvertUTCtoLocal(SentDate, TimeZone) as SentDate,
        Sender,
        [Status],
        Recipients,
        AuditReference,
        AuditReferenceTypeID,
        [Subject],
        Body,
        DomainKey,
        DomainID,
        cast(ExtraData as XML) as ExtraData
    into etl_penEmailAudit
    from
        penguin_tblEmailAudit_aucm
        cross apply dbo.fn_GetDomainKeys(DomainId, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar,ID) as EmailAuditKey,
        ID as EmailAuditID,
        dbo.xfn_ConvertUTCtoLocal(SentDate, TimeZone) as SentDate,
        Sender,
        [Status],
        Recipients,
        AuditReference,
        AuditReferenceTypeID,
        [Subject],
        Body,
        DomainKey,
        DomainID,
        cast(ExtraData as XML) as ExtraData
    from
        penguin_tblEmailAudit_autp
        cross apply dbo.fn_GetDomainKeys(DomainId, 'TIP', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar,ID) as EmailAuditKey,
        ID as EmailAuditID,
        dbo.xfn_ConvertUTCtoLocal(SentDate, TimeZone) as SentDate,
        Sender,
        [Status],
        Recipients,
        AuditReference,
        AuditReferenceTypeID,
        [Subject],
        Body,
        DomainKey,
        DomainID,
        cast(ExtraData as XML) as ExtraData
    from
        penguin_tblEmailAudit_ukcm
        cross apply dbo.fn_GetDomainKeys(DomainId, 'CM', 'UK') dk
		
    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar,ID) as EmailAuditKey,
        ID as EmailAuditID,
        dbo.xfn_ConvertUTCtoLocal(SentDate, TimeZone) as SentDate,
        Sender,
        [Status],
        Recipients,
        AuditReference,
        AuditReferenceTypeID,
        [Subject],
        Body,
        DomainKey,
        DomainID,
        cast(ExtraData as XML) as ExtraData
    from
        penguin_tblEmailAudit_uscm
        cross apply dbo.fn_GetDomainKeys(DomainId, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penEmailAudit') is null
    begin

        create table [db-au-cmdwh].dbo.[penEmailAudit]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [EmailAuditKey] varchar(41) not null,
            [EmailAuditID] bigint not null,
            [SentDate] datetime null,
            [Sender] varchar(50) null,
            [Status] bit null,
            [Recipients] varchar(200) null,
            [AuditReference] varchar(20) null,
            [AuditReferenceTypeID] int null,
            [Subject] nvarchar(200) null,
            [Body] nvarchar(max) null,
            [DomainKey] varchar(41) null,
            [DomainID] int null,
            [ExtraData] xml null
        )

        create nonclustered index idx_penEmailAudit_CompanyKey on [db-au-cmdwh].dbo.penEmailAudit(CompanyKey)
        create nonclustered index idx_penEmailAudit_CountryKey on [db-au-cmdwh].dbo.penEmailAudit(CountryKey)
        create nonclustered index idx_penEmailAudit_EmailAuditKey on [db-au-cmdwh].dbo.penEmailAudit(EmailAuditKey)
        create nonclustered index idx_penEmailAudit_SentDate on [db-au-cmdwh].dbo.penEmailAudit(SentDate)

    end
    else
    begin

        delete a
        from
            [db-au-cmdwh].dbo.penEmailAudit a
            inner join etl_penEmailAudit b on
                a.EmailAuditKey collate database_default = b.EmailAuditKey collate database_default

    end


    insert [db-au-cmdwh].dbo.penEmailAudit with(tablockx)
    (
        CountryKey,
        CompanyKey,
        EmailAuditKey,
        EmailAuditID,
        SentDate,
        Sender,
        [Status],
        Recipients,
        AuditReference,
        AuditReferenceTypeID,
        [Subject],
        Body,
        DomainKey,
        DomainID,
        ExtraData
    )
    select
        CountryKey,
        CompanyKey,
        EmailAuditKey,
        EmailAuditID,
        SentDate,
        Sender,
        [Status],
        Recipients,
        AuditReference,
        AuditReferenceTypeID,
        [Subject],
        Body,
        DomainKey,
        DomainID,
        ExtraData
    from
        etl_penEmailAudit

end


GO
