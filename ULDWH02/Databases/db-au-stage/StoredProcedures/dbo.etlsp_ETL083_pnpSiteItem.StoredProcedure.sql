USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpSiteItem]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpSiteItem
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpSiteItem] 
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

	if object_id('[db-au-dtc].dbo.pnpSiteItem') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpSiteItem](
			ItemSK int,
			SiteSK int,
			ItemID int,
			SiteID int,
			SiteFee numeric(10,2),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			index idx_pnpSiteItem_ItemSK nonclustered (ItemSK),
			index idx_pnpSiteItem_SiteSK nonclustered (SiteSK),
			index idx_pnpSiteItem_ItemID nonclustered (ItemID),
			index idx_pnpSiteItem_SiteID nonclustered (SiteID)
	)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 
			i.ItemSK,
			s.SiteSK,
			si.kitemid as ItemID,
			si.ksiteid as SiteID,
			si.sitefee as SiteFee,
			si.slogin as CreatedDatetime,
			si.slogmod as UpdatedDatetime
		into #src
		from 
			penelope_btsitefee_audtc si
			outer apply (
				select top 1 ItemSK
				from [db-au-dtc].dbo.pnpItem
				where ItemId = si.kitemid
			) i
			outer apply (
				select top 1 SiteSK
				from [db-au-dtc].dbo.pnpSite
				where SiteID = si.ksiteid
			) s
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpSiteItem as tgt
		using #src
			on #src.ItemID = tgt.ItemID and #src.SiteID = tgt.SiteID
		when matched then 
			update set 
				tgt.ItemSK = #src.ItemSK,
				tgt.SiteSK = #src.SiteSK,
				tgt.SiteFee = #src.SiteFee,
				tgt.UpdatedDatetime = #src.UpdatedDatetime
		when not matched by target then 
			insert (
				ItemSK,
				SiteSK,
				ItemID,
				SiteID,
				SiteFee,
				CreatedDatetime,
				UpdatedDatetime
			)
			values (
				#src.ItemSK,
				#src.SiteSK,
				#src.ItemID,
				#src.SiteID,
				#src.SiteFee,
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
