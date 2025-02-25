USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vw_Finance_CN]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_Finance_CN] as  
select *   
from  
(select CreditNoteNumber,cn.OriginalPolicyId,M.PolicyNumber 'New_Issued',cn.RedeemPolicyId ,N.PolicyNumber 'Redeemed',UpdateDateTime,  
--row_number() over(partition by CreditNoteNumber,M.PolicyNumber,N.PolicyNumber order by updatedatetime desc) 'Rnk'    
row_number() over(partition by CreditNoteNumber order by updatedatetime desc) 'Rnk'    
from [db-au-cmdwh]..penPolicyCreditNote cn left join  
(select penPolicyTransSummary.PolicyID,penPolicyTransSummary.PolicyNumber  
from [db-au-cmdwh]..penPolicyTransSummary join [db-au-cmdwh]..penPolicy on penPolicy.PolicyNumber = penPolicyTransSummary.PolicyNumber) M  
on cn.OriginalPolicyId = M.PolicyID  
left join  
(select penPolicyTransSummary.PolicyID,penPolicyTransSummary.PolicyNumber  
from [db-au-cmdwh]..penPolicyTransSummary join [db-au-cmdwh]..penPolicy on penPolicy.PolicyNumber = penPolicyTransSummary.PolicyNumber) N  
on cn.RedeemPolicyId = N.PolicyID) S
GO
