USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimDuration]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_dimDuration]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131114
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penCountry table available
Description:    dimDuration dimension table contains destination attributes.
Parameters:     @LoadType: value is Migration or Incremental
Change History:
                20131114 - LT - Procedure created
                20140710 - PW - Added ABS Travel duration
                20140714 - PW - Removed type 2 references
                20140725 - LT - Amended merged statement
                20140905 - LS - refactoring
                20150204 - LS - replace batch codes with standard batch logging

*************************************************************************************************************************************/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'Policy Star',
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


    --create dimDuration if table does not exist
    if object_id('[db-au-star].dbo.dimDuration') is null
    begin
    
        create table [db-au-star].dbo.dimDuration
        (
            DurationSK int identity(1,1) not null,
            Duration int not null,
            DurationBand nvarchar(50) null,
            ABSDurationBand nvarchar(50) null,
            MinimumBand int null,
            MaximumBand int null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null,
            HashKey varbinary(30) null
        )
        
        create clustered index idx_dimDuration_DurationSK on [db-au-star].dbo.dimDuration(DurationSK)
        create nonclustered index idx_dimDuration_Duration on [db-au-star].dbo.dimDuration(Duration)
        create nonclustered index idx_dimDuration_DurationBand on [db-au-star].dbo.dimDuration(DurationBand)
        create nonclustered index idx_dimDuration_ABSDurationBand on [db-au-star].dbo.dimDuration(ABSDurationBand)
        create nonclustered index idx_dimDuration_HashKey on [db-au-star].dbo.dimDuration(HashKey)

        set identity_insert [db-au-star].dbo.dimDuration on

        --populate dimension with default unknown values
        insert [db-au-star].dbo.dimDuration
        (
            DurationSK,
            Duration,
            DurationBand,
            ABSDurationBand,
            MinimumBand,
            MaximumBand,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            -1,
            -1,
            'UNKNOWN',
            'UNKNOWN',
            -1,
            -1,
            getdate(),
            null,
            @batchid,
            null,
            binary_checksum(-1,'UNKNOWN',-1,-1)
        )

        set identity_insert [db-au-star].dbo.dimDuration off
        
    end


    if object_id('[db-au-stage].dbo.etl_dimDuration') is not null 
        drop table [db-au-stage].dbo.etl_dimDuration
        
    select
        a.Duration,
        a.DurationBand,
        case
            when a.Duration < 0 then 'UNKNOWN'
            when a.Duration between 0 and 7 then 'Under 1 Week'
            when a.Duration between 8 and 14 then '1-2 Weeks'
            when a.Duration between 15 and 28 then '2-4 Weeks'
            when a.Duration between 29 and 60 then '1-2 Months'
            when a.Duration between 61 and 90 then '2-3 Months'
            when a.Duration between 91 and 180 then '3-6 Months'
            when a.Duration between 181 and 366 then '6-12 Months'
            else 'Greater than 12 Months'
        end as ABSDurationBand,
        a.MinimumBand,
        a.MaximumBand,
        convert(datetime,null) as LoadDate,
        convert(datetime,null) as updateDate,
        convert(int,null) as LoadID,
        convert(int,null) as updateID,
        convert(varbinary,null) as HashKey
    into [db-au-stage].dbo.etl_dimDuration
    from
        [db-au-stage].dbo.etl_excel_duration a



    --Update HashKey value
    update [db-au-stage].dbo.etl_dimDuration
    set 
        HashKey = binary_checksum(Duration, DurationBand, MinimumBand, MaximumBand)


    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_dimDuration

    begin transaction
    begin try

        -- Merge statement
        merge into [db-au-star].dbo.dimDuration as DST
        using [db-au-stage].dbo.etl_dimDuration as SRC
        on (src.Duration = DST.Duration)

        -- inserting new records
        when not matched by target then
        insert
        (
            Duration,
            DurationBand,
            ABSDurationBand,
            MinimumBand,
            MaximumBand,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            SRC.Duration,
            SRC.DurationBand,
            SRC.ABSDurationBand,
            SRC.MinimumBand,
            SRC.MaximumBand,
            getdate(),
            null,
            @batchid,
            null,
            SRC.HashKey
        )
        
        -- update existing records where data has changed via HashKey
        when matched and DST.HashKey <> SRC.HashKey then
        update
        SET
            DST.Duration = SRC.Duration,
            DST.DurationBand = SRC.DurationBand,
            DST.ABSDurationBand = SRC.ABSDurationBand,
            DST.MinimumBand = SRC.MinimumBand,
            DST.MaximumBand = SRC.MaximumBand,
            DST.UpdateDate = getdate(),
            DST.UpdateID = @batchid,
            DST.HashKey = SRC.HashKey
            
        output $action into @mergeoutput;

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
