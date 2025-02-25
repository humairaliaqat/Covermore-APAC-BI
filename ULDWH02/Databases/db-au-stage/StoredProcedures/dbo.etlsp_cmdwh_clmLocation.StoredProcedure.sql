USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_clmLocation]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_clmLocation]
as
begin
/*
    20140415, LS, 20728 Refactoring
    20140731, LS, T12242 Global Claim
    20140801, LS, use batch logging
    20141111, LS, T14092 Claims.Net Global
                  add new UK data set
*/

    set nocount on

    exec etlsp_StagingIndex_Claim

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
        @SubjectArea = 'Claim ODS',
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

    if object_id('[db-au-cmdwh].dbo.clmLocation') is null
    begin

        create table [db-au-cmdwh].dbo.clmLocation
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] varchar(2) not null,
            [LocationKey] varchar(40) not null,
            [LocationID] int not null,
            [Location] nvarchar(50) null,
            [LocationDesc] nvarchar(50) null,
            [Display] bit null,
            [CreateDateTime] datetime null,
            [UpdateDateTime] datetime null,
            [DeleteDateTime] datetime null,
            [CreateBatchID] int null,
            [UpdateBatchID] int null
        )

        create clustered index idx_clmLocation_BIRowID on [db-au-cmdwh].dbo.clmLocation(BIRowID)
        create nonclustered index idx_clmLocation_LocationID on [db-au-cmdwh].dbo.clmLocation(LocationID,CountryKey) include (Location,LocationDesc)
        create nonclustered index idx_clmLocation_LocationKey on [db-au-cmdwh].dbo.clmLocation(LocationKey) include (Location,LocationDesc)

    end

    if object_id('tempdb..#clmLocation') is not null
        drop table #clmLocation

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, l.LO_ID) LocationKey,
        l.LO_ID LocationID,
        l.LOCAT Location,
        l.LODESC LocationDesc,
        l.Display
    into #clmLocation
    from
        claims_kllocation_au l
        cross apply dbo.fn_GetDomainKeys(l.KLDOMAINID, 'CM', 'AU') dk

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, l.LO_ID) LocationKey,
        l.LO_ID LocationID,
        l.LOCAT Location,
        l.LODESC LocationDesc,
        l.Display
    from
        claims_kllocation_uk2 l
        cross apply dbo.fn_GetDomainKeys(l.KLDOMAINID, 'CM', 'UK') dk

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, l.LO_ID) LocationKey,
        l.LO_ID LocationID,
        l.LOCAT Location,
        l.LODESC LocationDesc,
        l.Display
    from
        claims_kllocation_nz l
        cross apply
        (
            select
                'NZ' CountryKey
        ) dk

    union all

    select
        dk.CountryKey,
        dk.CountryKey + '-' + convert(varchar, l.LO_ID) LocationKey,
        l.LO_ID LocationID,
        l.LOCAT Location,
        l.LODESC LocationDesc,
        l.Display
    from
        claims_kllocation_uk l
        cross apply
        (
            select
                'UK' CountryKey
        ) dk

    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.clmLocation with(tablock) t
        using #clmLocation s on
            s.LocationKey = t.LocationKey

        when
            matched and
            binary_checksum(
                t.Location,
                t.LocationDesc,
                t.Display
            ) <>
            binary_checksum(
                s.Location,
                s.LocationDesc,
                s.Display
            )
        then

            update
            set
                Location = s.Location,
                LocationDesc = s.LocationDesc,
                Display = s.Display,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                CountryKey,
                LocationKey,
                LocationID,
                Location,
                LocationDesc,
                Display,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.CountryKey,
                s.LocationKey,
                s.LocationID,
                s.Location,
                s.LocationDesc,
                s.Display,
                getdate(),
                @batchid
            )

        when
            not matched by source and
            DeleteDateTime is null
        then

            update
            set
                DeleteDateTime = getdate()

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
            @SourceInfo = 'clmLocation data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end


GO
