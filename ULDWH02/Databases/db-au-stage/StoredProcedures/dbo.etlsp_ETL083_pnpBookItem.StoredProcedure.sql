USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpBookItem]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpBookItem
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpBookItem] 
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

	if object_id('[db-au-dtc].dbo.pnpBookItem') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpBookItem](
			BookItemSK int identity(1,1) primary key,
			BookItemID int,
			SiteID INT,
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			index idx_pnpBookItem_BookItemID nonclustered (BookItemID),
			index idx_pnpBookItem_SiteID nonclustered (SiteID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			kbookitemid as BookItemID,
			ksiteid as SiteID,
			slogin as CreatedDatetime,
			slogmod as UpdatedDatetime
		into #src
		from 
			penelope_irbookitem_audtc

		select @sourcecount = count(*) from #src
	
		merge [db-au-dtc].dbo.pnpBookItem as tgt
		using #src
			on #src.BookItemID = tgt.BookItemID
		when matched and tgt.UpdatedDatetime < #src.UpdatedDatetime then 
			update set 
				tgt.SiteID = #src.SiteID,
				tgt.UpdatedDatetime = #src.UpdatedDatetime
		when not matched by target then 
			insert (
				BookItemID,
				SiteID,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.BookItemID,
				#src.SiteID,
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
