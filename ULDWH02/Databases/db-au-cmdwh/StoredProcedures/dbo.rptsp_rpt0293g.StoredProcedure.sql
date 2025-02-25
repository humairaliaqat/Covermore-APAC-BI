USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0293g]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0293g]  
    @Country varchar(2),  
    @ReportingPeriod varchar(30),  
    @StartDate varchar(10) = null,  
    @EndDate varchar(10) = null  
    
as  
begin  
  
/****************************************************************************************************/  
--  Name:           dbo.[rptsp_rpt0293g]  
--  Author:         Leonardus Setyabudi  
--  Date Created:   20121008  
--  Description:    This stored procedure returns claim movement in a specified period  
--  Parameters:       
--  Change History: 20121008 - LS - Created  
--                  20121019 - LS - Add first completed assessment outcome, Case 17950
--                  20121105 - LS - Add officer
--                  20121123 - LS - Change officer algorithm, generally based on last activity in period
--                                  Change output form
--                  20130307 - LS - Disable officer code (abandoned by Nathan Carey)
--                                  Case 18323
--                                      Include Agency Group
--                                      Split Closing to Closing & Redundant
--                                      Split NoAction to <=90 & >90
--                  20130308 - LS - Redundant Flag need to check period between diarised to closed
--                  20130405 - LS - Case 18413, add last assessment by
--                  20130405 - LS - Case 18416, add total value
--                  20130703 - LS - bug fix, e5 work should refers claim work type cases only
--                                  amend redundancy from exactly 4 months to greater than 2 months
--                    
/****************************************************************************************************/  
  
