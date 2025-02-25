USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vcorpQuoteMetrics]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vcorpQuoteMetrics]
as
select 
    OutletKey,
    QuoteDate,
    IssueDate,
    QuoteKey,
    isPolicy,
    Tier,
    case
        when Idx = min(Idx) over (partition by QuoteKey) then 1
        else 0
    end QuoteCount,
    case
        when isPolicy = 1 and Idx = min(Idx) over (partition by QuoteKey) then 1
        else 0
    end PolicyCount,
	Sellprice,
	Premium,
	StampDuty,
    GST,
    Commission,
    CommissionGST
from
    (
        select 
            q.OutletKey,
            QuoteDate,
            case
                when qt.IssueDate < QuoteDate then QuoteDate
                else qt.IssueDate
            end IssueDate,
            QuoteKey,
            isPolicy,
            case
                when isnull(Tier1, 0) > 0 then 'Tier 1'
                when isnull(Tier3, 0) > 0 then 'Tier 3'
                when isnull(Tier4, 0) > 0 then 'Tier 4'
                else 'Tier 2'
            end Tier,
            row_number() over (order by q.QuoteKey, qt.IssueDate) Idx,
		    isnull(qt.Sellprice, 0) Sellprice,
		    isnull(qt.Premium, 0) Premium,
		    isnull(qt.PremiumSD, 0) StampDuty,
            isnull(qt.PremiumGST, 0) GST,
            isnull(qt.Commission, 0) Commission,
            isnull(qt.CommissionGST, 0) CommissionGST
        from
            corpQuotes q with(nolock)
            outer apply
            (
                select 
                    sum
                    (
                        case
                            when qc.ClosingTypeID = 10 then 1
                            else 0
                        end
                    ) Tier1,
                    sum
                    (
                        case
                            when qc.ClosingTypeID = 11 then 1
                            else 0
                        end
                    ) Tier3,
                    sum
                    (
                        case
                            when qc.ClosingTypeID = 12 then 1
                            else 0
                        end
                    ) Tier4
                from
                    corpClosing qc with(nolock)
                where
                    qc.QuoteKey = q.QuoteKey
            ) qc
            outer apply
            (
                select 
                    convert(datetime, convert(varchar(8), AccountingPeriod, 120) + '01') IssueDate,
		            isnull(qt.UWSaleExGST, 0) + isnull(qt.GSTGross, 0) Sellprice,
		            isnull(qt.UWSaleExGST, 0) - (isnull(qt.DomStamp, 0) + isnull(qt.IntStamp, 0)) Premium,
		            isnull(qt.DomStamp, 0) + isnull(qt.IntStamp, 0) PremiumSD,
                    isnull(qt.GSTGross, 0) PremiumGST,
                    isnull(qt.AgtCommExGST, 0) + isnull(qt.GSTAgtComm, 0) Commission,
                    isnull(qt.GSTAgtComm, 0) CommissionGST
                from
                    corpTaxes qt
                where
                    qt.QuoteKey = q.QuoteKey and
                    qt.PropBal in ('P', 'B') and
                    qt.AccountingPeriod is not null
            ) qt
    ) q
GO
