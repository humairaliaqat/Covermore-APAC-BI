USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1004]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt1004]
    @Country varchar(2) = 'AU',
    @ReportingPeriod varchar(30),
    @StartDate datetime = null,
    @EndDate datetime = null

as
begin

    set nocount on

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt1004
--  Author:         ME
--  Date Created:   20180621
--  Description:    This stored procedure returns claim average turnaround time details as per Zurich definitions
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--		    @Country: Value is valid country(such as AU, NZ, UK, ID, SG, MY or CN)
--   
--  Change History: 20180621 - ME - Created		
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


    declare @rptStartDate Date
    declare @rptEndDate Date

    /* get reporting dates */
    if @ReportingPeriod <> '_User Defined'
        select
            @rptStartDate = CAST(StartDate AS DATE),
            @rptEndDate = CAST(EndDate AS DATE)
        from
            vDateRange
        where
            DateRange = @ReportingPeriod

    else
        select
            @rptStartDate = CAST(@StartDate AS DATE),
            @rptEndDate = CAST(@EndDate AS DATE)

	SELECT 
		   CAST(wa.CompletionDate AS DATE)  AS FirstCompletionDate,		   
		   wa.CompletionDate  AS FirstCompletionDateTime,
		   w.ClaimKey,
		   w.ClaimNumber,
		   w.CreationDate,
		   	CASE 
				WHEN cl.FirstEstimateValue <= 1000.00 AND cl.SectionCount = 1 THEN 'Fast-Track' 
				WHEN 1000.00 < cl.FirstEstimateValue AND cl.FirstEstimateValue <= 3000.00 AND cl.SectionCount = 1 THEN 'General' 
				WHEN 3000.00 < cl.FirstEstimateValue AND cl.FirstEstimateValue <= 24999.99 THEN 'Complex Claims' 
				WHEN cl.FirstEstimateValue <= 24999.99 AND cl.SectionCount > 1 THEN 'Complex Claims' 
			ELSE 'Unclassified'
			END				AS ClaimType,
			datediff(day, w.CreationDate, wa.CompletionDate) * 1.0 -
					(
						select
							count(d.[Date])
						from
							Calendar d
						where
							d.[Date] >= w.CreationDate and
							d.[Date] <  CAST(wa.CompletionDate as date) and
							(
								d.isHoliday = 1 or
								d.isWeekEnd = 1
							)
					) TurnAroundTimeBusinessDays,
			ActiveBusinessDays 

	FROM e5WorkActivity wa
		INNER JOIN e5Work w
			ON wa.Work_ID = w.Work_ID
		INNER JOIN ( SELECT ClaimKey,
							SUM(firstEstimateValue)	AS FirstEstimateValue,
							COUNT(DISTINCT SectionKey)	AS SectionCount
					 FROM clmClaimSummary
					 GROUP BY ClaimKey	 
				   ) cl
			ON w.ClaimKey = cl.ClaimKey
		OUTER APPLY ( 
					select
						sum(
							case
								when we.StatusName = 'Active' then datediff(day, convert(date, we.EventDate), convert(date, isnull(nwe.NextChangeDate, getdate()))) - OffDays
								else 0
							end
						) ActiveBusinessDays

					from
						e5WorkEvent we
						outer apply
						(
							select top 1
								r.EventDate		AS  NextChangeDate
							from
								e5WorkEvent r
							where
								r.Work_Id = w.Work_ID and
								r.EventDate > we.EventDate and
								(
									(
										r.EventName in ('Changed Work Status', 'Merged Work') and
										isnull(r.EventUser, r.EventUserID) not in ('e5 Launch Service', 'svc-e5-prd-services')
									)
									or
									(
										--e5 Launch Service may cause a case to have total (Active Days + Diarised Days) > Absolute Age
										--this is due to [Saved Work] events with multiple [Status] occuring in same timestamp to ms
										--part of known issue revolving online claims in e5 v2
										r.EventName = 'Saved Work' and
										r.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
									)
								)
							order by
								r.EventDate
						) nwe
						outer apply
						(
							select
								count(d.[Date]) OffDays
							from
								Calendar d
							where
								d.[Date] >= convert(date, we.EventDate) and
								d.[Date] <  convert(date, isnull(nwe.NextChangeDate, getdate())) and
								(
									d.isHoliday = 1 or
									d.isWeekEnd = 1
								)
						) phd
					where
						we.Work_ID = w.Work_ID and
						(
							(
								we.EventName in ('Changed Work Status', 'Merged Work') and
								isnull(we.EventUser, we.EventUserID) not in ('e5 Launch Service', 'svc-e5-prd-services')
							)
							or
							(
								we.EventName = 'Saved Work' and
								we.EventUser in ('e5 Launch Service', 'svc-e5-prd-services')
							)
						) and
						we.StatusName in ('Active', 'Diarised') and
						we.EventDate >= w.CreationDate and
						we.EventDate <= wa.CompletionDate
				) wdays

	WHERE   wa.CategoryActivityName = 'Assessment Outcome' and
			wa.AssessmentOutcomeDescription IN ('Approve','Deny') and
			CAST(wa.CompletionDate AS DATE) >= @rptStartDate and
			CAST(wa.CompletionDate AS DATE) <= @rptEndDate and
			not exists ( select 1 
						 from e5WorkActivity wa2
						 where wa2.Work_ID = wa.Work_ID and
							wa2.CategoryActivityName = 'Assessment Outcome' and
							wa2.AssessmentOutcomeDescription IN ('Approve','Deny') and
							wa2.CompletionDate < wa.CompletionDate 
						 ) and
		   w.Country = @Country


end



GO
