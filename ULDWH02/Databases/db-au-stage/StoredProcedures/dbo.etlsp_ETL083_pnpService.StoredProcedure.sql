USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpService]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpService
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpService] 
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

	if object_id('[db-au-dtc].dbo.pnpService') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpService](
			ServiceSK int identity(1,1) primary key,
			ServiceID varchar(50),
			Name nvarchar(80),
			DisplayName nvarchar(80),
			ServiceType nvarchar(20),
			Stream nvarchar(50),
			Notes nvarchar(4000),
			StartDate date,
			EndDate date,
			[Status] varchar(5),
			luasertype1 int,
			luasertype2 int,
			luasertype3 int,
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			CreatedBy nvarchar(10),
			UpdatedBy nvarchar(10),
			CostCentreGLAccount nvarchar(10),	 -- serglcode
			luasertype4 int,
			NaturalGLAccount nvarchar(10),	-- revglcode
			BillService varchar(5),
			CPTCode nvarchar(50),
			SuggestedSessionCount int,
			SuggestedApptLength int,
			IsEAPCaseService varchar(5),
			DefaultBookingTabAttendee varchar(5),
			fahcsiaprog varchar(5),
			fahcsiaservicetype nvarchar(4000),
			IsFRC varchar(5),
			IsLegalAss varchar(5),
			HasParentAgree varchar(5),
			DefaultBookingEventMembers varchar(5),
			defaultbookingservfilemembers varchar(5),
			fahcsiaprogenddate date,
			hasfahcsiafeedback varchar(5),
			kexempttypeidchilddefault int,
			fahcsiasessfeedefaulttopaying varchar(5),
			kexempttypeidnofeedefault int,
			DefaultBookingWorkers varchar(5)
	)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src	

		select 
			convert(varchar, a.kagserid) as ServiceID,
			asername as Name,
			pt.progtype as ServiceType,
			pg.proggroupname as Stream,
			a.asernotes as Notes,
			a.aserstartdate as StartDate,
			a.aserenddate as EndDate,
			a.aserstatus as Status,
			a.luasertype1 as luasertype1,
			a.luasertype2 as luasertype2,
			a.luasertype3 as luasertype3,
			a.slogin as CreatedDatetime,
			a.slogmod as UpdatedDatetime,
			a.sloginby as CreatedBy,
			a.slogmodby as UpdatedBy,
			a.serglcode as CostCentreGLAccount,
			a.luasertype4 as luasertype4,
			a.revglcode as NaturalGLAccount,
			cp.billserv as BillService,
			cp.cptcode as CPTCode,
			cp.suggestedsessioncount as SuggestedSessionCount,
			cp.suggestedapptlength as SuggestedApptLength,
			cp.iseapcaseservice as IsEAPCaseService,
			cp.defaultbookingtabattendee as DefaultBookingTabAttendee,
			cp.fahcsiaprog as fahcsiaprog,
			cp.fahcsiaservicetype as fahcsiaservicetype,
			cp.isfrc as IsFRC,
			cp.islegalass as IsLegalAss,
			cp.hasparentagree as HasParentAgree,
			cp.defaultbookingeventmembers as DefaultBookingEventMembers,
			cp.defaultbookingservfilemembers as defaultbookingservfilemembers,
			cp.fahcsiaprogenddate as fahcsiaprogenddate,
			cp.hasfahcsiafeedback as hasfahcsiafeedback,
			cp.kexempttypeidchilddefault as kexempttypeidchilddefault,
			cp.fahcsiasessfeedefaulttopaying as fahcsiasessfeedefaulttopaying,
			cp.kexempttypeidnofeedefault as kexempttypeidnofeedefault,
			cp.defaultbookingworkers as DefaultBookingWorkers
		into #src
		from 
			penelope_pragser_audtc a 
			left join penelope_ssprogtype_audtc pt on pt.kprogtypeid = a.kprogtypeid
			left join penelope_prcaseprog_audtc cp on cp.kagserid = a.kagserid
			left join penelope_saproggroup_audtc pg on pg.kproggroupid = cp.kproggroupid
		
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpService as tgt
		using #src
			on #src.ServiceID = tgt.ServiceID
		when matched then 
			update set 
				tgt.Name = #src.Name,
				tgt.ServiceType = #src.ServiceType,
				tgt.Stream = #src.Stream,
				tgt.Notes = #src.Notes,
				tgt.StartDate = #src.StartDate,
				tgt.EndDate = #src.EndDate,
				tgt.[Status] = #src.[Status],
				tgt.luasertype1 = #src.luasertype1,
				tgt.luasertype2 = #src.luasertype2,
				tgt.luasertype3 = #src.luasertype3,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.CostCentreGLAccount = #src.CostCentreGLAccount,
				tgt.luasertype4 = #src.luasertype4,
				tgt.NaturalGLAccount = #src.NaturalGLAccount,
				tgt.BillService = #src.BillService,
				tgt.CPTCode = #src.CPTCode,
				tgt.SuggestedSessionCount = #src.SuggestedSessionCount,
				tgt.SuggestedApptLength = #src.SuggestedApptLength,
				tgt.IsEAPCaseService = #src.IsEAPCaseService,
				tgt.DefaultBookingTabAttendee = #src.DefaultBookingTabAttendee,
				tgt.fahcsiaprog = #src.fahcsiaprog,
				tgt.fahcsiaservicetype = #src.fahcsiaservicetype,
				tgt.IsFRC = #src.IsFRC,
				tgt.IsLegalAss = #src.IsLegalAss,
				tgt.HasParentAgree = #src.HasParentAgree,
				tgt.DefaultBookingEventMembers = #src.DefaultBookingEventMembers,
				tgt.defaultbookingservfilemembers = #src.defaultbookingservfilemembers,
				tgt.fahcsiaprogenddate = #src.fahcsiaprogenddate,
				tgt.hasfahcsiafeedback = #src.hasfahcsiafeedback,
				tgt.kexempttypeidchilddefault = #src.kexempttypeidchilddefault,
				tgt.fahcsiasessfeedefaulttopaying = #src.fahcsiasessfeedefaulttopaying,
				tgt.kexempttypeidnofeedefault = #src.kexempttypeidnofeedefault,
				tgt.DefaultBookingWorkers = #src.DefaultBookingWorkers
		when not matched by target then 
			insert (
				ServiceID,
				Name,
				ServiceType,
				Stream,
				Notes,
				StartDate,
				EndDate,
				[Status],
				luasertype1,
				luasertype2,
				luasertype3,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				CostCentreGLAccount,
				luasertype4,
				NaturalGLAccount,
				BillService,
				CPTCode,
				SuggestedSessionCount,
				SuggestedApptLength,
				IsEAPCaseService,
				DefaultBookingTabAttendee,
				fahcsiaprog,
				fahcsiaservicetype,
				IsFRC,
				IsLegalAss,
				HasParentAgree,
				DefaultBookingEventMembers,
				defaultbookingservfilemembers,
				fahcsiaprogenddate,
				hasfahcsiafeedback,
				kexempttypeidchilddefault,
				fahcsiasessfeedefaulttopaying,
				kexempttypeidnofeedefault,
				DefaultBookingWorkers
			)
			values (
				#src.ServiceID,
				#src.Name,
				#src.ServiceType,
				#src.Stream,
				#src.Notes,
				#src.StartDate,
				#src.EndDate,
				#src.[Status],
				#src.luasertype1,
				#src.luasertype2,
				#src.luasertype3,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.CostCentreGLAccount,
				#src.luasertype4,
				#src.NaturalGLAccount,
				#src.BillService,
				#src.CPTCode,
				#src.SuggestedSessionCount,
				#src.SuggestedApptLength,
				#src.IsEAPCaseService,
				#src.DefaultBookingTabAttendee,
				#src.fahcsiaprog,
				#src.fahcsiaservicetype,
				#src.IsFRC,
				#src.IsLegalAss,
				#src.HasParentAgree,
				#src.DefaultBookingEventMembers,
				#src.defaultbookingservfilemembers,
				#src.fahcsiaprogenddate,
				#src.hasfahcsiafeedback,
				#src.kexempttypeidchilddefault,
				#src.fahcsiasessfeedefaulttopaying,
				#src.kexempttypeidnofeedefault,
				#src.DefaultBookingWorkers
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
