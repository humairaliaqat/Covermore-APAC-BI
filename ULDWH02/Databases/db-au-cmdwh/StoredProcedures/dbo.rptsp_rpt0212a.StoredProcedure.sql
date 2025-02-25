USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0212a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0212a]
    @Country varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @EventFilter varchar(512) = null,
    @PerilFilter varchar(3) = null,
    @SectionFilter varchar(2) = null
                    
/****************************************************************************************************/
--  Name:           rptsp_rpt0212a
--  Author:         Leonardus Setyabudi
--  Date Created:   20121015
--  Description:    This stored procedure returns list of Claims due to EMC add-on
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--                  @EventFilter: Filter claims event containing specific word
--                  @PerilFilter: Enter Peril Code
--                  @SectionFilter: Enter Section Code
--  
--  Change History: 20121015 - LS - copied from rptsp_rpt0212, additional fields for EMC department (#17944)
--                  
/****************************************************************************************************/

as
begin
--uncomment to debug
--declare @Country varchar(2)
--declare @ReportingPeriod varchar(30)
--declare @StartDate varchar(10)
--declare @EndDate varchar(10)
--declare @EventFilter varchar(512)
--declare @PerilFilter varchar(3)
--declare @SectionFilter varchar(2)
--select 
--    @Country = 'AU', 
--    @ReportingPeriod = 'Last Month', 
--    @EventFilter = 'depress'

    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = convert(date, @StartDate), 
            @rptEndDate = convert(date, @EndDate)
        
    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            [db-au-cmdwh].dbo.vDateRange
        where 
            DateRange = @ReportingPeriod
            
    select
        @EventFilter = rtrim(ltrim(isnull(@EventFilter, ''))),
        @PerilFilter = rtrim(ltrim(isnull(@PerilFilter, ''))),
        @SectionFilter = rtrim(ltrim(isnull(@SectionFilter, '')))
    
    if object_id('tempdb..#result') is not null
        drop table #result

    select 
        cl.ClaimNo,
        case 
            when p.CountryKey = 'AU' then
                case   
                    when p.PlanCode in ('PBA5','CPBA5') then 'Area 6'
                    when p.PlanCode like '%1' and p.PlanCode not like '%D%' then 'Area 1'
                    when p.PlanCode like '%2' and p.PlanCode not like '%D%' then 'Area 2'
                    when p.PlanCode like '%3' and p.PlanCode not like '%D%' then 'Area 3'
                    when (p.PlanCode like '%4' or p.PlanCode like '%5') and p.PlanCode not like '%D%' then 'Area 4'
                    when (p.PlanCode in ('X','XM') or p.PlanCode like '%D%') then 'Area 5'
                    else 'Unknown'
                end
            when p.CountryKey = 'NZ' then
                case   
                    when p.PlanCode like 'C%' or p.PlanCode like 'D%' then 'Area 8'
                    when p.PlanCode like 'A%' and p.Destination = 'Worldwide' then 'Area 10'
                    when p.PlanCode like 'A%' and p.Destination = 'Restricted Worldwide' then 'Area 11'
                    when p.PlanCode like 'A%' and p.Destination = 'South Pacific and Australia' then 'Area 12'
                    when p.PlanCode like 'A%' and p.Destination = 'New Zealand Only' then 'Area 13'
                    when p.PlanCode like 'A%' then 'Area 0'
                    when p.PlanCode like 'X%' or len(p.PlanCode) > 3 then 
                        case
                            when p.PlanCode like '%M%' then 'Area ' + convert(varchar, convert(int, substring(p.PlanCode, patindex('%[0-9]%', p.PlanCode), len(p.PlanCode) - patindex('%[0-9]%', p.PlanCode) + 1)) + 9)
                            else 'Area ' + substring(p.PlanCode, patindex('%[0-9]%', p.PlanCode), len(p.PlanCode) - patindex('%[0-9]%', p.PlanCode) + 1)
                        end
                else 'Unknown'
            end
            else
                case   
                    when p.PlanCode like '%1' then 'Area 1'
                    when p.PlanCode like '%2' then 'Area 2'
                    when p.PlanCode like '%3' then 'Area 3'
                    when p.PlanCode like '%4' then 'Area 4'
                    when p.PlanCode like '%5' then 'Area 5'
                    when p.PlanCode like '%6' then 'Area 6'
                    when p.PlanCode like '%7' then 'Area 7'
                    else 'Unknown'
                end
        end Area,
        isnull(emc.AgeOfDeparture, 0) EMCAge,
        isnull(emc.EMCNumber, '') EMCNumber,
        isnull(emc.Condition, '') Condition,
        isnull(emc.ConditionStatus, '') ConditionStatus,
        isnull(emc.ConditionScore, 0) ConditionScore,
        isnull(emc.HealixRiskScore, 0) HealixRisk,
        isnull(emc.MedicalRiskScore, 0) MedicalRisk,
        cl.EventDescription,        
        cl.ClaimValue TotalValue,
        cl.FirstEstimateValue,
        @rptStartDate StartDate,
        @rptEndDate EndDate
    into #result
    from 
        clmClaimSummary cl
        inner join Policy p on
            p.PolicyKey = cl.PolicyKey
        outer apply
        (
            select 
                pe.ClientID EMCNumber,
                ea.AgeOfDeparture,
                m.Condition,
                m.ConditionStatus,
                m.MedicalScore ConditionScore,
                e.MedicalRisk HealixRiskScore,
                mr.MedicalRiskScore
            from 
                PolicyEMC pe
                inner join emcApplications e on
                    patindex('%[^0-9]%', pe.ClientID) = 0 and
                    e.ApplicationID = pe.ClientID and
                    e.CountryKey = pe.CountryKey
                inner join emcMedical m on
                    m.ApplicationKey = e.ApplicationKey and
                    m.ConditionStatus in ('Approved', 'Denied')
                inner join emcApplicants ea on
                    ea.ApplicationKey = e.ApplicationKey
                outer apply
                (
                    select 
                        sum(GroupScore) MedicalRiskScore
                    from
                        (
                            select distinct
                                GroupID,
                                GroupScore
                            from
                                emcMedical m
                            where
                                m.ApplicationKey = e.ApplicationKey
                        ) mg
                ) mr
            where 
                pe.CountryKey = cl.CountryKey and 
                pe.PolicyNo = cl.PolicyNo and
                (
                    @EventFilter <> '' or
                    @PerilFilter <> '' or
                    @SectionFilter <> '' or
                    pe.PolicyEMCType = 'Assessed'    /* requirement: leave blank for self assessment */
                )
        ) emc
    where 
        cl.CountryKey = @Country and
        cl.ReceivedDate between @rptStartDate and @rptEndDate and
        cl.EventDescription like '%' + @EventFilter + '%' and
        cl.PerilCode like @PerilFilter + '%' and
        cl.SectionCode like @SectionFilter + '%' and
        
        (
            @EventFilter <> '' or
            @PerilFilter <> '' or
            @SectionFilter <> '' or
            cl.Benefit like '%med%' -- claim on medical section
        ) and

        -- has medical cover
        (
            @EventFilter <> '' or
            @PerilFilter <> '' or
            @SectionFilter <> '' or
            (
                @EventFilter = '' and
                @PerilFilter = '' and
                @SectionFilter = '' and
                exists
                (
                    select null
                    from [db-au-cmdwh].dbo.Policy p
                    where 
                        p.PolicyKey = cl.PolicyKey and
                        p.MedicalPremium > 0
                )
            )
        )
        
    if not exists (select null from #result)
        insert into #result
        select 
            0 ClaimNo,
            '' Area,
            0 EMCAge,
            0 EMCNumber,
            '' Condition,
            '' ConditionStatus,
            0 ConditionScore,
            0 OverallScore,
            '' EventDescription,
            0 TotalValue,
            0 FirstEstimateValue,
            @rptStartDate StartDate,
            @rptEndDate EndDate

    select
        ClaimNo,
        Area,
        EMCAge,
        EMCNumber,
        Condition,
        ConditionStatus,
        ConditionScore,
        HealixRisk,
        MedicalRisk,
        EventDescription EventDesc,
        TotalValue,
        FirstEstimateValue,
        StartDate,
        EndDate
    from #result 
    
end
GO
