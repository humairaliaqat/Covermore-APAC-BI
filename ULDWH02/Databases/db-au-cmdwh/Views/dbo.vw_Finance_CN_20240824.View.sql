USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vw_Finance_CN_20240824]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_Finance_CN_20240824] as      
select *       
from      
(select CreditNoteNumber,cn.OriginalPolicyId,M.PolicyNumber 'New_Issued',cn.RedeemPolicyId ,N.PolicyNumber 'Redeemed',UpdateDateTime,      
--row_number() over(partition by CreditNoteNumber,M.PolicyNumber,N.PolicyNumber order by updatedatetime desc) 'Rnk'        
row_number() over(partition by CreditNoteNumber order by updatedatetime desc) 'Rnk'        
from penPolicyCreditNote cn with(nolock) left join      
(select penPolicyTransSummary.PolicyID,penPolicyTransSummary.PolicyNumber      
from penPolicyTransSummary with(nolock) join penPolicy with(nolock) on penPolicy.PolicyNumber = penPolicyTransSummary.PolicyNumber) M      
on cn.OriginalPolicyId = M.PolicyID      
left join      
(select penPolicyTransSummary.PolicyID,penPolicyTransSummary.PolicyNumber      
from penPolicyTransSummary with(nolock) join penPolicy with(nolock) on penPolicy.PolicyNumber = penPolicyTransSummary.PolicyNumber) N      
on cn.RedeemPolicyId = N.PolicyID  
where CNStatusID not in (1,4,5)
--and status in ('Active','Redeemed')  
) S
GO
