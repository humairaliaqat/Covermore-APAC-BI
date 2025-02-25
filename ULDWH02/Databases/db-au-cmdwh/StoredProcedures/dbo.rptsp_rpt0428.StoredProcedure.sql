USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0428]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0428]
    @Country varchar(3) = 'AU',
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null
    
as
begin

/****************************************************************************************************/  
--  Name:           rptsp_rpt0428
--  Author:         Leonardus Setyabudi  
--  Date Created:   20130419
--  Description:    This stored procedure returns summary for Global SIM distribution
--  Parameters:     @ReportingPeriod 
--                  @StartDate 
--                  @EndDate 
--
--  Change History: 
--                  20130419 - LS - Created  
--                  20130423 - LS - bug fix, period should apply to notification & order date instead of issue date
--                  20130503 - LS - TFS 8382, add policy count & eligible policy count
--                  20130503 - LS - TFS 8382, bug fix on eligibility check
--                                  add more groups, compare date check to IssueDate instead of start - end dates
--                  20130507 - LS - TFS 8381, bug fix
--                                  lead time should include issue date (+1)
--                                  typo on original subgroups requirement 
--                  20130520 - LS - Case 18548, add distributed SIM summary
--                  20130625 - LS - Case 18648, change lead time from 12 to 15 days
--                  20131111 - LS - 19497, bug fix .. well not a bug actually, codes have been changed without notification
--                  20131112 - LS - 19568, update rules as in RPT0370
--                                  this is getting bad, need to rewrite to a simpler rules shareable between RPT0370 and this one
--                  20131119 - LS - TFS 10009 & 10010, include AirNZ in CM (A & NZ)
--                  20131206 - LS - cleanup, remove redundant logic (e.g. AA includes all subgroups)
--                                  19758, Include RAC
--                  20131224 - LS - use shared business logic, thanks _insert_deity_of_choice_here_!!!
--                  20140117 - LS - 20021, add sub group
--                                  rewrite, optimise
--                    
/****************************************************************************************************/  
  
