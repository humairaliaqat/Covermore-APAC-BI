USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactPolicyTransaction_20210824]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[vfactPolicyTransaction_20210824] as            
select           
    pt.BIRowID,            
    pt.DateSK,            
    pt.DomainSK,            
    pt.OutletSK,            
    pt.PolicySK,            
    pt.ConsultantSK,            
    pt.PaymentSK,            
    pt.AreaSK,            
    pt.DestinationSK,            
    pt.DurationSK,            
    pt.ProductSK,            
    pt.AgeBandSK,            
    pt.PromotionSK,            
    pt.TransactionTypeStatusSK,                 
    pt.IssueDate,            
    pt.PostingDate,            
    pt.PolicyTransactionKey,            
    pt.TransactionNumber,            
    pt.TransactionType,            
    pt.TransactionStatus,            
    pt.isExpo,            
    pt.isPriceBeat,            
    pt.isAgentSpecial,            
    pt.BonusDays,            
    pt.isClientCall,            
    pt.AllocationNumber,            
    pt.RiskNet,            
    pt.Premium,            
    pt.BookPremium,            
    pt.SellPrice,            
    pt.NetPrice,            
    pt.PremiumSD,            
    pt.PremiumGST,            
    pt.Commission,            
    pt.CommissionSD,            
    pt.CommissionGST,            
    pt.PremiumDiscount,            
    pt.AdminFee,            
    pt.AgentPremium,            
    pt.UnadjustedSellPrice,            
    pt.UnadjustedNetPrice,            
    pt.UnadjustedCommission,            
    pt.UnadjustedAdminFee,            
    --pt.PolicyCount,         --commented out as per CHG0033722
	Case when pt.TransactionType='Base' and  pt.TransactionStatus='Active' then 1 else 0   -  pt.CancelledPolicyCount end as   PolicyCount,  --Revised logic as per CHG0033722         
    pt.AddonPolicyCount,            
    pt.ExtensionPolicyCount,            
    ISNULL(pt.CancelledPolicyCount,0) as CancelledPolicyCount,    
	ISNULL(pt.CancelledTransactionCount,0) as CancelledTransactionCount,      --ADDED UNDER CHG0033591       
    pt.CancelledAddonPolicyCount,            
    pt.CANXPolicyCount,            
    pt.DomesticPolicyCount,            
    pt.InternationalPolicyCount,            
    pt.InboundPolicyCount,            
    pt.TravellersCount,            
    pt.AdultsCount,            
    pt.ChildrenCount,            
    pt.ChargedAdultsCount,            
    pt.DomesticTravellersCount,            
    pt.DomesticAdultsCount,            
    pt.DomesticChildrenCount,            
    pt.DomesticChargedAdultsCount,            
    pt.InboundTravellersCount,            
    pt.InboundAdultsCount,            
    pt.InboundChildrenCount,            
    pt.InboundChargedAdultsCount,            
    pt.InternationalTravellersCount,            
    pt.InternationalAdultsCount,            
    pt.InternationalChildrenCount,            
    pt.InternationalChargedAdultsCount,            
    pt.LuggageCount,            
    pt.MedicalCount,            
    pt.MotorcycleCount,            
    pt.RentalCarCount,            
    pt.WintersportCount,            
    pt.AttachmentCount,            
    pt.EMCCount,            
    pt.LoadDate,            
    pt.LoadID,            
    pt.updateDate,            
    pt.updateID,            
    ref.OutletReference,                    
    pt.LeadTime,            
    pt.Duration,            
    pt.CancellationCover,            
    p.PolicyKey,            
    pt.DepartureDate TripStart,            
    pt.ReturnDate TripEnd,            
    pt.PolicyIssueDate,            
    pt.UnderwriterCode         
         
from             
     factPolicyTransaction as pt            
    inner join dimpolicy as p on             
        p.policysk = pt.policysk            
    cross apply   
    (            
        select 'Point in time' OutletReference            
        union all            
        select 'Latest alpha' OutletReference            
    ) ref            
            
where            
    pt.DateSK >= 20130101        
            
            
            
          
            
            





GO
