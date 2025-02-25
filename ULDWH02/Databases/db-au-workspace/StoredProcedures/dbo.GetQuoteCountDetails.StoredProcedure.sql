USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[GetQuoteCountDetails]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetQuoteCountDetails]
AS
BEGIN

 if object_id('cdgquote2') is not null    
        drop table cdgquote2 

		BEGIN
select 
        cast (d1.Date as date) QuoteDate,
        count(distinct q.SessionID) as  QuoteCount,
		count(distinct q.SessionID) QuoteSessionCount,        
        s.Domain,
        q1.BusinessUnitName as BusinessUnit
    into cdgquote2
    from 
		[WAREHOUSEV2.POWEREDBYCOVERMORE.COM].Impulse2DW.dbo.factSession s
        inner join [WAREHOUSEV2.POWEREDBYCOVERMORE.COM].Impulse2DW.dbo.factQuote q on s.factSessionID = q.SessionID
        inner join [WAREHOUSEV2.POWEREDBYCOVERMORE.COM].Impulse2DW.dbo.DimBusinessUnit q1 on q.BusinessUnitID = q1.DimBusinessUnitID
        inner join [WAREHOUSEV2.POWEREDBYCOVERMORE.COM].Impulse2DW.dbo.DimDate d1 on d1.DimDateID = q.QuoteTransactionDateID
    where
		q1.BusinessUnitName in ('AirNZ-NZ-WL','AUPost','CMAU-B2C','FMG-NZ-WL','HKE-WL','IAL-NRMA2','Medibank','VirginNZ-INT','Westpac-NZ') and
        d1.Date >= CONVERT(DATE,GETDATE()-30,103) and
        d1.Date <= CONVERT(DATE,GETDATE(),103)
	group by
        cast (d1.Date as date),
        case when q.TotalGrossPremium is not null then 1
			 else 0
		end,
        case when s.IsPolicyPurchased = 1 then 1
			 else 0
		end,
        s.Domain,
        q1.BusinessUnitName
		   
	union all

    select 
        cast(d1.Date as date) QuoteDate,
        count(distinct s.factSessionID) as  QuoteCount,
        count(distinct s.factSessionID) as  QuoteSessionCount,
        s.Domain,
        bu.BusinessUnitName as BusinessUnit
    from 
		[WAREHOUSEV2.POWEREDBYCOVERMORE.COM].Impulse2DW.dbo.factSession s
        inner join [WAREHOUSEV2.POWEREDBYCOVERMORE.COM].Impulse2DW.dbo.DimDate d1 on d1.DimDateID = s.SessionCreateDateID
		inner join [WAREHOUSEV2.POWEREDBYCOVERMORE.COM].Impulse2DW.dbo.DimBusinessUnit bu on s.BusinessUnitID = bu.DimBusinessUnitID
	   where
        d1.Date >= CONVERT(DATE,GETDATE()-30,103) and
        d1.Date <= CONVERT(DATE,GETDATE(),103) and
		s.BusinessUnitID not in 
		(	26, --AirNZ-NZ-WL
			20, --AUPost
			59, --CMAU-B2C
			87, --FMG-NZ-WL
			80, --HKE-WL
			90, --IAL-NRMA2
			32, --Medibank
			57, --VirginNZ-INT
			60	--Westpac-NZ
		)
	group by        
        cast(d1.Date as date),
        s.Domain,
        bu.BusinessUnitName

		END


select quotedate,source,bicount,FactQuount from (
select quotedate,sum(quotecount) as source from   cdgquote2  where domain='au'
group by quotedate)
as a 
left join 
(
select quotesource,convert(date,quotedate,103) as date,sum(quotecount) as bicount from [db-au-cmdwh].[dbo].penQuoteSummary where  
convert(date,quotedate,103)>=CONVERT(DATE,GETDATE()-30,103) and convert(date,quotedate,103)<=CONVERT(DATE,GETDATE(),103) and countrykey='au'
and quotesource=3
group by quotesource,convert(date,quotedate,103)
) as b on a.quotedate=b.date
left join
(
select CountryCode,convert(date,date,103) as Date,sum(QuoteCount) as FactQuount from [db-au-star]..factQuoteSummary as a inner join 
[db-au-star]..dimDomain as b on a.DomainSK=b.DomainSK
inner join  [db-au-star]..Dim_Date as c on a.DateSK=c.Date_SK where a.DomainSK=2
and convert(date,date,103)>=CONVERT(DATE,GETDATE()-30,103) and convert(date,date,103)<=CONVERT(DATE,GETDATE(),103)
group by CountryCode,convert(date,date,103)
) as c on a.quotedate=c.Date

END
GO
