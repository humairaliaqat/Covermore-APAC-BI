USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_claimsection]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rawsp_claimsection]
  @Country varchar(2),
  @AgencyGroup varchar(2),
  @DateRange varchar(30),
  @StartDate date = null,
  @EndDate date = null
  
as
begin  

/****************************************************************************************************/
--  Name:          rawsp_claimsection
--  Author:        Leonardus Setyabudi
--  Date Created:  20111024
--  Description:   This stored procedure extract claim's section data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL 
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History:  20111024 - LS - Created
--					 20160830 - PZ - Include AHM (groupcode = 'AH') in Medibank (groupcode = 'MB') extract 
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select 
  @Country = 'AU', 
  @AgencyGroup = 'MB',
  @DateRange = 'Yesterday'
*/

  set nocount on 
  
  declare @dataStartDate date
  declare @dataEndDate date

  /* get dates */
  if @DateRange = '_User Defined'
    select 
      @dataStartDate = @StartDate,
      @dataEndDate = @EndDate
    
  else
    select 
      @dataStartDate = StartDate, 
      @dataEndDate = EndDate
    from [db-au-cmdwh].dbo.vDateRange
    where DateRange = @DateRange


  select 
    cl.ClaimNo,
    cs.EventID,
    cs.SectionID,
    cs.SectionCode,
    cs.EstimateValue,
    cs.Redundant,
    cs.BenefitSectionID,
    cs.BenefitSubSectionID,
    cb.BenefitCode,
    cb.BenefitDesc,
    cb.ProductCode,
    cb.BenefitValidFrom,
    cb.BenefitValidTo,
    cb.BenefitLimit,
    cb.CommonCategory
  from 
    Agency a
    inner join clmClaim cl on cl.AgencyKey = a.AgencyKey
    inner join clmEvent ce on ce.ClaimKey = cl.ClaimKey
    inner join clmSection cs on cs.EventKey = ce.EventKey
    inner join clmBenefit cb on cb.BenefitSectionKey = cs.BenefitSectionKey
  where 
    a.CountryKey = @Country and
	a.AgencyGroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    a.AgencyStatus = 'Current' and
    ce.CreateDate >= @dataStartDate and 
    ce.CreateDate <  dateadd(day, 1, @dataEndDate)
    
  union
  
  select distinct
    cl.ClaimNo,
    cs.EventID,
    cs.SectionID,
    cs.SectionCode,
    cs.EstimateValue,
    cs.Redundant,
    cs.BenefitSectionID,
    cs.BenefitSubSectionID,
    cb.BenefitCode,
    cb.BenefitDesc,
    cb.ProductCode,
    cb.BenefitValidFrom,
    cb.BenefitValidTo,
    cb.BenefitLimit,
    cb.CommonCategory
  from 
    Agency a
    inner join clmClaim cl on cl.AgencyKey = a.AgencyKey
    inner join clmPayment cp on cp.ClaimKey = cl.ClaimKey
    inner join clmSection cs on cs.SectionKey = cp.SectionKey
    inner join clmBenefit cb on cb.BenefitSectionKey = cs.BenefitSectionKey
  where 
    a.CountryKey = @Country and
	a.AgencyGroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    a.AgencyStatus = 'Current' and
    cp.ModifiedDate >= @dataStartDate and 
    cp.ModifiedDate <  dateadd(day, 1, @dataEndDate) and
    cp.PaymentStatus in ('PAID', 'RECY')
  
end
GO
