USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_RefundWorkingGroup]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_RefundWorkingGroup]
 
@Country varchar(20),  
--@Company varchar(20),
@Status varchar(30),
@AlphaCode varchar(30) = null,
@ReportingPeriod varchar(30),
@StartDate datetime = null,  
@EndDate datetime = null  
----Uncomment to debug
--DECLARE 
--@Country varchar(20) ='AU',  
----@Company varchar(20)='CM',
--@Status varchar(30)='ACTIVE',
--@AlphaCode varchar(30) = 'ALL',
--@ReportingPeriod varchar(30)='Current Quarter',
--@StartDate datetime = '2020-11-01',  
--@EndDate datetime = '2020-11-30'   
As
Begin

set nocount on  

IF @Alphacode = 'ALL'
BEGIN
SET @Alphacode = NULL;
END
ELSE
BEGIN
SET @Alphacode=@Alphacode;
END

  
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
---------------------------------------------------------------------------------------
--print @rptStartDate ;print @rptEndDate ;
----------------------------------------------------------------------------------------	
		IF OBJECT_ID('tempdb..#ACTIVETRANS') IS NOT NULL 
				DROP TABLE #ACTIVETRANS

  SELECT A.PolicyID, 
A.PolicyKey,
Policytransactionkey,
max(TransactionDateTime) over (partition by A.policykey) As TransactionDate,
Sum(GrossPremium) over (partition by A.policykey) as 'GrossPremium' ,
Sum (TotalCommission) over (partition by A.policykey)as 'TotalCommission',
Sum (TotalNet) over (partition by A.policykey) as 'TotalNet', 
MAX (PaymentMode) over (partition by A.policykey) AS PaymentMode,
MAX(PaymentGatewayID) over (partition by A.policykey) AS  PaymentGatewayID
       
INTO #ACTIVETRANS

FROM [db-au-cmdwh].dbo.penPolicyTransaction A
--LEFT OUTER JOIN [db-au-cmdwh].dbo.penpolicy pol on A.policykey=pol.policykey
OUTER APPLY 
(
    select  TOP 1 PaymentGatewayID
    from
            [db-au-cmdwh]..Penpayment p with(nolock) 
    WHERE
            p.PolicyTransactionKey = A.PolicyTransactionKey			
)p
WHERE TransactionStatusID  NOT IN ('2','3') 
and TransactionStatus is not NULL
AND (PaymentMode <> 'CreditNote'OR PaymentMode IS NULL)  -- excludes redeemed policies issued on credit
and  A.CountryKey = (@Country) --and A.CompanyKey = (@Company)
--and (pol.AlphaCode = @AlphaCode OR @AlphaCode IS NULL)
--and pol.tripstart >= @rptStartDate and 
--	pol.tripstart <  dateadd(day, 1, @rptEndDate)
--  and pol.TripType ='Single Trip'  
GROUP BY 
A.Policykey,
A.PolicyID,
Policytransactionkey,
TransactionDateTime,
PaymentMode,PaymentGatewayID, 
GrossPremium,
TotalCommission,
TotalNet 


IF OBJECT_ID('tempdb..#CANCELLEDTRANS') IS NOT NULL 
				DROP TABLE #CANCELLEDTRANS

  
SELECT distinct A.PolicyID, 
A.PolicyKey,
Policytransactionkey,
max(TransactionDateTime) over (partition by A.policykey) As CancellationDate,
Sum(GrossPremium) over (partition by A.policykey) as 'GrossPremiumCancel' ,
Sum (TotalCommission) over (partition by A.policykey)as 'TotalCommissionCancel',
Sum (TotalNet) over (partition by A.policykey) as 'TotalNetCancel', 
MAX (PaymentMode) over (partition by A.policykey) AS PaymentMode,
MAX(PaymentGatewayID) over (partition by A.policykey) AS  PaymentGatewayIDCancel

