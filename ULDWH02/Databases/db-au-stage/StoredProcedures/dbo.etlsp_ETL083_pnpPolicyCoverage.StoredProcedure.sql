USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpPolicyCoverage]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpPolicyCoverage
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpPolicyCoverage] 
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

	if object_id('[db-au-dtc].dbo.pnpPolicyCoverage') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpPolicyCoverage](
			PolicyCoverageSK int identity(1,1) primary key,
			PolicySK int,
			PolicyCoverageID varchar(50),
			PolicyAgreementID int,
			covulimita varchar(5),
			covulimit numeric(10, 2),
			covnoshow numeric(6, 4),
			covdatea varchar(5),
			StartDate date,
			EndDate date,
			covautha varchar(5),
			covauthno nvarchar(25),
			covauthconf varchar(5),
			kcovreauthid int,
			Comments nvarchar(max),
			covdollara varchar(5),
			DollarLimit numeric(10, 2),
			CreatedDatetime datetime2(7),
			UpdatedDatetime datetime2(7),
			CreatedBy nvarchar(20),
			UpdatedBy nvarchar(20),
			[Status] varchar(5),
			BillType nvarchar(30),
			index idx_pnpPolicyCoverage_PolicyCoverageID_PolicyCoverageSK (PolicyCoverageID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			p.PolicySK,
			convert(varchar, pc.kcoverageid) as PolicyCoverageID,
			pc.kpolagreid as PolicyAgreementID,
			pc.covulimita as covulimita,
			pc.covulimit as covulimit,
			pc.covnoshow as covnoshow,
			pc.covdatea as covdatea,
			pc.covstart as StartDate,
			pc.covend as EndDate,
			pc.covautha as covautha,
			pc.covauthno as covauthno,
			pc.covauthconf as covauthconf,
			pc.kcovreauthid as kcovreauthid,
			pc.covcom as Comments,
			pc.covdollara as covdollara,
			pc.covdollaramt as DollarLimit,
			pc.slogin as CreatedDatetime,
			pc.slogmod as UpdatedDatetime,
			pc.sloginby as CreatedBy,
			pc.slogmodby as UpdatedBy,
			pc.covstatus as [Status],
			bt.billtype as BillType
		into #src
		from 
			penelope_frcoverage_audtc pc
			left join penelope_ssbilltype_audtc bt on bt.kbilltypeid = pc.kbilltypeid
			outer apply (
				select top 1 PolicySK
				from [db-au-dtc].dbo.pnpPolicy
				where PolicyID = convert(varchar, pc.kpolicyid)
			) p

		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpPolicyCoverage as tgt
		using #src
			on #src.PolicyCoverageID = tgt.PolicyCoverageID
		when matched then 
			update set 
				tgt.PolicySK = #src.PolicySK,
				tgt.PolicyAgreementID = #src.PolicyAgreementID,
				tgt.covulimita = #src.covulimita,
				tgt.covulimit = #src.covulimit,
				tgt.covnoshow = #src.covnoshow,
				tgt.covdatea = #src.covdatea,
				tgt.StartDate = #src.StartDate,
				tgt.EndDate = #src.EndDate,
				tgt.covautha = #src.covautha,
				tgt.covauthno = #src.covauthno,
				tgt.covauthconf = #src.covauthconf,
				tgt.kcovreauthid = #src.kcovreauthid,
				tgt.Comments = #src.Comments,
				tgt.covdollara = #src.covdollara,
				tgt.DollarLimit = #src.DollarLimit,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.UpdatedBy = #src.UpdatedBy,
				tgt.[Status] = #src.[Status],
				tgt.BillType = #src.BillType

		when not matched by target then 
			insert (
				PolicySK,
				PolicyCoverageID,
				PolicyAgreementID,
				covulimita,
				covulimit,
				covnoshow,
				covdatea,
				StartDate,
				EndDate,
				covautha,
				covauthno,
				covauthconf,
				kcovreauthid,
				Comments,
				covdollara,
				DollarLimit,
				CreatedDatetime,
				UpdatedDatetime,
				CreatedBy,
				UpdatedBy,
				[Status],
				BillType
			)
			values (
				#src.PolicySK,
				#src.PolicyCoverageID,
				#src.PolicyAgreementID,
				#src.covulimita,
				#src.covulimit,
				#src.covnoshow,
				#src.covdatea,
				#src.StartDate,
				#src.EndDate,
				#src.covautha,
				#src.covauthno,
				#src.covauthconf,
				#src.kcovreauthid,
				#src.Comments,
				#src.covdollara,
				#src.DollarLimit,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.CreatedBy,
				#src.UpdatedBy,
				#src.[Status],
				#src.BillType
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
