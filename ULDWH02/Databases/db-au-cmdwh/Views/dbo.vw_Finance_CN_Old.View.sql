USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vw_Finance_CN_Old]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_Finance_CN_Old] as  
select *   
from  
(

select *,row_number() over(partition by CreditNoteNumber,New_Issued order by updatedatetime desc) 'Rnk' from (
select distinct  CreditNoteNumber,cn.OriginalPolicyId,M.PolicyNumber 'New_Issued',cn.RedeemPolicyId ,N.PolicyNumber 'Redeemed',UpdateDateTime    
from penPolicyCreditNote cn left join  
(select penPolicyTransSummary.PolicyID,penPolicyTransSummary.PolicyNumber  
from penPolicyTransSummary join penPolicy on penPolicy.PolicyNumber = penPolicyTransSummary.PolicyNumber where penPolicy.PolicyKey='AU-CM7-21482572') M  
on cn.OriginalPolicyId = M.PolicyID  
left join  
(select penPolicyTransSummary.PolicyID,penPolicyTransSummary.PolicyNumber  
from penPolicyTransSummary join penPolicy on penPolicy.PolicyNumber = penPolicyTransSummary.PolicyNumber where penPolicy.PolicyKey='AU-CM7-21482572') N  
on cn.RedeemPolicyId = N.PolicyID) S) as a
GO
