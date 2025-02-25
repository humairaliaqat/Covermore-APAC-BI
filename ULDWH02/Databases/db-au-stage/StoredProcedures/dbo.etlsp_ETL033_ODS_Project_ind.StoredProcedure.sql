USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Project_ind]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL033_ODS_Project_ind]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180423
Prerequisite:   
Description:    load project table
Change History:
                20160509 - LL - created
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

    if object_id('[db-au-cmdwh]..glProjects_ind') is null
    begin

        create table [db-au-cmdwh]..glProjects_ind
        (
            BIRowID bigint identity(1,1) not null,
            ParentProjectCode varchar(50) not null,
            ParentProjectDescription nvarchar(255),
            ProjectCode varchar(50) not null,
            ProjectDescription nvarchar(255),
            ProjectOwnerCode varchar(50) not null,
            ProjectOwnerDescription nvarchar(255),
            CreateBatchID int,
            CreateDateTime datetime,
            UpdateBatchID int,
            UpdateDateTime datetime,
            DeleteDateTime datetime
        )

        create clustered index cidx_ind on [db-au-cmdwh]..glProjects_ind (BIRowID)
        create nonclustered index idx_ind on [db-au-cmdwh]..glProjects_ind (ProjectCode) include (ParentProjectCode,ParentProjectDescription,ProjectDescription,ProjectOwnerCode,ProjectOwnerDescription)
        create nonclustered index idx_parent_ind on [db-au-cmdwh]..glProjects_ind (ParentProjectCode) include (ProjectCode,ProjectDescription,ParentProjectDescription)

    end

    if object_id('tempdb..#glProjects_ind') is not null
        drop table #glProjects_ind

    select *
    into #glProjects_ind
    from
        [db-au-cmdwh]..glProjects_ind
    where
        1 = 0

    insert into #glProjects_ind
    (
        ParentProjectCode,
        ParentProjectDescription,
        ProjectCode,
        ProjectDescription,
        ProjectOwnerCode,
        ProjectOwnerDescription
    )
    select 
        t.[Parent Project Code],
        t.[Parent Project Code Description],
        t.[Project Code],
        t.[Project Description],
        t.[Project Owner Code],
        t.[Project Owner Description]
    from
        [db-au-stage]..sungl_excel_project_ind t
    where
        isnull(ltrim(rtrim(t.[Project Code])), '') <> ''

    set @sourcecount = @@rowcount

    begin transaction
    
    begin try

        merge into [db-au-cmdwh]..glProjects_ind with(tablock) t
        using #glProjects_ind s on
            s.ProjectCode = t.ProjectCode

        when 
            matched and
            binary_checksum(t.ParentProjectCode,t.ParentProjectDescription,t.ProjectDescription,t.ProjectOwnerCode,t.ProjectOwnerDescription,t.DeleteDateTime) <>
            binary_checksum(s.ParentProjectCode,s.ParentProjectDescription,s.ProjectDescription,s.ProjectOwnerCode,s.ProjectOwnerDescription,s.DeleteDateTime) 
        then

            update
            set
                ParentProjectCode = s.ParentProjectCode,
                ParentProjectDescription = s.ParentProjectDescription,
                ProjectDescription = s.ProjectDescription,
                ProjectOwnerCode = s.ProjectOwnerCode,
                ProjectOwnerDescription = s.ProjectOwnerDescription,
                UpdateDateTime = getdate(),
                UpdateBatchID = @batchid,
                DeleteDateTime = null

        when not matched by target then
            insert
            (
                ParentProjectCode,
                ParentProjectDescription,
                ProjectCode,
                ProjectDescription,
                ProjectOwnerCode,
                ProjectOwnerDescription,
                CreateDateTime,
                CreateBatchID
            )
            values
            (
                s.ParentProjectCode,
                s.ParentProjectDescription,
                s.ProjectCode,
                s.ProjectDescription,
                s.ProjectOwnerCode,
                s.ProjectOwnerDescription,
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
