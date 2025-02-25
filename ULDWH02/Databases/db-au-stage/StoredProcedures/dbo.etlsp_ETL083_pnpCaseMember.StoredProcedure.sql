USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpCaseMember]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpCaseMember
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpCaseMember] 
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

	if object_id('[db-au-dtc].dbo.pnpCaseMember') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpCaseMember](
			CaseMemberSK int identity(1,1) primary key,
			CaseSK int,
			IndividualSK int,
			CaseMemberID varchar(50),
			Relationship nvarchar(20),
			SafetyFlag varchar(5),
			IsCaseInitiator varchar(5),
			IsPrimaryClient varchar(5),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			c.CaseSK,
			i.IndividualSK,
			convert(varchar, cm.kcasemembersid) as CaseMemberID,
			ft.familytreename as Relationship,
			cm.cmemsafety as SafetyFlag,
			cm.cmeminitiator as IsCaseInitiator,
			cm.cmemprimary as IsPrimaryClient,
			cm.slogin as CreatedDatetime,
			cm.slogmod as UpdatedDatetime
		into #src
		from 
			penelope_aiccasemembers_audtc cm
			left join penelope_lufamilytree_audtc ft on ft.lufamilytreeid = cm.lucmemfamilytreeid
			outer apply (
				select top 1 CaseSK
				from [db-au-dtc].dbo.pnpCase
				where CaseID = convert(varchar, cm.kcaseid)
			) c
			outer apply (
				select top 1 IndividualSK
				from [db-au-dtc].dbo.pnpIndividual
				where IndividualID = convert(varchar, cm.kindid)
					and IsCurrent = 1
			) i

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpCaseMember as tgt
		using #src
			on #src.CaseMemberID = tgt.CaseMemberID
		when matched then 
			update set 
				tgt.CaseSK = #src.CaseSK,
				tgt.IndividualSK = #src.IndividualSK,
				tgt.Relationship = #src.Relationship,
				tgt.SafetyFlag = #src.SafetyFlag,
				tgt.IsCaseInitiator = #src.IsCaseInitiator,
				tgt.IsPrimaryClient = #src.IsPrimaryClient,
				tgt.UpdatedDatetime = #src.UpdatedDatetime
		when not matched by target then 
			insert (
				CaseSK,
				IndividualSK,
				CaseMemberID,
				Relationship,
				SafetyFlag,
				IsCaseInitiator,
				IsPrimaryClient,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.CaseSK,
				#src.IndividualSK,
				#src.CaseMemberID,
				#src.Relationship,
				#src.SafetyFlag,
				#src.IsCaseInitiator,
				#src.IsPrimaryClient,
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
