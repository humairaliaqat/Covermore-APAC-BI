USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_Product_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_STAR_Product_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load product dimension
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

    if object_id('[db-au-star]..Dim_GL_Product_ind') is null
    begin

        create table [db-au-star]..Dim_GL_Product_ind
        (
            [Product_SK] int not null identity(1,1),
            [Product_Code] varchar(50) not null,
            [Product_Desc] varchar(200) null,
            [Product_Type_Code] varchar(50) not null,
            [Product_Type_Desc] varchar(200) null,
            [Product_Parent_Code] varchar(50) not null,
            [Product_Parent_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_GL_Product_PK_ind on [db-au-star].dbo.Dim_GL_Product_ind(Product_SK)
        create nonclustered index IX01_Dim_GL_Product_ind on [db-au-star].dbo.Dim_GL_Product_ind(Product_Code) include (Product_Type_Code,Product_Parent_Code)

        set identity_insert [db-au-star]..Dim_GL_Product_ind on

        insert into [db-au-star]..Dim_GL_Product_ind
        (
            [Product_SK],
            [Product_Code],
            [Product_Desc],
            [Product_Type_Code],
            [Product_Type_Desc],
            [Product_Parent_Code],
            [Product_Parent_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Product_SK],
            'UNKNOWN' [Product_Code],
            'UNKNOWN' [Product_Desc],
            'UNKNOWN' [Product_Type_Code],
            'UNKNOWN' [Product_Type_Desc],
            'UNKNOWN' [Product_Parent_Code],
            'UNKNOWN' [Product_Parent_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_GL_Product_ind off

    end

    if object_id('tempdb..#Dim_GL_Product_ind') is not null
        drop table #Dim_GL_Product_ind

    select *
    into #Dim_GL_Product_ind
    from
        [db-au-star]..Dim_GL_Product_ind
    where
        1 = 0

    insert into #Dim_GL_Product_ind
    (
        [Product_Code],
        [Product_Desc],
        [Product_Type_Code],
        [Product_Type_Desc],
        [Product_Parent_Code],
        [Product_Parent_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.ProductCode,
        s.ProductDescription,
        s.ProductTypeCode,
        s.ProductTypeDescription,
        s.ParentProductCode,
        s.ParentProductDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glProducts_ind s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_GL_Product_ind with(tablock) t
        using #Dim_GL_Product_ind s on
            s.[Product_Code] = t.[Product_Code]

        when 
            matched and
            binary_checksum(t.[Product_Desc],t.[Product_Type_Code],t.[Product_Type_Desc],t.[Product_Parent_Code],t.[Product_Parent_Desc]) <>
            binary_checksum(s.[Product_Desc],s.[Product_Type_Code],s.[Product_Type_Desc],s.[Product_Parent_Code],s.[Product_Parent_Desc]) 
        then

            update
            set
                [Product_Desc] = s.[Product_Desc],
                [Product_Type_Code] = s.[Product_Type_Code],
                [Product_Type_Desc] = s.[Product_Type_Desc],
                [Product_Parent_Code] = s.[Product_Parent_Code],
                [Product_Parent_Desc] = s.[Product_Parent_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Product_Code],
                [Product_Desc],
                [Product_Type_Code],
                [Product_Type_Desc],
                [Product_Parent_Code],
                [Product_Parent_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Product_Code],
                s.[Product_Desc],
                s.[Product_Type_Code],
                s.[Product_Type_Desc],
                s.[Product_Parent_Code],
                s.[Product_Parent_Desc],
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
