USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0237]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0237]
  @Country varchar(2),
  @AgencyGroup varchar(2),
  @ReportingPeriod varchar(30),
  @StartDate varchar(10) = null,
  @EndDate varchar(10) = null
                   
as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0237
--  Author:         Leonardus Setyabudi
--  Date Created:   20111118
--  Description:    This stored procedure returns claims information including payment by claimant
--  Parameters:     @Country: Enter Country Code; e.g. AU
--                  @AgencyGroup: agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--   
--  Change History: 20111118 - LS - Created, changed from WEBI
--                  20120124 - LS - change cross apply to payment to outer apply
--                  20120501 - LS - minor formatting fix null values handling
--					20160830 - PZ - Include AHM (groupcode = 'AH') in Medibank (groupcode = 'MB') extract 
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
  @AgencyGroup = 'MB',
  @ReportingPeriod = 'Fiscal Year-To-Date', 
  @StartDate = null, 
  @EndDate = null
*/

  set nocount on

  declare @rptStartDate smalldatetime
  declare @rptEndDate smalldatetime

  /* get reporting dates */
  if @ReportingPeriod = '_User Defined'
    select 
      @rptStartDate = convert(smalldatetime,@StartDate), 
      @rptEndDate = convert(smalldatetime,@EndDate)
    
  else
    select 
      @rptStartDate = StartDate, 
      @rptEndDate = EndDate
    from [db-au-cmdwh].dbo.vDateRange
    where DateRange = @ReportingPeriod

	if object_id('tempdb..#agencygroup') is not null
        drop table #agencygroup

  /* clean up temp tables */

  select
    cl.ClaimNo,
    cl.ReceivedDate,
    cl.PolicyNo,
    cl.PolicyProduct,
    cl.PolicyPlanCode,
    case
      when p.AddOns <> '' then left(p.AddOns, len(p.AddOns) - 1)
      else ''
    end AddOns,
    p.NumberOfDays,
    p.Excess,
    p.NumberOfPersons,
    ce.PerilCode,
    ce.PerilDesc,
    ce.EventCountryName,
    ce.BenefitDesc,
    ce.EstimateValue,
    isnull(cp.Name, char(10)) Name,
    isnull(cp.Age, 0) Age,
    isnull(cp.PaymentAmount, 0) PaymentAmount,
    @rptStartDate StartDate,
    @rptEndDate EndDate
  from
    Agency a
    inner join clmClaim cl on 
      cl.AgencyCode = a.AgencyCode and 
      cl.CountryKey = a.CountryKey and
      a.AgencyStatus = 'Current'
    cross apply 
    (
      select
        case
          when MedicalPremium <> 0 then 'EMC, ' 
          else ''
        end +
        case
          when LuggagePremium <> 0 then 'Luggage, ' 
          else ''
        end +
        case
          when MotorcyclePremium <> 0 then 'Motorcycle, ' 
          else ''
        end +
        case
          when RentalCarPremium <> 0 then 'Rental Car, ' 
          else ''
        end +
        case
          when WinterSportPremium <> 0 then 'Winter Sport, ' 
          else ''
        end AddOns,
        p.NumberOfPersons,
        p.NumberOfDays,
        p.Excess,
        p.IssuedDate
      from Policy p
      where p.CountryPolicyKey = cl.PolicyKey
    ) p
    cross apply
    (
      select
        ce.PerilCode,
        ce.PerilDesc,
        ce.EventCountryName,
        cs.SectionKey,
        cb.BenefitDesc,
        cs.EstimateValue
      from 
        clmEvent ce
        inner join clmSection cs on cs.EventKey = ce.EventKey
        inner join clmBenefit cb on cb.BenefitSectionKey = cs.BenefitSectionKey
      where cl.ClaimKey = ce.ClaimKey
    ) ce
    outer apply
    (
      select 
        cn.Firstname + ' ' + cn.Surname Name,
        datediff(year, cn.DOB, p.IssuedDate) Age,
        sum(cp.PaymentAmount) PaymentAmount
      from 
        clmPayment cp
        inner join clmName cn on cn.NameKey = cp.PayeeKey
      where 
        cp.SectionKey = ce.SectionKey and
        cp.PaymentStatus in ('PAID', 'RECY')
      group by
        cn.Firstname + ' ' + cn.Surname,
        datediff(year, cn.DOB, p.IssuedDate)
    ) cp
  where
    a.CountryKey = @Country and
	a.AgencyGroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    cl.ReceivedDate >= @rptStartDate and 
    cl.ReceivedDate <  dateadd(day, 1, @rptEndDate)

end
GO
