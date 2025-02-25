USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vw_Traveller_Sequence_No]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE View [dbo].[vw_Traveller_Sequence_No]        
 as        
 (        
 select A.PolicyKey,FirstName,LastName,DOB,ROW_NUMBER()over(partition by A.PolicyKey order by  PolicyTravellerID asc ) as Traveller_Sequence_No         
 from [db-au-cmdwh].[dbo].penPolicyTraveller as a inner join [db-au-cmdwh].[dbo].penPolicy        
 as b on a.PolicyKey=b.PolicyKey where AlphaCode in ('BGD0001','BGD0002','BGD0003','BPN0001','BPN0002','AGN0001','AGN0002')        
 )
GO
