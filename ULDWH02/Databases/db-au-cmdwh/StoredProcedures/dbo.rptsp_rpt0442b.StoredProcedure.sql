USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0442b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0442b]
    @AgencyGroup varchar(3),
    @ProductCode varchar(3),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @hasEmail varchar(1) = 'Y'

as
begin


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0442b
--  Author:         Linus Tor
--  Date Created:   20140731
--  Description:    This stored procedure returns AMT renewal policies where policy holder has an email address to be used in report
--					bursting.
--					NOTE: This stored procedure is making assumption, RPT0442 report is run using the following parameters:
--							@AgencyGroup: ALL
--							@ProductCode: ALL
--							@ReportingPeriod: Next Month
--							@hasEmail: Y
--					If RPT0442 report is not run with the above parameter values, then the returned data of this stored proc is not valid.
--
--  Change History: 20140731 - LT - created
--
/****************************************************************************************************/

--uncomment to debug
--declare
--    @AgencyGroup varchar(3),
--    @ProductCode varchar(3),
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10),
--	@hasEmail varchar(1)
--select	  
--    @AgencyGroup = 'ALL',
--    @ProductCode = 'ALL',
--    @ReportingPeriod = 'Next Month',
--    @StartDate = null,
--    @EndDate = null,
--    @hasEmail = 'Y'

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
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
        p.PolicyNumber,
        ltrim(rtrim(c.FirstName)) + ' ' + ltrim(rtrim(c.LastName)) as CustomerName,        
        p.PolicyEnd as ExpiryDate,
        ltrim(rtrim(u.FirstName)) + ' ' + ltrim(rtrim(u.LastName)) as AgentName,
        a.OutletName + ' (' + a.AlphaCode + ')' as AgencyName,
        c.EmailAddress as EmailAddress,
        @rptStartDate as rptStartDate,
        @rptEndDate as rptEndDate
        from
            penPolicy p
            inner join penPolicyTransSummary pt on
                pt.PolicyKey = p.PolicyKey and
                pt.TransactionType = 'Base'
            inner join penOutlet a on
                p.OutletAlphaKey = a.OutletAlphaKey and
                a.OutletStatus = 'Current'
			inner join penUser u on
				pt.UserKey = u.UserKey and
				u.UserStatus = 'Current'           
            inner join penPolicyTraveller c on
                p.PolicyKey = c.PolicyKey and
                c.IsPrimary = 1 and
                c.isAdult = 1
        where
            p.CountryKey = 'UK' and
            pt.isAMT = 1 and
            (
                @AgencyGroup = 'ALL' or
                a.GroupCode = @AgencyGroup
            ) and
            (
                @ProductCode = 'ALL' or
                p.ProductCode = @ProductCode
            ) and
            p.TripEnd between @rptStartDate and @rptEndDate and
            p.CancelledDate is null and
            (case when isnull(c.EmailAddress,'') <> '' then 'Y'
                  else 'N'
             end) = @hasEmail
        order by
            p.PolicyNumber

end
GO
