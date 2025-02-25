USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpUserScheduleOverride]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[etlsp_ETL083_pnpUserScheduleOverride] 
AS

-- =============================================
-- Author:		Linus Tor
-- Create date: 2018-11-22
-- Description:	Transformation - pnpUserScheduleOverride
-- =============================================

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if object_id('[db-au-dtc].dbo.pnpUserScheduleOverride') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpUserScheduleOverride]
		(
			UserScheduleOverrideSK int identity(1,1) primary key,
			UserSK int,
			SiteSK int,
			UserScheduleOverrideID int,
            UserID varchar(50),
			SiteID int,
            UserScheduleDate date,
            UserScheduleIn time,
			UserScheduleOut time,
			UserScheduleAvailabilityType nvarchar(50) null,
            CreatedDatetime datetime2,
            UpdatedDatetime datetime2,
			index idx_pnpUserScheduleOverride_UserSK nonclustered (UserSK),
			index idx_pnpUserScheduleOverride_SiteSK nonclustered (SiteSK),
			index idx_pnpUserScheduleOverride_UserScheduleOverrideID nonclustered (UserScheduleOverrideID),
			index idx_pnpUserScheduleOverride_UserID nonclustered (UserID),
			index idx_pnpUserScheduleOverride_SiteID nonclustered (SiteID)
		)
	end;

	if object_id('[db-au-stage].dbo.penelope_wruserschedovr_audtc') is null
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
			us.kuserschedovrid as UserScheduleOverrideSK,
			u.UserSK,
			s.SiteSK,
			us.kuserschedovrid as UserScheduleOverrideID,
			convert(varchar(50), us.kuserid) as UserID,
			us.ksiteid as SiteID,
            us.[uscheddate] as UserScheduleDate,
			us.[uschedin] as UserScheduleIn,
			us.[uschedout] as UserScheduleOut,
			uat.useravailtype as UserScheduleAvailabilityType,
			us.slogin as CreatedDatetime,
			us.slogmod as UpdatedDatetime
		into #src
		from 
			[dbo].[penelope_wruserschedovr_audtc] us
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

		merge [db-au-dtc].dbo.pnpUserScheduleOverride as tgt
		using #src
			on #src.UserScheduleOverrideID = tgt.UserScheduleOverrideID
		when matched then 
			update set 
				tgt.UserSK = #src.UserSK,
				tgt.SiteSK = #src.SiteSK,
				tgt.UserID = #src.UserID,
				tgt.SiteID = #src.SiteID,
				tgt.UserScheduleIn = #src.UserScheduleIn,
				tgt.UserScheduleOut = #src.UserScheduleOut,
				tgt.UserScheduleAvailabilityType = #src.UserScheduleAvailabilityType,
				tgt.UpdatedDatetime = #src.UpdatedDatetime
		when not matched by target then 
			insert (
				UserSK,
				SiteSK,
				UserScheduleOverrideID,
				UserID,
				SiteID,
				UserScheduleDate,
				UserScheduleIn,
				UserScheduleOut,
				UserScheduleAvailabilityType,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.UserSK,
				#src.SiteSK,
				#src.UserScheduleOverrideID,
				#src.UserID,
				#src.SiteID,
				#src.UserScheduleDate,
				#src.UserScheduleIn,
				#src.UserScheduleOut,
				#src.UserScheduleAvailabilityType,
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
