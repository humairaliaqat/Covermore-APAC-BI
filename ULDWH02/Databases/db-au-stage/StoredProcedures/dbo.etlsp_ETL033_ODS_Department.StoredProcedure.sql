USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Department]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL033_ODS_Department]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160506
Prerequisite:   
Description:    load department table
Change History:
                20160506 - LL - created
    
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
        @SubjectArea = 'SUN GL',
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

    if object_id('[db-au-cmdwh]..glDepartments') is null
    begin

        create table [db-au-cmdwh]..glDepartments
        (
            BIRowID bigint identity(1,1) not null,
            ParentDepartmentCode varchar(50) not null,
            ParentDepartmentDescription nvarchar(255),
            DepartmentCode varchar(50) not null,
            DepartmentDescription nvarchar(255),
            DepartmentTypeCode varchar(50) not null,
            DepartmentTypeDescription nvarchar(200),
            DepartmentEntityCode varchar(50) not null,
            DepartmentEntityDescription nvarchar(200),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glDepartments (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glDepartments (DepartmentCode) include 
            (ParentDepartmentCode,ParentDepartmentDescription,DepartmentDescription,DepartmentTypeCode,DepartmentTypeDescription,DepartmentEntityCode,DepartmentEntityDescription)
        create nonclustered index idx_parent on [db-au-cmdwh]..glDepartments (ParentDepartmentCode) include (DepartmentCode,DepartmentDescription,ParentDepartmentDescription)

    end

    if object_id('tempdb..#glDepartments') is not null
        drop table #glDepartments

    select *
    into #glDepartments
    from
        [db-au-cmdwh]..glDepartments
    where
        1 = 0

    insert into #glDepartments
    (
        ParentDepartmentCode,
        ParentDepartmentDescription,
        DepartmentCode,
        DepartmentDescription,
        DepartmentTypeCode,
        DepartmentTypeDescription,
        DepartmentEntityCode,
        DepartmentEntityDescription
    )
    select 
        t.[Parent Dept Code],
        t.[Parent Dept Description],
        t.[Child Dept Code],
        t.[Child Dept Description],
        t.[Department Type Code],
        t.[Department Type Description],
        t.[Department Entity Code],
        t.[Department Entity Description]
    from
        [db-au-stage]..sungl_excel_department t
    where
        isnull(ltrim(rtrim(t.[Child Dept Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glDepartments with(tablock) t
        using #glDepartments s on
            s.DepartmentCode = t.DepartmentCode

        when 
            matched and
            binary_checksum(t.ParentDepartmentCode,t.ParentDepartmentDescription,t.DepartmentDescription,t.DepartmentTypeCode,t.DepartmentTypeDescription,t.DepartmentEntityCode,t.DepartmentEntityDescription,t.DeleteDateTime) <>
            binary_checksum(s.ParentDepartmentCode,s.ParentDepartmentDescription,s.DepartmentDescription,s.DepartmentTypeCode,s.DepartmentTypeDescription,s.DepartmentEntityCode,s.DepartmentEntityDescription,s.DeleteDateTime)
        then

            update
            set
                ParentDepartmentCode = s.ParentDepartmentCode,
                ParentDepartmentDescription = s.ParentDepartmentDescription,
                DepartmentDescription = s.DepartmentDescription,
                DepartmentTypeCode = s.DepartmentTypeCode,
                DepartmentTypeDescription = s.DepartmentTypeDescription,
                DepartmentEntityCode = s.DepartmentEntityCode,
                DepartmentEntityDescription = s.DepartmentEntityDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentDepartmentCode,
                ParentDepartmentDescription,
                DepartmentCode,
                DepartmentDescription,
                DepartmentTypeCode,
                DepartmentTypeDescription,
                DepartmentEntityCode,
                DepartmentEntityDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentDepartmentCode,
                s.ParentDepartmentDescription,
                s.DepartmentCode,
                s.DepartmentDescription,
                s.DepartmentTypeCode,
                s.DepartmentTypeDescription,
                s.DepartmentEntityCode,
                s.DepartmentEntityDescription,
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
