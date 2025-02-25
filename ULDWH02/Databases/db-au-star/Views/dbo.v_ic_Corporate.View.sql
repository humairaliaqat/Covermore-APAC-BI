USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_Corporate]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [db-au-star]
--GO

--/****** Object:  View [dbo].[v_ic_Corporate]    Script Date: 7/05/2019 8:16:55 AM ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO





CREATE view [dbo].[v_ic_Corporate]
as
select --top 10000
    q.BIRowID * -10 PolicySK,
    q.BIRowID,
    (
        select top 1
            dt.Date_SK
        from
            [db-au-star].dbo.Dim_Date dt
        where
            dt.[Date] = convert(date, convert(varchar(8), qt.AccountingPeriod, 120) + '01')
    ) DateSK,
    (
        select top 1
            dom.DomainSK
        from
            [db-au-star].dbo.dimDomain dom
        where
            dom.CountryCode = q.CountryKey
    ) DomainSK,
    (
        select top 1
            do.OutletSK
        from
            [db-au-star].dbo.dimOutlet do
        where
			do.OutletKey = o.OutletKey and
            convert(date, q.IssuedDate) >= do.ValidStartDate and 
            convert(date, q.IssuedDate) <  dateadd(day, 1, do.ValidEndDate)
    ) OutletSK,
    (
        select top 1
            product.ProductSK
        from
            [db-au-star].dbo.dimProduct product
        where
            product.ProductKey = q.CountryKey + '-CM7-CMC-Corporate-Corporate-Corporate'
    ) ProductSK,
	q.CountryKey Country,
    o.OutletKey,
	q.QuoteKey,
	q.PolicyKey,
    [db-au-cmdwh].dbo.fn_GetUnderWriterCode('CM', q.CountryKey, o.AlphaCode, convert(date, q.IssuedDate)) UnderwriterCode,
    isnull
    (
        (
            select top 1
                DurationSK
            from
                [db-au-star]..dimDuration 
            where
                Duration = (datediff(day, q.PolicyStartDate, q.PolicyExpiryDate) + 1)
        ),
        -1
    ) DurationSK,
	convert(date, convert(varchar(8), qt.AccountingPeriod, 120) + '01') [Date],
    convert(date, qt.AccountingPeriod) AccountingPeriod,
    convert(date, q.IssuedDate) IssueDate,
    q.PolicyNo PolicyNumber,
    convert(varchar(max), q.PolicyNo) ExposedPolicyNumber,
	convert(date, q.PolicyStartDate) PolicyStartDate,
	convert(date, q.PolicyExpiryDate) PolicyExpiryDate,
    isnull(q.Excess, 0) Excess,
    q.CountryKey + '-CM7-CMC-Corporate-Corporate-Corporate' ProductKey,
	isnull(qt.UWSaleExGST, 0) - (isnull(qt.DomStamp, 0) + isnull(qt.IntStamp, 0)) Premium,
	isnull(qt.UWSaleExGST, 0) + isnull(qt.GSTGross, 0) Sellprice,
	isnull(qt.DomStamp, 0) + isnull(qt.IntStamp, 0) PremiumSD,
    isnull(qt.GSTGross, 0) PremiumGST,
    isnull(qt.AgtCommExGST, 0) + isnull(qt.GSTAgtComm, 0) Commission,
    isnull(qt.GSTAgtComm, 0) CommissionGST,
    convert(date, q.PolicyStartDate) DepartureDateSK,
    convert(date, q.PolicyExpiryDate) ReturnDateSK,
    convert(date, q.IssuedDate) IssueDateSK,
    case
        when
            q.PolicyNo is not null and
            qt.PropBal = 'P' and 
            qt.ItemType = 'DEST' 
        then 1
        else 0
    end PolicyCount,
    case
        when row_number() over (partition by q.QuoteKey order by isnull(qt.TaxID, 0)) = 1 then 1
        else 0
    end QuoteCount,
    case
        when isnull(qc.Tier1, 0) > 0 then 'Tier 1'
        when isnull(qc.Tier3, 0) > 0 then 'Tier 3'
        when isnull(qc.Tier4, 0) > 0 then 'Tier 4'
        else 'Tier 2'
    end Tier
from
    [db-au-cmdwh].dbo.corpQuotes q with(nolock)
    left join [db-au-cmdwh].dbo.corpTaxes qt with(nolock) on
		qt.QuoteKey = q.QuoteKey and
        qt.AccountingPeriod >= '2011-07-01'
    left join [db-au-cmdwh].dbo.penOutlet o with(nolock) on
		o.CountryKey = q.CountryKey and
		o.AlphaCode = q.AgencyCode and
		o.OutletStatus = 'Current'
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
            [db-au-cmdwh].dbo.corpClosing qc with(nolock)
        where
            qc.QuoteKey = q.QuoteKey
    ) qc
where
    q.IssuedDate >= '2015-01-01'





GO
