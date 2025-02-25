USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vpenPolicyTax]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vpenPolicyTax] as
/*
    20131204 - LS - case 19524, stamp duty & gst bug, classify tax components
    20151223 - LS - include MY duty fee in Stamp Duty
    20170508 - LL - use penTax, to avoid issue of null tax name or type in penPolicyTax
*/
select
    PolicyTravellerTransactionKey,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxAmount
            else 0
        end
    ) GSTBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxAmount
            else 0
        end
    ) GSTBusinessBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxAmount
            else 0
        end
    ) GSTStandardBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxAmountPOSDisc
            else 0
        end
    ) GSTAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxAmountPOSDisc
            else 0
        end
    ) GSTBusinessAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxAmountPOSDisc
            else 0
        end
    ) GSTStandardAfterDiscount,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxAmount
            else 0
        end
    ) StampDutyBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxAmount
            else 0
        end
    ) StampDutyInternationalBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxAmount
            else 0
        end
    ) StampDutyDomesticBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxAmountPOSDisc
            else 0
        end
    ) StampDutyAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxAmountPOSDisc
            else 0
        end
    ) StampDutyInternationalAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxAmountPOSDisc
            else 0
        end
    ) StampDutyDomesticAfterDiscount,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxOnAgentComm
            else 0
        end
    ) CommGSTBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxOnAgentComm
            else 0
        end
    ) CommGSTBusinessBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxOnAgentComm
            else 0
        end
    ) CommGSTStandardBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxOnAgentCommPOSDisc
            else 0
        end
    ) CommGSTAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxOnAgentCommPOSDisc
            else 0
        end
    ) CommGSTBusinessAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%business%' and isnull(tx.TaxType, ptx.TaxType) in ('GST', 'IPT') then TaxOnAgentCommPOSDisc
            else 0
        end
    ) CommGSTStandardAfterDiscount,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxOnAgentComm
            else 0
        end
    ) CommStampDutyBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxOnAgentComm
            else 0
        end
    ) CommStampDutyInternationalBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxOnAgentComm
            else 0
        end
    ) CommStampDutyDomesticBeforeDiscount,
    sum(
        case
            when isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxOnAgentCommPOSDisc
            else 0
        end
    ) CommStampDutyAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxOnAgentCommPOSDisc
            else 0
        end
    ) CommStampDutyInternationalAfterDiscount,
    sum(
        case
            when isnull(tx.TaxName, ptx.TaxName) not like '%international%' and isnull(tx.TaxType, ptx.TaxType) in ('Stamp Duty', 'Duty Fee') then TaxOnAgentCommPOSDisc
            else 0
        end
    ) CommStampDutyDomesticAfterDiscount
from
    penPolicyTax ptx
    outer apply
    (
        select top 1 
            tx.TaxName,
            tx.TaxType
        from
            penTax tx
        where
            tx.TaxKey = ptx.TaxKey
    ) tx
group by
    PolicyTravellerTransactionKey


GO
