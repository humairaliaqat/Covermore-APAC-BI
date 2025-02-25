USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_Credti_Note_status_RPT520]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_Credti_Note_status_RPT520]

/************************************************************************************************************************************                                            
Author:         Siddhesh SHinde                                  
Date:           20241030                                     
Description:    This proc being developed for fullfill the Bendigo Option 3 reporting                                          
Change History:  CHG0039919
NAME :           CHG0039919  BI Request: Fix the gap in RPT520 Report to avoid monthly manual SQL extracts             
                                                          
*************************************************************************************************************************************/                                            
as                                          
begin

if object_id('tempdb..#tbl_RPT520_CN_Status') is not null drop table #tbl_RPT520_CN_Status

SELECT distinct tp.PolicyID
	, tp.PolicyNumber as 'OriginalPolicyNumber'
	, tp.Area
	, CAST(DATEADD(day, 1, tp.tripStart) as date) as 'TripStart'
	, CAST(DATEADD(day, 1, tp.TripEnd) as date) as 'TripEnd'
	, CAST(DATEADD(HOUR, 12, tp.IssueDate) as date) as 'PolicyIssueDate AEST'
	, tcn.CreditNoteNumber
	, CAST(DATEADD(HOUR, 12, tcn.CreateDateTime) as date) as 'CNCreatedDate AEST'
	, tcn.Status as 'CNStatus'
	, tcn.Amount as 'CreditNoteOriginalValue'
	, tcn.RedeemAmount as 'AmountRedeemed'
	, tcn.Commission as 'CommissionEarned'
	, tcn.RedeemedCommission as 'CommissionRedeemed'
	, tp.AlphaCode
	, tp.DomainID
	, tou.OutletName
	, tou.GroupName
    ,tcn.RedeemPolicyId
    ,b.PolicyNumber as 'NewPolicyNumber'
    ,b.AlphaCode as 'NewAlphaCode'
    ,b.Status as 'NewPolicyStatus'
    ,b.IssueDate as 'NewPolicyIssueDate'
    ,b.CancelledDate as 'NewPolicyCancelDate'
    , tp.PolicyNumber as 'New_Issued_Policy_Number'
    , case when tcn.Status = 'Expired' then 'No' else 'Yes' end 'Active_Credit_Note'
    , b.PolicyNumber as 'Redeemed_Policy_Number'
    , case when tcn.Status = 'Expired' then 'No' else 'Yes' end 'Redeemed_Credit_Note'
	into #tbl_RPT520_CN_Status
FROM [db-au-cmdwh]..penPolicy as tp JOIN [db-au-cmdwh]..penOutlet as tou ON tp.AlphaCode = tou.AlphaCode 
JOIN [db-au-cmdwh]..penPolicyCreditNote as tcn ON tcn.OriginalPolicyID = tp.PolicyID
outer apply (select distinct PolicyNumber,AlphaCode,IssueDate,CancelledDate,Status from [db-au-cmdwh]..penPolicy where PolicyId = CASE WHEN tcn.RedeemPolicyId = 0 THEN NULL
            ELSE tcn.RedeemPolicyId
       END) b
WHERE PolicyID IN 
(SELECT OriginalPolicyID FROM [db-au-penguinsharp.aust.covermore.com.au].[AU_PenguinSharp_Active].dbo.tblPolicyCreditNote)
and tou.OutletStatus = 'Current'
--and tp.PolicyNumber in ('721100106277')
AND tp.DomainID = '7'

if object_id('[db-au-cmdwh]..tbl_RPT520_CN_Status') is not null drop table tbl_RPT520_CN_Status
select * into tbl_RPT520_CN_Status
from #tbl_RPT520_CN_Status

end
GO
