USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0663]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0663]
    @Country varchar(2) = 'AU',
    @ReportingPeriod varchar(30),
    @StartDate datetime = null,
    @EndDate datetime = null

as
begin

    set nocount on

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0663
--  Author:         Leonardus Setyabudi
--  Date Created:   Unknown
--  Description:    This stored procedure returns Claim average turnaround details
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--		    @Country: Value is valid country(such as AU, NZ, UK, ID, SG, MY or CN)
--   
--  Change History: Unknown - LS - Created
--		    20160526 - SD - Addition of Assigned User and Company Name to differentiate India and AU claims team			
--
/****************************************************************************************************/


--uncomment to debug
/*
declare @ReportingPeriod varchar(30)
declare @StartDate datetime
declare @EndDate datetime
declare @Country varchar(2)
select @Country = 'AU', @ReportingPeriod = 'Current Fiscal Year', @StartDate = null, @EndDate = null
*/


    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
    if @ReportingPeriod <> '_User Defined'
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod

    else
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    if object_id('tempdb..#cy') is not null
        drop table #cy

	;with cte_raw as
    	(
        select 
            w.Reference,
            w.AssignedUser,
            Company.company,
            dw.ClaimNumber,
            w.WorkType,
            w.CreationDate CreationDate,
            datediff(day, w.CreationDate, TurnAroundDate) * 1.0 -
            (
                select
                    count(d.[Date])
                from
                    Calendar d
                where
                    d.[Date] >= w.CreationDate and
                    d.[Date] <  dateadd(day, 1, convert(date, TurnAroundDate)) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            ) TurnAroundTime

            --case
            --    when w.CompletionDate is null then 'Not actioned'
            --    when mw.MergeDate is null then 'Unable to merge'
            --    when dw.StatusName is not null then dw.StatusName
            --    else 'Active'
            --end WorkStatus,
            ----mw.MergeDate,
            --dwe.TurnAroundDate
            --,
            --dwe.StatusName
        from
            e5Work w
            outer apply
            (
                select top 1
                    mw.EventDate MergeDate,
                    substring(mw.Detail, 40, 36) MergeDestination
                from 
                    e5WorkEvent mw
                where
                    mw.Work_Id = w.Work_ID and
                    mw.Detail like '<a%'
            ) mw
            left join e5Work dw on
                dw.Original_Work_ID = mw.MergeDestination
            outer apply
            (
                select top 1 
                    dwe.EventDate TurnAroundDate,
                    dwe.StatusName
                from
                    e5WorkEvent dwe
                where
                    dwe.Work_Id = dw.Work_ID and
                    dwe.EventDate > mw.MergeDate and
                    dwe.EventUser <> 'e5 Launch Service' and
                    dwe.EventName = 'Changed Work Status' and
                    dwe.StatusName <> 'Active'
                order by
                    dwe.EventDate
            ) dwe
			outer apply
			(
				select top 1
					company
				from
					usrLDAP
				where
					DisplayName = w.AssignedUser
			) Company
        where
            w.WorkType = 'Correspondence' and
            --w.CreationDate >= '2015-07-01' and
            dwe.TurnAroundDate is not null

        union all

        select 
            w.Reference,
            w.AssignedUser,
            Company.company,
            w.ClaimNumber,
            w.WorkType,
            --w.StatusName WorkStatus,
            --we.TurnAroundDate
            isnull(FirstActiveDate, w.CreationDate) CreationDate,
            datediff(day, isnull(FirstActiveDate, w.CreationDate), TurnAroundDate) * 1.0 -
            (
                select
                    count(d.[Date])
                from
                    Calendar d
                where
                    d.[Date] >= isnull(FirstActiveDate, w.CreationDate) and
                    d.[Date] <  dateadd(day, 1, convert(date, TurnAroundDate)) and
                    (
                        d.isHoliday = 1 or
                        d.isWeekEnd = 1
                    )
            ) TurnAroundTime
        from
            e5Work w
            outer apply
            (
                --check for e5 Launch Service straight to Diarised (onlince claim bug)
                select top 1 
                    els.StatusName,
                    els.EventDate
                from
                    e5WorkEvent els
                where
                    els.Work_Id = w.Work_ID
                order by
                    els.EventDate
            ) els
            outer apply
            (
                --use first active if it's a botch online launch
                select top 1 
                    EventDate FirstActiveDate
                from
                    e5WorkEvent fa
                where
                    fa.Work_Id = w.Work_ID and
                    fa.EventName in ('Changed Work Status', 'Merged Work', 'Saved Work') and
                    fa.StatusName = 'Active' and
                    (
                        fa.EventUser <> 'e5 Launch Service' or
                        fa.EventDate >= dateadd(day, 1, convert(date, els.EventDate))
                    ) and
                    els.StatusName = 'Diarised'
                order by
                    fa.EventDate
            ) fa
            outer apply
            (
                select top 1 
                    we.EventDate TurnAroundDate
                from
                    e5WorkEvent we
                where
                    we.Work_Id = w.Work_ID and
                    we.EventDate > isnull(FirstActiveDate, w.CreationDate) and
                    we.EventUser <> 'e5 Launch Service' and
                    we.EventName = 'Changed Work Status' and
                    we.StatusName <> 'Active'
                order by
                    we.EventDate
            ) we
	outer apply
	(
		select top 1
			company
		from
			usrLDAP
		where
			DisplayName = w.AssignedUser
	) Company
        where
            (
                w.WorkType like '%claim%' or
                w.WorkType in ('Complaints')
            ) and
            w.WorkType not in ('Claims Audit', 'New Claim') and
            --w.CreationDate >= '2015-07-01' and
            we.TurnAroundDate is not null
    )
    select 
        WorkType,
	AssignedUser,
	company,
        convert(datetime, convert(date, CreationDate)) CreationDate, 
        sum(TurnAroundTime) CYTurnAroundTime,
        count(Reference) CYCaseCount,
        0 LYTurnAroundTime,
        0 LYCaseCount,
        @rptStartDate StartDate,
        @rptEndDate EndDate
    from
        cte_raw
    where
        CreationDate >= @rptStartDate and
        CreationDate <  dateadd(day, 1, @rptEndDate)
    group by
        WorkType,
        convert(date, CreationDate),
	AssignedUser,
	company

    union

    select 
        WorkType,
	AssignedUser,
	company,
        convert(datetime, convert(date, dateadd(year, 1, CreationDate))) CreationDate, 
        0 CYTurnAroundTime,
        0 CYCaseCount,
        sum(TurnAroundTime) LYTurnAroundTime,
        count(Reference) LYCaseCount,
        @rptStartDate StartDate,
        @rptEndDate EndDate
    from
        cte_raw
    where
        dateadd(year, 1, CreationDate) >= @rptStartDate and
        dateadd(year, 1, CreationDate) <  dateadd(day, 1, @rptEndDate)
    group by
        WorkType,
        convert(date, dateadd(year, 1, CreationDate)) ,
	AssignedUser,
	company    


end


GO
