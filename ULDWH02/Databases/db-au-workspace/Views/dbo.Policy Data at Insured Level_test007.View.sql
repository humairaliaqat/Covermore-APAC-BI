USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Policy Data at Insured Level_test007]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[Policy Data at Insured Level_test007] 
as


select distinct  p.QuoteID,
                 d.PolicyNumber,
				 d.IssueDate,
				 b.TransactionType,
				 b.PolicyTransactionKey,
				 b.TransactionStatus ,
				 b.TransactionDateTime,
				 a.isPrimary,
				 a.Title,
				 a.FirstName,
				 a.LastName,
				 a.DOB,
				 a.Age,
				 a.EMCScore,
				 a.AssessmentType,
				 a.EmcCoverLimit,
				 q.HasEMC

 
--select COUNT (1)
from
(select distinct CountryKey,CompanyKey,OutletSKey,PolicyKey,PolicyID,IssueDate,PolicyNumber,PolicyNoKey
  from  [db-au-cmdwh].[dbo].penPolicy  with(nolock)
	where IssueDate between DATEADD(mm,-3,getdate()) and GETDATE()
	)d
	---440014

    outer apply (
	 select distinct p1.QuoteID from [db-au-cmdwh].[dbo].penQuote p1 with(nolock)
	where d.CountryKey=p1.CountryKey and d.CompanyKey=p1.CompanyKey and d.OutletSKey=p1.OutletSKey 
	and d.PolicyKey=p1.PolicyKey and d.PolicyID=p1.PolicyID )p
	 --440014


	outer apply (
	  select distinct b1.PolicyTransactionKey,b1.TransactionStatus ,b1.TransactionDateTime,CompanyKey,CountryKey,PolicyTransactionID,
	  TransactionType  from [db-au-cmdwh].[dbo].penPolicyTransaction b1 with(nolock)
	where d.CountryKey=b1.CountryKey and d.CompanyKey=b1.CompanyKey and d.PolicyKey=b1.PolicyKey 
	and d.PolicyNoKey=b1.PolicyNoKey and d.PolicyNumber=b1.PolicyNumber)b
	---440014


	outer apply (
	select distinct a1.isPrimary,a1.Title,a1.FirstName,a1.LastName,a1.DOB,a1.Age,a1.EMCScore,a1.AssessmentType,a1.EmcCoverLimit
	from [db-au-cmdwh].[dbo].penPolicyTraveller a1 with(nolock)
	where  d.CountryKey=a1.CountryKey and d.CompanyKey=a1.CompanyKey and d.PolicyID=a1.PolicyID and d.PolicyKey=a1.PolicyKey and isPrimary=1)a
	--439995


	outer apply (
	select distinct  q1.HasEMC
	 from [db-au-cmdwh].[dbo].penPolicyTravellerTransaction q1 with(nolock)
	where b.CountryKey=q1.CountryKey and b.CompanyKey=q1.CompanyKey and b.PolicyTransactionKey=q1.PolicyTransactionKey
	and b.PolicyTransactionID=q1.PolicyTransactionID )q
	---463097
	 

  
GO
