USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0779b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0779b]
	@country nvarchar(5),
    @ReportingPeriod varchar(30),
    @StartDate date,
    @EndDate date
as

begin

    set nocount on

    /****************************************************************************************************/
    --  Name:           dbo.rptsp_rpt0779b
    --  Author:         Peter Zhuo
    --  Date Created:   20160524
    --  Description:    This stored procedure shows claims which were active or diarised at the end of the chosen period
    --  Parameters:     @Country: claim country
    --                  @ReportingPeriod (@StartDate, @EndDate): Standard BI reporting period
    --                  
    --  Change History: 
    --                  20160524	-	PZ	-	Created
    --
    /****************************************************************************************************/


    --Uncomment to debug
    --declare
    --	@country nvarchar(5),
    --    @ReportingPeriod varchar(30),
    --    @StartDate date,
    --    @EndDate date
    --    --@i int
    --select
    --	@Country = 'AU',
    --    @ReportingPeriod = '_User Defined',
    --    @StartDate = '2016-05-01',
    --    @EndDate = '2016-05-15'



    declare
        @rptStartDate datetime,
        @rptEndDate datetime

    --get reporting dates
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
    ----------------------------------------------------------


    select
	    aa.ClaimNumber as [Claim Number],
	    aa.[Last Status In The Chosen Period],
	    aa.[Date The Claim Moved Into This Status],
	    w.StatusName as [Current Status],
		@ReportingPeriod as [Reporting Period],
		@rptStartDate as [Start Date],
		@rptEndDate as [End Date]
    from
    (--aa
    select
	    w.Work_ID,
	    w.ClaimNumber,
	    we.StatusName as [Last Status In The Chosen Period],
	    we.EventDate [Date The Claim Moved Into This Status],
	    ROW_NUMBER() over(partition by w.ClaimNumber order by we.EventDate desc) as [X]
    from e5WorkEvent we
    inner join e5work w on we.Work_ID = w.Work_ID
    where
	    w.Country = @country
	    and w.WorkType like '%claim%'
	    and 
		    (
		    we.EventName = 'Changed Work Status' 
		    or
		    (
			    we.EventName = 'Saved Work' and
			    we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
		    )
            ) 
	    and (we.EventDate <= @rptEndDate)
    )as aa
    inner join e5work w on aa.Work_ID = w.Work_ID
    where
	    [X] = 1
	    and aa.[Last Status In The Chosen Period] in ('Active','Diarised')



end
GO
