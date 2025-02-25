USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0212]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0212]  
    @Country varchar(2),
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @EventFilter varchar(512) = null,
    @PerilFilter varchar(3) = null,
    @SectionFilter varchar(2) = null
                    
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0212
--  Author:         Leonardus Setyabudi
--  Date Created:   20110823
--  Description:    This stored procedure returns list of Claims due to EMC add-on
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. Format YYYY-MM-DD eg. 2010-01-01
--  
--  Change History: 20110823 - LS - Created
--                  20110825 - LS - wrong report number
--                  20110829 - LS - total value should be aggregated
--                                - changed condition from assumption that if there's an EMC assessment
--                                  then it has EMC add-on. Not always true.
--                                  changed to filter on medical premium not 0  
--                  20111124 - LS - change PolicyEMCID to ClientID
--                                - add event description
--                                - add emc condition and acceptance status
--                                - due to all additional fields above, report changed to grouping in CR
--                  20120518 - LS - add condition score & overall score, case 17411
--                  20120829 - LS - change to use rolled up emc tables instead of wills
--                                  add event filter (case 17828)
--                  20120912 - LS - add peril & section filter
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
        isnull(emc.EMCNumber, '') EMCNumber,
        isnull(emc.Condition, '') Condition,
        isnull(emc.ConditionStatus, '') ConditionStatus,
        isnull(emc.ConditionScore, 0) ConditionScore,
        isnull(emc.OverallScore, 0) OverallScore,
        ce.EventDesc,        
        cs.TotalValue,
        @rptStartDate StartDate,
        @rptEndDate EndDate
    into #result
    from 
        clmClaim cl
        inner join clmEvent ce on 
            ce.ClaimKey = cl.ClaimKey
        cross apply
        (
            select 
                cs.SectionCode,
                cs.EstimateValue +
                isnull(
                    (
                        select 
                            sum(PaymentAmount)
                        from 
                            [db-au-cmdwh].dbo.clmPayment cp
                        where 
                            cp.SectionKey = cs.SectionKey and
                            cp.PaymentStatus = 'PAID'
                    ),
                    0
                ) TotalValue
            from 
                clmSection cs
                inner join clmBenefit cb on 
                    cb.BenefitSectionKey = cs.BenefitSectionKey
            where 
                cs.EventKey = ce.EventKey and
                (
                    @EventFilter <> '' or
                    @PerilFilter <> '' or
                    @SectionFilter <> '' or
                    BenefitDesc like '%med%' -- claim on medical section
                )
        ) cs
        outer apply
        (
            select 
                pe.ClientID EMCNumber,
                m.Condition,
                m.ConditionStatus,
                m.MedicalScore ConditionScore,
                sum(
                    case
                        when m.ConditionStatus = 'Approved' then isnull(m.MedicalScore, 0)
                        else 0
                    end
                ) over () OverallScore
            from 
                PolicyEMC pe
                inner join emcApplications e on
                    patindex('%[^0-9]%', pe.ClientID) = 0 and
                    e.ApplicationID = pe.ClientID and
                    e.CountryKey = pe.CountryKey
                inner join emcMedical m on
                    m.ApplicationKey = e.ApplicationKey and
                    m.ConditionStatus in ('Approved', 'Denied')
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
        cl.CreateDate between @rptStartDate and @rptEndDate and
        ce.EventDesc like '%' + @EventFilter + '%' and
        ce.PerilCode like @PerilFilter + '%' and
        cs.SectionCode like @SectionFilter + '%' and

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
                        p.CountryPolicyKey = cl.PolicyKey and
                        p.MedicalPremium > 0
                )
            )
        )
        
    if not exists (select null from #result)
        insert into #result
        select 
            0 ClaimNo,
            0 EMCNumber,
            '' Condition,
            '' ConditionStatus,
            0 ConditionScore,
            0 OverallScore,
            '' EventDesc,        
            0 TotalValue,
            @rptStartDate StartDate,
            @rptEndDate EndDate
        
    select
        ClaimNo,
        EMCNumber,
        Condition,
        ConditionStatus,
        ConditionScore,
        OverallScore,
        EventDesc,        
        TotalValue,
        StartDate,
        EndDate
    from #result 
    
end
GO
