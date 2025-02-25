USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_JointVenture]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_STAR_JointVenture]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160512
Prerequisite:   
Description:    load jv dimension
Change History:
                20160513 - LL - created
    
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

    if object_id('[db-au-star]..Dim_Joint_Venture') is null
    begin

        create table [db-au-star]..Dim_Joint_Venture
        (
            [Joint_Venture_SK] int not null identity(1,1),
            [Joint_Venture_Category_Code] varchar(50) not null,
            [Joint_Venture_Category_Desc] varchar(200) null,
            [Joint_Venture_Code] varchar(50) not null,
            [Joint_Venture_Desc] varchar(200) null,
            [Distribution_Type_Code] varchar(50) not null,
            [Distribution_Type_Desc] varchar(200) null,
            [Super_Group_Code] varchar(50) not null,
            [Super_Group_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_Joint_Venture_PK on [db-au-star].dbo.Dim_Joint_Venture(Joint_Venture_SK)
        create nonclustered index idx on [db-au-star].dbo.Dim_Joint_Venture(Joint_Venture_Code) include (Joint_Venture_Desc,Joint_Venture_Category_Desc,Distribution_Type_Desc)

        set identity_insert [db-au-star]..Dim_Joint_Venture on

        insert into [db-au-star]..Dim_Joint_Venture
        (
            [Joint_Venture_SK],
            [Joint_Venture_Category_Code],
            [Joint_Venture_Category_Desc],
            [Joint_Venture_Code],
            [Joint_Venture_Desc],
            [Distribution_Type_Code],
            [Distribution_Type_Desc],
            [Super_Group_Code],
            [Super_Group_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Joint_Venture_SK],
            'UNKNOWN' [Joint_Venture_Category_Code],
            'UNKNOWN' [Joint_Venture_Category_Desc],
            'UNKNOWN' [Joint_Venture_Code],
            'UNKNOWN' [Joint_Venture_Desc],
            'UNKNOWN' [Distribution_Type_Code],
            'UNKNOWN' [Distribution_Type_Desc],
            'UNKNOWN' [Super_Group_Code],
            'UNKNOWN' [Super_Group_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_Joint_Venture off

    end

    if object_id('tempdb..#Dim_Joint_Venture') is not null
        drop table #Dim_Joint_Venture

    select *
    into #Dim_Joint_Venture
    from
        [db-au-star]..Dim_Joint_Venture
    where
        1 = 0

    insert into #Dim_Joint_Venture
    (
        [Joint_Venture_Category_Code],
        [Joint_Venture_Category_Desc],
        [Joint_Venture_Code],
        [Joint_Venture_Desc],
        [Distribution_Type_Code],
        [Distribution_Type_Desc],
        [Super_Group_Code],
        [Super_Group_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.TypeOfJVCode,
        s.TypeOfJVDescription,
        s.JVCode,
        s.JVDescription,
        s.DistributionTypeCode,
        s.DistributionTypeDescription,
        s.SuperGroupCode,
        s.SuperGroupDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glJointVentures s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Joint_Venture with(tablock) t
        using #Dim_Joint_Venture s on
            s.[Joint_Venture_Code] = t.[Joint_Venture_Code]

        when 
            matched and
            binary_checksum(t.[Joint_Venture_Category_Code],t.[Joint_Venture_Category_Desc],t.[Joint_Venture_Desc],t.[Distribution_Type_Code],t.[Distribution_Type_Desc],t.[Super_Group_Code],t.[Super_Group_Desc]) <>
            binary_checksum(s.[Joint_Venture_Category_Code],s.[Joint_Venture_Category_Desc],s.[Joint_Venture_Desc],s.[Distribution_Type_Code],s.[Distribution_Type_Desc],s.[Super_Group_Code],s.[Super_Group_Desc]) 
        then

            update
            set
                [Joint_Venture_Category_Code] = s.[Joint_Venture_Category_Code],
                [Joint_Venture_Category_Desc] = s.[Joint_Venture_Category_Desc],
                [Joint_Venture_Desc] = s.[Joint_Venture_Desc],
                [Distribution_Type_Code] = s.[Distribution_Type_Code],
                [Distribution_Type_Desc] = s.[Distribution_Type_Desc],
                [Super_Group_Code] = s.[Super_Group_Code],
                [Super_Group_Desc] = s.[Super_Group_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Joint_Venture_Category_Code],
                [Joint_Venture_Category_Desc],
                [Joint_Venture_Code],
                [Joint_Venture_Desc],
                [Distribution_Type_Code],
                [Distribution_Type_Desc],
                [Super_Group_Code],
                [Super_Group_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Joint_Venture_Category_Code],
                s.[Joint_Venture_Category_Desc],
                s.[Joint_Venture_Code],
                s.[Joint_Venture_Desc],
                s.[Distribution_Type_Code],
                s.[Distribution_Type_Desc],
                s.[Super_Group_Code],
                s.[Super_Group_Desc],
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
