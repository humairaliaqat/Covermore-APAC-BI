USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt_CTM_BlueInsurance]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[rptsp_rpt_CTM_BlueInsurance]            
as            
            
SET NOCOUNT ON            
            
            
/****************************************************************************************************/              
--  Name:                     
--  Author:                   
--  Date Created:             
--  Description:    This stored procedure returns CTM Blue Cancellation policies    
--  Change History: 20250210 - SS - Created              
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
from penPolicy p with(nolock) join penPolicytransaction pt with(nolock) on p.policykey = pt.policykey          
join penoutlet po with(nolock) on p.alphacode = po.alphacode          
outer apply          
(select EmailAddress          
from penPolicyTraveller ppt with(nolock) where ppt.isPrimary = 1 and ppt.PolicyKey = p.PolicyKey) ppt          
where --convert(varchar(20),pt.TransactionDateTime,23) >= '2024-10-24' --and convert(varchar(20),pt.TransactionDateTime,23) <= '2024-10-25'         
p.AlphaCode in ('BIN0003') and  po.outletstatus = 'Current' and CancelledDate is not null          
and TransactionStatusID in (2,3) 
GO
