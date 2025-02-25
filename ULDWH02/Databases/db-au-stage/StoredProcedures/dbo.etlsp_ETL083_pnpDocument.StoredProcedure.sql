USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpDocument]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date: 2017-04-19
-- Description:    Transformation - pnpDocument
-- Modifications:
--        20180409 DM - Remove the Documents which no longer exist within Penelope
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpDocument]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(100),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Penelope',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-dtc].dbo.pnpDocument') is null
    begin
        create table [db-au-dtc].[dbo].[pnpDocument](
            DocumentSK int identity(1,1) primary key,
            DocumentMasterSK int,
            CreateUserSK int,
            UpdateUserSK int,
            DocumentID int,
            Notes nvarchar(max),
            SignatureTitle nvarchar(max),
            SignatureTextTop nvarchar(max),
            SignatureTextBottom nvarchar(max),
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            CreateUserID varchar(50),
            UpdateUserID varchar(50),
            RevFinalized varchar(5),
            DocumentMasterID int,
            RevUseStage varchar(5),
            RevUsePages varchar(5),
            [Type] nvarchar(35),
            IsExternal varchar(5),
            index idx_pnpDocument_DocumentMasterSK nonclustered (DocumentMasterSK),
            index idx_pnpDocument_CreateUserSK nonclustered (CreateUserSK),
            index idx_pnpDocument_UpdateUserSK nonclustered (UpdateUserSK),
            index idx_pnpDocument_DocumentID nonclustered (DocumentID),
            index idx_pnpDocument_CreateUserID nonclustered (CreateUserID),
            index idx_pnpDocument_UpdateUserID nonclustered (UpdateUserID),
            index idx_pnpDocument_DocumentMasterID nonclustered (DocumentMasterID)
        )
    end;

    begin transaction
    begin try

        if object_id('tempdb..#src') is not null drop table #src

        select
            dm.DocumentMasterSK,
            cu.CreateUserSK,
            uu.UpdateUserSK,
            d.kdocid as DocumentID,
            d.docnotes as Notes,
            d.sigtitle as SignatureTitle,
            d.sigtexttop as SignatureTextTop,
            d.sigtextbot as SignatureTextBottom,
            d.slogin as CreatedDatetime,
            d.slogmod as UpdatedDatetime,
            convert(varchar(50), d.kuseridlogin) as CreateUserID,
            convert(varchar(50), d.kuseridlogmod) as UpdateUserID,
            d.docrevfinalized as RevFinalized,
            d.kdocmastid as DocumentMasterID,
            d.docrevusestage as RevUseStage,
            d.docrevusepages as RevUsePages,
            et.entityname as [Type],
            d.isexternal as IsExternal
        into #src
        from
            penelope_drdoc_audtc d
            left join penelope_ssentitytype_audtc et on et.kentitytypeid = d.kentitytypeidbookitem
            outer apply (
                select top 1 DocumentMasterSK
                from [db-au-dtc].dbo.pnpDocumentMaster
                where DocumentMasterID = d.kdocmastid
            ) dm
            outer apply (
                select top 1 UserSK as CreateUserSK
                from [db-au-dtc].dbo.pnpUser
                where UserID = convert(varchar(50), d.kuseridlogin)
                    and IsCurrent = 1
            ) cu
            outer apply (
                select top 1 UserSK as UpdateUserSK
                from [db-au-dtc].dbo.pnpUser
                where UserID = convert(varchar(50), d.kuseridlogmod)
                    and IsCurrent = 1
            ) uu

        select @sourcecount = count(*) from #src

        merge [db-au-dtc].dbo.pnpDocument as tgt
        using #src
            on #src.DocumentID = tgt.DocumentID
        when matched then
            update set
                tgt.DocumentMasterSK = #src.DocumentMasterSK,
                tgt.CreateUserSK = #src.CreateUserSK,
                tgt.UpdateUserSK = #src.UpdateUserSK,
                tgt.Notes = #src.Notes,
                tgt.SignatureTitle = #src.SignatureTitle,
                tgt.SignatureTextTop = #src.SignatureTextTop,
                tgt.SignatureTextBottom = #src.SignatureTextBottom,
                tgt.UpdatedDatetime = #src.UpdatedDatetime,
                tgt.UpdateUserID = #src.UpdateUserID,
                tgt.RevFinalized = #src.RevFinalized,
                tgt.DocumentMasterID = #src.DocumentMasterID,
                tgt.RevUseStage = #src.RevUseStage,
                tgt.RevUsePages = #src.RevUsePages,
                tgt.[Type] = #src.[Type],
                tgt.IsExternal = #src.IsExternal
        when not matched by target then
            insert (
                DocumentMasterSK,
                CreateUserSK,
                UpdateUserSK,
                DocumentID,
                Notes,
                SignatureTitle,
                SignatureTextTop,
                SignatureTextBottom,
                CreatedDatetime,
                UpdatedDatetime,
                CreateUserID,
                UpdateUserID,
                RevFinalized,
                DocumentMasterID,
                RevUseStage,
                RevUsePages,
                [Type],
                IsExternal
            )
            values (
                #src.DocumentMasterSK,
                #src.CreateUserSK,
                #src.UpdateUserSK,
                #src.DocumentID,
                #src.Notes,
                #src.SignatureTitle,
                #src.SignatureTextTop,
                #src.SignatureTextBottom,
                #src.CreatedDatetime,
                #src.UpdatedDatetime,
                #src.CreateUserID,
                #src.UpdateUserID,
                #src.RevFinalized,
                #src.DocumentMasterID,
                #src.RevUseStage,
                #src.RevUsePages,
                #src.[Type],
                #src.IsExternal
            )

        output $action into @mergeoutput;

        select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

        -- CurrentRevDocumentSK in [db-au-dtc].dbo.pnpDocumentMaster
        update [db-au-dtc].dbo.pnpDocumentMaster
        set CurrentRevDocumentSK = crd.CurrentRevDocumentSK
        from [db-au-dtc].dbo.pnpDocumentMaster dm
            outer apply (
                select top 1 DocumentSK as CurrentRevDocumentSK
                from [db-au-dtc].dbo.pnpDocument
                where DocumentID = dm.CurrentRevDocumentID
            ) crd
        where CurrentRevDocumentID is not null

        --mod: 20180409 DM - Remove the Documents which no longer exist within Penelope
        --20180706, LL, use new framework's id table.

        --20180614, LL, safety check
        declare 
            @new int, 
            @old int

        select 
            @new = count(*)
        from
            [penelope_dtcomdoc_audtc_id]

        select 
            @old = count(*)
        from
            [db-au-dtc].dbo.pnpCompletedDocument

        --select @old, @new

        --if @new > @old - 100
        begin

            delete d
            output deleted.* into [db-au-dtc].dbo.pnpCompletedDocumentDeleted
            from
                [db-au-dtc].dbo.pnpCompletedDocument D
            where
                not exists
                (
                    select
                        null
                    from
                        [penelope_dtcomdoc_audtc_id] e
                    where
                        d.CompletedDocumentID = e.kcomdocid
                )

            delete R
            output deleted.* INTO [db-au-dtc].dbo.pnpCompletedDocumentRevisionDeleted
            from
                [db-au-dtc].dbo.pnpCompletedDocumentRevision R
            where
                CompletedDocumentRevisionSK in
                (
                    select
                        CompletedDocumentRevisionSK
                    from
                        [db-au-dtc].dbo.pnpCompletedDocumentDeleted D
                )

            delete A
            output deleted.* INTO [db-au-dtc].dbo.[pnpCompletedDocumentAnswerDeleted]
            from
                [db-au-dtc].dbo.pnpCompletedDocumentAnswer A
            where
                CompletedDocumentRevisionSK in
                (
                    select
                        CompletedDocumentRevisionSK
                    from
                        [db-au-dtc].dbo.pnpCompletedDocumentDeleted D
                )

        end

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Finished',
            @LogSourceCount = @sourcecount,
            @LogInsertCount = @insertcount,
            @LogUpdateCount = @updatecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

END
GO
