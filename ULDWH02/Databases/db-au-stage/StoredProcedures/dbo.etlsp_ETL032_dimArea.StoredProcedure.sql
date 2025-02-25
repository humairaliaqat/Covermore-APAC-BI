USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimArea]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_dimArea]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131114
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penCountry table available
Description:    dimArea dimension table contains destination attributes.
Parameters:     @LoadType: value is Migration or Incremental
Change History:
                20131114 - LT - Procedure created
                20140714 - PW - Removed type 2 references
                20140725 - LT - Amended merged statement
                20140905 - LS - refactoring
                20150204 - LS - replace batch codes with standard batch logging
                20150515 - LS - default values for new areas

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

    --create dimArea if table does not exist
    if object_id('[db-au-star].dbo.dimArea') is null
    begin

        create table [db-au-star].dbo.dimArea
        (
            AreaSK int identity(1,1) not null,
            Country nvarchar(10) not null,
            AreaName nvarchar(100) null,
            AreaType nvarchar(50) null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null,
            HashKey varbinary(30) null
        )

        create clustered index idx_dimArea_AreaSK on [db-au-star].dbo.dimArea(AreaSK)
        create nonclustered index idx_dimArea_Country on [db-au-star].dbo.dimArea(Country)
        create nonclustered index idx_dimArea_AreaName on [db-au-star].dbo.dimArea(AreaName) include (AreaSK,Country,AreaType)
        create nonclustered index idx_dimArea_AreaType on [db-au-star].dbo.dimArea(AreaType)
        create nonclustered index idx_dimArea_HashKey on [db-au-star].dbo.dimArea(HashKey)

        set identity_insert [db-au-star].dbo.dimArea on

        --populate dimension with default unknown values
        insert [db-au-star].dbo.dimArea
        (
            AreaSK,
            Country,
            AreaName,
            AreaType,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey
        )
        values
        (
            -1,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            getdate(),
            null,
            @batchid,
            null,
            binary_checksum(-1, -1, 'UNKNOWN', 'UNKNOWN')
        )

        set identity_insert [db-au-star].dbo.dimArea off

    end

    if object_id('[db-au-stage].dbo.etl_dimArea') is not null
        drop table [db-au-stage].dbo.etl_dimArea

    select distinct
        isnull(d.CountryCode,'UNKNOWN') as Country,
        case
            when a.CountryKey = 'AU' and a.AreaType = 'Domestic (Inbound)' then 'Australia Inbound'
            when a.CountryKey = 'NZ' and a.AreaType = 'Domestic (Inbound)' then 'New Zealand Inbound'
            when a.CountryKey = 'NZ' and a.AreaType = 'Domestic' and a.AreaName like 'New Zealand%' then 'New Zealand'
            when a.CountryKey = 'MY' and a.AreaType = 'Domestic' and a.AreaName = 'Domestic' then 'Malaysia'
            when a.CountryKey = 'UK' and a.AreaType = 'Domestic' and a.AreaName = 'Domestic Dummy' then 'United Kingdom'
            else a.AreaName
        end as AreaName,
        a.AreaType,
        convert(datetime,null) as LoadDate,
        convert(datetime,null) as updateDate,
        convert(int,null) as LoadID,
        convert(int,null) as updateID,
        convert(varbinary,null) as HashKey
    into [db-au-stage].dbo.etl_dimArea
    from
        [db-au-cmdwh].dbo.penArea a
        left join [db-au-star].dbo.dimDomain d on
            a.DomainID = d.DomainID


    --Update HashKey value
    update [db-au-stage].dbo.etl_dimArea
    set
        HashKey = binary_checksum(Country, AreaName, AreaType)

    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_dimArea

    begin transaction

    begin try

        -- Merge statement
        merge into [db-au-star].dbo.dimArea as DST
        using [db-au-stage].dbo.etl_dimArea as SRC
        on
            (
                SRC.Country = DST.Country and
                SRC.AreaName = DST.AreaName and
                SRC.AreaType = DST.AreaType
            )

        -- inserting new records
        when not matched by target then
        insert
        (
            Country,
            AreaName,
            AreaType,
            LoadDate,
            updateDate,
            LoadID,
            updateID,
            HashKey,
            Weighting,
            AreaNumber
        )
        values
        (
            SRC.Country,
            SRC.AreaName,
            SRC.AreaType,
            getdate(),
            null,
            @batchid,
            null,
            SRC.HashKey,
            99,
            null
        )
        -- update existing records where data has changed via HashKey
        when matched and DST.HashKey <> SRC.HashKey then
        update
        set
            DST.Country = SRC.Country,
            DST.AreaName = SRC.AreaName,
            DST.AreaType = SRC.AreaType,
            DST.HashKey = SRC.HashKey,
            DST.UpdateDate = getdate(),
            DST.UpdateID = @batchid

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