-- uncomment to debug  
--declare @Country varchar(2)  
--declare @ReportingPeriod varchar(30)  
--declare @StartDate varchar(10)  
--declare @EndDate varchar(10)  
--select   
--    @Country = 'AU',  
--    @ReportingPeriod = 'Last July',   
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
  
    if object_id('tempdb..#allclaims') is not null  
        drop table #allclaims  
      
    if object_id('tempdb..#output') is not null  
        drop table #output

    create table #allclaims  
    (  
        ClaimKey varchar(9),  
        Opening int,
        New int,
        Reopen int,
        Closing int,
        Redundant int
    )  
      
    create table #output
    (  
        ClaimKey varchar(9),
        e5 bit,
        Opening int,
        New int,
        Reopen int,
        Closing int,
        Redundant int,
        NoAction int,
        CM varchar(200),
        FirstAssessmentBy varchar(200),
        FirstAssessmentDate datetime,
        LastAssessmentDate datetime,
        LastAssessmentBy varchar(200)
    )  

    create clustered index cidx on #allclaims(ClaimKey)  
    create clustered index cidx on #output(ClaimKey)  
    --create index idx on #output(e5)  
    --create index idxcm on #output(CM)
  
    /* open claims */  
    ;with cte_open as  
    (  
        select   
            ClaimKey,  
            min(FirstEstimateDate) FirstEstimateDate  
        from   
            clmClaimSummary cs  
        where  
            ClaimKey like @Country + '%'   
        group by  
            ClaimKey      
    )  
    select   
        ClaimKey,  
        Estimate,
        FirstEstimateDate
    into #opening  
    from  
        cte_open cl  
        cross apply  
        (  
            select   
                sum(Estimate) Estimate  
            from  
                clmEvent ce  
                inner join clmSection cs on  
                    cs.EventKey = ce.EventKey  
                cross apply  
                (  
                    select top 1   
                        EHEstimateValue Estimate  
                    from   
                        clmEstimateHistory ceh  
                    where  
                        ceh.CountryKey = @Country and  
                        ceh.EHCreateDate < @rptStartDate and  
                        ceh.EHSectionID = cs.SectionID  
                    order by   
                        EstimateHistoryID desc  
                ) eh   
            where  
                ce.ClaimKey = cl.ClaimKey  
        ) cs  
    where  
        FirstEstimateDate < @rptStartDate  
  
    create clustered index cidx on #opening (Estimate, ClaimKey)  
  
  
    /* opening */  
    insert into #allclaims 
    (
        ClaimKey,
        Opening
    )
    select   
        ClaimKey,  
        1
    from  
        #opening cl
    where  
        Estimate > 0  
          
  
    /* new claims */  
    ;with cte_new as  
    (  
        select   
            ClaimKey,  
            min(FirstEstimateDate) FirstEstimateDate  
        from   
            clmClaimSummary cs  
        where  
            ClaimKey like @Country + '%'   
        group by  
            ClaimKey      
    )  
    insert into #allclaims
    (
        ClaimKey,
        New
    )
    select   
        ClaimKey,  
        1
    from  
        cte_new cl  
    where  
        FirstEstimateDate >= @rptStartDate and  
        FirstEstimateDate <  dateadd(day, 1, @rptEndDate)  
          
  
    /* reopen */  
    insert into #allclaims 
    (
        ClaimKey,
        Reopen
    )
    select distinct
        ce.ClaimKey,  
        1
    from   
        clmEstimateHistory ceh   
        inner join clmSection cs on  
            cs.CountryKey = ceh.CountryKey and  
            cs.SectionID = ceh.EHSectionID  
        inner join clmEvent ce on  
            cs.EventKey = ce.EventKey  
    where  
        ceh.CountryKey = @Country and  
        ceh.EHCreateDate >= @rptStartDate and  
        ceh.EHCreateDate <  dateadd(day, 1, @rptEndDate) and  
        ceh.EHEstimateValue > 0 and  
        exists  
        (  
            select null  
            from  
                #opening cl  
            where  
                Estimate = 0 and  
                cl.ClaimKey = ce.ClaimKey  
        )

          
    /* closed */  
    ;with cte_estimates as  
    (  
        select distinct
            ce.ClaimKey
        from   
            clmEstimateHistory ceh   
            inner join clmSection cs on  
                cs.CountryKey = ceh.CountryKey and  
                cs.SectionID = ceh.EHSectionID  
            inner join clmEvent ce on  
                cs.EventKey = ce.EventKey
        where  
            ceh.CountryKey = @Country and  
            ceh.EHCreateDate >= @rptStartDate and  
            ceh.EHCreateDate <  dateadd(day, 1, @rptEndDate) and  
            ceh.EHEstimateValue = 0 and  
            exists   
            (  
                select null  
                from  
                    #allclaims o  
                where   
                    o.ClaimKey = ce.ClaimKey  
            )
    )  
    insert into #allclaims 
    (
        ClaimKey,
        Closing,
        Redundant
    )
    select   
        cl.ClaimKey,
        1,
        case
            when Name = 'E5User' and we.Id is not null then 1
            else 0
        end
    from  
        cte_estimates cl  
        cross apply  
        (  
            select   
                sum(Estimate) Estimate
            from  
                clmEvent ce  
                inner join clmSection cs on  
                    cs.EventKey = ce.EventKey  
                cross apply  
                (  
                    select top 1   
                        EHEstimateValue Estimate
                    from   
                        clmEstimateHistory ceh  
                    where  
                        ceh.CountryKey = @Country and  
                        ceh.EHCreateDate < dateadd(day, 1, @rptEndDate) and  
                        ceh.EHSectionID = cs.SectionID  
                    order by   
                        EstimateHistoryID desc  
                ) eh   
            where  
                ce.ClaimKey = cl.ClaimKey  
        ) cs  
        cross apply  
        (  
            select top 1
                eh.Name,
                eh.EHCreateDate
            from  
                clmEvent ce  
                inner join clmSection cs on  
                    cs.EventKey = ce.EventKey  
                cross apply  
                (  
                    select top 1
                        EstimateHistoryID,
                        EHCreateDate,
                        css.Name
                    from   
                        clmEstimateHistory ceh  
                        inner join clmSecurity css on
                            css.SecurityID = ceh.EHCreatedByID and
                            css.CountryKey = ceh.CountryKey
                    where  
                        ceh.CountryKey = @Country and  
                        ceh.EHCreateDate < dateadd(day, 1, @rptEndDate) and  
                        ceh.EHSectionID = cs.SectionID  
                    order by   
                        EstimateHistoryID desc  
                ) eh   
            where  
                ce.ClaimKey = cl.ClaimKey  
            order by
                EstimateHistoryID desc
        ) css
        outer apply
        (
            select top 1 
                we.Id
            from
                e5Work w
                inner join e5WorkEvent we on
                    we.Work_Id = w.Work_ID
                outer apply
                (
                    select top 1
                        pwe.StatusName,
                        pwe.EventDate
                    from
                        e5WorkEvent pwe
                    where
                        pwe.Work_Id = w.Work_ID and
                        pwe.Id < we.Id and
                        pwe.EventDate < we.EventDate and
                        pwe.EventName = 'Changed Work Status'
                    order by
                        pwe.Id desc
                ) pwe
            where
                w.ClaimKey = cl.ClaimKey and
                w.WorkType like '%claim%' and
                we.EventDate between dateadd(day, -1, css.EHCreateDate) and dateadd(day, 1, css.EHCreateDate) and
                we.EventName = 'Changed Work Status' and
                we.StatusName = 'Complete' and
                we.EventUser is null and --'ActivationEventProvider'
                pwe.StatusName = 'Diarised' and --Must closed from Diarised state greater than 2 months
                datediff(day, pwe.EventDate, we.EventDate) > 60
        ) we
    where  
        Estimate = 0  

    insert into #output          
    (  
        ClaimKey,
        Opening,
        New,
        Reopen,
        Closing,
        Redundant
    )
    select 
        ClaimKey,
        sum(isnull(Opening, 0)) Opening,
        sum(isnull(New, 0)) New,
        sum(isnull(Reopen, 0)) Reopen,
        sum(isnull(Closing, 0)) Closing,
        sum(isnull(Redundant, 0)) Redundant
    from
        #allclaims
    group by
        ClaimKey
        
    update cl
    set
        cl.FirstAssessmentBy = ac.FirstAssessmentBy,
        cl.FirstAssessmentDate = ac.FirstAssessmentDate,
        cl.LastAssessmentDate = la.LastAssessmentDate,
        cl.LastAssessmentBy = la.LastAssessmentBy
    from
        #output cl
        outer apply
        (
            select top 1
                wa.CompletionDate FirstAssessmentDate,
                wa.CompletionUser FirstAssessmentBy
            from
                e5Work w
                inner join e5WorkActivity wa on
                    wa.Work_ID = w.Work_ID
            where
                w.ClaimKey = cl.ClaimKey and
                w.WorkType like '%claim%' and
                wa.CategoryActivityName = 'Assessment Outcome' and
                wa.CompletionDate is not null
            order by
                wa.CompletionDate
        ) ac
        outer apply
        (
            select top 1
                wa.CompletionDate LastAssessmentDate,
                wa.CompletionUser LastAssessmentBy
            from
                e5Work w
                inner join e5WorkActivity wa on
                    wa.Work_ID = w.Work_ID
            where
                w.ClaimKey = cl.ClaimKey and
                w.WorkType like '%claim%' and
                wa.CategoryActivityName = 'Assessment Outcome' and
                wa.CompletionDate is not null
            order by
                wa.CompletionDate desc
        ) la
       

    /* no action */
    update #output
    set
        NoAction = 0

    update cl
    set
        cl.NoAction = 1
    from
        #output cl
    where
        Opening = 1 and
        Closing = 0 and
        not exists    
        (    
            select null    
            from    
                e5Work w    
                inner join e5WorkActivity wa on    
                    wa.Work_ID = w.Work_ID    
            where    
                w.ClaimKey = cl.ClaimKey and    
                w.WorkType like '%claim%' and
                CategoryActivityName = 'Assessment Outcome' and    
                wa.CompletionDate >= @rptStartDate and    
                wa.CompletionDate <  dateadd(day, 1, @rptEndDate)   
        )    
        
      
    select 
        ClaimNo,
        Opening,
        New,
        Reopen,
        Closing,
        Redundant,
        NoAction,
        isnull(CM, 'Unassigned') CaseManager,
        FirstAssessmentBy,
        FirstAssessmentDate,
        @rptStartDate StartDate,  
        @rptEndDate EndDate,
        a.AgencyGroupName,
        LastAssessmentDate,
        LastAssessmentBy,
        cls.ClaimValue
    from
        #output t
        inner join clmClaim cl on
            cl.ClaimKey = t.ClaimKey
        inner join Agency a on
            a.AgencyKey = cl.AgencyKey and
            a.AgencyStatus = 'Current'
        cross apply
        (
            select 
                sum(EstimateValue + PaidRecoveredPayment) ClaimValue
            from
                clmClaimSummary cls
            where
                cls.ClaimKey = cl.ClaimKey
        ) cls

end
GO
