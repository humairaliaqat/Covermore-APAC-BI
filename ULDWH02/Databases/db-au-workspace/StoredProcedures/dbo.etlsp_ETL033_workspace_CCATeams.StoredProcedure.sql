USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_workspace_CCATeams]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[etlsp_ETL033_workspace_CCATeams]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160512
Prerequisite:   
Description:    load CCATeams dimension
Change History:
                20160512 - LL - created
				20210303 - HL - Adding code to load new dimension CCA Teams workspace table as per INC0189611
*************************************************************************************************************************************/

    set nocount on

    declare
        @batchid int,
        @workspacet date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    --exec syssp_getrunningbatch
    --    @SubjectArea = 'SUN GL',
    --    @BatchID = @batchid out,
    --    @workspacetDate = @workspacet out,
    --    @EndDate = @end out

    --select
    --    @name = object_name(@@procid)

    --exec syssp_genericerrorhandler
    --    @LogToTable = 1,
    --    @ErrorCode = '0',
    --    @BatchID = @batchid,
    --    @PackageID = @name,
    --    @LogStatus = 'Running'

    if object_id('[db-au-workspace]..Dim_CCATeams_Codes') is null
    begin

        create table [db-au-workspace]..Dim_CCATeams_Codes
        (
            [CCATeams_Codes_SK] int not null identity(1,1),
            [CCATeams_Code] varchar(50) not null,
            [CCATeams_Desc] varchar(200) null,
            [CCATeams_Owner_Code] varchar(50) not null,
            [CCATeams_Owner_Desc] varchar(200) null,
            [Parent_CCATeams_Code] varchar(50) not null,
            [Parent_CCATeams_Code_Desc] varchar(200) null,
            [Create_Date] datetime not null,
            [Update_Date] datetime null,
            [Insert_Batch_ID] int not null,
            [Update_Batch_ID] int null
        )

        create clustered index Dim_CCATeams_Codes_PK on [db-au-workspace].dbo.Dim_CCATeams_Codes(CCATeams_Codes_SK)
        create nonclustered index IX01_Dim_CCATeams_Codes on [db-au-workspace].dbo.Dim_CCATeams_Codes(CCATeams_Code)

        set identity_insert [db-au-workspace]..Dim_CCATeams_Codes on

        insert into [db-au-workspace]..Dim_CCATeams_Codes
        (
            [CCATeams_Codes_SK],
            [CCATeams_Code],
            [CCATeams_Desc],
            [CCATeams_Owner_Code],
            [CCATeams_Owner_Desc],
            [Parent_CCATeams_Code],
            [Parent_CCATeams_Code_Desc],
            [Create_Date],
            [Update_Date],
            [Insert_Batch_ID],
            [Update_Batch_ID]
        )
        select
            -1 [CCATeams_SK],
            'UNKNOWN' [CCATeams_Code],
            'UNKNOWN' [CCATeams_Desc],
            'UNKNOWN' [CCATeams_Owner_Code],
            'UNKNOWN' [CCATeams_Owner_Desc],
            'UNKNOWN' [Parent_CCATeams_Code],
            'UNKNOWN' [Parent_CCATeams_Code_Desc],
            getdate() [Create_Date],
            getdate() [Update_Date],
            0 [Insert_Batch_ID],
            0 [Update_Batch_ID]

        set identity_insert [db-au-workspace]..Dim_CCATeams_Codes off

    end

    if object_id('tempdb..#Dim_CCATeams_Codes') is not null
        drop table #Dim_CCATeams_Codes

    select *
    into #Dim_CCATeams_Codes
    from
        [db-au-workspace]..Dim_CCATeams_Codes
    where
        1 = 0

    insert into #Dim_CCATeams_Codes
    (
        [CCATeams_Code],
        [CCATeams_Desc],
        [CCATeams_Owner_Code],
        [CCATeams_Owner_Desc],
        [Parent_CCATeams_Code],
        [Parent_CCATeams_Code_Desc],
        [Create_Date],
        [Insert_Batch_ID]
    )
    select 
        s.CCATeamsCode,
        s.CCATeamsDescription,
        s.CCATeamsOwnerCode,
        s.CCATeamsOwnerDescription,
        s.ParentCCATeamsCode,
        s.ParentCCATeamsDescription,
        getdate(),
        -1
    from
        [db-au-workspace]..glCCATeams s

    set @sourcecount = @@rowcount

    --begin transaction
    
    --begin try

        merge into [db-au-workspace]..Dim_CCATeams_Codes with(tablock) t
        using #Dim_CCATeams_Codes s on
            s.[CCATeams_Code] = t.[CCATeams_Code]

        when 
            matched and
            binary_checksum(t.[CCATeams_Desc],t.[CCATeams_Owner_Code],t.[CCATeams_Owner_Desc],t.[Parent_CCATeams_Code],t.[Parent_CCATeams_Code_Desc]) <>
            binary_checksum(s.[CCATeams_Desc],s.[CCATeams_Owner_Code],s.[CCATeams_Owner_Desc],s.[Parent_CCATeams_Code],s.[Parent_CCATeams_Code_Desc]) 
        then

            update
            set
                [CCATeams_Desc] = s.[CCATeams_Desc],
                [Parent_CCATeams_Code] = s.[Parent_CCATeams_Code],
                [Parent_CCATeams_Code_Desc] = s.[Parent_CCATeams_Code_Desc],
                [CCATeams_Owner_Code] = s.[CCATeams_Owner_Code],
                [CCATeams_Owner_Desc] = s.[CCATeams_Owner_Desc],
                Update_Date = getdate(),
                Update_Batch_ID = '1'--@batchid

        when not matched by target then
            insert
            (
                [CCATeams_Code],
                [CCATeams_Desc],
                [CCATeams_Owner_Code],
                [CCATeams_Owner_Desc],
                [Parent_CCATeams_Code],
                [Parent_CCATeams_Code_Desc],
                [Create_Date],
                [Insert_Batch_ID]
            )
            values
            (
                s.[CCATeams_Code],
                s.[CCATeams_Desc],
                s.[CCATeams_Owner_Code],
                s.[CCATeams_Owner_Desc],
                s.[Parent_CCATeams_Code],
                s.[Parent_CCATeams_Code_Desc],
                getdate(),
                '1'--@batchid
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

    --    exec syssp_genericerrorhandler
    --        @LogToTable = 1,
    --        @ErrorCode = '0',
    --        @BatchID = @batchid,
    --        @PackageID = @name,
    --        @LogStatus = 'Finished',
    --        @LogSourceCount = @sourcecount,
    --        @LogInsertCount = @insertcount,
    --        @LogUpdateCount = @updatecount

    --end try

    --begin catch

    --    if @@trancount > 0
    --        rollback transaction

    --    exec syssp_genericerrorhandler
    --        @SourceInfo = 'data refresh failed',
    --        @LogToTable = 1,
    --        @ErrorCode = '-100',
    --        @BatchID = @batchid,
    --        @PackageID = @name,
    --        @LogStatus = 'Error'

    --end catch

    --if @@trancount > 0
    --    commit transaction


end


GO
