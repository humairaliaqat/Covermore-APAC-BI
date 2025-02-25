USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_katrina_cammish_aav0352]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tmp_katrina_cammish_aav0352]
as

SELECT
  Agency.AgencyCode,
  Agency.AgencyName,
  Policy.CreateDate,
  'FY2011' as FYear,
  sum(Policy.GrossPremiumExGSTBeforeDiscount + Policy.GSTonGrossPremium) as SellPriceIncGST,
  sum(Policy.GrossPremiumExGSTBeforeDiscount + Policy.GSTonGrossPremium - Policy.CommissionAmount - Policy.GSTOnCommission) as NetPrice,
  sum(case when Policy.PolicyType in ('N','E') then 1 when Policy.PolicyType = 'R' and Policy.OldPolicyType in ('N','E') then -1 else 0 end) as NewPolicy
FROM
  Agency 
  INNER JOIN Policy ON 
	(Policy.AgencyKey=Agency.AgencyKey and 
	Agency.AgencyStatus = 'Current')  
WHERE
  (
   Agency.CountryKey  =  'AU' and
   Agency.AgencyCode  =  'AAV0352' and
   Policy.CreateDate between '2010-07-01' and '2011-06-30'
  )
GROUP BY
  Agency.AgencyCode, 
  Agency.AgencyName, 
  Policy.CreateDate

union all

SELECT
  Agency.AgencyCode,
  Agency.AgencyName,
  Policy.CreateDate,
  'FY2010' as FYear,
  sum(Policy.GrossPremiumExGSTBeforeDiscount + Policy.GSTonGrossPremium) as SellPriceIncGST,
  sum(Policy.GrossPremiumExGSTBeforeDiscount + Policy.GSTonGrossPremium - Policy.CommissionAmount - Policy.GSTOnCommission) as NetPrice,
  sum(case when Policy.PolicyType in ('N','E') then 1 when Policy.PolicyType = 'R' and Policy.OldPolicyType in ('N','E') then -1 else 0 end) as NewPolicy
FROM
  Agency 
  INNER JOIN Policy ON 
	(Policy.AgencyKey=Agency.AgencyKey and 
	Agency.AgencyStatus = 'Current')  
WHERE
  (
   Agency.CountryKey  =  'AU' and
   Agency.AgencyCode  =  'AAV0352' and
   Policy.CreateDate between '2009-07-01' and '2010-06-30'
  )
GROUP BY
  Agency.AgencyCode, 
  Agency.AgencyName, 
  Policy.CreateDate
GO