INTO #CANCELLEDTRANS
FROM [db-au-cmdwh].dbo.penPolicyTransaction A 
--LEFT OUTER JOIN [db-au-cmdwh].dbo.penpolicy pol on A.policykey=pol.PolicyKey
OUTER APPLY 
(
    select  TOP 1 PaymentGatewayID
      --  select top 5 *    
    from
            [db-au-cmdwh]..Penpayment p with(nolock) --WHERE OutletSKey=374268
    WHERE
            p.PolicyTransactionKey = A.PolicyTransactionKey
			
)p
WHERE TransactionStatusID IN ('2','3') 
and TransactionStatus is not NULL
AND (PaymentMode <> 'CreditNote'OR PaymentMode IS NULL)  -- excludes redeemed policies issued on credit
--and  CountryKey in('AU','NZ')
and  A.CountryKey = (@Country) --and A.CompanyKey = (@Company)
--and (pol.AlphaCode = @AlphaCode OR @AlphaCode IS NULL)
--and pol.tripstart >= @rptStartDate and 
--	pol.tripstart <  dateadd(day, 1, @rptEndDate)
--  and pol.TripType ='Single Trip'   
GROUP BY 
A.Policykey,
A.PolicyID,
Policytransactionkey,
TransactionDateTime,
PaymentMode,PaymentGatewayID, 
GrossPremium,
TotalCommission,
TotalNet


 IF @Status = 'ACTIVE'
 BEGIN

	IF OBJECT_ID('tempdb..#ACTIVE') IS NOT NULL 
				DROP TABLE #ACTIVE


  SELECT DISTINCT  
    a.Countrykey,
	a.CompanyKey,
    a.PolicyNumber
    ,a.StatusDescription as PolicyStatusDescription
    ,b.Firstname
    ,b.LastName
    ,a.IssueDate
    ,A.TripStart AS DepartureDate
	,format(A.TripStart,'MMM','en-US') as DepartureMonth
    ,PolicyStart
    ,PolicyEnd
    ,a.MultiDestination AS Destination
    ,E.GrossPremium
    ,E.TotalCommission  AS TotalCommission
    ,E.TotalNet
    ,(E.GrossPremium + G.GrossPremiumCancel) as ResidualPremiumGross
	,(E.TotalNet+G.TotalNetCancel) as ResidualPremiumNett
	,(E.TotalCommission+G.TotalCommissionCancel) as ResidualCommission
	,b.EmailAddress
    ,b.MobilePhone
    ,AlphaCode
     ,isnull(do.[Outlet Name], o.[Outlet Name]) as OutletName
     , case
        when isnull(do.[Outlet Super Group], '') = '' and isnull(o.[Outlet Super Group], '') = '' then o.[Outlet Group Name]
        when isnull(do.[Outlet Super Group], '') = '' and isnull(o.[Outlet Super Group], '') <> '' then o.[Outlet Super Group]
        else do.[Outlet Super Group] 
    end OutletSuperGroup
       ,isnull(do.[Outlet Sub Group Name], o.[Outlet Sub Group Name]) as OutletSubGroupName
    ,tripType AS TripType
    ,isnull(do.[JV Code], o.[JV Code]) as  JVCode
    --,c.AddonGroup 
	--,d.PayStatus
    ,D.StatusDesc
    ,CS.CatastropheCode 
    ,E.PaymentMode
	,E.TransactionDate
	,@rptStartDate as StartDate
	,@rptEndDate as EndDate
    INTO #Active

    FROM [db-au-cmdwh].dbo.PenPolicy a WITH (NOLOCK)
	

	
	INNER JOIN #ACTIVETRANS  E  WITH (NOLOCK) ON  A.Policykey=E.Policykey
	--INNER JOIN #T4  G  WITH (NOLOCK) ON  A.Policykey=G.Policykey
	LEFT JOIN #CANCELLEDTRANS  G  WITH (NOLOCK) ON  A.Policykey=G.Policykey

     OUTER APPLY 
            (
             SELECT TOP 1 StatusDesc FROM [db-au-cmdwh].[dbo].clmclaim D     WHERE  A.PolicyNumber=d.PolicyNo
             ) D
     OUTER APPLY 
            (
             SELECT TOP 1 CatastropheCode FROM [db-au-cmdwh].dbo.clmclaimSummary CS    
			 WHERE A.PolicyNumber=CS.PolicyNo
             ) CS  
    CROSS apply 
        (SELECT TOP 1  b.Firstname
          ,b.LastName
          ,b.EmailAddress
          ,MobilePhone
          FROM [db-au-cmdwh].dbo.penPolicyTraveller b  WITH (NOLOCK) WHERE a.[Policykey]=b.[PolicyKey] AND ISNULL(B.FirstName,'')<>''
        ) B

