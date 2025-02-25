USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL049_dimClaim]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[etlsp_ETL049_dimClaim]
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null

as
begin

--20150722, LS, put in stored procedure
--20150821, LS, build a bridge

--uncomment to debug
--declare @DateRange varchar(30)
--declare @StartDate date
--declare @EndDate date
--select @DateRange = 'Last 30 Days'

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
    
    --set 
    --    @name = object_name(@@procid)

    set @name = 'etlsp_ETL049_dimClaim'

    /* get dates */
    select
        @start = @StartDate,
        @end = @EndDate

    if @DateRange <> '_User Defined'
        select
            @start = StartDate,
            @end = EndDate
        from
            [db-au-cmdwh].dbo.vDateRange
        where
            DateRange = @DateRange

    /* check if this is running on a batch or standalone */
    begin try

    
        exec syssp_getrunningbatch
            @SubjectArea = 'Claim STAR',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out
        
        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Running'
            
    end try
    
    begin catch
    
        set @batchid = -1
    
    end catch

    if object_id('[db-au-star].dbo.dimClaim') is null
    begin

        create table [db-au-star].dbo.dimClaim
        (
            [ClaimSK] bigint not null identity(1,1),
            [ClaimKey] varchar(40) not null,
            [PolicyTransactionKey] varchar(41) null,
            [ClaimNo] int not null,
            [DevelopmentDay] bigint not null,
            [ReceiptDate] date,
            [RegisterDate] date,
            [EventDate] date,
            [FirstNilDate] date,
            [LastNilDate] date,
            [FirstPaymentDate] date,
            [LastPaymentDate] date,
            [LodgementType] varchar(20) not null,
            [OnlineLodgementType] varchar(20) not null,
            [CustomerCareType] varchar(25) not null,
            [WorkType] nvarchar(100) not null,
            [WorkGroupType] nvarchar(100) not null,
            [WorkStatus] nvarchar(100) not null,
            [TimeInStatus] int not null,
            [AbsoluteAge] int not null,
            [Assignee] nvarchar(255) not null,
            [ReopenCount] int not null,
            [DiarisedCount] int not null,
            [ReassignCount] int not null,
            [DeclinedCount] int not null,
            [FirstNilLag] int not null,
            [FirstPaymentLag] int not null,
            [LastPaymentLag] int not null,
            [OtherClaimsOnPolicy] varchar(1) not null default ('N'),
            [CreateBatchID] int,
            [UpdateBatchID] int
        )

        create clustered index idx_dimClaim_ClaimSK on [db-au-star].dbo.dimClaim(ClaimSK)
        create nonclustered index idx_dimClaim_ClaimKey on [db-au-star].dbo.dimClaim(ClaimKey) include (ClaimSK,FirstNilDate,FirstPaymentDate,ReceiptDate)

        set identity_insert [db-au-star]..dimClaim on

        insert into dimClaim
        (
            ClaimSK,
            ClaimKey,
            ClaimNo,
            DevelopmentDay,
            ReceiptDate,
            RegisterDate,
            EventDate,
            FirstNilDate,
            LastNilDate,
            FirstPaymentDate,
            LastPaymentDate,
            LodgementType,
            OnlineLodgementType,
            CustomerCareType,
            WorkType,
            WorkGroupType,
            WorkStatus,
            TimeInStatus,
            AbsoluteAge,
            Assignee,
            ReopenCount,
            DiarisedCount,
            ReassignCount,
            DeclinedCount,
            FirstNilLag,
            FirstPaymentLag,
            LastPaymentLag,
            OtherClaimsOnPolicy,
            CreateBatchID
        )
        values
        (
            -1,
            'UNKNOWN',
            -1,
            -1,
            '3000-01-01',
            '3000-01-01',
            '3000-01-01',
            '3000-01-01',
            '3000-01-01',
            '3000-01-01',
            '3000-01-01',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            0,
            0,
            'UNKNOWN',
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            'N',
            -1
        )

        set identity_insert [db-au-star]..dimClaim off
    end

    --if object_id('[db-au-star].dbo.dimClaim_Bridge') is null
    --begin

    --    create table [db-au-star].dbo.dimClaim_Bridge
    --    (
    --        [BIRowID] bigint not null identity(1,1),
    --        [ClaimSK] bigint not null,
    --        [RefSK] varchar(max) not null,
    --        [Claim Date Reference] varchar(50) not null,
    --        [Payment Date Reference] varchar(50) not null,
    --        [PDR] varchar(10) not null,
    --        [ReferenceDate] date not null
    --    )

    --    create clustered index idx_dimClaim_BIRowID on [db-au-star].dbo.dimClaim_Bridge(BIRowID)
    --    create nonclustered index idx_dimClaim_ClaimSK on [db-au-star].dbo.dimClaim_Bridge(ClaimSK)
    --    create nonclustered index idx_dimClaim_References on [db-au-star].dbo.dimClaim_Bridge([Claim Reference Date], [Payment Date Reference]) include(ClaimSK, PDR, ReferenceDate)

    --end

    /*what has changed during the period*/
    exec etlsp_ETL049_helper_UpdatedClaim --Change here
        @StartDate = @start,
        @EndDate = @end
        
    if object_id('etl_UpdatedClaim') is null
        create table etl_UpdatedClaim (ClaimKey varchar(40))

    if object_id('tempdb..#dimClaim') is not null
        drop table #dimClaim

    select 
        cl.ClaimKey,
        cl.ClaimNo,
        case
            when datediff(day, convert(date, isnull(cl.PolicyIssuedDate, cl.CreateDate)), case when cl.ReceivedDate is null then cl.CreateDate when cl.ReceivedDate > cl.CreateDate then cl.CreateDate else cl.ReceivedDate end) < 0 then 0
            else datediff(day, convert(date, isnull(cl.PolicyIssuedDate, cl.CreateDate)), case when cl.ReceivedDate is null then cl.CreateDate when cl.ReceivedDate > cl.CreateDate then cl.CreateDate else cl.ReceivedDate end)
        end DevelopmentDay,
        --date convention
        --2000-01-01 -> Before 2001
        --3000-01-01 -> Unknown
        case
            when cld.ReceiptDate < '2001-01-01' then '2000-01-01'
            else cld.ReceiptDate
        end ReceiptDate,
        cl.CreateDate RegisterDate,
        case
            when ce.EventDate < '2001-01-01' then '2000-01-01'
            when ce.EventDate is null then cl.CreateDate
            when ce.EventDate < convert(date, cl.PolicyIssuedDate) then convert(date, cl.PolicyIssuedDate)
            when ce.EventDate > dateadd(day, 1, convert(date, cl.CreateDate)) then cl.CreateDate
            else ce.EventDate
        end EventDate,
        case
            when cl.FirstNilDate < '2001-01-01' then '2000-01-01'
            when cl.FirstNilDate is null then '3000-01-01'
            else cl.FirstNilDate
        end FirstNilDate,
        case
            when ci.LastNilDate < '2001-01-01' then '2000-01-01'
            when ci.LastNilDate is null then '3000-01-01'
            else ci.LastNilDate
        end LastNilDate,
        case
            when cpm.FirstPaymentDate < '2001-01-01' then '2000-01-01'
            when cpm.FirstPaymentDate is null then '3000-01-01'
            else cpm.FirstPaymentDate
        end FirstPaymentDate,
        case
            when cpm.LastPaymentDate < '2001-01-01' then '2000-01-01'
            when cpm.LastPaymentDate is null then '3000-01-01'
            else cpm.LastPaymentDate
        end LastPaymentDate,
        case
            when cl.OnlineClaim = 1 then 'Online Claim'
            else 'Paper Form'
        end LodgementType,
        case
            when cl.OnlineClaim = 1 and isnull(cl.OnlineAlpha, '') = '' then 'Customer'
            when cl.OnlineClaim = 1 and crm.CRMUser is not null then 'Internal Consultant'
            when cl.OnlineClaim = 1 and crm.CRMUser is null then 'External Consultant'
            else 'Offline'
        end OnlineLodgementType,
        case
            when isnull(cp.[Customer Care Case], 'N/A') = 'N/A' then 'Non-Customer Care Claim'
            else 'Customer Care Claim'
        end CustomerCareType,
        isnull(cp.[Work Type], 'Unknown') WorkType,
        isnull(cp.[Group Type], 'Unknown') WorkGroupType,
        isnull(cp.[Status], 'Unknown') WorkStatus,
        isnull(cp.[Time in current status], 0) TimeInStatus,
        isnull(cp.[Absolute Age], 0) AbsoluteAge,
        isnull(cp.[Assigned User], 'Unknown') Assignee,
        isnull(cp.[Reopen Count], 0) ReopenCount,
        isnull(cp.[Diarised Count], 0) DiarisedCount,
        isnull(cp.[ReAssignment Count], 0) ReassignCount,
        isnull(cp.[Declined Count], 0) DeclinedCount,
        isnull(datediff(d, cld.ReceiptDate, cl.FirstNilDate), -1) FirstNilLag,
        isnull(datediff(d, cld.ReceiptDate, cpm.FirstPaymentDate), -1) FirstPaymentLag,
        isnull(datediff(d, cld.ReceiptDate, cpm.LastPaymentDate), -1) LastPaymentLag,
        isnull(cp.[Check Existing Claims], 0) OtherClaimsOnPolicy
    into #dimClaim
    from
        [db-au-cmdwh]..clmClaim cl
        cross apply
        (
            select
                case
                    when cl.ReceivedDate is null then cl.CreateDate
                    when cl.ReceivedDate > dateadd(day, 1, convert(date, cl.CreateDate)) then cl.CreateDate
                    else cl.ReceivedDate
                end ReceiptDate
        ) cld
        outer apply
        (
            select top 1
                cp.[Assigned User],
                cp.[Status],
                cp.[Work Type],
                cp.[Group Type],
                cp.[Absolute Age],
                cp.[Time in current status],
                cp.[Customer Care Case],
                cp.[ReAssignment Count],
                cp.[Reopen Count],
                cp.[Diarised Count],
                cp.[Medical Review],
                cp.[Declined Count],
                cp.[Check Existing Claims]
            from
                [db-au-cmdwh]..vClaimPortfolio cp
            where
                cp.ClaimKey = cl.ClaimKey and
                --parent only
                (
                    cp.[Work Type] like '%claim%'
                )
            order by
                cp.[Assigned Date] desc
        ) cp
        outer apply
        (
            select top 1 
                cu.FirstName + ' ' + cu.LastName CRMUser
            from
                [db-au-cmdwh]..penCRMUser cu
            where
                cu.CountryKey = cl.CountryKey and
                cu.UserName = cl.OnlineConsultant
        ) crm
        outer apply
        (
            select 
                max(ci.IncurredDate) LastNilDate
            from
                [db-au-cmdwh]..[vclmClaimIncurred] ci
            where
                ci.ClaimKey = cl.ClaimKey and
                ci.Estimate = 0 and
                (
                    ci.PreviousEstimate <> 0 or
                    ci.IncurredAge <> 0 or
                    ci.Paid > 0
                )
        ) ci
        outer apply
        (
            select 
                min(cpm.PaymentDate) FirstPaymentDate,
                max(cpm.PaymentDate) LastPaymentDate
            from
                [db-au-cmdwh]..clmClaimPaymentMovement cpm
            where
                cpm.ClaimKey = cl.ClaimKey and
                cpm.PaymentStatus in ('APPR', 'PAID')
        ) cpm
        outer apply
        (
            select 
                min(ce.EventDate) EventDate
            from
                [db-au-cmdwh]..clmEvent ce
            where
                ce.ClaimKey = cl.ClaimKey
        ) ce
    where
        cl.ClaimKey in
        (
            select
                ClaimKey
            from
                etl_UpdatedClaim
        )


    set @sourcecount = @@rowcount

    begin transaction

    begin try

        merge into [db-au-star].dbo.dimClaim with(tablock) t
        using #dimClaim s on
            s.ClaimKey = t.ClaimKey

        when matched then

            update
            set
                ClaimNo = s.ClaimNo,
                DevelopmentDay = s.DevelopmentDay,
                ReceiptDate = s.ReceiptDate,
                RegisterDate = s.RegisterDate,
                EventDate = s.EventDate,
                FirstNilDate = s.FirstNilDate,
                LastNilDate = s.LastNilDate,
                FirstPaymentDate = s.FirstPaymentDate,
                LastPaymentDate = s.LastPaymentDate,
                LodgementType = s.LodgementType,
                OnlineLodgementType = s.OnlineLodgementType,
                CustomerCareType = s.CustomerCareType,
                WorkType = s.WorkType,
                WorkGroupType = s.WorkGroupType,
                WorkStatus = s.WorkStatus,
                TimeInStatus = s.TimeInStatus,
                AbsoluteAge = s.AbsoluteAge,
                Assignee = s.Assignee,
                ReopenCount = s.ReopenCount,
                DiarisedCount = s.DiarisedCount,
                ReassignCount = s.ReassignCount,
                DeclinedCount = s.DeclinedCount,
                FirstNilLag = s.FirstNilLag,
                FirstPaymentLag = s.FirstPaymentLag,
                LastPaymentLag = s.LastPaymentLag,
                OtherClaimsOnPolicy = s.OtherClaimsOnPolicy,
                UpdateBatchID = @batchid

        when not matched by target then
            insert
            (
                ClaimKey,
                ClaimNo,
                DevelopmentDay,
                ReceiptDate,
                RegisterDate,
                EventDate,
                FirstNilDate,
                LastNilDate,
                FirstPaymentDate,
                LastPaymentDate,
                LodgementType,
                OnlineLodgementType,
                CustomerCareType,
                WorkType,
                WorkGroupType,
                WorkStatus,
                TimeInStatus,
                AbsoluteAge,
                Assignee,
                ReopenCount,
                DiarisedCount,
                ReassignCount,
                DeclinedCount,
                FirstNilLag,
                FirstPaymentLag,
                LastPaymentLag,
                OtherClaimsOnPolicy,
                CreateBatchID
            )
            values
            (
                s.ClaimKey,
                s.ClaimNo,
                s.DevelopmentDay,
                s.ReceiptDate,
                s.RegisterDate,
                s.EventDate,
                s.FirstNilDate,
                s.LastNilDate,
                s.FirstPaymentDate,
                s.LastPaymentDate,
                s.LodgementType,
                s.OnlineLodgementType,
                s.CustomerCareType,
                s.WorkType,
                s.WorkGroupType,
                s.WorkStatus,
                s.TimeInStatus,
                s.AbsoluteAge,
                s.Assignee,
                s.ReopenCount,
                s.DiarisedCount,
                s.ReassignCount,
                s.DeclinedCount,
                s.FirstNilLag,
                s.FirstPaymentLag,
                s.LastPaymentLag,
                s.OtherClaimsOnPolicy,
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
            @SourceInfo = 'dimClaim data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

    end catch

    if @@trancount > 0
        commit transaction

end





GO
