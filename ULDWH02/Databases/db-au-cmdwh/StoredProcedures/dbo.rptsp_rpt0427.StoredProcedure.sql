USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0427]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0427]  
    @Country varchar(2),  
    @ReportingPeriod varchar(30),  
    @StartDate varchar(10) = null,  
    @EndDate varchar(10) = null  
    
as  
begin  
  
/****************************************************************************************************/  
--  Name:           dbo.[rptsp_rpt0427]  
--  Author:         Leonardus Setyabudi  
--  Date Created:   20130520  
--  Description:    This stored procedure returns claim movement in a specified period, grouped by CO  
--  Parameters:       
--  Change History: 
--                  20130520 - LS - Case 18542, copied from RPT0293g due to new business rules requirements
--                  20130703 - LS - bug fix, e5 work should refers claim work type cases only
--                                  amend redundancy from exactly 4 months to greater than 2 months
--                  20130705 - LS - don't classify as both closing and redundant
--                  20130726 - LS - include more work types
--                                  change first completed date to last assessment date just before completed
--                  20160520 - LS - redo using incurred movement
--                    
/****************************************************************************************************/  
  
-- uncomment to debug  
--declare @Country varchar(2)  
--declare @ReportingPeriod varchar(30)  
--declare @StartDate varchar(10)  
--declare @EndDate varchar(10)  
--select   
--    @Country = 'AU',  
--    @ReportingPeriod = 'Last January',   
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

    if object_id('tempdb..#opening') is not null  
        drop table #opening  
  
    if object_id('tempdb..#movement') is not null  
        drop table #movement
      
    select 
        cl.ClaimKey,
        1 Opening 
    into #opening
    from
        clmClaim cl with(nolock)
        inner join vclmClaimIncurredIntraDay cii with(nolock) on
            cii.ClaimKey = cl.ClaimKey
    where
        cl.CountryKey = @Country and
        cii.IncurredDate < @rptStartDate
    group by
        cl.ClaimKey
    having 
        sum(cii.NewCount + cii.ReopenedCount - cii.ClosedCount) > 0

    select 
        cl.ClaimKey,
        sum(cii.NewCount) NewCount, 
        sum(cii.ReopenedCount) ReopenedCount,
        sum(cii.ClosedCount) ClosedCount
    into #movement
    from
        clmClaim cl with(nolock)
        inner join vclmClaimIncurredIntraDay cii with(nolock) on
            cii.ClaimKey = cl.ClaimKey
    where
        CountryKey = 'AU' and
        cl.CountryKey = @Country and
        cii.IncurredDate >= @rptStartDate and
        cii.IncurredDate <  dateadd(day, 1, @rptEndDate)
    group by
        cl.ClaimKey

    ;with 
    cte_movement as
    (
        select 
            ClaimKey,
            sum(Opening) Opening,
            sum(NewCount) New,
            sum(ReopenedCount) Reopen,
            sum(ClosedCount) Closed,
            sum(Opening) + sum(NewCount) + sum(ReopenedCount) - sum(ClosedCount) Closing
        from
            (
                select 
                    ClaimKey,
                    Opening,
                    0 NewCount,
                    0 ReopenedCount,
                    0 ClosedCount
                from
                    #opening

                union all

                select
                    ClaimKey,
                    0 Opening,
                    NewCount,
                    ReopenedCount,
                    ClosedCount
                from
                    #movement
            ) t
        group by
            ClaimKey
    )
    select 
        cl.ClaimNo,
        Opening,
        New,
        Reopen,
        Closed Closing,
        0 Redundant,
        0 NoAction,
        isnull([Assigned User], 'Unassigned') CaseManager,
        '' FirstAssessmentBy,
        '' FirstAssessmentDate,
        @rptStartDate StartDate,  
        @rptEndDate EndDate,
        '' AgencyGroupName,
        null LastAssessmentDate,
        isnull([Assigned User], 'Unassigned') LastAssessmentBy,
        0 ClaimValue,
        0 FirstClosing, 
        0 MultipleClosing,
        '' FirstCompletedBy,
        null FirstCompletedDate
    from
        cte_movement t
        inner join clmClaim cl on
            cl.ClaimKey = t.ClaimKey
        outer apply
        (
            select top 1 
                [Assigned User]
            from
                vClaimPortfolio cp
            where
                cp.ClaimKey = cl.ClaimKey
        ) cp

  
    --if object_id('tempdb..#opening') is not null  
    --    drop table #opening  
  
    --if object_id('tempdb..#allclaims') is not null  
    --    drop table #allclaims  
      
    --if object_id('tempdb..#output') is not null  
    --    drop table #output

    --create table #allclaims  
    --(  
    --    ClaimKey varchar(9),  
    --    Opening int,
    --    New int,
    --    Reopen int,
    --    FirstClosing int,
    --    MultipleClosing int,
    --    Redundant int
    --)  
      
    --create table #output
    --(  
    --    ClaimKey varchar(9),
    --    e5 bit,
    --    Opening int,
    --    New int,
    --    Reopen int,
    --    FirstClosing int,
    --    MultipleClosing int,
    --    Redundant int,
    --    NoAction int,
    --    CM varchar(200),
    --    FirstAssessmentBy varchar(200),
    --    FirstAssessmentDate datetime,
    --    LastAssessmentDate datetime,
    --    LastAssessmentBy varchar(200),
    --    FirstCompletedBy varchar(200),
    --    FirstCompletedDate datetime
    --)  

    --/* open claims */  
    --;with cte_open as  
    --(  
    --    select   
    --        ClaimKey,  
    --        min(FirstEstimateDate) FirstEstimateDate  
    --    from   
    --        clmClaimSummary cs  
    --    where  
    --        ClaimKey like @Country + '%'   
    --    group by  
    --        ClaimKey      
    --)  
    --select   
    --    ClaimKey,  
    --    Estimate,
    --    FirstEstimateDate
    --into #opening  
    --from  
    --    cte_open cl  
    --    cross apply  
    --    (  
    --        select   
    --            sum(Estimate) Estimate  
    --        from  
    --            clmEvent ce  
    --            inner join clmSection cs on  
    --                cs.EventKey = ce.EventKey  
    --            cross apply  
    --            (  
    --                select top 1   
    --                    EHEstimateValue Estimate  
    --                from   
    --                    clmEstimateHistory ceh  
    --                where  
    --                    ceh.CountryKey = @Country and  
    --                    ceh.EHCreateDate < @rptStartDate and  
    --                    ceh.EHSectionID = cs.SectionID  
    --                order by   
    --                    EstimateHistoryID desc  
    --            ) eh   
    --        where  
    --            ce.ClaimKey = cl.ClaimKey  
    --    ) cs  
    --where  
    --    FirstEstimateDate < @rptStartDate  
  
    --create index idx on #opening (Estimate, ClaimKey)  
  
    --/* opening */  
    --insert into #allclaims 
    --(
    --    ClaimKey,
    --    Opening
    --)
    --select   
    --    ClaimKey,  
    --    1
    --from  
    --    #opening cl
    --where  
    --    Estimate > 0  
          
  
    --/* new claims */  
    --;with cte_new as  
    --(  
    --    select   
    --        ClaimKey,  
    --        min(FirstEstimateDate) FirstEstimateDate  
    --    from   
    --        clmClaimSummary cs  
    --    where  
    --        ClaimKey like @Country + '%'   
    --    group by  
    --        ClaimKey      
    --)  
    --insert into #allclaims
    --(
    --    ClaimKey,
    --    New
    --)
    --select   
    --    ClaimKey,  
    --    1
    --from  
    --    cte_new cl  
    --where  
    --    FirstEstimateDate >= @rptStartDate and  
    --    FirstEstimateDate <  dateadd(day, 1, @rptEndDate)  
          
  
    --/* reopen */  
    --insert into #allclaims 
    --(
    --    ClaimKey,
    --    Reopen
    --)
    --select distinct
    --    ce.ClaimKey,  
    --    1
    --from   
    --    clmEstimateHistory ceh   
    --    inner join clmSection cs on  
    --        cs.CountryKey = ceh.CountryKey and  
    --        cs.SectionID = ceh.EHSectionID  
    --    inner join clmEvent ce on  
    --        cs.EventKey = ce.EventKey  
    --where  
    --    ceh.CountryKey = @Country and  
    --    ceh.EHCreateDate >= @rptStartDate and  
    --    ceh.EHCreateDate <  dateadd(day, 1, @rptEndDate) and  
    --    ceh.EHEstimateValue > 0 and  
    --    exists  
    --    (  
    --        select null  
    --        from  
    --            #opening cl  
    --        where  
    --            Estimate = 0 and  
    --            cl.ClaimKey = ce.ClaimKey  
    --    )

    --create clustered index cidx on #allclaims(ClaimKey)  
          
    --/* closed */  
    --;with cte_estimates as  
    --(  
    --    select distinct
    --        ce.ClaimKey
    --    from   
    --        clmEstimateHistory ceh   
    --        inner join clmSection cs on  
    --            cs.CountryKey = ceh.CountryKey and  
    --            cs.SectionID = ceh.EHSectionID  
    --        inner join clmEvent ce on  
    --            cs.EventKey = ce.EventKey
    --    where  
    --        ceh.CountryKey = @Country and  
    --        ceh.EHCreateDate >= @rptStartDate and  
    --        ceh.EHCreateDate <  dateadd(day, 1, @rptEndDate) and  
    --        ceh.EHEstimateValue = 0 and  
    --        exists   
    --        (  
    --            select null  
    --            from  
    --                #allclaims o  
    --            where   
    --                o.ClaimKey = ce.ClaimKey  
    --        )
    --)  
    --insert into #allclaims 
    --(
    --    ClaimKey,
    --    FirstClosing,
    --    MultipleClosing,
    --    Redundant
    --)
    --select   
    --    cl.ClaimKey,
    --    case
    --        when Name = 'E5User' and we.Id is not null then 0
    --        when MultipleClosed > 1 then 0
    --        else 1
    --    end FirstClosing,
    --    case
    --        when Name = 'E5User' and we.Id is not null then 0
    --        when MultipleClosed > 1 then 1
    --        else 0
    --    end MultipleClosing,
    --    case
    --        when Name = 'E5User' and we.Id is not null then 1
    --        else 0
    --    end
    --from  
    --    cte_estimates cl  
    --    cross apply  
    --    (  
    --        select   
    --            sum(Estimate) Estimate
    --        from  
    --            clmEvent ce  
    --            inner join clmSection cs on  
    --                cs.EventKey = ce.EventKey  
    --            cross apply  
    --            (  
    --                select top 1   
    --                    EHEstimateValue Estimate
    --                from   
    --                    clmEstimateHistory ceh  
    --                where  
    --                    ceh.CountryKey = @Country and  
    --                    ceh.EHCreateDate < dateadd(day, 1, @rptEndDate) and  
    --                    ceh.EHSectionID = cs.SectionID  
    --                order by   
    --                    EstimateHistoryID desc  
    --            ) eh   
    --        where  
    --            ce.ClaimKey = cl.ClaimKey  
    --    ) cs  
    --    cross apply  
    --    (  
    --        select top 1
    --            eh.Name,
    --            eh.EHCreateDate
    --        from  
    --            clmEvent ce  
    --            inner join clmSection cs on  
    --                cs.EventKey = ce.EventKey  
    --            cross apply  
    --            (  
    --                select top 1
    --                    EstimateHistoryID,
    --                    EHCreateDate,
    --                    css.Name
    --                from   
    --                    clmEstimateHistory ceh  
    --                    inner join clmSecurity css on
    --                        css.SecurityID = ceh.EHCreatedByID and
    --                        css.CountryKey = ceh.CountryKey
    --                where  
    --                    ceh.CountryKey = @Country and  
    --                    ceh.EHCreateDate < dateadd(day, 1, @rptEndDate) and  
    --                    ceh.EHSectionID = cs.SectionID  
    --                order by   
    --                    EstimateHistoryID desc  
    --            ) eh   
    --        where  
    --            ce.ClaimKey = cl.ClaimKey  
    --        order by
    --            EstimateHistoryID desc
    --    ) css
    --    outer apply
    --    (
    --        select top 1 
    --            we.Id
    --        from
    --            e5Work w
    --            inner join e5WorkEvent we on
    --                we.Work_Id = w.Work_ID
    --            outer apply
    --            (
    --                select top 1
    --                    pwe.StatusName,
    --                    pwe.EventDate
    --                from
    --                    e5WorkEvent pwe
    --                where
    --                    pwe.Work_Id = w.Work_ID and
    --                    pwe.Id < we.Id and
    --                    pwe.EventDate < we.EventDate and
    --                    pwe.EventName = 'Changed Work Status'
    --                order by
    --                    pwe.Id desc
    --            ) pwe
    --        where
    --            w.ClaimKey = cl.ClaimKey and
    --            (
    --                w.WorkType like '%claim%' or
    --                w.WorkType like 'RN Review%' or
    --                w.WorkType like 'CO Medical%'
    --            ) and
    --            we.EventDate between dateadd(day, -1, css.EHCreateDate) and dateadd(day, 1, css.EHCreateDate) and
    --            we.EventName = 'Changed Work Status' and
    --            we.StatusName = 'Complete' and
    --            we.EventUser is null and --'ActivationEventProvider'
    --            pwe.StatusName = 'Diarised' and --Must closed from Diarised state greater than 2 months
    --            datediff(day, pwe.EventDate, we.EventDate) > 60
    --    ) we
    --    outer apply
    --    (
    --        select 
    --            count(we.Id) MultipleClosed
    --        from
    --            e5Work w
    --            inner join e5WorkEvent we on
    --                we.Work_Id = w.Work_ID
    --        where
    --            w.ClaimKey = cl.ClaimKey and
    --            (
    --                w.WorkType like '%claim%' or
    --                w.WorkType like 'RN Review%' or
    --                w.WorkType like 'CO Medical%'
    --            ) and
    --            we.EventDate < dateadd(day, 1, css.EHCreateDate) and
    --            we.EventName = 'Changed Work Status' and
    --            we.StatusName = 'Complete'
    --    ) mc
    --where  
    --    Estimate = 0  

    --insert into #output          
    --(  
    --    ClaimKey,
    --    Opening,
    --    New,
    --    Reopen,
    --    FirstClosing,
    --    MultipleClosing,
    --    Redundant
    --)
    --select 
    --    ClaimKey,
    --    sum(isnull(Opening, 0)) Opening,
    --    sum(isnull(New, 0)) New,
    --    sum(isnull(Reopen, 0)) Reopen,
    --    sum(isnull(FirstClosing, 0)) FirstClosing,
    --    sum(isnull(MultipleClosing, 0)) MultipleClosing,
    --    sum(isnull(Redundant, 0)) Redundant
    --from
    --    #allclaims
    --group by
    --    ClaimKey

    
    --update cl
    --set
    --    cl.FirstAssessmentBy = ac.FirstAssessmentBy,
    --    cl.FirstAssessmentDate = ac.FirstAssessmentDate,
    --    cl.LastAssessmentDate = la.LastAssessmentDate,
    --    cl.LastAssessmentBy = la.LastAssessmentBy,
    --    cl.FirstCompletedBy = fc.FirstCompletedBy,
    --    cl.FirstCompletedDate = fc.FirstCompletedDate
    --from
    --    #output cl
    --    outer apply
    --    (
    --        select top 1
    --            wa.CompletionDate FirstAssessmentDate,
    --            wa.CompletionUser FirstAssessmentBy
    --        from
    --            e5Work w
    --            inner join e5WorkActivity wa on
    --                wa.Work_ID = w.Work_ID
    --        where
    --            w.ClaimKey = cl.ClaimKey and
    --            (
    --                w.WorkType like '%claim%' or
    --                w.WorkType like 'RN Review%' or
    --                w.WorkType like 'CO Medical%'
    --            ) and
    --            wa.CategoryActivityName = 'Assessment Outcome' and
    --            wa.CompletionDate is not null
    --        order by
    --            wa.CompletionDate
    --    ) ac
    --    outer apply
    --    (
    --        select top 1
    --            wa.CompletionDate LastAssessmentDate,
    --            wa.CompletionUser LastAssessmentBy
    --        from
    --            e5Work w
    --            inner join e5WorkActivity wa on
    --                wa.Work_ID = w.Work_ID
    --        where
    --            w.ClaimKey = cl.ClaimKey and
    --            (
    --                w.WorkType like '%claim%' or
    --                w.WorkType like 'RN Review%' or
    --                w.WorkType like 'CO Medical%'
    --            ) and
    --            wa.CategoryActivityName = 'Assessment Outcome' and
    --            wa.CompletionDate is not null
    --        order by
    --            wa.CompletionDate desc
    --    ) la
    --    outer apply
    --    (
    --        select top 1 
    --            we.EventDate FirstCompleteStatus
    --        from
    --            e5Work w
    --            inner join e5WorkEvent we on
    --                we.Work_Id = w.Work_ID
    --        where
    --            w.ClaimKey = cl.ClaimKey and
    --            (
    --                w.WorkType like '%claim%' or
    --                w.WorkType like 'RN Review%' or
    --                w.WorkType like 'CO Medical%'
    --            ) and
    --            we.EventName = 'Changed Work Status' and
    --            we.StatusName = 'Complete'
    --        order by
    --            we.EventDate
    --    ) wc
    --    outer apply
    --    (
    --        select top 1
    --            wa.CompletionDate FirstCompletedDate,
    --            wa.CompletionUser FirstCompletedBy
    --        from
    --            e5Work w
    --            inner join e5WorkActivity wa on
    --                wa.Work_ID = w.Work_ID
    --        where
    --            w.ClaimKey = cl.ClaimKey and
    --            (
    --                w.WorkType like '%claim%' or
    --                w.WorkType like 'RN Review%' or
    --                w.WorkType like 'CO Medical%'
    --            ) and
    --            wa.CategoryActivityName = 'Assessment Outcome' and
    --            wa.CompletionDate is not null and
    --            wa.CompletionDate <= wc.FirstCompleteStatus
    --        order by
    --            wa.CompletionDate desc
    --    ) fc
       

    --/* no action */
    --update #output
    --set
    --    NoAction = 0

    --update cl
    --set
    --    cl.NoAction = 1
    --from
    --    #output cl
    --where
    --    Opening = 1 and
    --    FirstClosing = 0 and
    --    MultipleClosing = 0 and
    --    not exists    
    --    (    
    --        select null    
    --        from    
    --            e5Work w    
    --            inner join e5WorkActivity wa on    
    --                wa.Work_ID = w.Work_ID    
    --        where    
    --            w.ClaimKey = cl.ClaimKey and    
    --            (
    --                w.WorkType like '%claim%' or
    --                w.WorkType like 'RN Review%' or
    --                w.WorkType like 'CO Medical%'
    --            ) and
    --            CategoryActivityName = 'Assessment Outcome' and    
    --            wa.CompletionDate >= @rptStartDate and    
    --            wa.CompletionDate <  dateadd(day, 1, @rptEndDate)   
    --    )    
        
      
    --select 
    --    ClaimNo,
    --    Opening,
    --    New,
    --    Reopen,
    --    FirstClosing + MultipleClosing Closing,
    --    Redundant,
    --    NoAction,
    --    isnull(CM, 'Unassigned') CaseManager,
    --    FirstAssessmentBy,
    --    FirstAssessmentDate,
    --    @rptStartDate StartDate,  
    --    @rptEndDate EndDate,
    --    a.AgencyGroupName,
    --    LastAssessmentDate,
    --    LastAssessmentBy,
    --    cls.ClaimValue,
    --    FirstClosing, 
    --    MultipleClosing,
    --    FirstCompletedBy,
    --    FirstCompletedDate
    --    --,
    --    --(
    --    --    select distinct
    --    --        cls.Benefit + ', '
    --    --    from 
    --    --        clmClaimSummary cls
    --    --    where
    --    --        cls.ClaimKey = cl.ClaimKey
    --    --    for xml path('')
    --    --) Sections
    --from
    --    #output t
    --    inner join clmClaim cl on
    --        cl.ClaimKey = t.ClaimKey
    --    inner join Agency a on
    --        a.AgencyKey = cl.AgencyKey and
    --        a.AgencyStatus = 'Current'
    --    cross apply
    --    (
    --        select 
    --            sum(EstimateValue + PaidRecoveredPayment) ClaimValue
    --        from
    --            clmClaimSummary cls
    --        where
    --            cls.ClaimKey = cl.ClaimKey
    --    ) cls

end
GO
