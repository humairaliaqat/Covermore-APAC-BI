USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_e5WorkActivityProperties_v4]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_e5WorkActivityProperties_v4]
as
begin
/*
20141211, LS, create
20150708, LS, T16817, NZ e5 v3
*/

    set nocount on

    exec etlsp_StagingIndex_e5_v4

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

	begin try
	
		exec syssp_getrunningbatch
			@SubjectArea = 'e5 ODS v4',
			@BatchID = @batchid out,
			@StartDate = @start out,
			@EndDate = @end out
			
	end try
	
	begin catch
		
		set @batchid = -1
	
	end catch

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh].dbo.e5WorkActivityProperties_v4') is null
    begin

        create table [db-au-cmdwh].[dbo].e5WorkActivityProperties_v4
        (
            [BIRowID] bigint not null identity(1,1),
            [Domain] varchar(5),
            [Country] varchar(5), 
            Work_ID varchar(50),
            WorkActivity_ID varchar(50),
            [Original_Work_ID] uniqueidentifier not null,
            [Original_WorkActivity_ID] uniqueidentifier null,
            [Property_ID] nvarchar(32) null,
            [PropertyValue] sql_variant null,
            [UpdateBatchID] int
        )

        create clustered index idx_e5WorkActivityProperties_v4_BIRowID on [db-au-cmdwh].dbo.e5WorkActivityProperties_v4(BIRowID)
        create nonclustered index idx_e5WorkActivityProperties_v4_WorkActivity_ID on [db-au-cmdwh].dbo.e5WorkActivityProperties_v4(WorkActivity_ID,Property_ID) include(Work_ID,PropertyValue)
        create nonclustered index idx_e5WorkActivityProperties_v4_ID on [db-au-cmdwh].dbo.e5WorkActivityProperties_v4(Work_ID,WorkActivity_ID,Property_ID) include (Domain,Country,PropertyValue)
        create nonclustered index idx_e5WorkActivityProperties_Property_ID on [db-au-cmdwh].dbo.e5WorkActivityProperties_v4(Property_ID) include (WorkActivity_ID,PropertyValue)

    end

    if object_id('tempdb..#e5WorkActivityProperties_v4') is not null
        drop table #e5WorkActivityProperties_v4

    select
        Domain,
        Country,
        Country + Domain + convert(varchar(40), Work_ID) Work_ID,
        Country + Domain + convert(varchar(40), WorkActivity_ID) WorkActivity_ID,
        Work_ID Original_Work_ID,
        WorkActivity_ID Original_WorkActivity_ID,
        Property_ID collate database_default Property_ID,
        PropertyValue
    into #e5WorkActivityProperties_v4
    from
        e5_WorkActivityProperty_v4 wap
        cross apply
        (
            select top 1 
                w.Category1_Id
            from
                e5_Work_v4 w
            where
                w.Id = wap.Work_Id
        ) w
        cross apply
        (
            select top 1
                [Code] collate database_default [Code],
                [Name] collate database_default [Name]
            from
                e5_Category1_v4
            where
                Id = w.Category1_Id
        ) bn
        cross apply
        (
            select
                'V3' Domain,
                bn.Code Country
        ) dm


    set @sourcecount = @@rowcount

    begin transaction

    begin try

        delete 
        from
            [db-au-cmdwh].[dbo].[e5WorkActivityProperties_v4] 
        where
            WorkActivity_ID in
            (
                select 
                    WorkActivity_ID
                from
                    #e5WorkActivityProperties_v4
            )

        insert into [db-au-cmdwh].[dbo].[e5WorkActivityProperties_v4] with(tablock)
        (
            Domain,
            Country,
            Work_ID,
            WorkActivity_ID,
            Original_Work_ID,
            Original_WorkActivity_ID,
            Property_ID,
            PropertyValue,
            UpdateBatchID
        )
        select
            s.Domain,
            s.Country,
            s.Work_ID,
            s.WorkActivity_ID,
            s.Original_Work_ID,
            s.Original_WorkActivity_ID,
            s.Property_ID,
            s.PropertyValue,
            @batchid
        from
            #e5WorkActivityProperties_v4 s

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
            @SourceInfo = 'e5WorkActivityProperties_v4 data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
