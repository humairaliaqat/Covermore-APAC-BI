USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_BusinessUnit_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_ODS_BusinessUnit_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load BU table
Change History:
                20160506 - LL - created
				20180423 - LT - created for SUN GL India
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
        @SubjectArea = 'SUN GL INDIA',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    if @batchid = -1
        raiserror('prevent running without batch', 15, 1) with nowait

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-cmdwh]..glBusinessUnits_ind') is null
    begin

        create table [db-au-cmdwh]..glBusinessUnits_ind
        (
            BIRowID bigint identity(1,1) not null,
            ParentBusinessUnitCode varchar(50),
            BusinessUnitCode varchar(50) not null,
            BusinessUnitDescription nvarchar(255),
            CurrencyCode varchar(50),
            SourceSystemCode varchar(50),
            DomainID varchar(50),
            CountryCode varchar(50),
            CountryDescription varchar(200),
            RegionCode varchar(50),
            RegionDescription varchar(200),
            TypeOfEntityCode varchar(50),
            TypeOfEntityDescription varchar(50),
            TypeOfBusinessCode varchar(50),
            TypeOfBusinessDescription varchar(200),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx_ind on [db-au-cmdwh]..glBusinessUnits_ind (BIRowID)
        create nonclustered index idx_ind on [db-au-cmdwh]..glBusinessUnits_ind (BusinessUnitCode) include 
            (ParentBusinessUnitCode,BusinessUnitDescription,CurrencyCode,SourceSystemCode,DomainID,CountryCode,CountryDescription,RegionCode,RegionDescription,TypeOfEntityCode,TypeOfEntityDescription,TypeOfBusinessCode,TypeOfBusinessDescription)
        create nonclustered index idx_parent_ind on [db-au-cmdwh]..glBusinessUnits_ind (ParentBusinessUnitCode) include (BusinessUnitCode,BusinessUnitDescription)

    end

    if object_id('tempdb..#glBusinessUnits_ind') is not null
        drop table #glBusinessUnits_ind

    select *
    into #glBusinessUnits_ind
    from
        [db-au-cmdwh]..glBusinessUnits_ind
    where
        1 = 0

    insert into #glBusinessUnits_ind
    (
        ParentBusinessUnitCode,
        BusinessUnitCode,
        BusinessUnitDescription,
        CurrencyCode,
        SourceSystemCode,
        DomainID,
        CountryCode,
        CountryDescription,
        RegionCode,
        RegionDescription,
        TypeOfEntityCode,
        TypeOfEntityDescription,
        TypeOfBusinessCode,
        TypeOfBusinessDescription
    )
    select 
        t.[Parent Business Unit Code],
        t.[Business Unit Code],
        t.[Business Unit Description],
        t.[Currency Code],
        t.[Source System Code],
        t.[Domain ID],
        t.[Country Code],
        t.[Country Description],
        t.[Region Code],
        t.[Region Description],
        t.[Type of Entity Code],
        t.[Type of Entity Description],
        t.[Type of Business Code],
        t.[Type of Business Description]
    from
        [db-au-stage]..sungl_excel_businessunit_ind t
    where
        isnull(ltrim(rtrim(t.[Business Unit Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glBusinessUnits_ind with(tablock) t
        using #glBusinessUnits_ind s on
            s.BusinessUnitCode = t.BusinessUnitCode

        when 
            matched and
            binary_checksum(t.ParentBusinessUnitCode,t.BusinessUnitDescription,t.CurrencyCode,t.SourceSystemCode,t.DomainID,t.CountryCode,t.CountryDescription,t.RegionCode,t.RegionDescription,t.TypeOfEntityCode,t.TypeOfEntityDescription,t.TypeOfBusinessCode,t.TypeOfBusinessDescription,t.DeleteDateTime) <>
            binary_checksum(s.ParentBusinessUnitCode,s.BusinessUnitDescription,s.CurrencyCode,s.SourceSystemCode,s.DomainID,s.CountryCode,s.CountryDescription,s.RegionCode,s.RegionDescription,s.TypeOfEntityCode,s.TypeOfEntityDescription,s.TypeOfBusinessCode,s.TypeOfBusinessDescription,s.DeleteDateTime)
        then

            update
            set
                ParentBusinessUnitCode = s.ParentBusinessUnitCode,
                BusinessUnitDescription = s.BusinessUnitDescription,
                CurrencyCode = s.CurrencyCode,
                SourceSystemCode = s.SourceSystemCode,
                DomainID = s.DomainID,
                CountryCode = s.CountryCode,
                CountryDescription = s.CountryDescription,
                RegionCode = s.RegionCode,
                RegionDescription = s.RegionDescription,
                TypeOfEntityCode = s.TypeOfEntityCode,
                TypeOfEntityDescription = s.TypeOfEntityDescription,
                TypeOfBusinessCode = s.TypeOfBusinessCode,
                TypeOfBusinessDescription = s.TypeOfBusinessDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentBusinessUnitCode,
                BusinessUnitCode,
                BusinessUnitDescription,
                CurrencyCode,
                SourceSystemCode,
                DomainID,
                CountryCode,
                CountryDescription,
                RegionCode,
                RegionDescription,
                TypeOfEntityCode,
                TypeOfEntityDescription,
                TypeOfBusinessCode,
                TypeOfBusinessDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentBusinessUnitCode,
                s.BusinessUnitCode,
                s.BusinessUnitDescription,
                s.CurrencyCode,
                s.SourceSystemCode,
                s.DomainID,
                s.CountryCode,
                s.CountryDescription,
                s.RegionCode,
                s.RegionDescription,
                s.TypeOfEntityCode,
                s.TypeOfEntityDescription,
                s.TypeOfBusinessCode,
                s.TypeOfBusinessDescription,
                getdate(),
                @batchid
            )

        when
            not matched by source and
            t.DeleteDateTime is null
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
                        when MergeAction = 'delete' then 1
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
            @PackageID = @name,
            @LogStatus = 'Error'

    end catch

    if @@trancount > 0
        commit transaction

end
GO
