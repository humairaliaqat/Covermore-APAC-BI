USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Product]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL033_ODS_Product]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160509
Prerequisite:   
Description:    load product table
Change History:
                20160509 - LL - created
    
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

    if object_id('[db-au-cmdwh]..glProducts') is null
    begin

        create table [db-au-cmdwh]..glProducts
        (
            BIRowID bigint identity(1,1) not null,
            ParentProductCode varchar(50) not null,
            ParentProductDescription nvarchar(255),
            ProductCode varchar(50) not null,
            ProductDescription nvarchar(255),
            ProductTypeCode varchar(50) not null,
            ProductTypeDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx on [db-au-cmdwh]..glProducts (BIRowID)
        create nonclustered index idx on [db-au-cmdwh]..glProducts (ProductCode) include (ParentProductCode,ParentProductDescription,ProductDescription,ProductTypeCode,ProductTypeDescription)
        create nonclustered index idx_parent on [db-au-cmdwh]..glProducts (ParentProductCode) include (ProductCode,ProductDescription,ParentProductDescription)

    end

    if object_id('tempdb..#glProducts') is not null
        drop table #glProducts

    select *
    into #glProducts
    from
        [db-au-cmdwh]..glProducts
    where
        1 = 0

    insert into #glProducts
    (
        ParentProductCode,
        ParentProductDescription,
        ProductCode,
        ProductDescription,
        ProductTypeCode,
        ProductTypeDescription
    )
    select 
        t.[Product Parent Code],
        t.[Product Parent Description],
        t.[Product Code],
        t.[Product Description],
        t.[Product Type Code],
        t.[Product Type Description]
    from
        [db-au-stage]..sungl_excel_product t
    where
        isnull(ltrim(rtrim(t.[Product Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glProducts with(tablock) t
        using #glProducts s on
            s.ProductCode = t.ProductCode

        when 
            matched and
            binary_checksum(t.ParentProductCode,t.ParentProductDescription,t.ProductDescription,t.ProductTypeCode,t.ProductTypeDescription,t.DeleteDateTime) <>
            binary_checksum(s.ParentProductCode,s.ParentProductDescription,s.ProductDescription,s.ProductTypeCode,s.ProductTypeDescription,s.DeleteDateTime) 
        then

            update
            set
                ParentProductCode = s.ParentProductCode,
                ParentProductDescription = s.ParentProductDescription,
                ProductDescription = s.ProductDescription,
                ProductTypeCode = s.ProductTypeCode,
                ProductTypeDescription = s.ProductTypeDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentProductCode,
                ParentProductDescription,
                ProductCode,
                ProductDescription,
                ProductTypeCode,
                ProductTypeDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentProductCode,
                s.ParentProductDescription,
                s.ProductCode,
                s.ProductDescription,
                s.ProductTypeCode,
                s.ProductTypeDescription,
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
