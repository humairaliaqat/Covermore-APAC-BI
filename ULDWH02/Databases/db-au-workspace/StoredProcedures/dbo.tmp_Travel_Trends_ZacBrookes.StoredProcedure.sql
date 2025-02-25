USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[tmp_Travel_Trends_ZacBrookes]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[tmp_Travel_Trends_ZacBrookes]
as

declare @rptStartDate varchar(10)
declare @rptEndDate varchar(10)
select @rptStartDate = '2010-01-01', @rptEndDate = '2012-12-31'

SELECT
  case when Customer.AgeAtDateOfIssue between 0 and 25 then '0-25'
       when Customer.AgeAtDateOfIssue between 26 and 54 then '26-54'
       when Customer.AgeAtDateOfIssue >= 55 then '55+'
  end AgeGroup,
  Policy.Destination,
  Year(Policy.IssuedDate) as [Year],
  avg(datediff(day,Policy.IssuedDate, Policy.DepartureDate)) as AvgLeadTime,
  avg(Policy.NumberOfDays) as AvgDuration,
  count(distinct Policy.PolicyNo) as Policy  
FROM
  [db-au-cmdwh].dbo.Policy INNER JOIN [db-au-cmdwh].dbo.Customer ON (Policy.CustomerKey=Customer.CustomerKey)  
WHERE
  (
   Policy.CountryKey  =  'AU'   AND
   Policy.IssuedDate  BETWEEN  @rptStartDate and @rptEndDate   AND
   Policy.PolicyType  =  'N'   AND
   Customer.isPrimary  =  1   AND
   (Policy.Destination is not null and Policy.Destination <> '') AND
   Policy.PolicyNo  NOT IN  (select OldPolicyNo from [db-au-cmdwh].dbo.Policy where CountryKey = 'AU' and IssuedDate between @rptStartDate and @rptEndDate and PolicyType = 'R' and OldPolicyType = 'N')
  )
group by
  case when Customer.AgeAtDateOfIssue between 0 and 25 then '0-25'
       when Customer.AgeAtDateOfIssue between 26 and 54 then '26-54'
       when Customer.AgeAtDateOfIssue >= 55 then '55+'
  end,
  Policy.Destination,
  Year(Policy.IssuedDate)

GO
