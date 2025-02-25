USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpAgencySchedule]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpAgencySchedule
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpAgencySchedule] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpAgencySchedule') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpAgencySchedule](
			SiteSK int,
			AgencyScheduleID int,
			[Day] nvarchar(10),
			AgencyScheduleIn time,
			AgencyScheduleOut time,
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			index idx_pnpAgencySchedule_SiteID nonclustered (SiteSK),
			index idx_pnpAgencySchedule_AgencyScheduleID nonclustered (AgencyScheduleID)
		)
	end;

	if object_id('[db-au-stage].dbo.penelope_saagencysched_audtc') is null
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
			pnpSite.SiteSK as SiteSK,
			s.kagencyschedid as AgencyScheduleID,
			d.[day] as [Day],
			s.aschedin as AgencyScheduleIn,
			s.aschedout as AgencyScheduleOut,
			s.slogin as CreatedDatetime,
			s.slogmod as UpdatedDatetime
		into #src
		from 
			penelope_saagencysched_audtc s
			left join penelope_luday_audtc d on d.ludayid = s.ludayid
			outer apply (
				select top 1 SiteSK 
				from [db-au-dtc].dbo.pnpSite 
				where SiteID = convert(varchar, s.ksiteid)
			) pnpSite

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpAgencySchedule as tgt
		using #src
			on #src.AgencyScheduleID = tgt.AgencyScheduleID
		when matched and tgt.UpdatedDatetime < #src.UpdatedDatetime then 
			update set 
				tgt.SiteSK = #src.SiteSK,
				tgt.[Day] = #src.[Day],
				tgt.AgencyScheduleIn = #src.AgencyScheduleIn,
				tgt.AgencyScheduleOut = #src.AgencyScheduleOut,
				tgt.UpdatedDatetime = #src.UpdatedDatetime
		when not matched by target then 
			insert (
				SiteSK,
				AgencyScheduleID,
				[Day],
				AgencyScheduleIn,
				AgencyScheduleOut,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.SiteSK,
				#src.AgencyScheduleID,
				#src.[Day],
				#src.AgencyScheduleIn,
				#src.AgencyScheduleOut,
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

Finish:
END


GO
