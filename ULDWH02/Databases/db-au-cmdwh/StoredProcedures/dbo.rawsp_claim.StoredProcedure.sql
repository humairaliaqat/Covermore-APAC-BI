USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_claim]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_claim]
  @Country varchar(2),
  @AgencyGroup varchar(2),
  @DateRange varchar(30),
  @StartDate date = null,
  @EndDate date = null
  
as
begin  

/****************************************************************************************************/
--  Name:          rawsp_claim
--  Author:        Leonardus Setyabudi
--  Date Created:  20111024
--  Description:   This stored procedure extract claim data for given parameters
--  Parameters:    @Country: Country Code; e.g. AU
--                 @AgencyGroup: Agency group code; e.g. AP, FL 
--                 @DateRange: Value is valid date range
--                 @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                 @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History:  20111024 - LS - Created
--					 20111126 - LS - Add Agency Code
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
    a.CountryKey,
    cl.ClaimNo,
    cl.PolicyNo,
	cl.AgencyCode,
    cl.ReceivedDate,
    cl.CreateDate,
    cl.CreatedBy,
    cl.StatusDesc,
    cl.Authorisation,
    cl.FinalisedDate,
    cl.OnlineClaim,
    cl.IntDom,
    cl.Excess,
    cl.SingleFamily,
    cl.ITCPremium,
    cl.LuggageFlag,
    cl.HRisk,
    convert(varchar(4096), cl.Comment) [Comment],
    cl.RecoveryType,
    cl.RecoveryTypeDesc,
    cl.RecoveryOutcome,
    cl.RecoveryOutcomeDesc
  from 
    Agency a
    inner join clmClaim cl on cl.AgencyKey = a.AgencyKey
  where 
    a.CountryKey = @Country and
	a.AgencyGroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    a.AgencyStatus = 'Current' and
    (
      (
        cl.CreateDate >= @dataStartDate and 
        cl.CreateDate <  dateadd(day, 1, @dataEndDate)
      ) or
      (
        cl.FinalisedDate >= @dataStartDate and 
        cl.FinalisedDate <  dateadd(day, 1, @dataEndDate)
      )
    )
    
end
GO
