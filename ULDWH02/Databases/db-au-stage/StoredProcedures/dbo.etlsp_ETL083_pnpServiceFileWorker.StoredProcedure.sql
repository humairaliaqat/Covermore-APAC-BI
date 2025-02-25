USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpServiceFileWorker]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpServiceFileWorker
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpServiceFileWorker] 
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

	if object_id('[db-au-dtc].dbo.pnpServiceFileWorker') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpServiceFileWorker](
			ServiceFileSK int,
			UserSK int,
			ServiceFileID varchar(50),
			WorkerID varchar(50),
			UserID varchar(50),
			IsPrimary varchar(5),
			Attending varchar(5),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			kfahcsiastateid int,
			workerattached varchar(5),
			index idx_pnpServiceFileWorker_ServiceFileID nonclustered (ServiceFileID),
			index idx_pnpServiceFileWorker_WorkerID nonclustered (WorkerID),
			index idx_pnpServiceFileWorker_UserID nonclustered (UserID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src
			
		select 
			sf.ServiceFileSK,
			u.UserSK,
			convert(varchar, sfw.kprogprovid) as ServiceFileID,
			convert(varchar, sfw.kcworkerid) as WorkerID,
			convert(varchar, w.kuserid) as UserID,
			'0' as IsPrimary,
			sfw.actlevelbooking as Attending,
			sfw.slogin as CreatedDatetime,
			sfw.slogmod as UpdatedDatetime,
			sfw.kfahcsiastateid as kfahcsiastateid,
			sfw.workerattached as workerattached
		into #src
		from 
			penelope_acwprogcworker_audtc sfw
			left join penelope_wrcworker_audtc w on w.kcworkerid = sfw.kcworkerid
			outer apply (
				select top 1 ServiceFileSK
				from [db-au-dtc].dbo.pnpServiceFile
				where ServiceFileID = convert(varchar, sfw.kprogprovid)
			) sf
			outer apply (
				select top 1 UserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = convert(varchar, w.kuserid) 
					and IsCurrent = 1
			) u
		union all
		select 
			sf2.ServiceFileSK,
			u2.UserSK,
			convert(varchar, sf.kprogprovid) as ServiceFileID,
			convert(varchar, sf.kcworkeridprim) as WorkerID,
			convert(varchar, w.kuserid) as UserID,
			'1' as IsPrimary,
			'1' as Attending,
			sf.slogin as CreatedDatetime,
			sf.slogmod as UpdatedDatetime,
			null as kfahcsiastateid,
			null as workerattached
		from 
			penelope_ctprogprov_audtc sf
			left join penelope_wrcworker_audtc w on w.kcworkerid = sf.kcworkeridprim
			outer apply (
				select top 1 ServiceFileSK
				from [db-au-dtc].dbo.pnpServiceFile
				where ServiceFileID = convert(varchar, sf.kprogprovid)
			) sf2
			outer apply (
				select top 1 UserSK
				from [db-au-dtc].dbo.pnpUser
				where UserID = convert(varchar, w.kuserid) 
					and IsCurrent = 1
			) u2
		where 
			sf.kcworkeridprim is not null

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpServiceFileWorker as tgt
		using #src
			on #src.ServiceFileID = tgt.ServiceFileID and #src.WorkerID = tgt.WorkerID and tgt.CreatedDatetime = #src.CreatedDatetime
		when matched then 
			update set 
				tgt.ServiceFileSK = #src.ServiceFileSK,
				tgt.UserSK = #src.UserSK,
				tgt.UserID = #src.UserID,
				tgt.IsPrimary = #src.IsPrimary,
				tgt.Attending = #src.Attending,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.kfahcsiastateid = #src.kfahcsiastateid,
				tgt.workerattached = #src.workerattached
		when not matched by target then 
			insert (
				ServiceFileSK,
				UserSK,
				ServiceFileID,
				WorkerID,
				UserID,
				IsPrimary,
				Attending,
				CreatedDatetime,
				UpdatedDatetime,
				kfahcsiastateid,
				workerattached
			)
			values (
				#src.ServiceFileSK,
				#src.UserSK,
				#src.ServiceFileID,
				#src.WorkerID,
				#src.UserID,
				#src.IsPrimary,
				#src.Attending,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.kfahcsiastateid,
				#src.workerattached
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
