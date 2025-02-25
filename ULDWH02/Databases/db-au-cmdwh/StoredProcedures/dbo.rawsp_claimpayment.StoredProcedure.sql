USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_claimpayment]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_claimpayment]
  @Country varchar(2),
  @AgencyGroup varchar(2),
  @DateRange varchar(30),
  @StartDate date = null,
  @EndDate date = null
  
as
begin  

/****************************************************************************************************/
--  Name:          rawsp_claimpayment
--  Author:        Leonardus Setyabudi
--  Date Created:  20111024
--  Description:   This stored procedure extract claim's payment data for given parameters
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
    cp.EventID,
    cp.SectionID,
    cp.PaymentID,
    cp.AddresseeID NameID,
    cp.ProviderID,
    cp.CreatedDate,
    cp.ModifiedDate,
    cp.Method,
    cp.BillAmount,
    cp.CurrencyCode,
    cp.GST,
    cp.PaymentAmount,
    cp.ExcessAmount,
    cp.PaymentStatus
  from 
    Agency a
    inner join clmClaim cl on cl.AgencyKey = a.AgencyKey
    inner join clmPayment cp on cp.ClaimKey = cl.ClaimKey
  where 
    a.CountryKey = @Country and
	a.AgencyGroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    a.AgencyStatus = 'Current' and
    cp.ModifiedDate >= @dataStartDate and 
    cp.ModifiedDate <  dateadd(day, 1, @dataEndDate)
  
end
GO
