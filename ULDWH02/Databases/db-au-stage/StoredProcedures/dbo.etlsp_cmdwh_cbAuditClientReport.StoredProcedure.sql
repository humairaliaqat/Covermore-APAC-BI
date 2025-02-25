USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbAuditClientReport]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cbAuditClientReport]
as
begin
/*
20150716, LS, T16930, Carebase 4.6
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('etl_cbAuditClientReport') is not null
        drop table etl_cbAuditClientReport

    select
        'AU' CountryKey,
        'AU-' + convert(varchar, cr.ROWID) + '-' + left(cr.AUDIT_ACTION, 1) collate database_default + replace(replace(replace(replace(convert(varchar, cr.AUDIT_DATETIME, 126), ':', ''), '-', ''), '.', ''), 'T', '') collate database_default + convert(varchar, binary_checksum(*)) AuditKey,
        cr.AUDIT_USERNAME AuditUserName,
        cr.AUDIT_ACTION AuditAction,
        convert(date, dbo.xfn_ConvertUTCtoLocal(cr.AUDIT_DATETIME, 'AUS Eastern Standard Time')) AuditDateTime,
        cr.AUDIT_DATETIME AuditDateTimeUTC,
        left('AU-' + CASE_NO, 20) CaseKey,
        left('AU-' + convert(varchar, ROWID), 20) ClientReportKey,
        CASE_NO CaseNo,
        ROWID ClientReportID,
        AC CreatedByID,
        CreatedBy,
        convert(date, dbo.xfn_ConvertUTCtoLocal(CREATED_DT, 'AUS Eastern Standard Time')) CreateDate,
        CREATED_DT CreateTimeUTC,
        convert(date, dbo.xfn_ConvertUTCtoLocal(NOTE_DATE, 'AUS Eastern Standard Time')) NoteDate,
        dbo.xfn_ConvertUTCtoLocal(NOTE_DATE, 'AUS Eastern Standard Time') NoteTime,
        NOTE_DATE NoteTimeUTC,
        case
            when type = 'RO' then 'Routine'
            when type = 'SU' then 'Semi Urgent'
            when type = 'UP' then 'Update'
            when type = 'UR' then 'Urgent'
            else 'Undefined'
        end NoteType,
        Notes,
        CHASE_COVER IsChaseCover,
        case
            when HEADER = 'Y' then 1
            else 0
        end IsHeader,
        case
            when CANCEL = 'Y' then 1
            else 0
        end IsCancelled,
        cr.URGENCY_ID UrgencyID,
        u.DESCRIPTION Urgency,
        Reason,
        EmailDate,
        cr.IsDeleted,
        EmailDetails
    into etl_cbAuditClientReport
    from
        carebase_AUDIT_CLR_CLREPORT_aucm cr
        left join carebase_tblCRUrgency_aucm u on
            u.URGENCY_ID = cr.URGENCY_ID
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME CreatedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = cr.AC
        ) ob

    if object_id('[db-au-cmdwh].dbo.cbAuditClientReport') is null
    begin

        create table [db-au-cmdwh].dbo.cbAuditClientReport
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [AuditKey] varchar(50) not null,
            [AuditUserName] nvarchar(150) null,
            [AuditDateTime] datetime not null,
            [AuditDateTimeUTC] datetime not null,
            [AuditAction] char(1) not null,
            [CaseKey] nvarchar(20) not null,
            [ClientReportKey] nvarchar(20) not null,
            [CaseNo] nvarchar(15) not null,
            [ClientReportID] int not null,
            [CreatedByID] nvarchar(30) null,
            [CreatedBy] nvarchar(55) null,
            [CreateDate] datetime null,
            [CreateTimeUTC] datetime null,
            [NoteDate] datetime null,
            [NoteTime] datetime null,
            [NoteTimeUTC] datetime null,
            [NoteType] nvarchar(15) null,
            [Notes] nvarchar(max) null,
            [IsChaseCover] bit null,
            [IsHeader] bit null,
            [IsCancelled] bit null,
            [UrgencyID] int null,
            [Urgency] nvarchar(100) null,
            [Reason] nvarchar(2000) null,
            [EmailDate] datetime null,
            [IsDeleted] bit null,
            [EmailDetails] nvarchar(max) null
        )

        create clustered index idx_cbAuditClientReport_BIRowID on [db-au-cmdwh].dbo.cbAuditClientReport(BIRowID)
        create nonclustered index idx_cbAuditClientReport_AuditKey on [db-au-cmdwh].dbo.cbAuditClientReport(AuditKey)
        create nonclustered index idx_cbAuditClientReport_ClientReportKey on [db-au-cmdwh].dbo.cbAuditClientReport(ClientReportKey)

    end


    begin transaction cbAuditClientReport

    begin try

        delete
        from [db-au-cmdwh].dbo.cbAuditClientReport
        where
            AuditKey in
            (
                select
                    AuditKey
                from
                    etl_cbAuditClientReport
            )

        insert into [db-au-cmdwh].dbo.cbAuditClientReport with(tablock)
        (
            CountryKey,
            AuditKey,
            AuditUserName,
            AuditDateTime,
            AuditDateTimeUTC,
            AuditAction,
            CaseKey,
            ClientReportKey,
            CaseNo,
            ClientReportID,
            CreatedByID,
            CreatedBy,
            CreateDate,
            CreateTimeUTC,
            NoteDate,
            NoteTime,
            NoteTimeUTC,
            NoteType,
            Notes,
            IsChaseCover,
            IsHeader,
            IsCancelled,
            UrgencyID,
            Urgency,
            Reason,
            EmailDate,
            IsDeleted,
            EmailDetails
        )
        select
            CountryKey,
            AuditKey,
            AuditUserName,
            AuditDateTime,
            AuditDateTimeUTC,
            AuditAction,
            CaseKey,
            ClientReportKey,
            CaseNo,
            ClientReportID,
            CreatedByID,
            CreatedBy,
            CreateDate,
            CreateTimeUTC,
            NoteDate,
            NoteTime,
            NoteTimeUTC,
            NoteType,
            Notes,
            IsChaseCover,
            IsHeader,
            IsCancelled,
            UrgencyID,
            Urgency,
            Reason,
            EmailDate,
            IsDeleted,
            EmailDetails
        from
            etl_cbAuditClientReport

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbAuditClientReport

        exec syssp_genericerrorhandler 'cbAuditClientReport data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbAuditClientReport

end
GO
