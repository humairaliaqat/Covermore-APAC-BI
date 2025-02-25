USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_STAR_Currency]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_ETL033_STAR_Currency]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160512
Prerequisite:   
Description:    load currency dimension
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

    if object_id('[db-au-star]..Dim_Currency') is null
    begin

        create table [db-au-star]..Dim_Currency
        (
            [Currency_SK] int not null identity(1,1),
            [Currency_Code] varchar(50) not null,
            [Currency_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_Currency_PK on [db-au-star].dbo.Dim_Currency(Currency_SK)
        create nonclustered index IX01_Dim_Currency on [db-au-star].dbo.Dim_Currency(Currency_Code)

        set identity_insert [db-au-star]..Dim_Currency on

        insert into [db-au-star]..Dim_Currency
        (
            [Currency_SK],
            [Currency_Code],
            [Currency_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [Currency_SK],
            'UNKNOWN' [Currency_Code],
            'UNKNOWN' [Currency_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-star]..Dim_Currency off

    end

    if object_id('tempdb..#Dim_Currency') is not null
        drop table #Dim_Currency

    select *
    into #Dim_Currency
    from
        [db-au-star]..Dim_Currency
    where
        1 = 0

    insert into #Dim_Currency
    (
        [Currency_Code],
        [Currency_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.CurrencyCode,
        s.CurrencyDescription,
        getdate(),
        -1
    from
        [db-au-cmdwh]..glCurrencies s

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-star]..Dim_Currency with(tablock) t
        using #Dim_Currency s on
            s.[Currency_Code] = t.[Currency_Code]

        when 
            matched and
            binary_checksum(t.[Currency_Desc]) <>
            binary_checksum(s.[Currency_Desc]) 
        then

            update
            set
                [Currency_Desc] = s.[Currency_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = @batchid

        when not matched by target then
            insert
            (
                [Currency_Code],
                [Currency_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[Currency_Code],
                s.[Currency_Desc],
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
