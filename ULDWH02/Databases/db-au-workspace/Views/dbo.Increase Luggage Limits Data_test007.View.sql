USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Increase Luggage Limits Data_test007]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[Increase Luggage Limits Data_test007] 
as


select distinct  d.PolicyNumber,
                 b.TransactionType,
				 b.PolicyTransactionKey,
				 b.TransactionStatus,
				 b.TransactionDateTime,
				 d.IssueDate,
				 a.isPrimary,
				 g.AddOnText,
				 g.CoverIncrease

--select top 100 *--COUNT(PolicyNumber)
from
    (select distinct PolicyNumber,CountryKey,CompanyKey,PolicyID,PolicyKey,IssueDate
	from [db-au-cmdwh].[dbo].penPolicy  with(nolock)
	where IssueDate between DATEADD(mm,-3,getdate()) and GETDATE()
	)d
	---440124

	
     outer apply (
	 select distinct  b1.TransactionType,b1.PolicyTransactionKey,b1.TransactionStatus,b1.TransactionDateTime
	 from [db-au-cmdwh].[dbo].penPolicyTransaction b1 with(nolock)
	 where  d.CountryKey=b1.CountryKey and d.CompanyKey=b1.CompanyKey and d.PolicyID=b1.PolicyID and d.PolicyNumber=b1.PolicyNumber )b
	 ---440206
    

    outer apply (
	select distinct a1.isPrimary
	from [db-au-cmdwh].[dbo].penPolicyTraveller a1 with(nolock)
	where d.CountryKey=a1.CountryKey and d.CompanyKey=a1.CompanyKey and d.PolicyKey=a1.PolicyKey 
	and d.PolicyID=a1.PolicyID and isPrimary=1)a 
	---440159
	

	outer apply (
	select distinct  g1.AddOnText ,g1.CoverIncrease --- distinct convert(nvarchar(2000),  g1.AddOnText) as AddOnText
	from [db-au-cmdwh].[dbo].penPolicyTravellerAddOn g1 with(nolock)
	where d.CountryKey=g1.CountryKey and d.CompanyKey=g1.CompanyKey)g

	 
    


GO
