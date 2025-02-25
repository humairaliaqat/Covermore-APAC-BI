USE [db-au-workspace]
GO
/****** Object:  View [dbo].[Quote_Count]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Quote_Count]
as
(
SELECT convert(date,[db-au-stage].dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)
as Date,count(sessionid) as Quote_C0unt from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG     as b on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID                             
WHERE BusinessUnitID=142 AND CampaignID=335
group by convert(date,[db-au-stage].dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103) 
)
GO
