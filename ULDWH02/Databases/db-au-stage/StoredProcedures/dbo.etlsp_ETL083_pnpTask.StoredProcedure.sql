USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpTask]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-10-27
-- Description:	Transformation - pnpTask
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpTask] 
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

	if object_id('[db-au-dtc].dbo.pnpTask') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpTask](
			TaskSK int identity(1,1),
			AssigneeUserSK int,
			CompletedDocumentSK int,
			DocumentMasterSK int,
			AssigneeUserID varchar(50),
			ServiceFileID varchar(50),
			CompletedDocumentID int,
			DocumentMasterID int,
			ThreadID int,
			ParentThreadID int,
			PreviousThreadID int,
			ThreadCategory nvarchar(100),
			EntityType nvarchar(100),
			ThreadType nvarchar(100),
			ThreadSubject nvarchar(140),
			ThreadLocked tinyint,
			Approved tinyint,
			TaskPriority nvarchar(20),
			TaskStatus nvarchar(20),
			TaskCancel nvarchar(1000),
			TaskDateFrom date,
			TaskDateTo date,
			TaskDateComplete date,
			RuleName nvarchar(100)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src	

		select 
			a.AssigneeUserSK,
			sfk.ServiceFileSK,
			cd.CompletedDocumentSK,
			dm.DocumentMasterSK,
			convert(varchar, u.kuserid) AssigneeUserID,
			convert(varchar, sf.kprogprovid) ServiceFileID,
			tt.kcomdocid CompletedDocumentID,
			tt.kdocmastid DocumentMasterID,
			t.kthreadid ThreadID,
			tt.kthreadidparent ParentThreadID,
			tt.kthreadidprev PreviousThreadID,
			m.maptypedesc ThreadCategory,
			e.entitytype EntityType,
			ttype.threadtype ThreadType,
			t.threadsubject ThreadSubject,
			t.threadlocked ThreadLocked,
			tt.approved Approved,
			tp.taskpriority TaskPriority,
			s.taskstatus TaskStatus,
			tc.taskcancel TaskCancel,
			tt.taskdatefrom TaskDateFrom,
			tt.taskdateto TaskDateTo,
			tt.taskdatecomp TaskDateComplete,
			r.RuleName
		into #src
		from 
			penelope_aaentitymap_audtc em 
			join penelope_ssassocmaptype_audtc m on em.kmaptypeid = m.kmaptypeid 
			join penelope_ssentitytable_audtc e on e.kentitytableid = m.kentitytableidprim 
			join penelope_mtthread_audtc t on em.assocKey1 = t.kthreadid 
			join penelope_ssthreadtype_audtc ttype on ttype.kthreadtypeid = t.kthreadtypeid 
			join penelope_lutaskpri_audtc tp on t.lutaskpriid = tp.lutaskpriid 
			join penelope_mtthreadtask_audtc tt on em.assocKey1 = tt.kthreadid 
			join penelope_sstaskstatus_audtc s on s.ktaskstatusid = tt.ktaskstatusid 
			join penelope_mtthreadproc_audtc p on em.assockey1 = p.kthreadid 
			join penelope_attriggerrules_audtc r on p.kautothreadid = r.ktriggerid 
			left join penelope_wruser_audtc u on u.kbookitemid = tt.kbookitemidassigned 
			left join penelope_ctprogprov_audtc sf on em.primkey1 = sf.kprogprovid and e.kentitytableid = 300 
			left join penelope_mttaskcancel_audtc tc on tc.ktaskcancelid = tt.ktaskcancelid 
			outer apply (
				select top 1 UserSK AssigneeUserSK
				from [db-au-dtc]..pnpUser 
				where UserID = convert(varchar, u.kuserid)
			) a 
			outer apply (
				select top 1 ServiceFileSK 
				from [db-au-dtc]..pnpServiceFile
				where ServiceFileID = convert(varchar, sf.kprogprovid) 
			) sfk 
			outer apply (
				select top 1 CompletedDocumentSK 
				from [db-au-dtc]..pnpCompletedDocument 
				where CompletedDocumentID = tt.kcomdocid
			) cd 
			outer apply (
				select top 1 DocumentMasterSK
				from [db-au-dtc]..pnpDocumentMaster 
				where DocumentMasterID = tt.kdocmastid
			) dm 
		where 
			m.maptypedesc not in (
				'Case-Reminder',
				'Service File-Reminder',
				'Individual-Reminder',
				'Thread-Reminder',
				'Service Event-Reminder',
				'Individual Account Summary-Reminder',
				'Funder-Reminder',
				'Group-Reminder',
				'Group Event-Reminder',
				'Informal Series-Reminder',
				'Informal Event-Reminder',
				'Funder Account Summary-Reminder',
				'Indirect Event-Reminder',
				'Pre-Enrollment Entry-Reminder',
				'Referral Entry-Reminder',
				'Anonymous Service-Reminder',
				'Policy Member-Reminder',
				'Bluebook Entry-Reminder',
				'Case Service-Reminder',
				'Informal Service-Reminder',
				'Worker-Reminder',
				'Document-Reminder'
			)


		select @sourcecount = count(*) from #src 

		merge [db-au-dtc].dbo.pnpTask as tgt
		using #src
			on #src.ThreadID = tgt.ThreadID
		when not matched by target then 
			insert (
				AssigneeUserSK,
				CompletedDocumentSK,
				DocumentMasterSK,
				AssigneeUserID,
				ServiceFileID,
				CompletedDocumentID,
				DocumentMasterID,
				ThreadID,
				ParentThreadID,
				PreviousThreadID,
				ThreadCategory,
				EntityType,
				ThreadType,
				ThreadSubject,
				ThreadLocked,
				Approved,
				TaskPriority,
				TaskStatus,
				TaskCancel,
				TaskDateFrom,
				TaskDateTo,
				TaskDateComplete,
				RuleName
			)
			values (
				#src.AssigneeUserSK,
				#src.CompletedDocumentSK,
				#src.DocumentMasterSK,
				#src.AssigneeUserID,
				#src.ServiceFileID,
				#src.CompletedDocumentID,
				#src.DocumentMasterID,
				#src.ThreadID,
				#src.ParentThreadID,
				#src.PreviousThreadID,
				#src.ThreadCategory,
				#src.EntityType,
				#src.ThreadType,
				#src.ThreadSubject,
				#src.ThreadLocked,
				#src.Approved,
				#src.TaskPriority,
				#src.TaskStatus,
				#src.TaskCancel,
				#src.TaskDateFrom,
				#src.TaskDateTo,
				#src.TaskDateComplete,
				#src.RuleName
			)
		when matched then 
			update set 
				tgt.AssigneeUserSK = #src.AssigneeUserSK,
				tgt.CompletedDocumentSK = #src.CompletedDocumentSK,
				tgt.DocumentMasterSK = #src.DocumentMasterSK,
				tgt.AssigneeUserID = #src.AssigneeUserID,
				tgt.ServiceFileID = #src.ServiceFileID,
				tgt.CompletedDocumentID = #src.CompletedDocumentID,
				tgt.DocumentMasterID = #src.DocumentMasterID,
				tgt.ThreadID = #src.ThreadID,
				tgt.ParentThreadID = #src.ParentThreadID,
				tgt.PreviousThreadID = #src.PreviousThreadID,
				tgt.ThreadCategory = #src.ThreadCategory,
				tgt.EntityType = #src.EntityType,
				tgt.ThreadType = #src.ThreadType,
				tgt.ThreadSubject = #src.ThreadSubject,
				tgt.ThreadLocked = #src.ThreadLocked,
				tgt.Approved = #src.Approved,
				tgt.TaskPriority = #src.TaskPriority,
				tgt.TaskStatus = #src.TaskStatus,
				tgt.TaskCancel = #src.TaskCancel,
				tgt.TaskDateFrom = #src.TaskDateFrom,
				tgt.TaskDateTo = #src.TaskDateTo,
				tgt.TaskDateComplete = #src.TaskDateComplete,
				tgt.RuleName = #src.RuleName
				

		output $action into @mergeoutput;

		select
            @insertcount = sum(case when MergeAction = 'insert' then 1 else 0 end),
            @updatecount = sum(case when MergeAction = 'update' then 1 else 0 end)
        from
            @mergeoutput

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
