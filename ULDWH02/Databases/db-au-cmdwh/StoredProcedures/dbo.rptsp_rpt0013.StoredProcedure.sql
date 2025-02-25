USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0013]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt0013]
  @Country varchar(2),
  @FCCountry varchar(2) = null,
  @ReportingPeriod varchar(30),
  @StartDate varchar(10) = null,
  @EndDate varchar(10) = null

as
begin


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0013
--  Author:         Leonardus Setyabudi
--  Date Created:   20111201
--  Description:    This stored procedure returns FC KPI
--  Parameters:     @Country: Country code
--                  @FCCountry: Flight Centre Country Code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20111201 - LS - Created
--                  20120420 - LS - Kate J, include FLT0215 & FLT0216 in Island Force (IF)
--                  20130213 - LS - Case 18232, change policy date reference from CreateDate to IssuedDate
--					20140129 - LT - Migrated to Penguin
--					20140402 - LT - Changed ConsultantInitial to use FirstName + ' ' + LastName
--					20150317 - LT - F23419 - amend Consultant Count calculation to reflect STAR, Cube, & Dashboards
--					20161006 - LT - INC0017900  - fixed consultant linkage issue.
--												- changed date reference to PostingDate (in line with Universe)
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @FCCountry varchar(2)
declare @ReportingPeriod varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select 
    @Country = 'AU',
    @FCCountry = 'OY',
    @ReportingPeriod = '_User Defined', 
    @StartDate = '2016-10-01', 
    @EndDate = '2016-10-04'
