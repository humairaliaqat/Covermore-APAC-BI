USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_Department]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_STAR_Department]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160512
Prerequisite:   
Description:    load department dimension
Change History:
                20160512 - LL - created
    
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

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-star]..Dim_Department') is null
    begin

        create table [db-au-star]..Dim_Department
        (
            [Department_SK] int not null identity(1,1),
            [Department_Code] varchar(50) not null,
            [Department_Desc] varchar(200) null,
            [Parent_Department_Code] varchar(50) not null,
            [Parent_Department_Desc] varchar(200) null,
            [Department_Type_Code] varchar(50) not null,
            [Department_Type_Desc] varchar(200) null,
            [Department_Entity_Code] varchar(50) not null,
            [Department_Entity_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_Department_PK on [db-au-star].dbo.Dim_Department(Department_SK)
        create nonclustered index IX01_Dim_Department on [db-au-star].dbo.Dim_Department(Department_Code)

        set identity_insert [db-au-star]..Dim_Department on

        insert into [db-au-star]..Dim_Department
        (
            [Department_SK],
            [Department_Code],
            [Department_Desc],
            [Parent_Department_Code],
            [Parent_Department_Desc],
            [Department_Type_Code],
            [Department_Type_Desc],
            [Department_Entity_Code],
            [Department_Entity_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Department_SK],
            'UNKNOWN' [Department_Code],
            'UNKNOWN' [Department_Desc],
            'UNKNOWN' [Parent_Department_Code],
            'UNKNOWN' [Parent_Department_Desc],
            'UNKNOWN' [Department_Type_Code],
            'UNKNOWN' [Department_Type_Desc],
            'UNKNOWN' [Department_Entity_Code],
            'UNKNOWN' [Department_Entity_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_Department off

    end

    if object_id('tempdb..#Dim_Department') is not null
        drop table #Dim_Department

    select *
    into #Dim_Department
    from
        [db-au-star]..Dim_Department
    where
        1 = 0

    insert into #Dim_Department
    (
        [Department_Code],
        [Department_Desc],
        [Parent_Department_Code],
        [Parent_Department_Desc],
        [Department_Type_Code],
        [Department_Type_Desc],
        [Department_Entity_Code],
        [Department_Entity_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.DepartmentCode,
        s.DepartmentDescription,
        s.ParentDepartmentCode,
        s.ParentDepartmentDescription,
        s.DepartmentTypeCode,
        s.DepartmentTypeDescription,
        s.DepartmentEntityCode,
        s.DepartmentEntityDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glDepartments s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Department with(tablock) t
        using #Dim_Department s on
            s.[Department_Code] = t.[Department_Code]

        when 
            matched and
            binary_checksum(t.[Department_Desc],t.[Parent_Department_Code],t.[Parent_Department_Desc],t.[Department_Type_Code],t.[Department_Type_Desc],t.[Department_Entity_Code],t.[Department_Entity_Desc]) <>
            binary_checksum(s.[Department_Desc],s.[Parent_Department_Code],s.[Parent_Department_Desc],s.[Department_Type_Code],s.[Department_Type_Desc],s.[Department_Entity_Code],s.[Department_Entity_Desc]) 
        then

            update
            set
                [Department_Desc] = s.[Department_Desc],
                [Parent_Department_Code] = s.[Parent_Department_Code],
                [Parent_Department_Desc] = s.[Parent_Department_Desc],
                [Department_Type_Code] = s.[Department_Type_Code],
                [Department_Type_Desc] = s.[Department_Type_Desc],
                [Department_Entity_Code] = s.[Department_Entity_Code],
                [Department_Entity_Desc] = s.[Department_Entity_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Department_Code],
                [Department_Desc],
                [Parent_Department_Code],
                [Parent_Department_Desc],
                [Department_Type_Code],
                [Department_Type_Desc],
                [Department_Entity_Code],
                [Department_Entity_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Department_Code],
                s.[Department_Desc],
                s.[Parent_Department_Code],
                s.[Parent_Department_Desc],
                s.[Department_Type_Code],
                s.[Department_Type_Desc],
                s.[Department_Entity_Code],
                s.[Department_Entity_Desc],
                getdate(),
                @batchid
            )

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
