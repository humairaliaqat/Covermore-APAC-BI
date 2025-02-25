USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0779a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[rptsp_rpt0779a]
	@country nvarchar(5),
    @ReportingPeriod varchar(30),
    @StartDate date,
    @EndDate date
as
begin

    set nocount on

    /****************************************************************************************************/
    --  Name:           dbo.rptsp_rpt0779a
    --  Author:         Peter Zhuo
    --  Date Created:   20160524
    --  Description:    This stored procedure shows claims with approved and denied count in the chosen period
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
    --    @EndDate = '2016-05-04'


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
	    --w.ClaimKey,
	    w.ClaimNumber as [Claim Number],
	    wa.AssessmentOutcomeDescription as [Assessment Outcome],
	    wa.CreationDate as [Assessment Outcome Start Date],
	    wa.CompletionDate as [Assessment Outcome Completion Date]
    from e5WorkActivity wa 
    inner join e5work w on wa.Work_id = w.Work_ID
    where
	    w.Country = @country
	    and (wa.CompletionDate >= @rptStartDate and wa.CompletionDate <= @rptEndDate)
	    and w.WorkType like '%Claim%'	
	    and wa.CategoryActivityName = 'Assessment Outcome'
	    and wa.AssessmentOutcomeDescription in ('Deny', 'Approve')

end
GO