*/

    set nocount on

    declare @rptStartDate smalldatetime
    declare @rptEndDate smalldatetime
    declare @workingDays int

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select 
            @rptStartDate = convert(smalldatetime,@StartDate), 
            @rptEndDate = convert(smalldatetime,@EndDate)

    else
        select 
            @rptStartDate = StartDate, 
            @rptEndDate = EndDate
        from 
            [db-au-cmdwh].dbo.vDateRange
        where 
            DateRange = @ReportingPeriod

    select @workingDays = count([Date])
    from 
        Calendar
    where 
        [Date] between @rptStartDate and @rptEndDate and
        isHoliday = 0 and
        isWeekDay = 1

    ;with cte_policies as
    (
        select
            a.AlphaCode as AgencyCode,
            a.OutletName as AgencyName,
            a.Branch,
            a.FCAreaCode as FLCountryCode,
            a.FCArea as FLCountryName,
            a.SubGroupName as AgencySubGroupName,
            isnull(u.FirstName + ' ' + u.LastName,'Cover-More CSR') as ConsultantInitial,
            case when p.TransactionType = 'Base' and p.TransactionStatus = 'Active' and u.ConsultantType = 'External' then p.UserKey else null end as ConvertedConsultant,
            sum(p.NewPolicyCount) as PolicyCount,
            sum(p.GrossPremium) as GrossSales,
            sum(p.Commission) as Commission
        from 
            penOutlet a
            inner join penPolicyTransSummary p on 
                p.OutletAlphaKey = a.OutletAlphaKey and
                a.OutletStatus = 'Current'
			outer apply
			(
				select top 1 FirstName, LastName, ConsultantType
				from penUser
				where UserKey = p.UserKey and UserStatus = 'Current'
			) u           
        where
            a.GroupCode = 'FL' and
            a.CountryKey = @Country and
            (
                a.FCAreaCode = isnull(@FCCountry, a.FCAreaCode) or
                (
                    @FCCountry = 'IF' and
                    (
                        a.FCAreaCode = @FCCountry or
                        a.AlphaCode in ('FLT0215', 'FLT0216')
                    )
                )
            ) and
            a.FCAreaCode is not null and
            a.FCAreaCode <> '' and
            a.FCArea is not null and
            a.FCArea <> '' and
            not      
            (
                a.OutletName like '%Test %' or
                a.OutletName like '% Test%' or
                a.OutletName like '%tester%' or
                a.OutletName like '%training%' or
                a.OutletName = 'test'
            ) and
            p.PostingDate >= @rptStartDate and
            p.PostingDate <  dateadd(day, 1, @rptEndDate)
        group by
            a.AlphaCode,
            a.OutletName,
            a.Branch,
            a.FCAreaCode,
            a.FCArea,
            a.SubGroupName,
            isnull(u.FirstName + ' ' + u.LastName,'Cover-More CSR'),
            case when p.TransactionType = 'Base' and p.TransactionStatus = 'Active' and u.ConsultantType = 'External' then p.UserKey else null end
    )
    select
        AgencyCode,
        AgencyName,
        AgencySubGroupName,
        Branch,
        FLCountryCode,
        FLCountryName,
        upper(ConsultantInitial) ConsultantInitial,
        PolicyCount,
        GrossSales,
        Commission,
        @workingDays WorkingDays,
        PolicyCount - @workingDays KPI,
        @rptStartDate StartDate, 
        @rptEndDate EndDate,
        a.AgencyConsultantCount,
        a.AgencyPolicyCount,
        a.AgencyGrossSales,
        a.AgencyCommission,
        a.AgencyAvgSales,
        a.AgencyAvgPolicy,
        a.AgencyKPI,
        c.CountryConsultantCount,
        c.CountryPolicyCount,
        c.CountryGrossSales,
        c.CountryCommission,
        c.CountryAvgSales,
        c.CountryAvgPolicy,
        c.CountryKPI,
        t.TotalConsultantCount,
        t.TotalPolicyCount,
        t.TotalGrossSales,
        t.TotalCommission,
        t.TotalAvgSales,
        t.TotalAvgPolicy,
        t.TotalKPI
    from 
        cte_policies p
        cross apply
        (
            select
                count(distinct ConvertedConsultant) AgencyConsultantCount,
                sum(PolicyCount) AgencyPolicyCount,
                sum(GrossSales) AgencyGrossSales,
                sum(Commission) AgencyCommission,
                case
                    when count(distinct ConvertedConsultant) = 0 then 0
                    else round(sum(GrossSales) * 1.0 / count(distinct ConvertedConsultant), 0)
                end AgencyAvgSales,
                case
                    when count(distinct ConvertedConsultant) = 0 then 0
                    else round(sum(PolicyCount) * 1.0 / count(distinct ConvertedConsultant), 0)
                end AgencyAvgPolicy,
                sum(PolicyCount) - count(distinct ConvertedConsultant) * @workingDays AgencyKPI
            from 
                cte_policies r
            where 
                r.AgencyCode = p.AgencyCode 
            group by 
                r.AgencyCode
        ) a
        cross apply
        (
            select
                count(ConvertedConsultant) CountryConsultantCount,
                sum(PolicyCount) CountryPolicyCount,
                sum(GrossSales) CountryGrossSales,
                sum(Commission) CountryCommission,
                case
                    when count(distinct ConvertedConsultant) = 0 then 0
                    else round(sum(GrossSales) * 1.0 / count(distinct ConvertedConsultant), 0)
                end CountryAvgSales,
                case
                    when count(distinct ConvertedConsultant) = 0 then 0
                    else round(sum(PolicyCount) * 1.0 / count(distinct ConvertedConsultant), 0)
                end CountryAvgPolicy,
                sum(PolicyCount) - count(distinct ConvertedConsultant) * @workingDays CountryKPI
            from 
                cte_policies r
            where 
                r.FLCountryCode = p.FLCountryCode 
            group by 
                r.FLCountryCode
        ) c
        cross apply
        (
            select
                count(distinct ConvertedConsultant) TotalConsultantCount,
                sum(PolicyCount) TotalPolicyCount,
                sum(GrossSales) TotalGrossSales,
                sum(Commission) TotalCommission,
                case
                    when count(distinct ConvertedConsultant) = 0 then 0
                    else round(sum(GrossSales) * 1.0 / count(distinct ConvertedConsultant), 0)
                end TotalAvgSales,
                case
                    when count(distinct ConvertedConsultant) = 0 then 0
                    else round(sum(PolicyCount) * 1.0 / count(distinct ConvertedConsultant), 0)
                end TotalAvgPolicy,
                sum(PolicyCount) - count(distinct ConvertedConsultant) * @workingDays TotalKPI
            from 
                cte_policies r
        ) t
    order by 
        FLCountryName,
        AgencyKPI desc,
        AgencyCode,
        KPI desc

end
GO
