USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0285]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0285]
    @Country varchar(2),
    @AgencyGroup varchar(2) = null,
    @ProductCode varchar(5) = null,
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
                      
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0285
--  Author:         Leonardus Setyabudi
--  Date Created:   20120131
--  Description:    This stored procedure returns policies with return date in specified range
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: agency group code
--                  @ProductCode: policy product code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20120131 - LS - Created
--                  20120307 - LS - Add Agency Code & Agency Group Name for grouping
--                                  Make ProductCode optional
--                  20120528 - LS - exclude CMB, see rpt0286
--                                  add Product Code description
--                                  exclude agent specials
--                  20120530 - LS - limit to covermore products excluding corporate & mobile
--                  20120614 - LS - add custom common date range for business renewals
--					20120703 - LT - exclude STA, and TIP agency groups
--					20120711 - LT - exclude closed agents
--					20140129 - LT - migrated to Penguin
--                  20140630 - LS - TFS 12691 & 12581
--                                  exclude more groups (but still include if email is blank)
--                                  refactoring
--                                  remove @producttype dead codes
--					20150204 - LT - exclude IAL agency groups
--					20150209 - LT - F22842 - Amended query to restrict travellers age equal or greater than 75 years old
--											 on policy expiry date.
--					20161010 - PZ - INC0018099 - Update AMT letter in AU to include only AMT policies where ALL travellers 
--												 age is less than or equal to 74 at time of policy expiry date.
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @ProductCode varchar(5)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
    @Country = 'AU',
    @AgencyGroup = 'FL',
    @ProductCode = 'CMB',
    @ReportingPeriod = 'Next Year', 
    @StartDate = null, 
    @EndDate = null
*/

    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = @StartDate, 
            @rptEndDate = @EndDate

    else if @ReportingPeriod = 'Date +4 weeks'
        select 
            @rptStartDate = dateadd(week, 4, convert(date, getdate())), 
            @rptEndDate = dateadd(week, 4, convert(date, getdate()))

    else if @ReportingPeriod = 'Date +6 weeks'
        select 
            @rptStartDate = dateadd(week, 6, convert(date, getdate())), 
            @rptEndDate = dateadd(week, 6, convert(date, getdate()))

    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @ReportingPeriod

    if object_id('tempdb..#renewal') is not null
        drop table #renewal

    select
        p.PolicyNumber as PolicyNo,
        p.ProductCode,
        p.PolicyEnd as RenewalDate,
        a.AlphaCode as AgencyCode,
        p.PolicyKey,
        p.ProductDisplayName as ProductType
    into #renewal  
    from 
        penPolicy p 
        inner join penOutlet a on 
            a.OutletAlphaKey = p.OutletAlphaKey and 
            a.OutletStatus = 'Current'
        inner join penPolicyTransSummary pt on 
            p.PolicyKey = pt.PolicyKey
    where
        a.CountryKey = @Country and
        a.TradingStatus not in ('Closed') and			--closed, recoded, ceased trading
        (
            (
                @ProductCode is null and
                p.ProductCode <> 'CMB'
            ) or
            p.ProductCode = @ProductCode 
        ) and
        p.TripType = 'Annual Multi Trip' and
        p.PolicyEnd >= @rptStartDate and 
        p.PolicyEnd <  dateadd(day, 1, @rptEndDate) and
        pt.BasePremium > 200 and 
        pt.TransactionType = 'Base' and
        pt.isAgentSpecial <> 1 and
        
        p.StatusDescription = 'Active' and
        (
            (
                @AgencyGroup is null or 
                a.GroupCode = @AgencyGroup
            ) and
            (
                a.SuperGroupName not in ('AAA','STA','Australia Post','Medibank','IAL','P&O Cruises','Virgin')
            ) 
        ) and
        (
            exists
            (
                select top 1
                    null
                from
                    penPolicyTraveller ptv
                where
                    ptv.PolicyKey = p.PolicyKey and
                    ptv.isPrimary = 1 and
                    isnull(ltrim(rtrim(ptv.EmailAddress)), '') = ''
            ) or
            (
                not
                (
                   a.GroupCode = 'CM' and
                   a.SubGroupCode in ('PH', 'MS', 'WE') 
                ) and
                not
                (
                   a.GroupCode = 'FL' and
                   a.SubGroupCode in ('FL', 'WE') 
                )
            )
        )


    ;with cte_newcode as
    (
        select 
            a.AlphaCode as AgencyCode,
            n.AlphaCode as NewCode,
            n.TradingStatus as AgencyStatusCode,
            1 Depth
        from 
            penOutlet a
            inner join penOutlet n on 
                n.CountryKey = @Country and
                n.OutletStatus = 'Current' and 
                n.PreviousAlpha = a.AlphaCode
        where 
            a.CountryKey = @Country and
            a.OutletStatus = 'Current'

        union all

        select 
            o.AgencyCode,
            n.AlphaCode as NewCode,
            n.TradingStatus as AgencyStatusCode,
            o.Depth + 1 Depth
        from 
            cte_newcode o
            inner join penOutlet n on 
                n.CountryKey = @Country and
                n.OutletStatus = 'Current' and 
                n.PreviousAlpha = o.NewCode and
                n.AlphaCode <> o.AgencyCode
    )
    update t
    set
        t.AgencyCode = isnull(n.NewCode, t.AgencyCode)
    from
        #renewal t
        outer apply
        (
            select top 1 
                NewCode
            from 
                cte_newcode n
            where 
                n.AgencyCode = t.AgencyCode
            order by 
                Depth desc
        ) n

    select
        a.AlphaCode as AgencyCode,
        a.GroupName as AgencyGroupName,
        a.OutletName as AgencyName,
        a.SubGroupName,
        a.SuperGroupName,    
        a.ContactTitle,
        a.ContactFirstName,
        a.ContactLastName,
        a.ContactPhone,
        a.ContactStreet,
        a.ContactSuburb,
        a.ContactState,
        a.ContactPostCode,
        case
            when a.CountryKey = 'AU' then 'Australia'
            when a.CountryKey = 'NZ' then 'New Zealand'
            when a.CountryKey = 'UK' then 'United Kingdom'
        end Country,
        r.PolicyNo,
        r.ProductCode,
        r.ProductType,
        r.RenewalDate,
        c.Title,
        c.FirstName,
        c.LastName,
        (c.AddressLine1 + ' ' + c.AddressLine2) as CustAddressStreet,
        c.Suburb as CustAddressSuburb,
        c.Postcode as CustAddressPostCode,
        c.[State] as CustAddressState,
        c.Country as CustAddressCountry,
        @rptStartDate StartDate, 
        @rptEndDate EndDate
    from 
        #renewal r
        inner join penPolicyTraveller c on 
            c.PolicyKey = r.PolicyKey and
            c.IsAdult = 1 and
            c.isPrimary = 1
        inner join penOutlet a on
            a.CountryKey = @Country and
            a.OutletStatus = 'Current' and
            a.AlphaCode = r.AgencyCode
		outer apply
			( -- TOFR
				select 
					count(ptv.PolicyTravellerKey) as [TOFR Count]
				from 
					penPolicyTraveller ptv 
				where
					ptv.PolicyKey = r.PolicyKey
					and datediff(year,ptv.DOB,r.RenewalDate) >= 75
			) as TOFR --Too old for renewal
	where
		datediff(year,c.DOB,r.RenewalDate) < 75
		and (case when a.CountryKey = 'AU' and TOFR.[TOFR Count] > 0 then 1 else 0 end) = 0 -- TOFR Flag       
    order by 
        PolicyNo

end
GO
