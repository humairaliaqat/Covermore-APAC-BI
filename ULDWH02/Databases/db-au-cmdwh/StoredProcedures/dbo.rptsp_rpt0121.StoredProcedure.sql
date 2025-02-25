USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0121]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0121]		
    @ClaimType varchar(20),
    @Activity varchar(200),
    @WorkType varchar(200) = 'All Work Types',
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
    
as
begin
/****************************************************************************************************/
--	Name:			rptsp_rpt0121
--	Author:			Linus Tor
--	Date Created:	20100708
--	Description:	This stored procedure selects and calculates work activities created in reporting period
--					by claim and activity types
--	Parameters:		@ReportingPeriod: default date ranges or User Defined
--					@StartDate: YYYY-MM-DD eg. 2010-01-01
--					@EndDate: YYYY-MM-DD eg 2010-01-01
--	Parameters:
--	Change History:	20100708 - LT - Created
--					20110118 - LT - Migrated from Claims application/database
--					20110811 - LT - Modified stored procedure to run for different claim type and activities
--                  20130708 - LS - refactor
--                                  add WorkType filter (case 18682)
--
/****************************************************************************************************/

--uncomment to debug
--declare 
--    @ClaimType varchar(20),
--    @Activity varchar(200),
--    @WorkType varchar(200),
--    @ReportingPeriod varchar(30),
--    @StartDate datetime,
--    @EndDate datetime
--select 
--    @ClaimType = 'All Claims', 
--    @Activity = 'Assessment Outcome', 
--    @WorkType = 'All Work Types',
--    @ReportingPeriod = 'Month-to-Date'

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
    if @ReportingPeriod = 'User Defined'
        select 
            @rptStartDate = convert(smalldatetime,@StartDate), 
            @rptEndDate = convert(smalldatetime,@EndDate)
            
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    select 
        wa.CompletionUser as CompletedBy,                 
        wa.CompletionDate, 
        w.WorkType,        
        wa.CategoryActivityName as ActivityName,        
        w.ClaimNumber, 
        w.PolicyNumber,        
        w.ClaimDescription,         
        w.FirstNameClaimant1 as ClaimantFirstName,     
        w.SurnameClaimant1 as ClaimantSurname,      
        isNull(w.TotalEstimateValue, 0) as TotalEstimateValue,        
        isNull(w.TotalPaid, 0) as TotalPaidValue,
        w.OnlineClaim,
        @rptStartDate rptStartDate, 
        @rptEndDate rptEndDate
    from 
        e5WorkActivity wa         
        inner join e5Work w on 
            wa.Work_Id = w.Work_Id        
    where 
        w.WorkType <> 'Enrolment Forms' and
        (
            @ClaimType = 'All Claims' or
            (
                @ClaimType = 'Claims.NET' and
                isNull(w.OnlineClaim, 0) = 0
            ) or
            (
                @ClaimType = 'Online Claims' and
                isNull(w.OnlineClaim, 0) = 1
            )
        ) and
        (
            @Activity = 'All Activities' or
            wa.CategoryActivityName like @Activity + '%'
        ) and
        (
            @WorkType = 'All Work Types' or
            w.WorkType like @WorkType + '%'
        ) and
        wa.CompletionDate >= @rptStartDate and 
        wa.CompletionDate <  dateadd(day, 1, @rptEndDate)

end


GO
