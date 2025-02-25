USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1122]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt1122]  
@Country varchar(20),  
--@DateRange varchar(30),  
@ReportingPeriod varchar(30),
@StartDate datetime = null,  
@EndDate datetime = null 

  
--@Company varchar(20)  
  
As
/****************************************************************************************************/  
--  Name:           dbo.rptsp_rpt1122  
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
/*  
declare @Country varchar(10)  
--declare @DateRange varchar(30)  
declare @StartDate varchar(10)  
declare @EndDate varchar(10)  
select @Country = 'AU', @DateRange = 'Last Fiscal Month', @StartDate = NULL, @EndDate = NULL  
*/  
  
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


SELECT CASE penOutlet.DomainID WHEN 7 THEN 'AU' WHEN 8 THEN 'NZ' ELSE 'Other' END AS Domain, 
penOutlet.CountryKey As Country,
penOutlet.GroupCode AS GroupCode,
penOutlet.JV as JVName,
penOutlet.AlphaCode, 
penOutlet.OutletName,
penPolicy.PolicyNumber, 
CASE penPolicy.StatusCode WHEN 2 THEN 'Cancelled' ELSE 'Active'  END AS PolicyStatus,
penPolicyTransaction.Policynumber as TxNumber,
penPolicyTransaction.TransactionStatus as TxStatus, 
penPolicyTransaction.GrossPremium, 
penPolicyTransaction.TotalNet,
penPolicyTransaction.TotalCommission , 
CASE  WHEN Month(penPolicyTransaction.AccountingPeriod)=1 THEN 'January' WHEN Month(penPolicyTransaction.AccountingPeriod)=2 THEN 'February' WHEN Month(penPolicyTransaction.AccountingPeriod)=3 THEN 'March' WHEN Month(penPolicyTransaction.AccountingPeriod)=4 THEN 'April' WHEN Month(penPolicyTransaction.AccountingPeriod)=5 THEN 'May' 
WHEN Month(penPolicyTransaction.AccountingPeriod)=6 THEN 'June' WHEN Month(penPolicyTransaction.AccountingPeriod)=7 THEN 'July' WHEN Month(penPolicyTransaction.AccountingPeriod)=8 THEN 'August' WHEN Month(penPolicyTransaction.AccountingPeriod)=9 THEN 'September' WHEN Month(penPolicyTransaction.AccountingPeriod)=10 THEN 'October' 
WHEN Month(penPolicyTransaction.AccountingPeriod)=11 THEN 'November' WHEN Month(penPolicyTransaction.AccountingPeriod)=12 THEN 'December' ELSE 'NA' END AS AccountingPeriod, 
penPolicyTransaction.AllocationNumber,                                                                                                      
 CASE WHEN ISNULL(penPayment.PolicyTransactionId, 0) > 0  THEN 'Creditcard' WHEN ISNULL(penpolicycreditnote.redeempolicyid, 0) > 0  THEN 'CreditNote' ELSE  'Other' END AS Payment, 
 CASE ISNULL(penpolicycreditnote2.OriginalPolicyId, 0) WHEN 0 THEN 'No' ELSE 'CreditNoteIssued' END AS CreditNoteIssued,
penpolicycreditnote.[Status] AS RedeemStatus, 
penOutlet.BSB,
penOutlet.FCAreaCode,
 @rptStartDate as startdate,
 @rptEndDate as enddate

FROM [db-au-cmdwh].dbo.penPolicy (NOLOCK)    
INNER JOIN [db-au-cmdwh].dbo.penPolicyTransaction (NOLOCK) penPolicyTransaction  
ON penPolicy.PolicyID = penPolicyTransaction.PolicyID --AND penPolicy.DomainID = 7
AND ISNULL(penPolicyTransaction.AllocationNumber, 0) = 0  
LEFT JOIN [db-au-cmdwh].dbo.penPayment   (NOLOCK) ON penPayment.PolicyTransactionId = penPolicyTransaction.PolicyTransactionId
LEFT JOIN [db-au-cmdwh].dbo.penpolicycreditnote  (NOLOCK) ON penpolicycreditnote.redeempolicyid = penPolicy.PolicyID
LEFT JOIN [db-au-cmdwh].dbo.penpolicycreditnote penpolicycreditnote2 (NOLOCK) ON penpolicycreditnote2.OriginalPolicyId = penPolicy.PolicyID
INNER JOIN [db-au-cmdwh].dbo.penOutlet (NOLOCK) penOutlet ON penOutlet.AlphaCode = penPolicy.AlphaCode 
--INNER JOIN [db-au-cmdwh].dbo.Calendar    ON (penPolicyTransaction.AccountingPeriod=Calendar.Date)  
-- INNER JOIN [db-au-cmdwh].dbo.vDateRange    ON (Calendar.Date between vDateRange.StartDate and vDateRange.EndDate) 
WHERE 
--penPolicyTransaction.AccountingPeriod IN ('2020-01-31 00:00:00.000', '2020-02-28 00:00:00.000', '2020-03-31 00:00:00.000', '2020-04-30 00:00:00.000', '2020-05-31 00:00:00.000', '2020-06-30 00:00:00.000','2020-07-31 00:00:00.000','2020-08-31 00:00:00.000')
 penOutlet.CountryKey  IN  (@Country) 
 AND --penPolicyTransaction.AccountingPeriod BETWEEN @StartDate AND @EndDate
  penPolicyTransaction.AccountingPeriod >= @rptStartDate and  
        penPolicyTransaction.AccountingPeriod <  dateadd(day, 1, @rptEndDate) 
--AND vDateRange.DateRange = @DateRange  
--AND vDateRange.StartDate  =  @rptStartDate  
--AND vDateRange.EndDate  =  @rptEndDate  
--AND penOutlet.CompanyKey  IN  (@Company)  
ORDER BY penOutlet.domainid, penOutlet.Groupcode, penOutlet.JV, penOutlet.Alphacode, penPolicyTransaction.AccountingPeriod,penPolicy.PolicyNumber,
 penPolicyTransaction.PolicyNumber
END

GO
