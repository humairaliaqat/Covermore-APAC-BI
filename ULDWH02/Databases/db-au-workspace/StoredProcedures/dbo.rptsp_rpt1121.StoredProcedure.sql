USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1121]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rptsp_rpt1121]  

@Country varchar(20),  
@Company varchar(20),
@ReportingPeriod varchar(30),
@StartDate datetime = null,  
@EndDate datetime = null    
--@BankDate date = null  
  
   
as  
/****************************************************************************************************/  
--  Name:           dbo.rptsp_rpt1121  
--  Author:         Gitesh Shiraskar 
--  Date Created:   20200904  
--  Description:    This stored procedure is build for Credit Control Report 
--  Parameters:     @Country: Value is valid Country key  
--					@Company: Value is valid Compnay key 
--					@BankDate: Value is valid Bank date
--  Change History:    
--  
/****************************************************************************************************/    
BEGIN  
  
--Uncomment to Debug
  
--declare  
  
--@BankDate date = '2020-01-01',  
  
--@Country varchar(20) = 'AU',  
  
--@Company varchar(20 )= 'CM'  

    set nocount on  
  
    declare   
        @rptStartDate datetime,  
        @rptEndDate datetime 

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
 
 select distinct 
 penDomain.CountryKey as Country,
 penOutlet.GroupCode ,
 penOutlet.GroupName as GroupName,
 penOutlet.JV as JVName,
 penOutlet.AlphaCode,
 penOutlet.OutletName as AgencyName,
 penOutlet.PaymentType,
 penOutlet.AcctOfficerFirstName + penOutlet.AcctOfficerLastName as FinanceAdmin,  
 penPaymentRegisterTransaction.BankDate as Date,
 penPaymentRegister.PaymentType + penPaymentRegister.PaymentSource as TypeorSource,
 isnull(penCRMUser.UserName,N'') as CRMUser,
 penPaymentRegisterTransaction.Amount,
 penOutlet.FCAreaCode As AreaCode,
  @rptStartDate as startdate,
 @rptEndDate as enddate
 
 from [db-au-cmdwh].dbo.penPaymentRegisterTransaction   
 INNER JOIN [db-au-cmdwh].dbo.penPaymentRegister    on penPaymentRegister.PaymentRegisterId = penPaymentRegisterTransaction.PaymentRegisterId 
 AND penPaymentRegisterTransaction.[Status] = N'NEW'
 INNER JOIN [db-au-cmdwh].dbo.penOutlet   on penOutlet.OutletId = penPaymentRegister.OutletId --AND to1.FCAreaCode IN ( 'DC', 'OS', 'DD')
 INNER JOIN [db-au-cmdwh].dbo.penDomain   on  penDomain.DomainID = penOutlet.DomainID 
 LEFT JOIN [db-au-cmdwh].dbo.penCRMUser   on penCRMUser.CRMUserID = penPaymentRegister.CRMUserId
 where  
 isnull(penPaymentRegisterTransaction.PaymentAllocationId,0)= 0 
 AND --penPaymentRegisterTransaction.Bankdate  > @Bankdate  --'2020-01-01'
         penPaymentRegisterTransaction.Bankdate >= @rptStartDate and  
        penPaymentRegisterTransaction.Bankdate <  dateadd(day, 1, @rptEndDate)   

 AND penOutlet.CountryKey  IN  (@Country)  
 AND penOutlet.CompanyKey  IN  (@Company)     
 order by penDomain.CountryKey ,penOutlet.GroupCode, penOutlet.JV, penOutlet.AlphaCode,  penPaymentRegisterTransaction.BankDate
 END

 


 


GO
