USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0114]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0114]
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @WorkStatus varchar(10) = 'All'

as

begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0114
--  Author:         Linus Tor
--  Date Created:   20100901
--  Description:    This stored procedure selects work events based on the specified criteria and
--                  work event create date range. It then performs SLA Response Date, Actual Response
--                  Date, Turnaround Time, and SLA test calculations.
--  Parameters:     @ReportingPeriod: Value is any valid date range in ulsql02.e5_content.dbo.vDateRange
--                  @StartDate: Enter if @ReportingPeriod = 'User Defined'. Format YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = 'User Defined'. Format YYYY-MM-DD eg. 2010-01-01
--                  
--  Change History: 20100901 - LT - Created
--                  20110309 - LT - Added AssignedUser and TotalEstimateValue fields to the final result data, as
--                  per request by RyanK
--                  20110407 - LT - Added 2 result conditions: 
--                  IF Turnaround time <= 10 AND SLAResponseDate >= ActualResponseDate then PASS
--                  IF Turnaround time <= 10 AND SLAResponseDate < ActualResponseDate then FAILED
--                  20110607 - LT - Add exclusion work type, External Policy Holders
--                  20111219 - LS - remove extra holiday count from sla formula, it's already catered by addbusinessday                          
--                  20120412 - LS - add NextActivity (Case 17223)
--					20121003 - LT - added isOnlineClaim column (Case 17907)
--					20121113 - LS - rewrite, reduce run time from ~16 minutes to < 3 minutes
--                                  remove cursor
--                                  use event id trick to optimize index usage on ulsql2
--                  20121114 - LS - catch deadlock error and keep trying
--                                  use nolock to avoid deadlock
--                  20121128 - LS - regression bug fix, case 18034, Actual Response Date should be the first date
--                  20140403 - LS - case 20610, add work status & filter
--                  20140512 - LS - case 20610, regression bug fix, include null total estimate in Diarised
--                  
/****************************************************************************************************/
  
