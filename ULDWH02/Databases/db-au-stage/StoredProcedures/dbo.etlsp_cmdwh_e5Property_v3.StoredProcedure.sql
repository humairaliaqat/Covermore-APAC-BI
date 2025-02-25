USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_e5Property_v3]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_e5Property_v3]
as
begin
/*
20141210, LS, create (bill this to claim portfolio/dashboard)
20150708, LS, T16817, NZ e5 v3
*/

    set nocount on

    exec etlsp_StagingIndex_e5_v3

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
			@SubjectArea = 'e5 ODS',
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

    if object_id('[db-au-cmdwh].dbo.e5Property_v3') is null
    begin

        create table [db-au-cmdwh].[dbo].[e5Property_v3]
        (
            [BIRowID] bigint not null identity(1,1),
            [Domain] varchar(5),
            PropertyKey nvarchar(40),
            [ID] [nvarchar](32),
            [PropertyLabel] [nvarchar](100) null,
            [CreateBatchID] int,
            [UpdateBatchID] int,
            [DeleteBatchID] int
        )

        create clustered index idx_e5Property_v3_BIRowID on [db-au-cmdwh].dbo.e5Property_v3(BIRowID)
        create nonclustered index idx_e5Property_v3_PropertyKey on [db-au-cmdwh].dbo.e5Property_v3(PropertyKey) include(PropertyLabel)
        create nonclustered index idx_e5Property_v3_ID on [db-au-cmdwh].dbo.e5Property_v3(ID,Domain) include(PropertyLabel)

    end

    if object_id('tempdb..#e5Property_v3') is not null
        drop table #e5Property_v3

    select
        'V3' Domain,
        'V3' + [ID] collate database_default PropertyKey,
        [ID] collate database_default ID,
        [PropertyLabel] collate database_default PropertyLabel
    into #e5Property_v3
    from
        e5_property_v3


    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].[dbo].[e5Property_v3] with(tablock) t
        using #e5Property_v3 s on
            s.PropertyKey = t.PropertyKey

        when matched then

            update
            set
                ID = s.ID,
                PropertyLabel = s.PropertyLabel,
                UpdateBatchID = @batchid,
                DeleteBatchID = null

        when not matched by target then
            insert
            (
                Domain,
                PropertyKey,
                ID,
                PropertyLabel,
                CreateBatchID
            )
            values
            (
                s.Domain,
                s.PropertyKey,
                s.ID,
                s.PropertyLabel,
                @batchid
            )

        when
            not matched by source and
            DeleteBatchID is null
        then

            update
            set
                DeleteBatchID = @batchid

        output $action into @mergeoutput
        ;

        select
            @insertcount =
                sum(
                    case
                        when MergeAction = 'insert' then 1
                        else 0
                    end
                ),
            @updatecount =
                sum(
                    case
                        when MergeAction = 'update' then 1
                        else 0
                    end
                )
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
            @SourceInfo = 'e5Property_v3 data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end
GO
