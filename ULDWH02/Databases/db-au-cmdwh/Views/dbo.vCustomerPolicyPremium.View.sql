USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCustomerPolicyPremium]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vCustomerPolicyPremium]
as
select top 5000
    ec.CustomerID,
    pt.PolicyKey,
    pt.PolicyTransactionKey,
    pt.PolicyNumber,
    FirstName,
    PolicyTravellerKey,
    PriceCategory,
    AddOnText,
    CoverIncrease,
    isnull(GrossPremiumAfterDiscount, 0) GrossPremiumAfterDiscount
from
    [db-au-cmdwh]..penPolicyTransaction pt
    outer apply
    (
        --traveller's transaction
        select
            ptv.firstname,
            ptv.policytravellerkey,
            'Base Rate' PriceCategory,
            convert(nvarchar(500), '') AddOnText,
            convert(money, 0) CoverIncrease,
            isnull(pp.GrossPremiumAfterDiscount, 0) GrossPremiumAfterDiscount
        from
            penPolicyTraveller ptv
            inner join penPolicyTravellerTransaction ptt on
                ptt.PolicyTransactionKey = pt.PolicyTransactionKey and
                ptt.PolicyTravellerKey = ptv.PolicyTravellerKey
            left join vpenPolicyPrice pp on
                pp.CountryKey = ptt.CountryKey and
                pp.CompanyKey = ptt.CompanyKey and
                pp.ComponentID = ptt.PolicyTravellerTransactionID and
                pp.GroupID = 2
            left join vpenPolicyTax tx on
                tx.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
        where
            ptv.PolicyKey = pt.PolicyKey

        union all

        --traveller's addon
        select
            ptv.firstname,
            ptv.policytravellerkey,
            pta.AddOnGroup PriceCategory,
			pta.AddOnText,
			pta.CoverIncrease,
            pp.GrossPremiumAfterDiscount
        from
            penPolicyTraveller ptv
            inner join penPolicyTravellerTransaction ptt on
                ptt.PolicyTransactionKey = pt.PolicyTransactionKey and
                ptt.PolicyTravellerKey = ptv.PolicyTravellerKey
            inner join penPolicyTravellerAddOn pta on
                pta.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
            inner join vpenPolicyPrice pp on
                pp.CountryKey = ptt.CountryKey and
                pp.CompanyKey = ptt.CompanyKey and
                pp.ComponentID = pta.PolicyTravellerAddOnID and
                pp.GroupID = 3
        where
            ptv.PolicyKey = pt.PolicyKey

        union all

        --traveller's EMC
        select
            ptv.firstname,
            ptv.policytravellerkey,
            'EMC' PriceCategory,
            pe.EMCRef AddOnText,
            0 CoverIncrease,
            pp.GrossPremiumAfterDiscount
        from
            penPolicyTraveller ptv
            inner join penPolicyTravellerTransaction ptt on
                ptt.PolicyTransactionKey = pt.PolicyTransactionKey and
                ptt.PolicyTravellerKey = ptv.PolicyTravellerKey
            inner join penPolicyEMC pe on
                pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
            inner join vpenPolicyPrice pp on
                pp.CountryKey = ptt.CountryKey and
                pp.CompanyKey = ptt.CompanyKey and
                pp.ComponentID = pe.PolicyEMCID and
                pp.GroupID = 5
        where
            ptv.PolicyKey = pt.PolicyKey

        union all

        --policy addon
        select
            ptv.firstname,
            ptv.policytravellerkey,
            pa.AddOnGroup PriceCategory,
            pa.AddOnText,
            pa.CoverIncrease,
            pp.GrossPremiumAfterDiscount / count(ptv.policytravellerkey) over (partition by pt.policytransactionkey)
        from
            penPolicyAddOn pa
            inner join penPolicyTraveller ptv on
                ptv.PolicyKey = pt.PolicyKey
            inner join vpenPolicyPrice pp on
                pp.CountryKey = pa.CountryKey and
                pp.CompanyKey = pa.CompanyKey and
                pp.ComponentID = pa.PolicyAddOnID and
                pp.GroupID = 4
            left join vpenPolicyAddonTax tx on
                tx.PolicyAddOnKey = pa.PolicyAddOnKey
        where
            pa.PolicyTransactionKey = pt.PolicyTransactionKey
    ) ppc
    outer apply
    (
        select top 1 
            ep.CustomerID
        from
            entPolicy ep
        where
            ep.PolicyKey = pt.PolicyKey and
            ep.Reference = ppc.PolicyTravellerKey
    ) ec
where
    policykey = 'AU-CM7-7855404'
order by
    FirstName, PriceCategory
GO
