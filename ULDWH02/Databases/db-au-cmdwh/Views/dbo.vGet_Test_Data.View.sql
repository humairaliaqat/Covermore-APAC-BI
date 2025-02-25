USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vGet_Test_Data]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vGet_Test_Data]
AS

    SELECT DISTINCT --top 1000 
	--a.PolicyKey,
	a.Countrykey,
	a.PolicyNumber
	,a.StatusDescription as PolicyStatusDescription
	,b.Firstname
	,b.LastName
    ,a.IssueDate
	,[Departure Date]
	,PolicyStart
	,PolicyEnd
	,F.[Destination]
	,E.GrossPremium
	,E.VolumeCommission +e.Discount  AS Commission
	,E.RiskNet
	,b.EmailAddress
	,b.MobilePhone
	,[AlphaCode]
	 ,[Outlet Name]
     ,[Outlet Super Group]
	 ,[Outlet Sub Group Name]
     ,[Trip Type]
     ,[JV Code]
     ,a.TripType
	,c.AddonGroup 
	,D.StatusDesc 
	FROM [db-au-cmdwh].dbo.PenPolicy a
	LEFT OUTER JOIN [db-au-cmdwh].dbo.PenPolicyTransaction  E  WITH (NOLOCK) ON  A.PolicyNumber=E.PolicyNumber
	LEFT OUTER JOIN  [db-au-cmdwh].[dbo].[penPolicyTransAddOn] C WITH (NOLOCK)     on c.policykey=a.policykey
	 LEFT OUTER JOIN [db-au-cmdwh].dbo.clmclaim D  WITH (NOLOCK)  ON A.PolicyNumber=d.PolicyNo
	CROSS apply 
		(SELECT TOP 1  b.Firstname
		  ,b.LastName
		  ,b.EmailAddress
		  ,MobilePhone
		  FROM [db-au-cmdwh].dbo.penPolicyTraveller b WHERE a.[Policykey]=b.[PolicyKey] AND ISNULL(B.FirstName,'')<>''
		) B
INNER JOIN  [db-au-actuary].[dbo].[DWHDataSet] F WITH (NOLOCK)  ON A.PolicyNumber= F.[Policy No]
  WHERE [Departure Date] >='2020-03-23' --and a.Countrykey='AU'

  /*
  AND A.PolicyKey IN
  (
'AU-CM7-17192438',
'AU-CM7-17189628',
'NZ-CM8-17192392',
'NZ-CM8-17184783',
'AU-CM7-17194420',
'AU-CM7-17192346',
'AU-CM7-17192558',
'AU-CM7-17192593',
'AU-CM7-17194621',
'AU-CM7-17194621',
'AU-CM7-17192441',
'NZ-CM8-17190947',
'AU-CM7-17187289',
'AU-CM7-17187289',
'AU-CM7-17186069',
'NZ-CM8-17191926')
*/
	/*


	SELECT top 10 * from [db-au-cmdwh].dbo.penOutlet
	SELECT top 10 * from [db-au-cmdwh].dbo.PenPolicy
	SELECT top 10 * from [db-au-star].dbo.dimOutlet
	SELECT top 5 * FROM [db-au-actuary].[dbo].[DWHDataSet]

*/
GO
