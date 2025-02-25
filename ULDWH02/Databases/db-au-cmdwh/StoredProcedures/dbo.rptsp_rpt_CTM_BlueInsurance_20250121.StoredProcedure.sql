USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt_CTM_BlueInsurance_20250121]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
CREATE procedure [dbo].[rptsp_rpt_CTM_BlueInsurance_20250121]          
as          
          
SET NOCOUNT ON          
          
          
/****************************************************************************************************/            
--  Name:                   
--  Author:                 
--  Date Created:           
--  Description:    This stored procedure returns CTM Blue Insurance Cancellation policy details  
--     reporting period.          
--  Change History: CHG0040179 - 20241211 - SS - Created            
--            
/****************************************************************************************************/           
          
        
select distinct        
p.ExternalReference2 'QuoteReference',        
p.ExternalReference3 'PartnerQuoteReference',        
p.cancelleddate 'CancellationDate',        
'' 'cancellationEffectiveDate',        
p.tripstart 'commencementDate',        
'CTM' 'comparisonBrand',        
p.policyNumber,        
1 'policyRiskNumber',        
ppt.emailAddress,        
cancellationReason,        
'BLUE' 'brand',    
convert(varchar(20),pt.TransactionDateTime,23) 'TransactionDateTime'    
from penPolicy p join penPolicytransaction pt on p.policykey = pt.policykey        
join penoutlet po on p.alphacode = po.alphacode        
outer apply        
(select EmailAddress        
from penPolicyTraveller ppt where ppt.isPrimary = 1 and ppt.PolicyKey = p.PolicyKey) ppt        
where convert(varchar(20),pt.TransactionDateTime,23) >= '2024-10-24' --and convert(varchar(20),pt.TransactionDateTime,23) <= '2024-10-25'       
and p.AlphaCode in ('BIN0003') and  po.outletstatus = 'Current' and CancelledDate is not null        
and TransactionStatusID in (2,3)        
GO
