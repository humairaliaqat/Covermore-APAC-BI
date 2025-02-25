USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpFunderItem]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpFunderItem
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpFunderItem] 
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

	if object_id('[db-au-dtc].dbo.pnpFunderItem') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpFunderItem](
			ItemSK int,
			FunderSK int,
			ItemID int,
			FunderID int,
			FunderItemCode nvarchar(50),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			primary key (ItemSK, FunderSK),
			index idx_pnpFunderItem_ItemID nonclustered (ItemID),
			index idx_pnpFunderItem_FunderID nonclustered (FunderID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			i.ItemSK,
			f.FunderSK,
			kitemid as ItemID,
			kfunderid as FunderID,
			funditemcode as FunderItemCode,
			slogin as CreatedDatetime,
			slogmod as UpdatedDatetime
		into #src
		from 
			penelope_afnfuncode_audtc fi
			outer apply (select top 1 ItemSK from [db-au-dtc]..pnpItem where ItemID = fi.kitemid)  i 
			outer apply (select top 1 FunderSK from [db-au-dtc]..pnpFunder where FunderID = convert(varchar, fi.kfunderid) and IsCurrent = 1) f 
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpFunderItem as tgt
		using #src
			on #src.ItemID = tgt.ItemID and #src.FunderID = tgt.FunderID
		when matched and tgt.UpdatedDatetime < #src.UpdatedDatetime then 
			update set 
				tgt.ItemSK = #src.ItemSK,
				tgt.FunderSK = #src.FunderSK,
				tgt.FunderItemCode = #src.FunderItemCode,
				tgt.UpdatedDatetime = #src.UpdatedDatetime 
		when not matched by target then 
			insert (
				ItemSK,
				FunderSK,
				ItemID,
				FunderID,
				FunderItemCode,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.ItemSK,
				#src.FunderSK,
				#src.ItemID,
				#src.FunderID,
				#src.FunderItemCode,
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
