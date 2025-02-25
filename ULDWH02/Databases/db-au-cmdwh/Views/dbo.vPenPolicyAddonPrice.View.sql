USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vPenPolicyAddonPrice]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vPenPolicyAddonPrice] as
select
    pt.PolicyTransactionKey,
    pa.AddOnGroup,
    pa.Premium
from 
    penPolicyTransSummary pt
    cross apply
    (
        select 
            pa.AddOnGroup,
            sum(pp.GrossPremium) Premium
        from 
            penPolicyAddOn pa 
            inner join penPolicyPrice pp on
                pp.GroupID = 4 and
                pp.ComponentID = pa.PolicyAddOnID and
                pp.CountryKey = pt.CountryKey and
                pp.CompanyKey = pt.CompanyKey and
                pp.isPOSDiscount = 1
        where 
            pa.PolicyTransactionKey = pt.PolicyTransactionKey
        group by 
            pa.AddOnGroup
    ) pa

union

select
    pt.PolicyTransactionKey,
    pa.AddOnGroup,
    pa.Premium
from 
    penPolicyTransSummary pt
    cross apply
    (
        select 
            pta.AddOnGroup,
            sum(pp.GrossPremium) Premium
        from 
            penPolicyTraveller ptv 
            inner join penPolicyTravellerTransaction ptt on
                ptt.PolicyTransactionKey = pt.PolicyTransactionKey and
                ptt.PolicyTravellerKey = ptv.PolicyTravellerKey
            inner join penPolicyTravellerAddOn pta on 
                pta.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
            inner join penPolicyPrice pp on
                pp.GroupID = 3 and
                pp.ComponentID = pta.PolicyTravellerAddOnID and
                pp.CountryKey = pt.CountryKey and
                pp.CompanyKey = pt.CompanyKey and
                pp.isPOSDiscount = 1
        where 
            ptv.PolicyKey = pt.PolicyKey
        group by 
            pta.AddOnGroup
    ) pa

union

select 
    pt.PolicyTransactionKey,
    pe.AddOnGroup,
    pe.Premium
from 
    penPolicyTransSummary pt
    cross apply
    (
        select 
            'Medical' AddOnGroup,
            sum(pp.GrossPremium) Premium
        from 
            penPolicyTravellerTransaction ptt 
            inner join penPolicyEMC pe on 
                pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
            inner join penPolicyPrice pp on
                pp.GroupID = 5 and
                pp.ComponentID = pe.PolicyEMCID and
                pp.CountryKey = pt.CountryKey and
                pp.CompanyKey = pt.CompanyKey and
                pp.isPOSDiscount = 1
        where 
            ptt.PolicyTransactionKey = pt.PolicyTransactionKey
    ) pe
where
    pe.Premium is not null
  
GO
