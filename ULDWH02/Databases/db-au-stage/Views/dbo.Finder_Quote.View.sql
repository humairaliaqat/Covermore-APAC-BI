USE [db-au-stage]
GO
/****** Object:  View [dbo].[Finder_Quote]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Finder_Quote]            
as            
(            
SELECT distinct Date+''+Time as Quote_Date_Time,D.SessionToken,SessionID as   QuoteId, fdclid            
  FROM [db-au-cmdwh]..cdg_factSession_AU_AG_Finder AS A INNER JOIN [db-au-cmdwh]..cdg_factQuote_AU_AG as b on a.FactSessionID=b.SessionID            
INNER JOIN [db-au-stage].dbo.cdg_dimAffiliateCode_AU AS C ON A.AffiliateCodeID=C.DimAffiliateCodeID            
INNER JOIN [db-au-stage].dbo.cdg_dimdate_au as E on b.QuoteTransactionDateID=e.DimDateID            
INNER JOIN [db-au-stage].dbo.cdg_dimtime_au as F on b.QuoteTransactionTimeID=F.DimTimeID            
INNER JOIN           
(SELECT SessionToken,json_value([PartnerMetaData],'$.fdclid') as fdclid FROM [db-au-stage]..cdg_SessionPartnerMetaData_AU WHERE SessionToken IN (          
 SELECT DISTINCT SessionToken FROM [db-au-cmdwh]..cdg_factSession_AU_AG_Finder  AS A WITH (NOLOCK)        
 INNER JOIN [db-au-stage].dbo.cdg_dimAffiliateCode_AU AS C ON A.AffiliateCodeID=C.DimAffiliateCodeID WHERE AffiliateCode='MBN0042'))          
          
as d on a.SessionToken=d.SessionToken            
where AffiliateCode='MBN0042'             
and  convert(date,date,103)>='2024-02-29' and  convert(date,date,103)<'2024-03-04'             
)   
GO
