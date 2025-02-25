USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpCompletedDocumentRevision]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpCompletedDocumentRevision
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpCompletedDocumentRevision] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpCompletedDocumentRevision') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpCompletedDocumentRevision](
			CompletedDocumentRevisionSK int identity(1,1) primary key,
			CompletedDocumentSK int,
			CreateUserSK int,
			UpdateUserSK int,
			CreateBookItemSK int,
			UpdateBookItemSK int,
			CompletedDocumentRevisionID int,
			CompletedDocumentID int,
			RevisionDate date,
			DocumentLetterSent varchar(5),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreateUserID varchar(50),
			UpdateUserID varchar(50),
			CreateBookItemID int,
			UpdateBookItemID int,
			index idx_pnpCompletedDocumentRevision_CompletedDocumentSK nonclustered (CompletedDocumentSK),
			index idx_pnpCompletedDocumentRevision_CreateUserSK nonclustered (CreateUserSK),
			index idx_pnpCompletedDocumentRevision_UpdateUserSK nonclustered (UpdateUserSK),
			index idx_pnpCompletedDocumentRevision_CreateBookItemSK nonclustered (CreateBookItemSK),
			index idx_pnpCompletedDocumentRevision_UpdateBookItemSK nonclustered (UpdateBookItemSK),
			index idx_pnpCompletedDocumentRevision_CompletedDocumentRevisionID nonclustered (CompletedDocumentRevisionID),
			index idx_pnpCompletedDocumentRevision_CompletedDocumentID nonclustered (CompletedDocumentID),
			index idx_pnpCompletedDocumentRevision_CreateUserID nonclustered (CreateUserID),
			index idx_pnpCompletedDocumentRevision_UpdateUserID nonclustered (UpdateUserID),
			index idx_pnpCompletedDocumentRevision_CreateBookItemID nonclustered (CreateBookItemID),
			index idx_pnpCompletedDocumentRevision_UpdateBookItemID nonclustered (UpdateBookItemID)
		)
	end;

	if object_id('[db-au-stage].dbo.penelope_dtcomdocrev_audtc') is null
		goto Finish

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

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			cd.CompletedDocumentSK,
			cu.CreateUserSK,
			uu.UpdateUserSK,
			cbi.CreateBookItemSK,
			ubi.UpdateBookItemSK,
			cdr.kcomdocrevid as CompletedDocumentRevisionID,
			cdr.kcomdocid as CompletedDocumentID,
			cdr.cdocdaterev as RevisionDate,
			cdr.cdoclettersent as DocumentLetterSent,
			cdr.slogin as CreatedDatetime,
			cdr.slogmod as UpdatedDatetime,
			convert(varchar, cdr.kuseridlogin) as CreateUserID,
			convert(varchar, cdr.kuseridlogmod) as UpdateUserID,
			cdr.kbookitemidlogin as CreateBookItemID,
			cdr.kbookitemidlogmod as UpdateBookItemID
		into #src
		from 
			penelope_dtcomdocrev_audtc cdr
			outer apply (
				select top 1 CompletedDocumentSK
				from [db-au-dtc].dbo.pnpCompletedDocument
				where CompletedDocumentID = cdr.kcomdocid
			) cd
			outer apply (
				select top 1 UserSK as CreateUserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = convert(varchar, cdr.kuseridlogin) 
					and IsCurrent = 1
			) cu
			outer apply (
				select top 1 UserSK as UpdateUserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID =convert(varchar, cdr.kuseridlogmod) 
					and IsCurrent = 1
			) uu
			outer apply (
				select top 1 BookItemSK as CreateBookItemSK
				from [db-au-dtc].dbo.pnpBookItem
				where BookItemID = cdr.kbookitemidlogin
			) cbi
			outer apply (
				select top 1 BookItemSK as UpdateBookItemSK
				from [db-au-dtc].dbo.pnpBookItem
				where BookItemID = cdr.kbookitemidlogmod
			) ubi
		
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpCompletedDocumentRevision as tgt
		using #src
			on #src.CompletedDocumentRevisionID = tgt.CompletedDocumentRevisionID
		when matched then 
			update set 
				tgt.CompletedDocumentSK = #src.CompletedDocumentSK,
				tgt.CreateUserSK = #src.CreateUserSK,
				tgt.UpdateUserSK = #src.UpdateUserSK,
				tgt.CreateBookItemSK = #src.CreateBookItemSK,
				tgt.UpdateBookItemSK = #src.UpdateBookItemSK,
				tgt.CompletedDocumentID = #src.CompletedDocumentID,
				tgt.RevisionDate = #src.RevisionDate,
				tgt.DocumentLetterSent = #src.DocumentLetterSent,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdateUserID = #src.UpdateUserID,
				tgt.CreateBookItemID = #src.CreateBookItemID,
				tgt.UpdateBookItemID = #src.UpdateBookItemID
		when not matched by target then 
			insert (
				CompletedDocumentSK,
				CreateUserSK,
				UpdateUserSK,
				CreateBookItemSK,
				UpdateBookItemSK,
				CompletedDocumentRevisionID,
				CompletedDocumentID,
				RevisionDate,
				DocumentLetterSent,
				CreatedDatetime,
				UpdatedDatetime,
				CreateUserID,
				UpdateUserID,
				CreateBookItemID,
				UpdateBookItemID
			)
			values (
				#src.CompletedDocumentSK,
				#src.CreateUserSK,
				#src.UpdateUserSK,
				#src.CreateBookItemSK,
				#src.UpdateBookItemSK,
				#src.CompletedDocumentRevisionID,
				#src.CompletedDocumentID,
				#src.RevisionDate,
				#src.DocumentLetterSent,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreateUserID,
				#src.UpdateUserID,
				#src.CreateBookItemID,
				#src.UpdateBookItemID
			)
			
		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

		-- CompletedDocumentRevisionSK in [db-au-dtc].dbo.pnpCompletedDocument
		update [db-au-dtc].dbo.pnpCompletedDocument
		set CompletedDocumentRevisionSK = cdr.CompletedDocumentRevisionSK
		from [db-au-dtc].dbo.pnpCompletedDocument cd
			outer apply (
				select top 1 CompletedDocumentRevisionSK
				from [db-au-dtc].dbo.pnpCompletedDocumentRevision
				where CompletedDocumentID = cd.CompletedDocumentID
				order by RevisionDate desc
			) cdr

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

Finish:
END

GO
