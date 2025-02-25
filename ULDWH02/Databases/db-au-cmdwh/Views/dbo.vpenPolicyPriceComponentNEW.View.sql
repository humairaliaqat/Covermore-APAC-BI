USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vpenPolicyPriceComponentNEW]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create
CREATE
 view [dbo].[vpenPolicyPriceComponentNEW] as
/*
    20131204 - LS - case 19524, stamp duty & gst bug, create new pricing components calculation
    20140725 - LS - F21428, sas data verification, add addontext and cover increase to replace penPolicyTransAddon's code
	20160504 - LT - FC USA - Removed AddonText and CoverIncrease conditions
*/
with
cte_policyprice
as
(
    --traveller's transaction
    select
        pt.PolicyTransactionKey,
        pt.PolicyNumber,
		ptv.PolicyTravellerKey ,--added on 1-aug Ratnesh
        'Base Rate' PriceCategory,
        convert(nvarchar(500), '') AddOnText,
        convert(money, 0) CoverIncrease,
        isnull(pp.GrossPremiumBeforeDiscount, 0) GrossPremiumBeforeDiscount,
        isnull(pp.BasePremiumBeforeDiscount, 0) BasePremiumBeforeDiscount,
        isnull(pp.AdjustedNetBeforeDiscount, 0) AdjustedNetBeforeDiscount,
        isnull(pp.CommissionBeforeDiscount, 0) CommissionBeforeDiscount,
        isnull(pp.CommissionRateBeforeDiscount, 0) CommissionRateBeforeDiscount,
        isnull(pp.DiscountBeforeDiscount, 0) DiscountBeforeDiscount,
        isnull(pp.DiscountRateBeforeDiscount, 0) DiscountRateBeforeDiscount,
        isnull(pp.BaseAdminFeeBeforeDiscount, 0) BaseAdminFeeBeforeDiscount,
        isnull(pp.GrossAdminFeeBeforeDiscount, 0) GrossAdminFeeBeforeDiscount,
        isnull(pp.GrossPremiumAfterDiscount, 0) GrossPremiumAfterDiscount,
        isnull(pp.BasePremiumAfterDiscount, 0) BasePremiumAfterDiscount,
        isnull(pp.AdjustedNetAfterDiscount, 0) AdjustedNetAfterDiscount,
        isnull(pp.CommissionAfterDiscount, 0) CommissionAfterDiscount,
        isnull(pp.CommissionRateAfterDiscount, 0) CommissionRateAfterDiscount,
        isnull(pp.DiscountAfterDiscount, 0) DiscountAfterDiscount,
        isnull(pp.DiscountRateAfterDiscount, 0) DiscountRateAfterDiscount,
        isnull(pp.BaseAdminFeeAfterDiscount, 0) BaseAdminFeeAfterDiscount,
        isnull(pp.GrossAdminFeeAfterDiscount, 0) GrossAdminFeeAfterDiscount,
        isnull(tx.GSTBeforeDiscount, 0) GSTBeforeDiscount,
        isnull(tx.GSTBusinessBeforeDiscount, 0) GSTBusinessBeforeDiscount,
        isnull(tx.GSTStandardBeforeDiscount, 0) GSTStandardBeforeDiscount,
        isnull(tx.GSTAfterDiscount, 0) GSTAfterDiscount,
        isnull(tx.GSTBusinessAfterDiscount, 0) GSTBusinessAfterDiscount,
        isnull(tx.GSTStandardAfterDiscount, 0) GSTStandardAfterDiscount,
        isnull(tx.StampDutyBeforeDiscount, 0) StampDutyBeforeDiscount,
        isnull(tx.StampDutyInternationalBeforeDiscount, 0) StampDutyInternationalBeforeDiscount,
        isnull(tx.StampDutyDomesticBeforeDiscount, 0) StampDutyDomesticBeforeDiscount,
        isnull(tx.StampDutyAfterDiscount, 0) StampDutyAfterDiscount,
        isnull(tx.StampDutyInternationalAfterDiscount, 0) StampDutyInternationalAfterDiscount,
        isnull(tx.StampDutyDomesticAfterDiscount, 0) StampDutyDomesticAfterDiscount,
        isnull(tx.CommGSTBeforeDiscount, 0) CommGSTBeforeDiscount,
        isnull(tx.CommGSTBusinessBeforeDiscount, 0) CommGSTBusinessBeforeDiscount,
        isnull(tx.CommGSTStandardBeforeDiscount, 0) CommGSTStandardBeforeDiscount,
        isnull(tx.CommGSTAfterDiscount, 0) CommGSTAfterDiscount,
        isnull(tx.CommGSTBusinessAfterDiscount, 0) CommGSTBusinessAfterDiscount,
        isnull(tx.CommGSTStandardAfterDiscount, 0) CommGSTStandardAfterDiscount,
        isnull(tx.CommStampDutyBeforeDiscount, 0) CommStampDutyBeforeDiscount,
        isnull(tx.CommStampDutyInternationalBeforeDiscount, 0) CommStampDutyInternationalBeforeDiscount,
        isnull(tx.CommStampDutyDomesticBeforeDiscount, 0) CommStampDutyDomesticBeforeDiscount,
        isnull(tx.CommStampDutyAfterDiscount, 0) CommStampDutyAfterDiscount,
        isnull(tx.CommStampDutyInternationalAfterDiscount, 0) CommStampDutyInternationalAfterDiscount,
        isnull(tx.CommStampDutyDomesticAfterDiscount, 0) CommStampDutyDomesticAfterDiscount
    from
        penPolicyTransaction pt
        inner join penPolicyTraveller ptv on
            ptv.PolicyKey = pt.PolicyKey
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

    union all

    --traveller's addon
    select
        pt.PolicyTransactionKey,
        pt.PolicyNumber,
		ptv.PolicyTravellerKey,--added on 1-aug Ratnesh
        pta.AddOnGroup PriceCategory,
        pta.AddOnText,
        pta.CoverIncrease,            
        pp.GrossPremiumBeforeDiscount,
        pp.BasePremiumBeforeDiscount,
        pp.AdjustedNetBeforeDiscount,
        pp.CommissionBeforeDiscount,
        pp.CommissionRateBeforeDiscount,
        pp.DiscountBeforeDiscount,
        pp.DiscountRateBeforeDiscount,
        pp.BaseAdminFeeBeforeDiscount,
        pp.GrossAdminFeeBeforeDiscount,
        pp.GrossPremiumAfterDiscount,
        pp.BasePremiumAfterDiscount,
        pp.AdjustedNetAfterDiscount,
        pp.CommissionAfterDiscount,
        pp.CommissionRateAfterDiscount,
        pp.DiscountAfterDiscount,
        pp.DiscountRateAfterDiscount,
        pp.BaseAdminFeeAfterDiscount,
        pp.GrossAdminFeeAfterDiscount,
        0 GSTBeforeDiscount,
        0 GSTBusinessBeforeDiscount,
        0 GSTStandardBeforeDiscount,
        0 GSTAfterDiscount,
        0 GSTBusinessAfterDiscount,
        0 GSTStandardAfterDiscount,
        0 StampDutyBeforeDiscount,
        0 StampDutyInternationalBeforeDiscount,
        0 StampDutyDomesticBeforeDiscount,
        0 StampDutyAfterDiscount,
        0 StampDutyInternationalAfterDiscount,
        0 StampDutyDomesticAfterDiscount,
        0 CommGSTBeforeDiscount,
        0 CommGSTBusinessBeforeDiscount,
        0 CommGSTStandardBeforeDiscount,
        0 CommGSTAfterDiscount,
        0 CommGSTBusinessAfterDiscount,
        0 CommGSTStandardAfterDiscount,
        0 CommStampDutyBeforeDiscount,
        0 CommStampDutyInternationalBeforeDiscount,
        0 CommStampDutyDomesticBeforeDiscount,
        0 CommStampDutyAfterDiscount,
        0 CommStampDutyInternationalAfterDiscount,
        0 CommStampDutyDomesticAfterDiscount
    from
        penPolicyTransaction pt
        inner join penPolicyTraveller ptv on
            ptv.PolicyKey = pt.PolicyKey
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

    union all

    --traveller's EMC
    select
        pt.PolicyTransactionKey,
        pt.PolicyNumber,
		ptv.PolicyTravellerKey ,--added on 1-aug Ratnesh
        'EMC' PriceCategory,
        pe.EMCRef AddOnText,
        0 CoverIncrease,
        pp.GrossPremiumBeforeDiscount,
        pp.BasePremiumBeforeDiscount,
        pp.AdjustedNetBeforeDiscount,
        pp.CommissionBeforeDiscount,
        pp.CommissionRateBeforeDiscount,
        pp.DiscountBeforeDiscount,
        pp.DiscountRateBeforeDiscount,
        pp.BaseAdminFeeBeforeDiscount,
        pp.GrossAdminFeeBeforeDiscount,
        pp.GrossPremiumAfterDiscount,
        pp.BasePremiumAfterDiscount,
        pp.AdjustedNetAfterDiscount,
        pp.CommissionAfterDiscount,
        pp.CommissionRateAfterDiscount,
        pp.DiscountAfterDiscount,
        pp.DiscountRateAfterDiscount,
        pp.BaseAdminFeeAfterDiscount,
        pp.GrossAdminFeeAfterDiscount,
        0 GSTBeforeDiscount,
        0 GSTBusinessBeforeDiscount,
        0 GSTStandardBeforeDiscount,
        0 GSTAfterDiscount,
        0 GSTBusinessAfterDiscount,
        0 GSTStandardAfterDiscount,
        0 StampDutyBeforeDiscount,
        0 StampDutyInternationalBeforeDiscount,
        0 StampDutyDomesticBeforeDiscount,
        0 StampDutyAfterDiscount,
        0 StampDutyInternationalAfterDiscount,
        0 StampDutyDomesticAfterDiscount,
        0 CommGSTBeforeDiscount,
        0 CommGSTBusinessBeforeDiscount,
        0 CommGSTStandardBeforeDiscount,
        0 CommGSTAfterDiscount,
        0 CommGSTBusinessAfterDiscount,
        0 CommGSTStandardAfterDiscount,
        0 CommStampDutyBeforeDiscount,
        0 CommStampDutyInternationalBeforeDiscount,
        0 CommStampDutyDomesticBeforeDiscount,
        0 CommStampDutyAfterDiscount,
        0 CommStampDutyInternationalAfterDiscount,
        0 CommStampDutyDomesticAfterDiscount
    from
        penPolicyTransaction pt
        inner join penPolicyTraveller ptv on
            ptv.PolicyKey = pt.PolicyKey
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

    union all

    --policy addon
    select
		pt.PolicyTransactionKey,
        pt.PolicyNumber,
		NULL PolicyTravellerKey,--ptv.PolicyTravellerKey ,--added on 1-aug Ratnesh, later modified by Ratnesh to keep it as null, since these are at policy level only and not at traveller level. 
		--adding traveller level column here duplicates the row and shows double premium for relevent addon categories
        pa.AddOnGroup PriceCategory,
        pa.AddOnText,
        pa.CoverIncrease,
        pp.GrossPremiumBeforeDiscount,
        pp.BasePremiumBeforeDiscount,
        pp.AdjustedNetBeforeDiscount,
        pp.CommissionBeforeDiscount,
        pp.CommissionRateBeforeDiscount,
        pp.DiscountBeforeDiscount,
        pp.DiscountRateBeforeDiscount,
        pp.BaseAdminFeeBeforeDiscount,
        pp.GrossAdminFeeBeforeDiscount,
        pp.GrossPremiumAfterDiscount,
        pp.BasePremiumAfterDiscount,
        pp.AdjustedNetAfterDiscount,
        pp.CommissionAfterDiscount,
        pp.CommissionRateAfterDiscount,
        pp.DiscountAfterDiscount,
        pp.DiscountRateAfterDiscount,
        pp.BaseAdminFeeAfterDiscount,
        pp.GrossAdminFeeAfterDiscount,
        isnull(tx.GSTBeforeDiscount, 0) GSTBeforeDiscount,
        isnull(tx.GSTBusinessBeforeDiscount, 0) GSTBusinessBeforeDiscount,
        isnull(tx.GSTStandardBeforeDiscount, 0) GSTStandardBeforeDiscount,
        isnull(tx.GSTAfterDiscount, 0) GSTAfterDiscount,
        isnull(tx.GSTBusinessAfterDiscount, 0) GSTBusinessAfterDiscount,
        isnull(tx.GSTStandardAfterDiscount, 0) GSTStandardAfterDiscount,
        isnull(tx.StampDutyBeforeDiscount, 0) StampDutyBeforeDiscount,
        isnull(tx.StampDutyInternationalBeforeDiscount, 0) StampDutyInternationalBeforeDiscount,
        isnull(tx.StampDutyDomesticBeforeDiscount, 0) StampDutyDomesticBeforeDiscount,
        isnull(tx.StampDutyAfterDiscount, 0) StampDutyAfterDiscount,
        isnull(tx.StampDutyInternationalAfterDiscount, 0) StampDutyInternationalAfterDiscount,
        isnull(tx.StampDutyDomesticAfterDiscount, 0) StampDutyDomesticAfterDiscount,
        isnull(tx.CommGSTBeforeDiscount, 0) CommGSTBeforeDiscount,
        isnull(tx.CommGSTBusinessBeforeDiscount, 0) CommGSTBusinessBeforeDiscount,
        isnull(tx.CommGSTStandardBeforeDiscount, 0) CommGSTStandardBeforeDiscount,
        isnull(tx.CommGSTAfterDiscount, 0) CommGSTAfterDiscount,
        isnull(tx.CommGSTBusinessAfterDiscount, 0) CommGSTBusinessAfterDiscount,
        isnull(tx.CommGSTStandardAfterDiscount, 0) CommGSTStandardAfterDiscount,
        isnull(tx.CommStampDutyBeforeDiscount, 0) CommStampDutyBeforeDiscount,
        isnull(tx.CommStampDutyInternationalBeforeDiscount, 0) CommStampDutyInternationalBeforeDiscount,
        isnull(tx.CommStampDutyDomesticBeforeDiscount, 0) CommStampDutyDomesticBeforeDiscount,
        isnull(tx.CommStampDutyAfterDiscount, 0) CommStampDutyAfterDiscount,
        isnull(tx.CommStampDutyInternationalAfterDiscount, 0) CommStampDutyAfterDiscount,
        isnull(tx.CommStampDutyDomesticAfterDiscount, 0) CommStampDutyDomesticAfterDiscount
    from
        penPolicyTransaction pt
        --inner join penPolicyTraveller ptv on--added on 1aug18 by Ratnesh
          --  ptv.PolicyKey = pt.PolicyKey --added on 1aug18 by Ratnesh
        inner join penPolicyAddOn pa on
            pa.PolicyTransactionKey = pt.PolicyTransactionKey
        inner join vpenPolicyPrice pp on
            pp.CountryKey = pa.CountryKey and
            pp.CompanyKey = pa.CompanyKey and
            pp.ComponentID = pa.PolicyAddOnID and
            pp.GroupID = 4
        left join vpenPolicyAddonTax tx on
            tx.PolicyAddOnKey = pa.PolicyAddOnKey
)
select
    *
from
    cte_policyprice




GO
