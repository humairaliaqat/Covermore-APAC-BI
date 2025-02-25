USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1119]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[rptsp_rpt1119]

--@StartDate date = null,

@Country varchar(20),
@Company varchar(20),
@ReportingPeriod varchar(30),
@StartDate datetime = null,  
@EndDate datetime = null  
as

begin

--debug

--declare

--@StartDate varchar(10) = '2020-01-01',

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

penOutlet.CountryKey as Country,

penOutlet.CompanyKey as Company,

penOutlet.GroupCode ,

penOutlet.GroupName ,

penOutlet.jv as JVName,

penOutlet.AlphaCode ,

penOutlet.OutletName ,

tpr.PaymentType as PaymentType,

penOutlet.AcctOfficerFirstName + penOutlet.AcctOfficerLastName as FinanceAdmin,

tprt.BankDate as BankDate,

tpr.PaymentType + '/' + tpr.PaymentSource as TypeorSource,

isnull(tcu.UserName,N'') as CRMUser,

tprt.Status as PaymentRegisterTxStatus,

tprt.Amount,

tpr.Comment as PaymentRegisterComment,

tprt.Comment as PaymentREgisterTxComment,
@rptStartDate as startdate,
@rptEndDate as enddate


FROM

[db-au-cmdwh].dbo.penPaymentRegisterTransaction tprt

  INNER JOIN [db-au-cmdwh].dbo.penPaymentRegister tpr ON (tpr.PaymentRegisterKey=tprt.PaymentRegisterKey)
  AND tprt.Status != N'DONE'

  AND tpr.PaymentCode = 'DDT'

  LEFT OUTER JOIN [db-au-cmdwh].dbo.penOutlet ON (penOutlet.OutletKey=tpr.OutletKey)

  INNER JOIN [db-au-cmdwh].dbo.penCRMUser  tcu ON (tpr.CRMUserKey=tcu.CRMUserKey)

WHERE

isnull(tprt.PaymentAllocationId,0)= 0 AND

-- tprt.BankDate > @StartDate

 tprt.Bankdate >= @rptStartDate and    tprt.Bankdate <  dateadd(day, 1, @rptEndDate)   

AND penOutlet.CountryKey  IN  (@Country)

AND

   penOutlet.CompanyKey  IN  (@Company)

   AND

   ( isnull(penOutlet.OutletStatus, 'Current') = 'Current'  )




end







GO
