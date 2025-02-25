USE [db-au-workspace]
GO
/****** Object:  View [dbo].[rpt_cba_QuoteDetails_vw]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[rpt_cba_QuoteDetails_vw] as 
	select	CAST([db-au-cmdwh].dbo.xfn_ConvertUTCToLocal(quoteDateUTC,'AUS Eastern Standard Time') as date) QuoteDateAEST, 
			po.OutletName,
			QD.Destination, 
			--Q.isPurchased, 
			QD.ISO2Code,
			QD.ISO3Code,
			COUNT(DISTINCT Q.QuoteID) as QuoteCount,
			COUNT(DISTINCT CASE WHEN Q.isPurchased = 'true' THEN Q.QuoteID END)  as PurchasedCount
	from [db-au-cba].dbo.impulse_Quotes Q
	left join [db-au-cba].dbo.impulse_QuoteDestinations D ON Q.QuoteID = D.QuoteID AND D.DestinationOrdered = 0
	outer apply
		(
				SELECT UPPER(dest.Destination) AS Destination,
					   coun.ISO2Code, coun.ISO3Code
				FROM
					( SELECT Destination,
							 Max(LoadID) AS LoadID
					  FROM   [db-au-cba].[dbo].[dimDestination]
					  GROUP  BY Destination) dest
				OUTER APPLY ( SELECT TOP 1 ISO2Code, ISO3Code
							  FROM [db-au-cba].[dbo].[dimDestination]
							  WHERE LoadID = dest.LoadID
								 AND Destination = dest.Destination) Coun
				where D.Destination = Coun.ISO3Code
		) QD
	JOIN [db-au-cba].dbo.penOutlet po on Q.issuerAffiliateCode = po. AlphaCode AND po.OutletStatus = 'Current'
	where po.GroupCode = 'MB'
	AND CAST([db-au-cmdwh].dbo.xfn_ConvertUTCToLocal(quoteDateUTC,'AUS Eastern Standard Time') as date) >= '20180101'
	GROUP BY CAST([db-au-cmdwh].dbo.xfn_ConvertUTCToLocal(quoteDateUTC,'AUS Eastern Standard Time') as date), 
			po.OutletName,
			QD.Destination, 
			QD.ISO2Code,
			QD.ISO3Code
GO
