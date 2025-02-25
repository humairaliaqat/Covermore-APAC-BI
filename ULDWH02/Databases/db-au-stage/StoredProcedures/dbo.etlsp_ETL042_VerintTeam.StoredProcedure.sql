USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL042_VerintTeam]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL042_VerintTeam]
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20141218
Prerequisite:   Requires verActivityTimeline, verEmployee
Description:    
Parameters:     
Change History:
                20141218 - LS - created
                
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
        
    --declare @mergeoutput table (MergeAction varchar(20))

    --exec syssp_getrunningbatch
    --    @SubjectArea = 'VERINT ODS',
    --    @BatchID = @batchid out,
    --    @StartDate = @start out,
    --    @EndDate = @end out

    if object_id('[db-au-cmdwh]..verTeam') is null
    begin
        
        create table [db-au-cmdwh]..verTeam
        (
            BIRowID int not null identity(1,1),
            UserName nvarchar(50),
            EmployeeKey int,
            OrganisationKey int,
            StartDate date,
            EndDate date,
            CreateBatchID int,
            UpdateBatchID int
        )
        
        create clustered index idx_verTeam_BIRowID on [db-au-cmdwh]..verTeam (BIRowID)
        create nonclustered index idx_verTeam_UserName on [db-au-cmdwh]..verTeam (UserName,EndDate desc) include (EmployeeKey,OrganisationKey)
        create nonclustered index idx_verTeam_StartDate on [db-au-cmdwh]..verTeam (StartDate)
        
    end

    if object_id('tempdb..#activities') is not null
        drop table #activities

    select 
        row_number() over (order by t.EmployeeKey, t.ActivityDate) ID,
        t.EmployeeKey,
        t.UserName,
        t.ActivityDate,
        OrganisationKey
    into #activities
    from
        (
            select distinct
                e.EmployeeKey,
                e.UserName,
                convert(date, ActivityStartTime) ActivityDate
            --into #activities
            from
                [db-au-cmdwh]..verActivityTimeline a
                inner join [db-au-cmdwh]..verEmployee e on
                    e.EmployeeKey = a.EmployeeKey
            where
                e.UserName is not null 
        ) t
        cross apply
        (
            select top 1 
                r.OrganisationKey
            from
                [db-au-cmdwh]..verActivityTimeline r
            where
                r.ActivityStartTime >= t.ActivityDate and
                r.ActivityStartTime <  dateadd(day, 1, t.ActivityDate) and
                r.EmployeeKey = t.EmployeeKey
            order by
                r.ActivityStartTime desc
        ) o
    order by
        t.EmployeeKey,
        t.ActivityDate
        
    create nonclustered index idx on #activities (EmployeeKey, ActivityDate desc) include (OrganisationKey, ID)

    if object_id('tempdb..#ordered') is not null
        drop table #ordered
        
    select 
        EmployeeKey,
        UserName,
        OrganisationKey,
        ActivityDate
    into #ordered
    from
        (
            select 
                EmployeeKey,
                UserName,
                OrganisationKey,
                ActivityDate,
                case
                    when PO is null or OrganisationKey <> PO then 1
                    else 0
                end NewSection
            from
                #activities t
                outer apply
                (
                    select top 1
                        OrganisationKey PO
                    from
                       #activities r
                    where
                        r.EmployeeKey = t.EmployeeKey and
                        r.ActivityDate <= t.ActivityDate and
                        r.ID < t.ID
                    order by
                        r.ActivityDate desc
                ) r
        ) t
    where
        t.NewSection = 1
    order by
        EmployeeKey,
        ActivityDate

    if object_id('tempdb..#verTeam') is not null
        drop table #verTeam

    select 
        UserName,
        EmployeeKey,
        OrganisationKey,
        ActivityDate StartDate,
        isnull(EndDate, '2199-01-01') EndDate
    into #verTeam
    from
        #ordered t
        outer apply
        (
            select top 1
                dateadd(day, -1, r.ActivityDate) EndDate
            from
                #ordered r
            where
                r.EmployeeKey = t.EmployeeKey and
                r.ActivityDate > t.ActivityDate
            order by
                r.ActivityDate
        ) r
    order by
        UserName,
        EmployeeKey,
        ActivityDate

    
    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-cmdwh].dbo.verTeam with(tablock) t
        using #verTeam s on
            s.UserName = t.UserName and
            s.StartDate = t.StartDate

        when matched then

            update
            set
                OrganisationKey = s.OrganisationKey,
                EndDate = s.EndDate,
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                UserName,
                EmployeeKey,
                OrganisationKey,
                StartDate,
                EndDate,
                CreateBatchID
            )
            values
            (
                s.UserName,
                s.EmployeeKey,
                s.OrganisationKey,
                s.StartDate,
                s.EndDate,
                @batchid
            )

        --output $action into @mergeoutput
        ;

        --select
        --    @insertcount =
        --        sum(
        --            case
        --                when MergeAction = 'insert' then 1
        --                else 0
        --            end
        --        ),
        --    @updatecount =
        --        sum(
        --            case
        --                when MergeAction = 'update' then 1
        --                else 0
        --            end
        --        )
        --from
        --    @mergeoutput

        --exec syssp_genericerrorhandler
        --    @LogToTable = 1,
        --    @ErrorCode = '0',
        --    @BatchID = @batchid,
        --    @PackageID = @name,
        --    @LogStatus = 'Finished',
        --    @LogSourceCount = @sourcecount,
        --    @LogInsertCount = @insertcount,
        --    @LogUpdateCount = @updatecount

    end try

    begin catch

        if @@trancount > 0
            rollback transaction

        exec syssp_genericerrorhandler
            @SourceInfo = 'verTeam data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end



GO
