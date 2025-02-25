USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vpenPolicyPrice]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vpenPolicyPrice] as
/*
    20131204 - LS - case 19524, stamp duty & gst bug, roll up after and before discount pricing components
*/
select
    CountryKey,
    CompanyKey,
    ComponentID,
    GroupID,
    sum(
        case
            when isPOSDiscount = 0 then GrossPremium
            else 0
        end
    ) GrossPremiumBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then BasePremium
            else 0
        end
    ) BasePremiumBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then AdjustedNet
            else 0
        end
    ) AdjustedNetBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then Commission
            else 0
        end
    ) CommissionBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then CommissionRate
            else 0
        end
    ) CommissionRateBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then Discount
            else 0
        end
    ) DiscountBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then DiscountRate
            else 0
        end
    ) DiscountRateBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then BaseAdminFee
            else 0
        end
    ) BaseAdminFeeBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 0 then GrossAdminFee
            else 0
        end
    ) GrossAdminFeeBeforeDiscount,
    sum(
        case
            when isPOSDiscount = 1 then GrossPremium
            else 0
        end
    ) GrossPremiumAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then BasePremium
            else 0
        end
    ) BasePremiumAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then AdjustedNet
            else 0
        end
    ) AdjustedNetAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then Commission
            else 0
        end
    ) CommissionAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then CommissionRate
            else 0
        end
    ) CommissionRateAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then Discount
            else 0
        end
    ) DiscountAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then DiscountRate
            else 0
        end
    ) DiscountRateAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then BaseAdminFee
            else 0
        end
    ) BaseAdminFeeAfterDiscount,
    sum(
        case
            when isPOSDiscount = 1 then GrossAdminFee
            else 0
        end
    ) GrossAdminFeeAfterDiscount
from
    penPolicyPrice
group by
    CountryKey,
    CompanyKey,
    ComponentID,
    GroupID
GO
