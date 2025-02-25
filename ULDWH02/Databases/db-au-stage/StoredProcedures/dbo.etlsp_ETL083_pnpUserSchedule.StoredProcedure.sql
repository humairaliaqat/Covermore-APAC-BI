USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpUserSchedule]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpUserSchedule
-- Mod: 2018-01-23 Dane Murray - Adjusted to bring in the User Calendar Effective Dates and Names
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpUserSchedule] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpUserSchedule') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpUserSchedule](
			UserScheduleSK int identity(1,1) primary key,
			UserSK int,
			SiteSK int,
			UserScheduleID int,
            UserID varchar(50),
			SiteID int,
            [Day] nvarchar(10),
            ScheduleInDatetime time,
            ScheduleOutDatetime time,
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
            UserAvailabilityType nvarchar(50),
			UserCalendarName nvarchar(50),
			UserCalendarEffectiveDate date,
			UserCalendarEndDate date,
			index idx_pnpUserSchedule_UserSK nonclustered (UserSK),
			index idx_pnpUserSchedule_SiteSK nonclustered (SiteSK),
			index idx_pnpUserSchedule_UserScheduleID nonclustered (UserScheduleID),
			index idx_pnpUserSchedule_UserID nonclustered (UserID),
			index idx_pnpUserSchedule_SiteID nonclustered (SiteID)
		)
	end;

	if object_id('[db-au-stage].dbo.penelope_wrusersched_audtc') is null
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
			u.UserSK,
			s.SiteSK,
			us.kuserschedid as UserScheduleID,
			convert(varchar(50), us.kuserid) as UserID,
			us.ksiteid as SiteID,
			d.[day] as [Day],
			us.uschedin as ScheduleInDatetime,
			us.uschedout as ScheduleOutDatetime,
			us.slogin as CreatedDatetime,
			us.slogmod as UpdatedDatetime,
			uat.useravailtype as UserAvailabilityType,
			uc.usercalname as UserCalendarName,
			uc.usercaleffdate as UserCalendarEffectiveDate,
			dateadd(day, -1, uc.usercalenddate) as UserCalendarEndDate
		into #src
		from 
			penelope_wrusersched_audtc us
			JOIN penelope_wrusercal_audtc uc on us.kusercalid = uc.kusercalid
			left join penelope_luday_audtc d on d.ludayid = us.ludayid
			left join penelope_sauseravailtype_audtc uat on uat.kuseravailtypeid = us.kuseravailtypeid
			outer apply (
				select top 1 UserSK 
				from [db-au-dtc].dbo.pnpUser 
				where UserID = convert(varchar(50), us.kuserid ) 
					and IsCurrent = 1 
			) u
			outer apply (
				select top 1 SiteSK 
				from [db-au-dtc].dbo.pnpSite 
				where SiteID = us.ksiteid 
			) s
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpUserSchedule as tgt
		using #src
			on #src.UserScheduleID = tgt.UserScheduleID
		when matched then 
			update set 
				tgt.UserSK = #src.UserSK,
				tgt.SiteSK = #src.SiteSK,
				tgt.UserID = #src.UserID,
				tgt.SiteID = #src.SiteID,
				tgt.[Day] = #src.[Day],
				tgt.ScheduleInDatetime = #src.ScheduleInDatetime,
				tgt.ScheduleOutDatetime = #src.ScheduleOutDatetime,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UserAvailabilityType = #src.UserAvailabilityType,
				tgt.UserCalendarName = #src.UserCalendarName,
				tgt.UserCalendarEffectiveDate = #src.UserCalendarEffectiveDate,
				tgt.UserCalendarEndDate = #src.UserCalendarEndDate
		when not matched by target then 
			insert (
				UserSK,
				SiteSK,
				UserScheduleID,
				UserID,
				SiteID,
				[Day],
				ScheduleInDatetime,
				ScheduleOutDatetime,
				CreatedDatetime,
				UpdatedDatetime,
				UserAvailabilityType,
				UserCalendarName,
				UserCalendarEffectiveDate,
				UserCalendarEndDate
			)
			values (
				#src.UserSK,
				#src.SiteSK,
				#src.UserScheduleID,
				#src.UserID,
				#src.SiteID,
				#src.[Day],
				#src.ScheduleInDatetime,
				#src.ScheduleOutDatetime,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.UserAvailabilityType,
				#src.UserCalendarName,
				#src.UserCalendarEffectiveDate,
				#src.UserCalendarEndDate
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
