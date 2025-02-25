USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0816]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0816]	@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0816
--  Author:         Saurabh Date
--  Date Created:   20160911
--  Description:    Returns claim work and work event details where were re-activated and previos work event status = Diarised
--					
--  Parameters:     
--                  @DateRange: required. valid date range or _User Defined
--                  @StartDate: optional. required if date range = _User Defined
--                  @EndDate: optional. required if date range = _User Defined
--                  
--  Change History: 
--                  20160911 - SD - Created
--					20160912 - SD - Added Region, E5 User and Work Status. Removed Event ID, Event Name, Event Status, Event Detail, Previous Status.
--								  -	Also removed BusinessName filter and added filter to show only Active Claims
--					20190311 - SD - Change it to show data based on actication date, instead of creation date
--                  
/****************************************************************************************************/


--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate datetime
declare @EndDate datetime
select @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/


/* get reporting dates */
if @DateRange <> '_User Defined'
    select 
        @StartDate = StartDate, 
        @EndDate = EndDate
    from 
        vDateRange
    where 
        DateRange = @DateRange


select
	w.ClaimNumber,
	w.Country [Region],
	w.Reference,
	w.WorkType,
	dr.EventUser,
	dr.[Diarised Reason],
	w.StatusName as WorkStatus,
	Max(we.EventDate) [EventDate],
	we.EventUserID,
	@StartDate [Date Range Start Date],
	@EndDate [Date Range End Date]
from
	e5Work w
    inner join e5WorkEvent we on w.Work_ID = we.Work_ID
    cross apply										--match work events where previous status is Diarised
    (
        select top 1
            r.StatusName as PreviousStatus
        from
            e5WorkEvent r
        where
            r.Work_Id = we.Work_ID and
            r.EventDate < we.EventDate and
            r.StatusName = 'Diarised'
        order by
            r.EventDate desc
    ) r
	Outer Apply
	(
		Select top 1
			d.EventUser,
			Case 
				When d.EventName = 'Merged Work' Then 'Re-activated via a merge '
				when d.Detail like 'Diarised%' Then SubString(d.Detail,12,LEN(d.Detail))
				Else d.Detail
			End [Diarised Reason]
		From
			e5WorkEvent d
		Where
			d.Work_ID = we.Work_ID and
			d.StatusName = 'Diarised' and 
			d.EventName in ('Changed Work Status', 'Merged Work')
		Order by
			d.EventDate Desc
	) dr
where
	w.WorkType = 'Claim' and
	w.StatusName <> 'Rejected' and
	we.EventName = 'Changed Work Status' and
	we.EventUserID = 'ActivationEventProvider' and
	we.Detail = 'Activated' and
	we.EventDate >= @StartDate and
	we.EventDate < dateadd(day,1,@EndDate) and
	w.StatusName = 'Active'
Group BY
	w.ClaimNumber,
	w.Country,
	w.Reference,
	w.WorkType,
	dr.EventUser,
	dr.[Diarised Reason],
	w.StatusName,
	we.EventUserID
GO
