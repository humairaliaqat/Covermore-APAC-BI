USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpPolicyCoverageRate]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpPolicyCoverageRate
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpPolicyCoverageRate] 
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

	if object_id('[db-au-dtc].dbo.pnpPolicyCoverageRate') is null
	begin 
		create table [db-au-dtc].dbo.pnpPolicyCoverageRate(
			PolicyCoverageSK int,
			ItemSK int,
			PolicyCoverageID varchar(50),
			ItemID varchar(50),
			PrimaryDP varchar(5),
			PrimaryRate numeric(12,4),
			PrimaryCP numeric(10,2),
			subpr numeric(6,4),
			subdr numeric(10,2),
			subcp numeric(10,2),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			SubsequentRatesUsed varchar(5),
			primary key (PolicyCoverageSK, ItemSK),
			index idx_pnpPolicyCoverageRate_PolicyCoverageID nonclustered (PolicyCoverageID),
			index idx_pnpPolicyCoverageRate_ItemID nonclustered (ItemID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			pc.PolicyCoverageSK,
			i.ItemSK,
			convert(varchar, kcoverageid) as PolicyCoverageID,
			convert(varchar, kitemid) as ItemID,
			primdp as PrimaryDP,
			primrate as PrimaryRate,
			primcp as PrimaryCP,
			subpr as subpr,
			subdr as subdr,
			subcp as subcp,
			slogin as CreatedDatetime,
			slogmod as UpdatedDatetime,
			subseqratesused as SubsequentRatesUsed
		into #src
		from 
			penelope_frcovrates_audtc pcr
			cross apply (
				select top 1 PolicyCoverageSK
				from [db-au-dtc].dbo.pnpPolicyCoverage
				where PolicyCoverageID = convert(varchar, pcr.kcoverageid)
			) pc
			cross apply (
				select top 1 ItemSK
				from [db-au-dtc].dbo.pnpItem
				where ItemID = convert(varchar, pcr.kitemid)
			) i
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpPolicyCoverageRate as tgt
		using #src
			on #src.PolicyCoverageID = tgt.PolicyCoverageID and #src.ItemID = tgt.ItemID
		when matched then 
			update set 
				tgt.PolicyCoverageSK = #src.PolicyCoverageSK,
				tgt.ItemSK = #src.ItemSK,
				tgt.PrimaryDP = #src.PrimaryDP,
				tgt.PrimaryRate = #src.PrimaryRate,
				tgt.PrimaryCP = #src.PrimaryCP,
				tgt.subpr = #src.subpr,
				tgt.subdr = #src.subdr,
				tgt.subcp = #src.subcp,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.SubsequentRatesUsed = #src.SubsequentRatesUsed
		when not matched by target then 
			insert (
				PolicyCoverageSK,
				ItemSK,
				PolicyCoverageID,
				ItemID,
				PrimaryDP,
				PrimaryRate,
				PrimaryCP,
				subpr,
				subdr,
				subcp,
				CreatedDatetime,
				UpdatedDatetime,
				SubsequentRatesUsed
			)
			values (
				#src.PolicyCoverageSK,
				#src.ItemSK,
				#src.PolicyCoverageID,
				#src.ItemID,
				#src.PrimaryDP,
				#src.PrimaryRate,
				#src.PrimaryCP,
				#src.subpr,
				#src.subdr,
				#src.subcp,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.SubsequentRatesUsed
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
