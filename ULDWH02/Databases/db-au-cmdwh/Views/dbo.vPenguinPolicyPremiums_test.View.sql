USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vPenguinPolicyPremiums_test]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
    
    
    
 CREATE view [dbo].[vPenguinPolicyPremiums_test]    
/*    
20140131, LS,   initial production use (universe migration)    
                commented out metrics are for finance's GUG, disabled for now    
20140205, LS,   performance consideration, all UW related definition moved to vPenguinPolicyUWPremiums    
20140212, LS,   round commission to 2 decimal point (as in CRM)    
20140228, LS,   fix NAP definition, should be - Agency Commission instead of - Net Agency Commission.    
20140514, LS,   round sell price & unadjusted sell price to 2 decimal point  
20200911, GS,   Added IsCreditCard field as a part of Chang CHG0032939    
20200205, GS,   Amended join condition as a part of change CHG0033601  
*/    
as    
select    
    pt.PolicyTransactionKey,    
    pra.[Unadjusted Sell Price],    
    pra.[Unadjusted GST on Sell Price],    
    pra.[Unadjusted Stamp Duty on Sell Price],    
    prb.[Unadjusted Sell Price (excl GST)],    
    prb.[Unadjusted Premium],    
    pra.[Unadjusted Agency Commission],    
    pra.[Unadjusted GST on Agency Commission],    
    pra.[Unadjusted Stamp Duty on Agency Commission],    
    prb.[Unadjusted Agency Commission (excl GST)],    
    prb.[Unadjusted Net Agency Commission],    
    prc.[Unadjusted NAP],    
    prc.[Unadjusted NAP (incl Tax)],    
    prb.[Discount on Sell Price],    
    pra.[Sell Price],    
    pra.[GST on Sell Price],    
    pra.[Stamp Duty on Sell Price],    
    prb.[Sell Price (excl GST)],    
    prb.[Premium],    
    pra.[Agency Commission],    
    pra.[GST on Agency Commission],    
    pra.[Stamp Duty on Agency Commission],    
    prb.[Agency Commission (excl GST)],    
    prb.[Net Agency Commission],    
    prc.[NAP],    
    prc.[NAP (incl Tax)],    
    pra.[Risk Nett],  
    pay.IsCreditCard,  
  
 canb.[Sell Price] as [Sell Price on Can+ Benefit],  
  
 canb.[Agency Commission] as [Agency Commission on Can + Benefit]  
  
from    
    [db-au-cmdwh]..penPolicyTransSummary pt    
    cross apply    
    (    
        select    
            round(isnull(pt.UnAdjGrossPremium, 0), 2) as [Unadjusted Sell Price],    
            isnull(pt.UnAdjTaxAmountGST, 0) as [Unadjusted GST on Sell Price],    
            isnull(pt.UnAdjTaxAmountSD, 0) as [Unadjusted Stamp Duty on Sell Price],    
            round(isnull(pt.UnAdjCommission, 0), 2) + round(isnull(pt.UnAdjGrossAdminFee, 0), 2) as [Unadjusted Agency Commission],    
            round(isnull(pt.UnAdjTaxOnAgentCommissionGST, 0), 2) as [Unadjusted GST on Agency Commission],    
            round(isnull(pt.UnAdjTaxOnAgentCommissionSD, 0), 2) as [Unadjusted Stamp Duty on Agency Commission],    
            round(isnull(pt.GrossPremium, 0), 2) as [Sell Price],    
            isnull(pt.TaxAmountGST, 0) as [GST on Sell Price],    
            isnull(pt.TaxAmountSD, 0) as [Stamp Duty on Sell Price],    
            round(isnull(pt.Commission, 0), 2) + round(isnull(pt.GrossAdminFee, 0), 2) as [Agency Commission],    
            round(isnull(pt.TaxOnAgentCommissionGST, 0), 2) as [GST on Agency Commission],    
            round(isnull(pt.TaxOnAgentCommissionSD, 0), 2) as [Stamp Duty on Agency Commission],    
            isnull(pt.RiskNet, 0) as [Risk Nett]    
    ) pra    
    cross apply    
    (    
        select    
            pra.[Unadjusted Sell Price] - pra.[Unadjusted GST on Sell Price] as [Unadjusted Sell Price (excl GST)],    
            pra.[Unadjusted Sell Price] - pra.[Unadjusted GST on Sell Price] - [Unadjusted Stamp Duty on Sell Price] as [Unadjusted Premium],    
            pra.[Unadjusted Agency Commission] - pra.[Unadjusted GST on Agency Commission] as [Unadjusted Agency Commission (excl GST)],    
            pra.[Unadjusted Agency Commission] - pra.[Unadjusted GST on Agency Commission] - pra.[Unadjusted Stamp Duty on Agency Commission] as [Unadjusted Net Agency Commission],    
            pra.[Sell Price] - pra.[GST on Sell Price] as [Sell Price (excl GST)],    
            pra.[Sell Price] - pra.[GST on Sell Price] - [Stamp Duty on Sell Price] as [Premium],    
            pra.[Agency Commission] - pra.[GST on Agency Commission] as [Agency Commission (excl GST)],    
            pra.[Agency Commission] - pra.[GST on Agency Commission] - pra.[Stamp Duty on Agency Commission] as [Net Agency Commission],    
            pra.[Unadjusted Sell Price] - pra.[Sell Price] as [Discount on Sell Price]    
    ) prb    
    cross apply    
    (    
        select    
            prb.[Unadjusted Premium] - pra.[Unadjusted Agency Commission] as [Unadjusted NAP],    
            pra.[Unadjusted Sell Price] - pra.[Unadjusted Agency Commission] as [Unadjusted NAP (incl Tax)],    
            prb.[Premium] - pra.[Agency Commission] as [NAP],    
            pra.[Sell Price] - pra.[Agency Commission] as [NAP (incl Tax)]    
    ) prc    
  
 outer apply  
 (  
   select  p.PolicyTransactionKey, sum(GrossPremiumAfterDiscount )as [Sell Price],sum (CommissionAfterdiscount+GrossAdminFeeAfterDiscount ) as [Agency Commission]   
   from [db-au-cmdwh]..vpenPolicyPriceComponentOptimise p where p.PriceCategory = 'Cancellation Plus Cover' and   
   pt.PolicyTransactionKey=p.PolicyTransactionKey  
   group by p.PolicyTransactionKey  
   )canb  
  
  
  OUTER APPLY       --get isCreditCard  
 (  
  select top 1  
   case when p.PolicyTransactionID is not null then 1 else 0 end as IsCreditCard  
  from   
   [db-au-cmdwh]..penPayment p  
  where   
   --PolicyTransactionID = pt.PolicyTransactionID  
   p.PolicyTransactionKey = pt.PolicyTransactionKey--CHG0033601  
 ) pay  
    
    
    
    
  
GO
