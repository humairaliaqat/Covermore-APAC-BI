USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL083_pnpInformalSeries]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL083_pnpInformalSeries]
as

/************************************************************************************************************************************
Author:         Linus Tor
Date:           2019022
Description:    transform and load pnpInformalSeries data/table
Parameters:     
Change History:
                20190222 - LT - Procedure created

*************************************************************************************************************************************/

begin


    set nocount on


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

	if object_id('[db-au-stage].dbo.etl_penelope_pnpInformalSeries') is not null drop table [db-au-stage].dbo.etl_penelope_pnpInformalSeries
	
	select 
		c.kncaseprogid as InformalSeriesID,
		c.kncaseserid as CaseSeriesID,
		u.UserSK,
		c.kuserid as KUserID,
		c.ncsername as InformalSeriesName,
		c.ncseropen as StartDate,
		c.ncserend as EndDate,
		s.[Status]
	into etl_penelope_pnpInformalSeries
	from
		penelope_prncaseprogser_audtc c		
		outer apply
		(
			select top 1 
				UserSK
			from 
				[db-au-dtc].dbo.pnpUser
			where
				UserID = c.kuserid
		) u
		outer apply
		(
			select top 1 
				ncserstatus as [Status]
			from
				penelope_ssncserstatus_audtc
			where
				kncserstatusid = c.kncserstatusid
		) s


	if object_id('[db-au-dtc].dbo.pnpInformalSeries') is null
	begin
		create table [db-au-dtc].[dbo].[pnpInformalSeries]
		(
			[InformalSeriesSK] [int] IDENTITY(1,1) NOT NULL,
			[InformalSeriesID] [int] NOT NULL,
			[CaseSeriesID] [int] NOT NULL,
			[UserSK] [int] NOT NULL,
			[KUserID] [int] NOT NULL,
			[InformalSeriesName] [nvarchar](50) NOT NULL,
			[StartDate] [date] NOT NULL,
			[EndDate] [date] NULL,
			[Status] [varchar](6) NOT NULL,
			[CreatedDatetime] [datetime2](7) NOT NULL,
			[UpdatedDatetime] [datetime2](7) NOT NULL
		)
		create clustered index idx_pnpInformalSeries_InformalSeriesSK on [db-au-dtc].dbo.pnpInformalSeries(InformalSeriesSK)
		create nonclustered index idx_pnpInformalSeries_UserSK on [db-au-dtc].dbo.pnpInformalSeries(UserSK, InformalSeriesID, KUserID, StartDate)
	end

	select @sourcecount = count(*) from [db-au-stage].dbo.etl_penelope_pnpInformalSeries

	begin transaction
    begin try

		merge [db-au-dtc].dbo.pnpInformalSeries as tgt
		using [db-au-stage].dbo.etl_penelope_pnpInformalSeries src on 
				src.InformalSeriesID = tgt.InformalSeriesID and
				src.CaseSeriesID = tgt.CaseSeriesID
		when not matched by target then 
			insert 
			(
				[InformalSeriesID],
				[CaseSeriesID],
				[UserSK],
				[KUserID],
				[InformalSeriesName],
				[StartDate],
				[EndDate],
				[Status],
				[CreatedDatetime],
				[UpdatedDatetime]
			)
			values 
			(
				src.[InformalSeriesID],
				src.[CaseSeriesID],
				src.[UserSK],
				src.[KUserID],
				src.[InformalSeriesName],
				src.[StartDate],
				src.[EndDate],
				src.[Status],
				getdate(),
				getdate()
			)
		when matched then 
			update set 
				tgt.[UserSK] = src.[UserSK],
				tgt.[KUserID] = src.[KUserID],
				tgt.[InformalSeriesName] = src.[InformalSeriesName],
				tgt.[StartDate] = src.[StartDate],
				tgt.[EndDate] = src.[EndDate],
				tgt.[Status] = src.[Status],
				tgt.[UpdatedDatetime] = getdate()				

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

end
GO
