USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_Project_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_STAR_Project_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load project dimension
Change History:
                20160512 - LL - created
				20180423 - LT - created for SUN GL INDIA
    
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

    select
        @name = object_name(@@procid)

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    if object_id('[db-au-star]..Dim_Project_Codes_ind') is null
    begin

        create table [db-au-star]..Dim_Project_Codes_ind
        (
            [Project_Codes_SK] int not null identity(1,1),
            [Project_Code] varchar(50) not null,
            [Project_Desc] varchar(200) null,
            [Project_Owner_Code] varchar(50) not null,
            [Project_Owner_Desc] varchar(200) null,
            [Parent_Project_Code] varchar(50) not null,
            [Parent_Project_Code_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_Project_Codes_PK_ind on [db-au-star].dbo.Dim_Project_Codes_ind(Project_Codes_SK)
        create nonclustered index IX01_Dim_Project_Codes_ind on [db-au-star].dbo.Dim_Project_Codes_ind(Project_Code)

        set identity_insert [db-au-star]..Dim_Project_Codes_ind on

        insert into [db-au-star]..Dim_Project_Codes_ind
        (
            [Project_Codes_SK],
            [Project_Code],
            [Project_Desc],
            [Project_Owner_Code],
            [Project_Owner_Desc],
            [Parent_Project_Code],
            [Parent_Project_Code_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Project_SK],
            'UNKNOWN' [Project_Code],
            'UNKNOWN' [Project_Desc],
            'UNKNOWN' [Project_Owner_Code],
            'UNKNOWN' [Project_Owner_Desc],
            'UNKNOWN' [Parent_Project_Code],
            'UNKNOWN' [Parent_Project_Code_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_Project_Codes_ind off

    end

    if object_id('tempdb..#Dim_Project_Codes_ind') is not null
        drop table #Dim_Project_Codes_ind

    select *
    into #Dim_Project_Codes_ind
    from
        [db-au-star]..Dim_Project_Codes_ind
    where
        1 = 0

    insert into #Dim_Project_Codes_ind
    (
        [Project_Code],
        [Project_Desc],
        [Project_Owner_Code],
        [Project_Owner_Desc],
        [Parent_Project_Code],
        [Parent_Project_Code_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.ProjectCode,
        s.ProjectDescription,
        s.ProjectOwnerCode,
        s.ProjectOwnerDescription,
        s.ParentProjectCode,
        s.ParentProjectDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glProjects_ind s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Project_Codes_ind with(tablock) t
        using #Dim_Project_Codes_ind s on
            s.[Project_Code] = t.[Project_Code]

        when 
            matched and
            binary_checksum(t.[Project_Desc],t.[Project_Owner_Code],t.[Project_Owner_Desc],t.[Parent_Project_Code],t.[Parent_Project_Code_Desc]) <>
            binary_checksum(s.[Project_Desc],s.[Project_Owner_Code],s.[Project_Owner_Desc],s.[Parent_Project_Code],s.[Parent_Project_Code_Desc]) 
        then

            update
            set
                [Project_Desc] = s.[Project_Desc],
                [Parent_Project_Code] = s.[Parent_Project_Code],
                [Parent_Project_Code_Desc] = s.[Parent_Project_Code_Desc],
                [Project_Owner_Code] = s.[Project_Owner_Code],
                [Project_Owner_Desc] = s.[Project_Owner_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Project_Code],
                [Project_Desc],
                [Project_Owner_Code],
                [Project_Owner_Desc],
                [Parent_Project_Code],
                [Parent_Project_Code_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Project_Code],
                s.[Project_Desc],
                s.[Project_Owner_Code],
                s.[Project_Owner_Desc],
                s.[Parent_Project_Code],
                s.[Parent_Project_Code_Desc],
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