--uncomment to debug
--declare 
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10),
--    @WorkStatus varchar(10)
--select 
--    @ReportingPeriod = 'Last Month To Now',
--    @StartDate = null,
--    @EndDate = null,
--    @WorkStatus = 'All'

    set nocount on

    declare
        @rptStartDate datetime,
        @rptEndDate datetime,
        @eventstart int,
        @eventend int,
        @sql varchar(max),
        @deadlocked int
    
    /* get reporting dates */
    if @ReportingPeriod = 'User Defined'
        select 
            @rptStartDate = convert(date, @StartDate), 
            @rptEndDate = convert(date, @EndDate)

    else if @ReportingPeriod = 'Last Month To Yesterday'
    begin 

        select 
            @rptStartDate = StartDate 
        from 
            vDateRange 
        where 
            DateRange = 'Last Month'
        
        select 
            @rptEndDate = EndDate 
        from 
            vDateRange 
        where 
            DateRange = 'Yesterday'

    end

    else if @ReportingPeriod = 'Last Month To Now'
    begin
    
        select 
            @rptStartDate = StartDate,
            @rptEndDate = convert(date, getdate())
        from 
            vDateRange 
        where 
            DateRange = 'Last Month'

    end  

    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    /* cleanup temp tables */
    if object_id('tempdb..#users') is not null
        drop table #users

    if object_id('tempdb..#result') is not null
        drop table #result

    /* user names */
    select 
        [nvarchar1] collate database_default UserName,
        [nvarchar3] collate database_default UserID
    into #users
    from 
        ulsql02.wss_content_bpm.dbo.AllUserData with (nolock)
        
    create clustered index idx_userid on #users(UserID)

    create table #result
    (
        WorkID varchar(512),
        WorkStatus varchar(100),
        Reference int,
        ClaimNumber varchar(10),
        WorkType varchar(100),
        GroupType varchar(100),
        EventID bigint,
        EventName varchar(50),
        EventDate datetime,
        ReceivedDate datetime,
        EventUser varchar(100),
        EventStatus varchar(100),
        AssignedUser varchar(100),
        TotalEstimateValue money,
        Detail varchar(200),
        IsOnlineClaim bit,
        NextActivity varchar(100)
    )

    /* event id range */
    select top 1 
        @eventstart = Id
    from
        e5WorkEvent
    where
        EventDate < @rptStartDate and
        EventDate >= dateadd(day, -7, @rptStartDate)
    order by 
        Id desc

    select top 1 
        @eventend = Id
    from
        e5WorkEvent with(index(idx_e5WorkEvent_EventDate))
    where
        EventDate >= dateadd(day, 1, @rptEndDate)
    order by 
        Id
        
    set @sql =
        '
        select *
        from
            openquery(
                ULSQL02,
                ''
                select
                    we.Work_Id WorkID,
                    WorkStatus,
                    w.Reference,
                    wcp.ClaimNumber,
                    wt.WorkType,
                    gt.GroupType,
                    we.Id EventID,
                    en.EventName,
                    we.EventDate,
                    convert(
                        datetime,
                        convert(
                            varchar(10),
                            case 
                                when en.EventName = ''''Merged Work'''' then ow.OriginatorDate
                                when we.Detail = ''''Launched'''' then w.CreationDate
                                else we.EventDate
                            end,
                            120
                        )
                    ) ReceivedDate,
                    we.EventUser,
                    es.EventStatus,
                    w.AssignedUser,
                    wcp.TotalEstimateValue,
                    we.Detail,
                    wcp.IsOnlineClaim,
                    NextActivity
                from
                    e5_Content.dbo.WorkEvent we with(nolock, index(UQ__WorkEven__3214EC0675C27486))
                    inner join e5_Content.dbo.Work w with (nolock) on
                        w.Id = we.Work_Id
                    cross apply
                    (
                        select top 1 
                            s.Name WorkStatus
                        from
                            e5_content.dbo.Status s
                        where
                            s.ID = w.Status_ID
                    ) ws
                    cross apply
                    (
                        select top 1 
                            wcp.ClaimNumber,
                            convert(money, wcp.TotalEstimateValue) TotalEstimateValue,
                            isnull(wcp.OnlineClaim, 0) IsOnlineClaim
                        from
                            e5_content.dbo.WorkCustomProperty wcp with (nolock)
                        where 
                            w.Id = wcp.Work_Id
                    ) wcp
                    cross apply
                    (
                        select top 1
                            wt.Name WorkType
                        from
                            e5_content.dbo.Category2 wt with (nolock)
                        where
                            wt.Id = w.Category2_Id
                    ) wt
                    cross apply
                    (
                        select top 1
                            gt.Name GroupType
                        from
                            e5_content.dbo.Category3 gt with (nolock)
                        where
                            gt.Id = w.Category3_Id
                    ) gt
                    cross apply
                    (
                        select top 1 
                            Name EventName
                        from
                            e5_content.dbo.Event e with (nolock)
                        where
                            we.Event_Id = e.Id
                    ) en
                    cross apply
                    (
                        select top 1 
                            Name EventStatus
                        from
                            e5_content.dbo.Status s with (nolock)
                        where
                            we.Status_Id = s.Id
                    ) es
                    cross apply
                    (
                        select
                            case
                                when en.EventName = ''''Merged Work'''' then substring(we.Detail, 40, 36) 
                                else null
                            end OriginID
                    ) rw
                    outer apply
                    (
                        select top 1
                            CreationDate OriginatorDate
                        from
                            e5_content.dbo.Work ow with (nolock)
                        where
                            ow.Id = OriginID
                    ) ow
                    outer apply
                    (
                        select top 1 
                            ca.Name NextActivity
                        from 
                            e5_content.dbo.WorkActivity wa with(nolock, index(PK_WorkActivity_1))
                            inner join ulsql02.e5_content.dbo.CategoryActivity ca with (nolock) on 
                                ca.Id = wa.CategoryActivity_Id
                        where 
                            wa.work_id = w.Id
                        order by 
                            wa.SortOrder desc
                    ) na
                where
                    we.Id > ' + convert(varchar, @eventstart) + ' and ' +
                    isnull('
                    we.Id <= ' + convert(varchar, @eventend) + ' and ', 
                        ''
                    ) + '
                    (
                        (
                            we.Event_Id = 100 and                       --change work status to
                            we.Status_Id in (2, 4)                      --Diarised or Complete
                        ) or
                        we.Event_Id = 800 or                            --merge work
                        (                                               --just launched
                            we.Event_Id = 100 and
                            we.Status_Id = 1 and
                            we.Detail = ''''Launched''''
                        )
                    ) and
                    we.EventDate >= ''''' + convert(varchar(10), @rptStartDate, 120) + ''''' and
                    we.EventDate <  ''''' + convert(varchar(10), dateadd(day, 1, @rptEndDate), 120) + ''''' and
                    w.Status_Id <> 5 and                                --rejected
                    w.Category2_Id not in (1, 2, 5, 11, 12)             --enrolment forms, claims / unclassified, Correspondence, Complaints, External Policy Holders
                ''
            )
        '
    
    set @deadlocked = 1205
    
    while @deadlocked = 1205
    begin
    
        begin try
        
            --print @sql
            insert into #result
            exec(@sql)
        
            set @deadlocked = 0
            
        end try
        
        begin catch
        
            set @deadlocked = error_number()

            insert into #result (Reference)
            select 
                error_number()
                
        end catch
        
    end
    
    create clustered index idx_id on #result(WorkID)
    create index idx_name on #result(EventName, EventStatus, WorkID, ReceivedDate)
        
    select 
        Reference,
        ClaimNumber,
        IsOnlineClaim,
        WorkType,
        GroupType,
        EventName,
        Detail,
        ReceivedDate,
        isNull(eu.EventUser, '<Unassigned>') EventUser,
        EventStatus,
        isNull(au.AssignedUser, '<Unassigned>') AssignedUser,
        TotalEstimateValue,
        SLAResponseDate,
        ActualResponseDate,
        sla.TurnAroundTime,
        sla.SLAResult, 
        sla.TurnAroundCategory,
        NextActivity,
        @rptStartDate StartDate,
        @rptEndDate EndDate,
        WorkStatus
    from
        #result e
        outer apply
        (
            select top 1 
                UserName EventUser
            from
                #users u
            where
                u.UserID = e.EventUser
        ) eu
        outer apply
        (
            select top 1 
                UserName AssignedUser
            from
                #users u
            where
                u.UserID = e.AssignedUser
        ) au
        outer apply
        (
            select top 1
                r.ReceivedDate ActualResponseDate
            from
                #result r
            where
                r.WorkID = e.WorkID and
                r.EventName = 'Changed Work Status' and
                r.EventStatus in ('Diarised', 'Complete') and
                r.EventDate >= e.EventDate
            order by 
                r.ReceivedDate
        ) r
        cross apply
        (
            --if ReceivedDate falls on Sunday, Saturday, or Holiday, move to the next work day
            select top 1
                [Date] TrueReceiptDate
            from 
                Calendar 
            where 
                [Date] >= e.ReceivedDate and 
                isHoliday <> 1 and 
                isWeekDay = 1
            order by
                [Date]
        ) tr
        cross apply
        (
            --if ResponseDate falls on Sunday, Saturday or Holiday, move to the next work day
            select top 1
                [Date] SLAResponseDate
            from 
                Calendar 
            where 
                [Date] >= dbo.fn_AddWorkDays(TrueReceiptDate, 10) and 
                isHoliday <> 1 and 
                isWeekDay = 1
            order by
                [Date]
        ) rd
        cross apply
        (
            select
                datediff(d, TrueReceiptDate, ActualResponseDate) - 
                (
                    select 
                        count(distinct [Date]) 
                    from 
                        Calendar 
                    where 
                        [Date] between TrueReceiptDate and ActualResponseDate and
                        (
                            isHoliday = 1 or 
                            isWeekend = 1
                        )
                ) TurnAroundTime
        ) ta
        cross apply
        (
            select
                case 
                    when ActualResponseDate = ReceivedDate and TurnAroundTime is null then 0
                    else TurnAroundTime
                end TurnAroundTime,
                case 
                    when TurnAroundTime <= 10 and SLAResponseDate >= ActualResponseDate then 'PASS'
                    when TurnAroundTime <= 10 and SLAResponseDate < ActualResponseDate then 'FAILED'
                    when TurnAroundTime <= 10 then 'PASS'
                    when TurnAroundTime > 10 then 'FAILED'
                    when ActualResponseDate is null and SLAResponseDate < convert(date, getdate()) then 'FAILED'
                    else 'PENDING'
                end SLAResult, 
                case  
                    when TurnAroundTime <= 10  then '<= 10 days'
                    when TurnAroundTime = 11 then '11'
                    when TurnAroundTime = 12 then '12'
                    when TurnAroundTime = 13 then '13'
                    when TurnAroundTime = 14 then '14'
                    when TurnAroundTime = 15 then '15'
                    when TurnAroundTime between 16 and 20 then '6-10 Overdue'
                    when TurnAroundTime between 21 and 30 then '11-20 Overdue'
                    when TurnAroundTime between 31 and 50 then '21-40 Overdue'
                    when TurnAroundTime > 50 then '> 40 Overdue'
                    when TurnAroundTime is null then 'Not Responded' 
                end TurnAroundCategory
        ) sla
    where
        not
        (
            EventName = 'Changed Work Status' and
            EventStatus in ('Diarised', 'Complete')
        ) and
        (
            isnull(@WorkStatus, 'All') = 'All' or
            (
                @WorkStatus = 'Active' and
                WorkStatus <> 'Diarised'
            ) or
            (
                @WorkStatus = 'Diarised' and
                WorkStatus = 'Diarised' and
                isnull(TotalEstimateValue, 0) = 0
            )
        )
    order by
        Reference,
        ClaimNumber,
        EventID,
        EventDate

end
GO