outer apply
    (
        select top 1 
            do.OutletName [Outlet Name],
            do.SubGroupCode [Outlet Sub Group Code],
            do.SubGroupName [Outlet Sub Group Name],
            do.GroupCode [Outlet Group Code],
            do.GroupName [Outlet Group Name],
            do.SuperGroupName [Outlet Super Group],
            do.Channel [Outlet Channel],
            do.BDMName [Outlet BDM],
            do.ContactPostCode [Outlet Post Code],
            do.StateSalesArea [Outlet Sales State Area],
            do.TradingStatus [Outlet Trading Status],
            do.OutletType [Outlet Type],
            do.JV [JV Code],
            do.JVDesc [JV Description]
        from
            [db-au-star].[dbo].dimOutlet do with(nolock) --WHERE OUTLETSK=374268
        where
            do.AlphaCOde = a.AlphaCOde and
            do.isLatest = 'Y'
    ) do
    outer apply
    (
        select  top 1 
            o.OutletName [Outlet Name],
            o.SubGroupCode [Outlet Sub Group Code],
            o.SubGroupName [Outlet Sub Group Name],
            o.GroupCode [Outlet Group Code],
            o.GroupName [Outlet Group Name],
            o.SuperGroupName [Outlet Super Group],
            '' [Outlet Channel],
            o.BDMName [Outlet BDM],
            o.ContactPostCode [Outlet Post Code],
            o.StateSalesArea [Outlet Sales State Area],
            o.TradingStatus [Outlet Trading Status],
            o.OutletType [Outlet Type],
            o.JVCode [JV Code],
            o.JV [JV Description] 
        from
            [db-au-cmdwh]..penOutlet o with(nolock)--WHERE OutletSKey=374268
        where
            o.AlphaCOde = a.AlphaCOde and
            o.OutletStatus = 'Current'
    ) o

  WHERE
   A.StatusDescription = 'ACTIVE' and
	A.tripstart >= @rptStartDate and 
	A.tripstart <  dateadd(day, 1, @rptEndDate)
	--A.tripstart between '2020-03-24' and '2020-12-17'
  and  A.CountryKey = (@Country) --and A.CompanyKey = (@Company)
  and A.TripType ='Single Trip' 
  and (A.AlphaCode = @AlphaCode OR @AlphaCode IS NULL)

END

ELSE
  
