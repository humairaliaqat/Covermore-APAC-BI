USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cbPlan]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cbPlan]
as
begin
/*
20140715, LS,   TFS12109
                use transaction (as carebase has intra-day refreshes)
*/

    set nocount on

    exec etlsp_StagingIndex_Carebase

    if object_id('[db-au-cmdwh].dbo.cbPlan') is null
    begin

        create table [db-au-cmdwh].dbo.cbPlan
        (
            [BIRowID] bigint not null identity(1,1),
            [CountryKey] nvarchar(2) not null,
            [CaseKey] nvarchar(20) not null,
            [PlanKey] nvarchar(20) not null,
            [OriginalPlanKey] nvarchar(20) null,
            [CaseNo] nvarchar(15) not null,
            [PlanID] int not null,
            [PlanVersion] int null,
            [OriginalPlanID] nvarchar(20) null,
            [OpenedByID] nvarchar(30) null,
            [OpenedBy] nvarchar(55) null,
            [CompletedByID] nvarchar(30) null,
            [CompletedBy] nvarchar(55) null,
            [ActionLevel] nvarchar(30) null,
            [CancelledByID] nvarchar(30) null,
            [CancelledBy] nvarchar(55) null,
            [AllocatedToID] nvarchar(30) null,
            [AllocatedTo] nvarchar(55) null,
            [CreateDate] datetime null,
            [CreateTimeUTC] datetime null,
            [TodoDate] datetime null,
            [TodoTime] datetime null,
            [TodoTimeUTC] datetime null,
            [AllocatedDate] datetime null,
            [AllocatedTimeUTC] datetime null,
            [CompletionDate] datetime null,
            [CompletionTime] datetime null,
            [CompletionTimeUTC] datetime null,
            [PlanDetail] nvarchar(255) null,
            [AdditionalDetail] nvarchar(255) null,
            [IsPriority] bit null,
            [RescheduleReason] nvarchar(120) null,
            [IsRescheduled] bit null,
            [IsCompleted] bit null,
            [IsCancelled] bit null
        )

        create clustered index idx_cbPlan_BIRowID on [db-au-cmdwh].dbo.cbPlan(BIRowID)
        create nonclustered index idx_cbPlan_CaseKey on [db-au-cmdwh].dbo.cbPlan(CaseKey)
        create nonclustered index idx_cbPlan_CaseNo on [db-au-cmdwh].dbo.cbPlan(CaseNo,CompletionDate) include (CompletedBy,AllocatedTo,TodoDate,TodoTime,PlanDetail)
        create nonclustered index idx_cbPlan_CompletedBy on [db-au-cmdwh].dbo.cbPlan(CompletedBy,CompletionDate)
        create nonclustered index idx_cbPlan_CompletionDate on [db-au-cmdwh].dbo.cbPlan(CompletionDate,CompletedBy)
        create nonclustered index idx_cbPlan_CreateDate on [db-au-cmdwh].dbo.cbPlan(CreateDate,OpenedBy)
        create nonclustered index idx_cbPlan_OpenedBy on [db-au-cmdwh].dbo.cbPlan(OpenedBy,CreateDate)
        create nonclustered index idx_cbPlan_OriginalPlanID on [db-au-cmdwh].dbo.cbPlan(OriginalPlanID,CountryKey)
        create nonclustered index idx_cbPlan_PlanID on [db-au-cmdwh].dbo.cbPlan(PlanID)
        create nonclustered index idx_cbPlan_TodoDate on [db-au-cmdwh].dbo.cbPlan(TodoDate,CountryKey)

    end

    if object_id('tempdb..#cbPlan') is not null
        drop table #cbPlan

    select
        'AU' CountryKey,
        left('AU-' + CASE_NO, 20) CaseKey,
        left('AU-' + convert(varchar, ROWID), 20) PlanKey,
        left('AU-' + convert(varchar, original_plan_rowid), 20) OriginalPlanKey,
        CASE_NO CaseNo,
        rowid PlanID,
        row_version PlanVersion,
        original_plan_rowid OriginalPlanID,
        OPEN_AC OpenedByID,
        OpenedBy,
        comp_ac CompletedByID,
        CompletedBy,
        case
            when action_ac = 'ALL' then 'ALL'
            else ActionLevel
        end ActionLevel,
        cancel_ac CancelledByID,
        CancelledBy,
        allocated_ac AllocatedToID,
        AllocatedTo,
        dbo.xfn_ConvertUTCtoLocal(CREATED_DT, 'AUS Eastern Standard Time') CreateDate,
        CREATED_DT CreateTimeUTC,
        convert(date, dbo.xfn_ConvertUTCtoLocal(TODO_DATE, 'AUS Eastern Standard Time')) TodoDate,
        dbo.xfn_ConvertUTCtoLocal(TODO_DATE, 'AUS Eastern Standard Time') TodoTime,
        TODO_DATE TodoTimeUTC,
        dbo.xfn_ConvertUTCtoLocal(allocated_time, 'AUS Eastern Standard Time') AllocatedDate,
        allocated_time AllocatedTimeUTC,
        convert(date, dbo.xfn_ConvertUTCtoLocal(COMP_DATE, 'AUS Eastern Standard Time')) CompletionDate,
        dbo.xfn_ConvertUTCtoLocal(COMP_DATE, 'AUS Eastern Standard Time') CompletionTime,
        COMP_DATE CompletionTimeUTC,
        [Plan] PlanDetail,
        plan1 AdditionalDetail,
        case
            when PRIORITY <> 'N' then 1
            else 0
        end IsPriority,
        RescheduleReason,
        case
            when RescheduleReason is not null then 1
            else 0
        end IsRescheduled,
        case
            when comp_ac is not null then 1
            else 0
        end IsCompleted,
        case
            when cancel_ac is not null then 1
            else 0
        end IsCancelled
    into #cbPlan
    from
        carebase_CPL_PLAN_aucm pl
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME OpenedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = pl.OPEN_AC
        ) ob
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME CompletedBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = pl.comp_ac
        ) cb
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME CancelledBy
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = pl.cancel_ac
        ) cxb
        outer apply
        (
            select top 1
                PREF_NAME + ' ' + SURNAME AllocatedTo
            from
                carebase_ADM_USER_aucm u
            where
                u.USERID = pl.allocated_ac
        ) ab
        outer apply
        (
            select top 1
                at.AC_DESCRIPTION ActionLevel
            from
                carebase_UAC_ACTYPE_aucm at
            where
                at.AC_CODE = rtrim(ltrim(pl.action_ac))
        ) acb
        outer apply
        (
            select top 1
                prr.PLANRESCHREASON RescheduleReason
            from
                carebase_PLAN_RESCHEDULE_REASONS_aucm prr
            where
                prr.PRR_ID = pl.RESCHEDULEREASONID
        ) rr


    begin transaction cbPlan

    begin try

        delete
        from [db-au-cmdwh].dbo.cbPlan
        where
            PlanKey in
            (
                select
                    left('AU-' + convert(varchar, ROWID), 20) collate database_default
                from
                    carebase_CPL_PLAN_aucm
            )

        insert into [db-au-cmdwh].dbo.cbPlan with(tablock)
        (
            CountryKey,
            CaseKey,
            PlanKey,
            OriginalPlanKey,
            CaseNo,
            PlanID,
            PlanVersion,
            OriginalPlanID,
            OpenedByID,
            OpenedBy,
            CompletedByID,
            CompletedBy,
            ActionLevel,
            CancelledByID,
            CancelledBy,
            AllocatedToID,
            AllocatedTo,
            CreateDate,
            CreateTimeUTC,
            TodoDate,
            TodoTime,
            TodoTimeUTC,
            AllocatedDate,
            AllocatedTimeUTC,
            CompletionDate,
            CompletionTime,
            CompletionTimeUTC,
            PlanDetail,
            AdditionalDetail,
            IsPriority,
            RescheduleReason,
            IsRescheduled,
            IsCompleted,
            IsCancelled
        )
        select
            CountryKey,
            CaseKey,
            PlanKey,
            OriginalPlanKey,
            CaseNo,
            PlanID,
            PlanVersion,
            OriginalPlanID,
            OpenedByID,
            OpenedBy,
            CompletedByID,
            CompletedBy,
            ActionLevel,
            CancelledByID,
            CancelledBy,
            AllocatedToID,
            AllocatedTo,
            CreateDate,
            CreateTimeUTC,
            TodoDate,
            TodoTime,
            TodoTimeUTC,
            AllocatedDate,
            AllocatedTimeUTC,
            CompletionDate,
            CompletionTime,
            CompletionTimeUTC,
            PlanDetail,
            AdditionalDetail,
            IsPriority,
            RescheduleReason,
            IsRescheduled,
            IsCompleted,
            IsCancelled
        from
            #cbPlan

    end try

    begin catch

        if @@trancount > 0
            rollback transaction cbPlan

        exec syssp_genericerrorhandler 'cbPlan data refresh failed'

    end catch

    if @@trancount > 0
        commit transaction cbPlan

end

GO
