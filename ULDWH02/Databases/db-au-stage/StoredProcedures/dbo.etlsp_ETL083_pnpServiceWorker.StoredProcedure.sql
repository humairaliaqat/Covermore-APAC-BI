USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceWorker]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpServiceWorker
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpServiceWorker] 
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

	if object_id('[db-au-dtc].dbo.pnpServiceWorker') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpServiceWorker](
			ServiceSK int,
			UserSK int,
			ServiceID int,
			WorkerID varchar(50),
			UserID varchar(50),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			index idx_pnpServiceWorker_ServiceSK nonclustered (ServiceSK),
			index idx_pnpServiceWorker_UserSK nonclustered (UserSK),
			index idx_pnpServiceWorker_ServiceID nonclustered (ServiceID),
			index idx_pnpServiceWorker_WorkerID nonclustered (WorkerID),
			index idx_pnpServiceWorker_UserID nonclustered (UserID)
	)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			s.ServiceSK,
			u.UserSK,
			wp.kagserid as ServiceID,
			convert(varchar(50), wp.kcworkerid) as WorkerID,
			convert(varchar(50), w.kuserid) as UserID,
			wp.slogin as CreatedDatetime,
			wp.slogmod as UpdatedDatetime
		into #src
		from 
			penelope_awpworkprog_audtc wp 
			left join penelope_wrcworker_audtc w on w.kcworkerid = wp.kcworkerid
			outer apply (
				select top 1 ServiceSK
				from [db-au-dtc].dbo.pnpService
				where ServiceID = wp.kagserid
			) s
			outer apply (
				select top 1 UserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = convert(varchar(50), w.kuserid) 
					and IsCurrent = 1
			) u
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpServiceWorker as tgt
		using #src
			on #src.ServiceID = tgt.ServiceID and #src.WorkerID = tgt.WorkerID
		when matched then 
			update set 
				tgt.ServiceSK = #src.ServiceSK,
				tgt.UserSK = #src.UserSK,
				tgt.UserID = #src.UserID,
				tgt.UpdatedDatetime = #src.UpdatedDatetime
		when not matched by target then 
			insert (
				ServiceSK,
				UserSK,
				ServiceID,
				WorkerID,
				UserID,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.ServiceSK,
				#src.UserSK,
				#src.ServiceID,
				#src.WorkerID,
				#src.UserID,
				#src.CreatedDatetime,
				#src.UpdatedDatetime
			)
			
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
