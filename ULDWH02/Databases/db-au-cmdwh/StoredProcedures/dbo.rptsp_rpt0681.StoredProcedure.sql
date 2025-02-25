USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0681]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0681]    
    @Country varchar(100),
    @Underwriter varchar(100),
    @DateRange varchar(30),
    @StartDate datetime = null,
    @EndDate datetime = null

as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0681
--  Author:         Saurabh Date
--  Date Created:   20150911
--  Description:    This stored procedure returns Claims Incurred deails
--  Parameters:     @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @Country: Value is valid Country key
--                  @Underwriter: Value is valid Underwriter name
--   
--  Change History: 20150911 - SD - Created
--                  20151001 - LT - Changed PolicyIssuedDate reference to use clmClaim.PolicyIssuedDate
--                                  This is the date stored in Claims system. Policy numbers in 
--                                  Penguin are re-used - hence creating duplicates policy numbers
--                  20160411 - LS - refactoring
--                                  change legacy Agency to penOutlet
--                                  change outdated UW definition
--					20170504 - LT - added AgencyGroupName and AgencyGroupCode columns to output.
--									amend outlet lookup to also look for legacy TRIPS agency table.
--					20170601 - LT - Updated UW Definition as part of Zurich UW changeover
--					20170630 - LT - Updated UW Definition for APOTC
--					20171101 - LT - Updated UW Definition for ETI and ERV
--
/****************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
declare @Country varchar(100)
declare @Underwriter varchar(100)
select @DateRange = '_User Defined', @StartDate = '2009-09-01', @EndDate = '2016-12-31', @Country='UK', @Underwriter='ETI'
*/

    set nocount on

    declare @rptStartDate datetime
    declare @rptEndDate datetime

    /* get reporting dates */
    if @DateRange = '_User Defined'
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
            DateRange = @DateRange;

    SELECT
        uw.Underwriter,
		o.AgencyGroupName [Agency Group Name],
		o.AgencyGroupCode [Agency Group Code],
        case 
            when cs.IsFinalised = 1 
            then 'Finalised' 
            else 'Active' 
        end [Claim Status],
        cs.ProductCode [Product Code],
        cs.SectionCode [Section Code],
        cs.PlanCode [Plan Code],
        cs.PolicyNo [Policy Number],
        cs.ClaimNo [Claim Number],
        cs.EventDate [Event Date],
        year(c.PolicyIssuedDate) as [Underwriter Year],
        c.PolicyIssuedDate [Issued Date],
        cs.EventCountryName [Event Country],
        cs.Peril [Peril],
        o.AgencyGroupState [Agency Group State],
        cs.AreaType [Area Type],
        cs.CatastropheCode [Catastrophe Code],
        isnull(sum(cs.EstimateValue),0) [Estimate],
        isnull(sum(cs.PaidRecoveredPayment),0) [Paid],
        (isnull(sum(cs.EstimateValue),0) + isnull(sum(cs.PaidRecoveredPayment),0)) [Incurred],
        @rptStartDate [RPTStartDate],
        @rptEndDate [RPTEndDate]
    from
	    clmClaimSummary cs 
	    inner join clmClaim c on 
            cs.ClaimKey = c.ClaimKey 
        outer apply
        (
            select top 1
				a.AgencyGroupName,
				a.AgencyGroupCode,
				a.AgencyGroupState,
				a.AgencyCode
			from
			(
				select
					GroupName AgencyGroupName,
					GroupCode AgencyGroupCode,
					StateSalesArea AgencyGroupState,
					AlphaCode as AgencyCode
				from
					[db-au-cmdwh].dbo.penOutlet
				where
					OutletStatus = 'Current' and
					OutletKey = c.OutletKey

				union

				select
					AgencyGroupName,
					AgencyGroupCode,
					AgencyGroupState,
					AgencyCode			
				from
					[db-au-cmdwh].dbo.Agency 
				where
					AgencyStatus = 'Current' and
					AgencyKey = c.AgencyKey
			) a
			where isnull(a.AgencyGroupCode,'') > ''
		) o
        outer apply
        (
            select
                case 
                    when c.CountryKey in ('AU', 'NZ') and o.AgencyGroupCode in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN') and (c.PolicyIssuedDate < '2017-06-01' OR (o.AgencyCode in ('APN0004','APN0005') and c.PolicyIssuedDate < '2017-07-01')) then 'TIP-GLA'
					when c.CountryKey in ('AU', 'NZ') and o.AgencyGroupCode in ('AP', 'MB', 'RV', 'RC', 'RQ', 'RT', 'NR', 'AW', 'RA', 'AN') and (c.PolicyIssuedDate >= '2017-06-01' OR (o.AgencyCode in ('APN0004','APN0005') and c.PolicyIssuedDate >= '2017-07-01')) then 'TIP-ZURICH'
                    when c.CountryKey in ('AU', 'NZ') and c.PolicyIssuedDate between '2002-08-23' and '2009-06-30' then 'VERO'
                    when c.CountryKey in ('AU', 'NZ') and c.PolicyIssuedDate >= '2009-07-01' and c.PolicyIssuedDate < '2017-06-01' then 'GLA'
					when c.CountryKey in ('AU', 'NZ') and c.PolicyIssuedDate >= '2017-06-01' then 'ZURICH'
                    when c.CountryKey in ('UK') and c.PolicyIssuedDate >= '2009-09-01' and c.PolicyIssuedDate < '2017-07-01' then 'ETI'
					when c.CountryKey in ('UK') and c.PolicyIssuedDate >= '2017-07-01' then 'ERV'
                    when c.CountryKey in ('UK') and c.PolicyIssuedDate < '2009-09-01' then 'UKU'
                    when c.CountryKey in ('MY', 'SG') then 'ETIQA'
                    when c.CountryKey in ('CN') then 'CCIC'
                    when c.CountryKey in ('ID') then 'Simas Net'
                    else 'OTHER'
                end Underwriter
        ) uw
    WHERE
        cs.CountryKey  =  @Country AND
        uw.Underwriter = @Underwriter AND
        convert(varchar(10),c.PolicyIssuedDate,120) between  convert(varchar(10),@rptStartDate,120) and convert(varchar(10),@rptEndDate,120)
    GROUP BY
        uw.Underwriter,
		o.AgencyGroupName,
		o.AgencyGroupCode,
        case 
            when cs.IsFinalised = 1 
            then 'Finalised' 
            else 'Active' 
        end,
        cs.ProductCode,
        cs.SectionCode,
        cs.PlanCode,
        cs.PolicyNo,
        cs.ClaimNo,
        cs.EventDate,
        year(c.PolicyIssuedDate),
        c.PolicyIssuedDate,
        cs.EventCountryName,
        cs.Peril,
        o.AgencyGroupState,
        cs.AreaType,
        cs.CatastropheCode


end
GO
