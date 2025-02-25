USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0811]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0811]	@DateRange varchar(30),
									@StartDate datetime,
									@EndDate datetime
as
begin

    SET NOCOUNT ON


    /****************************************************************************************************/
    --  Name:           dbo.rptsp_rpt0811
    --  Author:         Saurabh Date
    --  Date Created:   20160922
    --  Description:    Returns Case and plan details for Insurance Specialist specific KPI's
    --					
    --  Parameters:     
    --                  @DateRange: required. valid date range or _User Defined
    --                  @StartDate: optional. required if date range = _User Defined
    --                  @EndDate: optional. required if date range = _User Defined
    --                  
    --  Change History: 
    --                  20160922 - SD - Created
    --					20161012 - SD - Changed GLA update and Denied category logic, also data will now be fetched on completion time
    --                  20170707 - ME - INC0039340, amended business rules
    --                  20170707 - ME - Used TodoTime column instead of TodoDate in Handover KPI definition

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


    select -- Categorizing plans for declines which are either completed within 24 hours or not
	    AllocatedTo, 
	    CaseNo, 
	    ActionLevel,
	    PlanDetail,
	    AllocatedDate,
	    CompletionTime,
	    DateDiff(Hour, AllocatedDate, CompletionTime) - (Holidays*24) [Time Taken (hours)],
	    Case
		    When DateDiff(Hour, AllocatedDate, CompletionTime) - (Holidays*24) <= 24 Then 'Declines Completed within 24 hours' 
		    Else 'Declines Not Completed within 24 hours' 
	    End [Category],
	    Sum(Case
			    When IsRescheduled = 1 Then 1
			    Else 0
		    End) [Rescheduled Count],
	    @StartDate [Start Date],
	    @EndDate [End Date]
    from 
	    cbPlan p	
	    CROSS APPLY (SELECT COUNT(*) AS Holidays
				      FROM [db-au-cmdwh].[dbo].[Calendar]
				      WHERE CAST([Date] AS Date) > CAST(p.AllocatedDate AS DAte) AND CAST([Date] AS Date) < CAST(p.CompletionTime AS Date)
				      AND (isHoliday = 1 OR isWeekEnd=1)) ca
    where 
	    ActionLevel = 'INSURANCE SPECIALIST' 
	    and isCancelled = 0
	    and (PlanDetail like 'Decline%' or PlanDetail like 'Add decline%' or PlanDetail like '7.5%')
	    and CompletionTime between @StartDate and @EndDate
    Group By
	    AllocatedTo, 
	    CaseNo, 
	    ActionLevel,
	    PlanDetail,
	    AllocatedDate,
	    CompletionTime,
	    DateDiff(Hour, AllocatedDate, CompletionTime) - (Holidays*24),
	    Case
	    When DateDiff(Hour, AllocatedDate, CompletionTime) - (Holidays*24) <= 24 Then 'Declines Completed within 24 hours' 
	    Else 'Declines Not Completed within 24 hours' 
	    End 

    UNION

    select -- Categorizing plans for GLA updates which are completed within 3 working days or not
	    AllocatedTo, 
	    CaseNo, 
	    ActionLevel,
	    PlanDetail,
	    AllocatedDate,
	    CompletionTime,
	    DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays1) AS [Time Taken (hours)],
	    Case 
		    --when DateDiff(Hour, r.FirstEstimateOver75K, CompletionTime) - (24*Holidays2) <= 72 Then 'GLA updates Completed within 3 Working Days'
		    when DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays1) <= 72 Then 'GLA updates Completed within 3 Working Days'		
		    Else 'GLA updates not Completed within 3 Working Days' 
	    End [Category],
	    Sum(Case
			    When IsRescheduled = 1 Then 1
			    Else 0
		    End) [Rescheduled Count],
	    @StartDate [Start Date],
	    @EndDate [End Date]
    from 
	    cbPlan p 
	    OUTER APPLY (  SELECT     
						     MIN(AuditDateTime) AS FirstEstimateOver75K  		 
				      FROM [cbAuditCase] a
				      WHERE  p.CaseKey = a.CaseKey
				      AND TotalEstimate >= 75000 ) r	
	    CROSS APPLY (SELECT COUNT(*) AS Holidays1
				    FROM [db-au-cmdwh].[dbo].[Calendar]
				    WHERE CAST([Date] AS Date) > CAST(p.AllocatedDate AS DAte) AND CAST([Date] AS Date) < CAST(p.CompletionTime AS Date)
				    AND (isHoliday = 1 OR isWeekEnd=1)) ca1
	    CROSS APPLY (SELECT COUNT(*) AS Holidays2
				    FROM [db-au-cmdwh].[dbo].[Calendar]
				    WHERE CAST([Date] AS Date) > CAST(r.FirstEstimateOver75K AS DAte) AND CAST([Date] AS Date) < CAST(p.CompletionTime AS Date)
				    AND (isHoliday = 1 OR isWeekEnd=1)) ca2
    where 
	    ActionLevel = 'INSURANCE SPECIALIST' 
	    and isCancelled = 0
	    and 
	    (PlanDetail like 'GLA Update%' OR PlanDetail LIKE '7.4%')
	    and CompletionTime between @StartDate and @EndDate
    Group By
	    AllocatedTo, 
	    CaseNo, 
	    ActionLevel,
	    PlanDetail,
	    AllocatedDate,
	    CompletionTime,
	    DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays1),
	    Case 
		    --when DateDiff(Hour, r.FirstEstimateOver75K, CompletionTime) - (24*Holidays2) <= 72 Then 'GLA updates Completed within 3 Working Days'
		    when DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays1) <= 72 Then 'GLA updates Completed within 3 Working Days'		
		    Else 'GLA updates not Completed within 3 Working Days' 
	    End 

    UNION

    select -- Categorizing plans where handover is completed within 48 hours or not
	    AllocatedTo, 
	    CaseNo, 
	    ActionLevel,
	    PlanDetail,
	    AllocatedDate,
	    CompletionTime,
	    DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays)  [Time Taken (hours)],
	    Case
		    When DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays) <= 48 Then 'Handover Completed within 48 hours' 
		    When CompletionTime <= TodoTime Then 'Handover Completed within 48 hours' 
		    Else 'Handover Not Completed within 48 hours'
	    End [Category],
	    Sum(Case
			    When IsRescheduled = 1 Then 1
			    Else 0
		    End) [Rescheduled Count],
	    @StartDate [Start Date],
	    @EndDate [End Date]
    from 
	    cbPlan p
	    CROSS APPLY (SELECT COUNT(*) AS Holidays
				    FROM [db-au-cmdwh].[dbo].[Calendar]
				    WHERE CAST([Date] AS Date) > CAST(p.AllocatedDate AS DAte) AND CAST([Date] AS Date) < CAST(p.CompletionTime AS Date)
				    AND (isHoliday = 1 OR isWeekEnd=1)) ca
    where 
	    ActionLevel = 'INSURANCE SPECIALIST' 
	    and isCancelled = 0
	    and CompletionTime between @StartDate and @EndDate
    Group By
	    AllocatedTo, 
	    CaseNo, 
	    ActionLevel,
	    PlanDetail,
	    AllocatedDate,
	    CompletionTime,
	    DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays),
	    Case
	    When DateDiff(Hour, AllocatedDate, CompletionTime) - (24*Holidays) <= 48 Then 'Handover Completed within 48 hours' 
	    When CompletionTime <= TodoTime Then 'Handover Completed within 48 hours' 
	    Else 'Handover Not Completed within 48 hours'
	    End 

end
GO
