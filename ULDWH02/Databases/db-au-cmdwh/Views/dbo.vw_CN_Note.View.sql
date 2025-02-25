USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vw_CN_Note]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_CN_Note]  
as  
--select *,row_number() over(partition by CreditNoteNumber,redeempolicyid order by updatedatetime desc) 'Rnk'  
--from penPolicyCreditNote where CreditNoteNumber = 'CN-723000643339'   
select distinct M.PolicyNumber, isnull([New Issued Credit Note],'No') '[New Issued Credit Note]', isnull([Redeemed CN],'No') '[Redeemed CN]' from 
(select penPolicyTransSummary.PolicyNumber
, case when a.OriginalPolicyId = penPolicyTransSummary.PolicyID and a.Status in ('Active','Refunded') then 'Yes'
  when b.OriginalPolicyId = penPolicyTransSummary.PolicyID and a.Status in ('Active','Refunded')  then 'Yes' end 'New Issued Credit Note',
  case when a.RedeemPolicyId = penPolicyTransSummary.PolicyID and b.Status = 'Redeemed' then 'Yes'
  when b.RedeemPolicyId = penPolicyTransSummary.PolicyID and b.Status = 'Redeemed'  then 'Yes' end 'Redeemed CN'--,
  --a.RedeemPolicyId,b.RedeemPolicyId,a.OriginalPolicyId,b.OriginalPolicyId,penPolicyTransSummary.PolicyID,a.cnstatusid,b.cnstatusid,penPolicyTransSummary.cnstatusid
from penPolicyTransSummary JOIN penPolicy on penPolicyTransSummary.PolicyNumber = penPolicy.PolicyNumber 
OUTER APPLY (select RedeemPolicyId,OriginalPolicyId,cnstatusid,Status from (select RedeemPolicyId,OriginalPolicyId,cnstatusid,Status,row_number() over(partition by CreditNoteNumber,redeempolicyid order by updatedatetime desc) 'Rnk'    
from penPolicyCreditNote) cn where OriginalPolicyId = penPolicyTransSummary.PolicyID ) as a
  OUTER APPLY (select RedeemPolicyId,OriginalPolicyId,cnstatusid,Status from (select RedeemPolicyId,OriginalPolicyId,cnstatusid,Status,row_number() over(partition by CreditNoteNumber,redeempolicyid order by updatedatetime desc) 'Rnk'    
from penPolicyCreditNote) cn where RedeemPolicyId = penPolicyTransSummary.PolicyID ) as b) M
  WHERE ([New Issued Credit Note] is not null or [Redeemed CN] is not null) 
GO
