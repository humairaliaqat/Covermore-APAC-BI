USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0442a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0442a]
    @AgencyGroup varchar(3),
    @ProductCode varchar(3),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @hasEmail varchar(1) = 'Y'

as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0442
--  Author:         Leonardus S
--  Date Created:   20130701
--  Description:    This stored procedure returns AMT policies with return date in specified range
--					and policy holder has email address
--  Parameters:     @AgencyGroup: Required. ALL or valid agency group code
--                  @ProductCode: Required. ALL or valid policy product code
--                  @ReportingPeriod: Required. Value is valid date range
--                  @StartDate: Required if _User Defined. Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--					@hasEmail: Required. Value is Y or N
--
--  Change History: 20130701 - LS - Created
--					20140716 - LT - Added ProductName column to final output
--					20140731 - LT - Changed stored proc number to rptsp_rpt0442a
--									Added hasEmail parameter.	
--					20171011 - LT - Added Gross Premium column to result			
/****************************************************************************************************/

--uncomment to debug
--declare
--    @AgencyGroup varchar(3),
--    @ProductCode varchar(3),
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10),
--	  @hasEmail varchar(1)
--select	  
--    @AgencyGroup = 'ALL',
--    @ProductCode = 'ALL',
--    @ReportingPeriod = 'Next Month',
--    @StartDate = null,
--    @EndDate = null,
--    @hasEmail = 'N'

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
        p.PolicyNumber PolicyNo,
        p.TripEnd ExpiryDate,
        p.ProductCode,
        p.ProductDisplayName as ProductName,
        p.PlanDisplayName PlanCode,
		pt.GrossPremium,
        a.OutletName AgencyName,
        a.ContactTitle AgencyTitle,
        a.ContactFirstName AgencyFirstName,
        a.ContactLastName AgencyLastName,
        a.ContactStreet AgencyStreet,
        a.ContactSuburb AgencySuburb,
        a.ContactState AgencyState,
        a.ContactPostCode AgencyPostCode,
        c.Title CustTitle,
        c.FirstName CustFirstName,
        c.LastName CustLastName,
        c.AddressLine1 +
        case
            when rtrim(ltrim(c.AddressLine2)) <> '' then ' ' + c.AddressLine2
            else ''
        end CustStreet,
        c.Suburb CustSuburb,
        c.State CustState,
        c.PostCode CustPostcode,
        c.Country CustCountry,
        c.EmailAddress
        from
            penPolicy p
            inner join penPolicyTransSummary pt on
                pt.PolicyKey = p.PolicyKey and
                pt.TransactionType = 'Base'
            inner join penOutlet a on
                p.OutletAlphaKey = a.OutletAlphaKey and
                a.OutletStatus = 'Current'
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
