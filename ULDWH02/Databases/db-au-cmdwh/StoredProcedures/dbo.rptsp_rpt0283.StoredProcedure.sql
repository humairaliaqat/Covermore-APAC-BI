USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0283]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0283]  
    @Country varchar(2),  
    @AgencyGroup varchar(2) = null,  
    @ReportingPeriod varchar(30),  
    @StartDate varchar(10) = null,  
    @EndDate varchar(10) = null  
                        
as  
begin  
 
  
/****************************************************************************************************/  
--  Name:           dbo.rptsp_rpt0283  
--  Author:         Leonardus Setyabudi  
--  Date Created:   20120131  
--  Description:    This stored procedure returns policies with return date in specified range  
--  Parameters:     @Country: Enter Country Code; e.g. AU  
--                  @AgencyGroup: agency group code  
--                  @ReportingPeriod: Value is valid date range  
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01  
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01  
--     
--  Change History: 20120131 - LS - Created  
--                  20120307 - LS - Add Agency Code & Agency Group Name for grouping  
--                  20120528 - LS - agent special only  
--                  20120614 - LS - add custom common date range for business renewals  
--                  20120703 - LT - exclude STA, and TIP agency groups  
--                  20120711 - LT - exclude closed agents  
--                  20120712 - LS - case 17673 use Customer name instead of agent's contact
--                  20120713 - LS - different customer primary flag between trips & penguin, use penguin
--                                  might as well rewrite all letters based on penguin at some point in time
--					20140129 - LT - Migrated to Penguin
--					20140507 - LT - Added isAgentSpecial filter to the query.
--                  20140630 - LS - TFS 12691 & 12581
--                                  exclude more groups (but still include if email is blank)
--                                  use policy key for primary traveller reference
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
declare @ReportingPeriod varchar(30)  
declare @StartDate varchar(10)  
declare @EndDate varchar(10)  
select   
    @Country = 'AU',  
    @AgencyGroup = null,  
    @ReportingPeriod = 'Next year',   
    @StartDate = '2018-07-01',   
    @EndDate = '2018-07-31'
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
        from [db-au-cmdwh].dbo.vDateRange  
        where DateRange = @ReportingPeriod  

    if object_id('tempdb..#renewal') is not null  
        drop table #renewal  

    select
        p.PolicyNumber as PolicyNo,  
        p.ProductCode,  
        p.TripEnd as RenewalDate,  
        a.AlphaCode as AgencyCode,
		p.PolicyKey 
    into #renewal    
    from   
        penPolicy p  
        inner join penOutlet a on   
            a.OutletAlphaKey = p.OutletAlphaKey and
            a.OutletStatus = 'Current'
		inner join penPolicyTransaction pt on 
			p.PolicyKey = pt.PolicyKey and
			pt.TransactionType = 'Base'
    where  
        a.CountryKey = @Country and  
        isnull(a.TradingStatus,'') not in ('Closed') and
        p.ProductCode = 'CMB' and  
        p.TripEnd >= @rptStartDate and   
        p.TripEnd <  dateadd(day, 1, @rptEndDate) and  
        pt.GrossPremium > 200 and   
        pt.isAgentSpecial = 1 and
        p.StatusDescription = 'Active' and  
        a.SuperGroupName not in 
        (
            'AAA',
            'STA',
            'Australia Post',
            'Medibank',
            'IAL'
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
        ) and
        (
			@AgencyGroup is null or
			a.GroupCode = @AgencyGroup
		)
 

    ;with cte_newcode as  
    (  
        select   
            a.AlphaCode as AgencyCode,  
            n.AlphaCode as NewCode,  
            n.StatusRegion as AgencyStatusCode,  
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
            n.AlphaCode NewCode,  
            n.StatusRegion as AgencyStatusCode,  
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
    set t.AgencyCode = isnull(n.NewCode, t.AgencyCode)  
    from  
        #renewal t  
        outer apply  
        (  
            select top 1 NewCode  
            from cte_newcode n  
            where n.AgencyCode = t.AgencyCode  
            order by Depth desc  
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
        r.RenewalDate,  
        c.Title,  
        c.FirstName,  
        c.LastName,
        @rptStartDate StartDate,   
        @rptEndDate EndDate  
    from   
        #renewal r  
        inner join penOutlet a on  
            a.CountryKey = @Country and  
            a.OutletStatus = 'Current' and  
            a.AlphaCode = r.AgencyCode   
        outer apply
        (
            select 
                ptv.Title,
                ptv.FirstName,
                ptv.LastName,
                ptv.DOB
            from 
                penPolicyTraveller ptv 
            where
                ptv.PolicyKey = r.PolicyKey and
                ptv.isPrimary = 1
        ) c
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
end  


GO
