USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0790]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0790] 
@ReportingPeriod varchar(30),
@StartDate date,
@EndDate date
as 

Begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0790
--  Author:         Peter Zhuo
--  Date Created:   20160802
--  Description:    This stored procedure produces details of claims where action were taken in more than 10 working
--					days since the claim became active in e5.
--  Parameters:     @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
--                  
--  Change History: 
--                  20160802	-	PZ	-	Created
--
/****************************************************************************************************/

set nocount on

--Uncomment to debug
--Declare
--    @ReportingPeriod varchar(30),
--    @StartDate date,
--    @EndDate date
--Select 
--    @ReportingPeriod = 'Last May',
--    @StartDate = '2015-02-01',
--    @EndDate = '2015-02-04'


declare
    @rptStartDate datetime,
    @rptEndDate datetime

    if @ReportingPeriod = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod


select
	bb.ClaimNo,
	bb.[Claim Status],
	bb.CreateDate,
	bb.AssignedUser,
	bb.[Active Event DateTime],
	bb.[Subsequent Status],
	bb.[Subsequent Status DateTime],
	bb.[Days in Between],
	bb.[Non-Workings Days in Between],
	bb.[Workings Days in Between],
	bb.[Event User],
	bb.Detail,
	@ReportingPeriod as [ReportingPeriod],
	@rptStartDate as [StartDate],
	@rptEndDate as [EndDate]
from
	(--bb
	select
		aa.*,
		ROW_NUMBER() over(partition by aa.ClaimNo, aa.[Active Event DateONLY] order by [Active Event DateTime] asc) as [X]
	from
		(--aa
		select
			cl.ClaimNo,
			w.StatusName as [Claim Status],
			cl.CreateDate,
			w.AssignedUser,
			we.EventDate as [Active Event DateTime],
			cast(we.EventDate as date) as [Active Event DateONLY],
			ss.StatusName as [Subsequent Status],
			ss.EventDate as [Subsequent Status DateTime],
			ss.EventUser as [Event User],
			ss.Detail,
			--floor(cast(datediff(minute,we.EventDate, ss.EventDate) as money) / 1440) as [Days in Between],
			datediff(day,we.EventDate, ss.EventDate) as [Days in Between],
			nwd.[Non-Workings Days in Between],
			datediff(day,we.EventDate, ss.EventDate) - nwd.[Non-Workings Days in Between] as [Workings Days in Between]
		from 
			e5Work w
		inner join clmClaim cl on cl.ClaimKey = w.ClaimKey
		inner join e5WorkEvent we on we.Work_ID = w.Work_ID
		outer apply
			( -- ss
			select top 1
				a_we.EventDate,
				a_we.StatusName,
				a_we.EventUser,
				a_we.Detail
			from 
				e5Work a_w
			inner join e5WorkEvent a_we on a_we.Work_ID = a_w.Work_ID
			where
				a_w.WorkType = 'Claim'
				and ((a_we.EventName = 'Changed Work Status' and a_we.StatusName <> 'Active') or (we.EventName = 'Completed Task' and we.StatusName = 'Rejected'))
				and a_we.EventName = 'Changed Work Status'
				and a_w.ClaimKey = w.ClaimKey
				and a_we.EventDate > we.EventDate
			order by
				a_we.EventDate asc
			) as ss
		outer apply
			( -- nwd
			select
				count(c.[Date]) as [Non-Workings Days in Between]
			from Calendar c
			where
				--c.[Date] >= cast(we.EventDate as date) and
				--c.[Date] <  dateadd(day, 1, cast(ss.EventDate as date)) and
				c.[Date] >= we.EventDate and
				c.[Date] <  dateadd(day, 1, cast(ss.EventDate as date)) and
				(
					c.isHoliday = 1 or
					c.isWeekEnd = 1
				)
			) as nwd
		where
			w.Country = 'AU'
			and w.WorkType = 'Claim'
			and (we.EventName = 'Changed Work Status')
			and we.StatusName = 'active'
			--and ss.EventDate >= '2016-08-01' and ss.EventDate < '2016-09-01'
			and ss.EventDate >= @rptStartDate and ss.EventDate < dateadd(day,1,@rptEndDate)


			--and w.ClaimKey = 'au-978154'
		)as aa
	where
		aa.[Workings Days in Between] >= 10 -- A breach if no action has been taken in 10 days since a claim becomes active
	)as bb
where
	bb.[X] = 1

end
GO
