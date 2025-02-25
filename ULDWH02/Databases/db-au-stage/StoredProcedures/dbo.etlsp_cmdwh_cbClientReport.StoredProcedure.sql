USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbClientReport]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cbClientReport]
as
begin
/*
20131202, LS,   schema changes
                client report note
20140415, LS,   Case 20680, add approximate date of deletion
20140519, LS,   Case 20680, add initial flag
20140715, LS,   TFS12109
                use transaction (as carebase has intra-day refreshes)
20190219, RS,   orphan note records (without an associated CRID) are filtered out and not loaded to DW.
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('etl_cbClientReport') is not null
        drop table etl_cbClientReport

    select
        'AU' CountryKey,
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
        EmailDetails,
        case
            when cr.IsDeleted = 1 and ecr.IsDeleted is null then getdate()
            when cr.IsDeleted = 1 and ecr.IsDeleted = 1 then ecr.ApproximateDeleteDate
            else null
        end ApproximateDeleteDate
    into etl_cbClientReport
    from
        carebase_CLR_CLREPORT_aucm cr
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
        outer apply
        (
            select top 1
                IsDeleted,
                ApproximateDeleteDate
            from
                [db-au-cmdwh]..cbClientReport ecr
            where
                ecr.ClientReportID = cr.ROWID and
                ecr.CaseNo collate database_default = cr.CASE_NO collate database_default
        ) ecr

    if object_id('[db-au-cmdwh].dbo.cbClientReport') is null
    begin

        create table [db-au-cmdwh].dbo.cbClientReport
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
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
            [EmailDetails] nvarchar(max) null,
            [ApproximateDeleteDate] datetime null,
            [isInitialCR] bit not null default ((0))
        )

        create clustered index idx_cbClientReport_BIRowID on [db-au-cmdwh].dbo.cbClientReport(BIRowID)
        create nonclustered index idx_cbClientReport_ApproxDelete on [db-au-cmdwh].dbo.cbClientReport(ApproximateDeleteDate) include (CaseKey)
        create nonclustered index idx_cbClientReport_CaseKey on [db-au-cmdwh].dbo.cbClientReport(CaseKey) include (ClientReportKey,CreatedBy,CreateTimeUTC,EmailDate,isInitialCR,IsDeleted)
        create nonclustered index idx_cbClientReport_CaseNo on [db-au-cmdwh].dbo.cbClientReport(CaseNo,CountryKey)
        create nonclustered index idx_cbClientReport_ClientReportID on [db-au-cmdwh].dbo.cbClientReport(ClientReportID) include (CaseNo,IsDeleted,ApproximateDeleteDate,CaseKey)
        create nonclustered index idx_cbClientReport_CreateDate on [db-au-cmdwh].dbo.cbClientReport(CreateDate,CountryKey)
        create nonclustered index idx_cbClientReport_CreatedBy on [db-au-cmdwh].dbo.cbClientReport(CreatedBy,CreateDate)
        create nonclustered index idx_cbClientReport_NoteDate on [db-au-cmdwh].dbo.cbClientReport(NoteDate,CountryKey)
        create nonclustered index idx_cbClientReport_NoteType on [db-au-cmdwh].dbo.cbClientReport(NoteType,CountryKey)

    end


    begin transaction cbClientReport

    begin try

        delete
        from [db-au-cmdwh].dbo.cbClientReport
        where
            ClientReportKey in
            (
                select
                    left('AU-' + convert(varchar, ROWID), 20) collate database_default
                from
                    carebase_CLR_CLREPORT_aucm
            )

        insert into [db-au-cmdwh].dbo.cbClientReport with(tablock)
        (
            CountryKey,
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
            EmailDetails,
            ApproximateDeleteDate
        )
        select
            CountryKey,
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
            EmailDetails,
            ApproximateDeleteDate
        from
            etl_cbClientReport

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbClientReport

        exec syssp_genericerrorhandler 'cbClientReport data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbClientReport


    --update initial flag
    update cr
    set
        isInitialCR = 1
    from
        [db-au-cmdwh]..cbClientReport cr
    where
        cr.ClientReportKey in
        (
            select
                ClientReportKey
            from
                etl_cbClientReport
        ) and
        cr.ClientReportKey =
        (
            select top 1
                t.ClientReportKey
            from
                [db-au-cmdwh]..cbClientReport t
            where
                t.CaseKey = cr.CaseKey
            order by
                t.CreateTimeUTC
        )


    --CR Notes
    if object_id('[db-au-cmdwh].dbo.cbClientReportNote') is null
    begin

        create table [db-au-cmdwh].dbo.cbClientReportNote
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [ClientReportKey] nvarchar(20) not null,
            [NoteKey] nvarchar(20) not null,
            [CRNoteKey] nvarchar(20) not null,
            [ClientReportID] int not null,
            [NoteID] int not null,
            [CRNoteID] int not null,
            [AttachmentName] nvarchar(max) null,
            [CRNoteIncludeDate] datetime null,
            [CRAttachIncludeDate] datetime null
        )

        create clustered index idx_cbClientReportNote_BIRowID on [db-au-cmdwh].dbo.cbClientReportNote(BIRowID)
        create nonclustered index idx_cbClientReportNote_ClientReportKey on [db-au-cmdwh].dbo.cbClientReportNote(ClientReportKey)
        create nonclustered index idx_cbClientReportNote_NoteKey on [db-au-cmdwh].dbo.cbClientReportNote(NoteKey)
        create nonclustered index idx_cbClientReportNote_CRNoteKey on [db-au-cmdwh].dbo.cbClientReportNote(CRNoteKey)
        create nonclustered index idx_cbClientReportNote_CRNoteIncludeDate on [db-au-cmdwh].dbo.cbClientReportNote(CRNoteIncludeDate)

    end


    begin transaction cbClientReportNote

    begin try

        delete
        from [db-au-cmdwh].dbo.cbClientReportNote
        where
            CRNoteKey in
            (
                select
                    left('AU-' + convert(varchar, ROWID), 20) collate database_default
                from
                    carebase_tblCRNotes_aucm
            )

        insert into [db-au-cmdwh].dbo.cbClientReportNote with(tablock)
        (
            CountryKey,
            ClientReportKey,
            NoteKey,
            CRNoteKey,
            ClientReportID,
            NoteID,
            CRNoteID,
            AttachmentName,
            CRNoteIncludeDate,
            CRAttachIncludeDate
        )
        select
            'AU' CountryKey,
            left('AU-' + convert(varchar, CRID), 20) ClientReportKey,
            left('AU-' + convert(varchar, NoteID), 20) NoteKey,
            left('AU-' + convert(varchar, RowId), 20) CRNoteKey,
            CRID ClientReportID,
            NoteID,
            RowId CRNoteID,
            AttachmentName,
            dbo.xfn_ConvertUTCtoLocal(CRNoteIncludeDate, 'AUS Eastern Standard Time') CRNoteIncludeDate,
            dbo.xfn_ConvertUTCtoLocal(CRAttachIncludeDate, 'AUS Eastern Standard Time') CRAttachIncludeDate
        from
            carebase_tblCRNotes_aucm
			where CRID is not null--added on 7-feb-2019 to filter out orphan note records.

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbClientReportNote

        exec syssp_genericerrorhandler 'cbClientReportNote data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbClientReportNote


end
GO
