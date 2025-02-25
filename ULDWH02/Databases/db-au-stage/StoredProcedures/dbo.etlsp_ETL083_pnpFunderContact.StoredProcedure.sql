USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpFunderContact]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Vincent Lam
-- Create date: 2017-04-19
-- Description:	Transformation - pnpFunderContact
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL083_pnpFunderContact] 
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

	if object_id('[db-au-dtc].dbo.pnpFunderContact') is null
	begin 
		create table [db-au-dtc].[dbo].[pnpFunderContact](
			FunderContactSK int identity(1,1) primary key,
			FunderSK int, 
			FunderContactID int,
			Name nvarchar(50),
			[Role] nvarchar(50),
			Phone1 nvarchar(13),
			Ext1 nvarchar(6),
			Phone2 nvarchar(13),
			Ext2 nvarchar(6),
			Fax nvarchar(13),
			Email nvarchar(70),
			Comments nvarchar(50),
			CreatedDatetime datetime2,
			UpdatedDatetime datetime2,
			Notes nvarchar(4000),
			index idx_pnpFunderContact_FunderSK nonclustered (FunderSK),
			index idx_pnpFunderContact_FunderContactID nonclustered (FunderContactID)
		)
	end;

	begin transaction
    begin try

		if object_id('tempdb..#src') is not null drop table #src

		select 			
			f.FunderSK as FunderSK,
			kfunderconid as FunderContactID,
			fconname as Name,
			fconrole as [Role],
			fconphone1 as Phone1,
			fconext1 as Ext1,
			fconphone2 as Phone2,
			fconext2 as Ext2,
			fconfax as Fax,
			fconemail as Email,
			fconcomments as Comments,
			slogin as CreatedDatetime,
			slogmod as UpdatedDatetime,
			fconnotes as Notes
		into #src
		from 
			penelope_frfuncon_audtc fc
			outer apply (
				select top 1 FunderSK
				from [db-au-dtc].dbo.pnpFunder
				where pnpFunder.FunderID = fc.kfunderid
					and pnpFunder.IsCurrent = 1
			) f
	
		select @sourcecount = count(*) from #src

		merge [db-au-dtc].dbo.pnpFunderContact as tgt
		using #src
			on #src.FunderContactID = tgt.FunderContactID
		when matched and tgt.UpdatedDatetime < #src.UpdatedDatetime then 
			update set 
				tgt.FunderSK = #src.FunderSK,
				tgt.Name = #src.Name,
				tgt.[Role] = #src.[Role],
				tgt.Phone1 = #src.Phone1,
				tgt.Ext1 = #src.Ext1,
				tgt.Phone2 = #src.Phone2,
				tgt.Ext2 = #src.Ext2,
				tgt.Fax = #src.Fax,
				tgt.Email = #src.Email,
				tgt.Comments = #src.Comments,
				tgt.UpdatedDatetime = #src.UpdatedDatetime,
				tgt.Notes = #src.Notes
		when not matched by target then 
			insert (
				FunderSK,
				FunderContactID,
				Name,
				[Role],
				Phone1,
				Ext1,
				Phone2,
				Ext2,
				Fax,
				Email,
				Comments,
				CreatedDatetime,
				UpdatedDatetime,
				Notes
			)
			values (
				#src.FunderSK,
				#src.FunderContactID,
				#src.Name,
				#src.[Role],
				#src.Phone1,
				#src.Ext1,
				#src.Phone2,
				#src.Ext2,
				#src.Fax,
				#src.Email,
				#src.Comments,
				#src.CreatedDatetime,
				#src.UpdatedDatetime,
				#src.Notes
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
