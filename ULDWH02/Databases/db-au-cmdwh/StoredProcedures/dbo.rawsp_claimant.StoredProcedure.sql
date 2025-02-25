USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_claimant]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rawsp_claimant]
  @Country varchar(2),
  @AgencyGroup varchar(2),
  @DateRange varchar(30),
  @StartDate date = null,
  @EndDate date = null
  
as
begin  

/****************************************************************************************************/
--  Name:          rawsp_claimant
--  Author:        Leonardus Setyabudi
--  Date Created:  20111024
--  Description:   This stored procedure extract claimant data for given parameters
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
    cn.NameID,
    cn.Num,
    cn.Title,
    cn.Firstname,
    cn.Surname,
    cn.DOB,
    cn.AddressStreet,
    cn.AddressSuburb,
    cn.AddressState,
    cn.AddressCountry,
    cn.AddressPostCode,
    cn.HomePhone,
    cn.WorkPhone,
    cn.Fax,
    cn.Email,
    isnull(cn.isPrimary, 0) isPrimary,
    isnull(cn.isPayer, 0) isPayer,
    isnull(cn.isDirectCredit, 0) isDirectCredit,
    isnull(cn.isThirdParty, 0) isThirdParty,
    isnull(cn.isForeign, 0) isForeign,
    isnull(cn.isEmailOK, 0) isEmailOK,
    isnull(cn.isGST, 0) isGST,
    isnull(cn.GoodsSupplier, 0) isGoodsSupplier,
    isnull(cn.ServiceProvider, 0) isServiceProvider,
    cn.ProviderID,
    cn.BusinessName,
    cn.PaymentMethodID,
    cn.EMC,
    cn.ITC,
    cn.ITCPCT,
    cn.GSTPercentage
  from 
    Agency a
    inner join clmClaim cl on cl.AgencyKey = a.AgencyKey
    inner join clmName cn on cn.ClaimKey = cl.ClaimKey
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
    
  union
  
  select 
    cl.ClaimNo,
    cn.NameID,
    cn.Num,
    cn.Title,
    cn.Firstname,
    cn.Surname,
    cn.DOB,
    cn.AddressStreet,
    cn.AddressSuburb,
    cn.AddressState,
    cn.AddressCountry,
    cn.AddressPostCode,
    cn.HomePhone,
    cn.WorkPhone,
    cn.Fax,
    cn.Email,
    isnull(cn.isPrimary, 0) isPrimary,
    isnull(cn.isPayer, 0) isPayer,
    isnull(cn.isDirectCredit, 0) isDirectCredit,
    isnull(cn.isThirdParty, 0) isThirdParty,
    isnull(cn.isForeign, 0) isForeign,
    isnull(cn.isEmailOK, 0) isEmailOK,
    isnull(cn.isGST, 0) isGST,
    isnull(cn.GoodsSupplier, 0) isGoodsSupplier,
    isnull(cn.ServiceProvider, 0) isServiceProvider,
    cn.ProviderID,
    cn.BusinessName,
    cn.PaymentMethodID,
    cn.EMC,
    cn.ITC,
    cn.ITCPCT,
    cn.GSTPercentage
  from 
    Agency a
    inner join clmClaim cl on cl.AgencyKey = a.AgencyKey
    inner join clmPayment cp on cp.ClaimKey = cl.ClaimKey
    inner join clmName cn on cn.Namekey = cp.PayeeKey
  where 
    a.CountryKey = @Country and
	a.AgencyGroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
    a.AgencyStatus = 'Current' and
    cp.ModifiedDate >= @dataStartDate and 
    cp.ModifiedDate <  dateadd(day, 1, @dataEndDate) and
    cp.PaymentStatus in ('PAID', 'RECY')
  
end
GO
