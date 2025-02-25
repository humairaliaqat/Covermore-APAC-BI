USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Policy Data at Policy Level_test007]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[Policy Data at Policy Level_test007] 
as


select distinct m.PostingDate,
                d.PolicyNumber,
				b.TransactionType,
				b.PolicyTransactionKey,
				b.TransactionStatus,
				b.TransactionDateTime,
				d.IssueDate,
			--	d.Destination,
				d.PrimaryCountry,
				d.AreaName,
				d.AreaNumber,
				d.AreaType,
				d.TripStart,
				d.TripEnd,
				d.MaxDuration,
				d.TripType,
				d.PlanCode,
				d.PlanName,
				m.SingleFamilyFlag,
				m.AdultsCount,
				m.ChildrenCount,
				m.TravellersCount,
				d.Excess,
				d.TripCost,
				m.BasePremium,
				a.Title,
				convert(nvarchar(100),a.FirstName)as FirstName,
				a.LastName,
				a.EmailAddress,
				a.MobilePhone,
				a.State,
				a.DOB,
				a.Age,
				y.AlphaCode,
				y.OutletName,
				y.Channel,
				t.PromoCode,
				t.Discount,
				m.Commission,
				m.NewPolicyCount


 from
(select distinct CompanyKey,countrykey,PolicyNumber,PolicyID,PolicyKey,OutletAlphaKey,OutletSKey,IssueDate,PrimaryCountry,
Area,Excess,TripCost,PlanName,AreaCode,AreaName,AreaNumber,AreaType,TripStart,TripEnd,MaxDuration,TripType,PlanCode
  from [db-au-cmdwh].[dbo].penPolicy  with (nolock)
	where IssueDate between DATEADD(mm,-3,getdate()) and GETDATE()
	)d
 ---436575

     outer apply (
	   select distinct m1.commission,m1.newpolicycount,m1.BasePremium,m1.SingleFamilyFlag,m1.AdultsCount,m1.ChildrenCount,
       m1.TravellersCount,PostingDate from [db-au-cmdwh].[dbo].penPolicyTransSummary m1  with (nolock)
	   where d.CountryKey=m1.CountryKey and d.CompanyKey=m1.CompanyKey and d.PolicyNumber=m1.PolicyNumber and d.PolicyID=m1.PolicyID )m
    
	 outer apply (
	 select distinct a1.Title,a1.FirstName,a1.LastName,a1.EmailAddress,a1.MobilePhone,a1.State,a1.DOB,a1.Age
	 from [db-au-cmdwh].[dbo].penPolicyTraveller a1  with (nolock)
	 where d.CountryKey=a1.CountryKey and d.CompanyKey=a1.CompanyKey and d.PolicyID=a1.PolicyID and a1.isPrimary=1)a
	 ---436578

	 outer apply (
	   select distinct b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime
	   from [db-au-cmdwh].[dbo].penPolicyTransaction b1  with (nolock)
	 where d.CountryKey=b1.CountryKey and d.CompanyKey=b1.CompanyKey and d.PolicyKey=b1.PolicyKey and d.PolicyNumber=b1.PolicyNumber)b
	 ---436575

	 outer apply (
	  select distinct y1.AlphaCode,y1.OutletName,y1.Channel
	  from  [db-au-cmdwh].[dbo].penOutlet y1  with (nolock)
	 where d.CountryKey=y1.CountryKey and d.CompanyKey=y1.CompanyKey and d.OutletAlphaKey=y1.OutletAlphaKey and d.OutletSKey=y1.OutletSKey)y
	 ---436570

	 
	 outer apply (
	   select distinct t1.PromoCode,t1.Discount
	   from [db-au-cmdwh].[dbo].penPolicyTransactionPromo t1  with (nolock)
	 where d.CountryKey=t1.CountryKey and d.CompanyKey=t1.CompanyKey and d.PolicyNumber=t1.PolicyNumber)t
	 ---440691

  
   
   
GO