--uncomment to debug  
--declare 
--    @Country varchar(3),
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10)  
--select   
--    @Country = 'AU',
--    @ReportingPeriod = 'Last Week',
--    @StartDate = null,   
--    @EndDate = null  

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
            [db-au-cmdwh].dbo.vDateRange  
        where   
            DateRange = @ReportingPeriod  
            
    /* cleanup temporary tables */
    if object_id('tempdb..#notification') is not null
        drop table #notification
        
    if object_id('tempdb..#orders') is not null
        drop table #orders

    if object_id('tempdb..#issued') is not null
        drop table #issued
        
    if object_id('tempdb..#distributed') is not null
        drop table #distributed

    /* policy with email sent during the period */
    select 
        PolicyKey,
        max(dq.CreateDateTime) LastNotified
    into #notification
    from
        penJob j
        inner join penDataQueue dq on
            dq.JobKey = j.JobKey
        inner join penPolicy p on
            dq.CountryKey = p.CountryKey and
            dq.CompanyKey = p.CompanyKey and
            dq.DataID = p.PolicyID
    where
        p.CountryKey = @Country and
        j.JobCode in
            (
                'AU_GLOBALSIM_CM',
                'AU_GLOBALSIM-EMAIL1_CM',
                'AU_GLOBALSIM-EMAIL2_CM',  
                'AU_GLOBALSIM_TIP',
                'AU_GLOBALSIM-EMAIL1_TIP',
                'AU_GLOBALSIM-EMAIL2_TIP',
                'NZ_GlobalSIM_CM',
                'NZ_GlobalSIM-EMAIL1_CM',
                'NZ_GlobalSIM-EMAIL2_CM'
            ) and
        dq.CreateDateTime >= @rptStartDate and
        dq.CreateDateTime <  dateadd(day, 1, @rptEndDate)
    group by
        PolicyKey

    /* policy with order created during the period */
    select  
        PolicyKey,
        OrderDate
    into #orders
    from
        vpenGlobalSIM gs
    where
        CountryKey = @Country and
        OrderDate >= @rptStartDate and
        OrderDate <  dateadd(day, 1, @rptEndDate)

    /* active base policy issued during the period */
    select  
        p.PolicyKey
    into #issued
    from
        penPolicy p
        inner join penOutlet o on
            o.OutletAlphaKey = p.OutletAlphaKey and
            o.OutletStatus = 'Current'
    where
        o.CountryKey = @Country and
        p.IssueDate >= @rptStartDate and
        p.IssueDate <  dateadd(day, 1, @rptEndDate) and
        p.StatusDescription = 'Active'

    /* distributed SIM */
    select 
        gs.PolicyKey,
        gs.InclusionDate,
        gs.OrderDate
    into #distributed
    from
        vpenGlobalSIM gs 
    where
        gs.CountryKey = @Country and
        InclusionDate >= @rptStartDate and 
        InclusionDate <  dateadd(day, 1, @rptEndDate)

    select 
        p.PolicyNumber,
        o.GroupName,
        o.SubGroupName,
        p.AreaName,
        pt.IssueDate,
        p.TripStart DepartureDate,
        n.LastNotified EmailDate,
        isnull(od.OrderDate, d.OrderDate) OrderDate,
        d.InclusionDate,
        p.TripDuration,
        datediff(day, isnull(od.OrderDate, d.OrderDate), p.TripStart) OrderDepLeadTime,
        AgeGroup,
        ptv.[State],
        pt.BasePolicyCount,
        pt.TravellersCount,
        pt.AdultsCount,
        case
            when n.PolicyKey is not null then 1
            else 0
        end EmailSent,
        case
            when od.PolicyKey is not null then 1
            else 0
        end SIMOrdered,
        case
            when n.PolicyKey is not null then 1
            when od.PolicyKey is not null then 1
            when exists
            (
                select 
                    null
                from
                    vpenGlobalSIM gs
                where
                    gs.PolicyKey = p.PolicyKey and
                    gs.ReportSet is not null
            ) then 1
            else 0
        end Eligible,
        case
            when d.PolicyKey is not null then 1
            else 0
        end SIMDispatched,
        @rptStartDate StartDate,   
        @rptEndDate EndDate  
    from
        penPolicy p
        inner join penPolicyTransSummary pt on
            pt.PolicyKey = p.PolicyKey and
            pt.TransactionType = 'Base'
        inner join penOutlet o on
            o.OutletAlphaKey = pt.OutletAlphaKey and
            o.OutletStatus = 'Current'
        cross apply
        (
            select top 1
                case 
                    when ptv.Age between 0 and 34 then '0 - 34'
                    when ptv.Age between 35 and 49 then '35 - 49'
                    when ptv.Age between 50 and 59 then '50 - 59'
                    when ptv.Age between 60 and 79 then '60 - 69'
                    else '70+'
                end AgeGroup,
                ptv.[State]
            from
                penPolicyTraveller ptv
            where
                ptv.PolicyKey = p.PolicyKey and
                ptv.isPrimary = 1
        ) ptv
        left join #notification n on
            n.PolicyKey = p.PolicyKey    
        left join #orders od on
            od.PolicyKey = p.PolicyKey
        left join #distributed d on
            d.PolicyKey = p.PolicyKey
    where
        p.PolicyKey in
        (
            select
                PolicyKey
            from
                #notification
                
            union
            
            select
                PolicyKey
            from
                #orders

            union
            
            select
                PolicyKey
            from
                #issued
            
            union
            
            select
                PolicyKey
            from
                #distributed
        )

    /* cleanup temporary tables */
    if object_id('tempdb..#notification') is not null
        drop table #notification
        
    if object_id('tempdb..#orders') is not null
        drop table #orders

    if object_id('tempdb..#issued') is not null
        drop table #issued
        
    if object_id('tempdb..#distributed') is not null
        drop table #distributed
        
end


GO