BEGIN
		
	IF OBJECT_ID('tempdb..#CANCELLED') IS NOT NULL 
				DROP TABLE #CANCELLED
  
  SELECT DISTINCT  
    a.Countrykey,
	a.CompanyKey,
    a.PolicyNumber
    ,a.StatusDescription as PolicyStatusDescription
    ,b.Firstname
    ,b.LastName
    ,a.IssueDate
    ,A.TripStart AS DepartureDate
	,format(A.TripStart,'MMM','en-US') as DepartureMonth
    ,PolicyStart
    ,PolicyEnd
    ,a.MultiDestination AS Destination
	,G.GrossPremiumCancel as GrossPremium
    ,G.TotalCommissionCancel  as TotalCommission
    ,G.TotalNetCancel as TotalNet
    ,(E.GrossPremium + G.GrossPremiumCancel) as ResidualPremiumGross
	,(E.TotalNet+G.TotalNetCancel) as ResidualPremiumNett
	,(E.TotalCommission+G.TotalCommissionCancel) as ResidualCommission
	,b.EmailAddress
    ,b.MobilePhone
    ,AlphaCode
     ,isnull(do.[Outlet Name], o.[Outlet Name]) as OutletName
     , case
        when isnull(do.[Outlet Super Group], '') = '' and isnull(o.[Outlet Super Group], '') = '' then o.[Outlet Group Name]
        when isnull(do.[Outlet Super Group], '') = '' and isnull(o.[Outlet Super Group], '') <> '' then o.[Outlet Super Group]
        else do.[Outlet Super Group] 
    end OutletSuperGroup
       ,isnull(do.[Outlet Sub Group Name], o.[Outlet Sub Group Name]) as  OutletSubGroupName
    ,tripType AS TripType
    ,isnull(do.[JV Code], o.[JV Code]) as  JVCode
    --,c.AddonGroup 
	--,d.PayStatus
    ,D.StatusDesc
    ,CS.CatastropheCode 
	,G.PaymentMode 
	,G.CancellationDate
	,@rptStartDate as StartDate
	,@rptEndDate as EndDate

    INTO #CANCELLED

    FROM [db-au-cmdwh].dbo.PenPolicy a WITH (NOLOCK)
	
   INNER JOIN #CANCELLEDTRANS  G  WITH (NOLOCK) ON  A.Policykey=G.Policykey

	
	LEFT JOIN #ACTIVETRANS  E  WITH (NOLOCK) ON  A.Policykey=E.Policykey

	

     OUTER APPLY 
            (
             SELECT TOP 1 StatusDesc FROM [db-au-cmdwh].[dbo].clmclaim D     WHERE  A.PolicyNumber=d.PolicyNo
             ) D
     OUTER APPLY 
            (
             SELECT TOP 1 CatastropheCode FROM [db-au-cmdwh].dbo.clmclaimSummary CS    
			 WHERE A.PolicyNumber=CS.PolicyNo
             ) CS  
    CROSS apply 
        (SELECT TOP 1  b.Firstname
          ,b.LastName
          ,b.EmailAddress
          ,MobilePhone
          FROM [db-au-cmdwh].dbo.penPolicyTraveller b  WITH (NOLOCK) WHERE a.[Policykey]=b.[PolicyKey] AND ISNULL(B.FirstName,'')<>''
        ) B

outer apply
    (
        select top 1 
            do.OutletName [Outlet Name],
            do.SubGroupCode [Outlet Sub Group Code],
            do.SubGroupName [Outlet Sub Group Name],
            do.GroupCode [Outlet Group Code],
            do.GroupName [Outlet Group Name],
            do.SuperGroupName [Outlet Super Group],
            do.Channel [Outlet Channel],
            do.BDMName [Outlet BDM],
            do.ContactPostCode [Outlet Post Code],
            do.StateSalesArea [Outlet Sales State Area],
            do.TradingStatus [Outlet Trading Status],
            do.OutletType [Outlet Type],
            do.JV [JV Code],
            do.JVDesc [JV Description]
        from
            [db-au-star].[dbo].dimOutlet do with(nolock) --WHERE OUTLETSK=374268
        where
            do.AlphaCOde = a.AlphaCOde and
            do.isLatest = 'Y'
    ) do
    outer apply
    (
        select  top 1 
            o.OutletName [Outlet Name],
            o.SubGroupCode [Outlet Sub Group Code],
            o.SubGroupName [Outlet Sub Group Name],
            o.GroupCode [Outlet Group Code],
            o.GroupName [Outlet Group Name],
            o.SuperGroupName [Outlet Super Group],
            '' [Outlet Channel],
            o.BDMName [Outlet BDM],
            o.ContactPostCode [Outlet Post Code],
            o.StateSalesArea [Outlet Sales State Area],
            o.TradingStatus [Outlet Trading Status],
            o.OutletType [Outlet Type],
            o.JVCode [JV Code],
            o.JV [JV Description] 
        from
            [db-au-cmdwh]..penOutlet o with(nolock)--WHERE OutletSKey=374268
        where
            o.AlphaCOde = a.AlphaCOde and
            o.OutletStatus = 'Current'
    ) o

  WHERE
   A.StatusDescription = 'CANCELLED' and
	A.tripstart >= @rptStartDate and 
	A.tripstart <  dateadd(day, 1, @rptEndDate)
	--A.tripstart between '2020-03-24' and '2020-12-17'
  and  A.CountryKey = (@Country) --and A.CompanyKey = (@Company)
  and A.TripType ='Single Trip'  
  and (A.AlphaCode = @AlphaCode OR @AlphaCode IS NULL)
  END
  
  IF @Status = 'ACTIVE'
  BEGIN
  Select * from #Active
  END 
  ELSE 
  BEGIN
  Select * from #CANCELLED
  END
  END



GO
