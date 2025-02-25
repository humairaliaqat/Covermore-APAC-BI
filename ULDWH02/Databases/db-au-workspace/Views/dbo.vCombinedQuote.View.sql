USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vCombinedQuote]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vCombinedQuote] as
select --top 100
    dateadd(year, 1, dd.Date) as YAGODate,
    dd.Date,
    do.OutletAlphaKey,
    dc.UserName as LoginName,
    dp.ProductCode,
    q.QuoteSessionCount,
	dc.ConsultantName as UserName,
    case
        --use quote count for integrated
        when exists
        (
            select
                null
            from
                [db-au-star]..dimIntegratdOutlet r
            where
                r.OutletSK = q.OutletSK
        ) then q.QuoteCount
        when exists
        (
            select
                null
            from
                [db-au-star].dbo.dimConsultant c
            where
                c.ConsultantSK = q.ConsultantSK and
                c.ConsultantName like '%webuser%'
        ) then q.QuoteSessionCount
        else q.QuoteCount
    end QuoteCount,
    dp.ProductKey
from
    [db-au-star].dbo.factQuoteSummary q
    inner join [db-au-star].dbo.Dim_Date dd with(nolock) on
        dd.Date_SK = q.DateSK
    inner join [db-au-star].dbo.dimOutlet do with(nolock) on
        do.OutletSK = q.OutletSK
    inner join [db-au-star].dbo.dimConsultant dc with(nolock) on
        dc.ConsultantSK = q.ConsultantSK
    inner join [db-au-star].dbo.dimProduct dp with(nolock) on
        dp.ProductSK = q.ProductSK



GO
