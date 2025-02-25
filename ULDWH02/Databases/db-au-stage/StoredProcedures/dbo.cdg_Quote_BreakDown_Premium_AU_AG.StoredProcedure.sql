USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[cdg_Quote_BreakDown_Premium_AU_AG]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
    
  
CREATE Procedure [dbo].[cdg_Quote_BreakDown_Premium_AU_AG]        
        
  AS      
  BEGIN      
      
insert into cdg_Quote_Addon_Premium_AU_AG(sessiontoken,LineTitle,LineCategoryCode,LineGrossPrice,LineDiscountPercent,LineDiscountedGross,LineActualGross,LineFormattedActualGross,QuoteTransactionDateTime,SessionID)        
        
        
select distinct sessiontoken,LineTitle,LineCategoryCode,LineGrossPrice,LineDiscountPercent,LineDiscountedGross,LineActualGross,LineFormattedActualGross,QuoteTransactionDateTime,SessionID from  (        
 select a.SessionToken,[key],value,QuoteTransactionDateTime,SessionID from (        
 select        
*        
from [db-au-stage].[dbo].[cdg_SessionPartnerMetaData_AU_AG]        
as a cross apply openjson(a.PartnerMetaData)        
   ) as a inner join [db-au-stage].[dbo].[cdg_factSession_AU_AG] as b on a.SessionToken=b.SessionToken          
   inner join  [db-au-stage].[dbo].[cdg_dimDate_AU_AG] as c on b.SessionCreateDateID=c.dimdateid         
   inner join [db-au-stage].[dbo].[cdg_factQuote_AU_AG] as d on b.FactSessionID=d.SessionID        
   where convert(date,date,103)>='2024-03-01' and d.BusinessUnitID=142  and         
   [key]='QuoteAddonPriceData'        
) as a outer apply        
OPENJSON (        
     JSON_QUERY(        
        value,        
        '$'        
     )        
   )        
  with (        
      LineTitle varchar(255) '$.LineTitle',        
      LineCategoryCode varchar(255) '$.LineCategoryCode',        
      LineGrossPrice  varchar(255) '$.LineGrossPrice',        
      LineDiscountPercent  varchar(255) '$.LineDiscountPercent',        
      LineDiscountedGross   varchar(255) '$.LineDiscountedGross',        
      LineActualGross   varchar(255) '$.LineActualGross',        
      LineFormattedActualGross   varchar(255) '$.LineFormattedActualGross'        
   ) AS r         
      
      
      
      
UPDATE cdg_Quote_Addon_Premium_AU_AG      
SET Link_ID=B.LinkID,      
GCLID=B.gclid,      
GA_Client_ID=b.gaClientID,      
Quote_Reference_ID=b.Quote_Reference_ID,      
Quote_Transaction_ID=b.Quote_Transaction_ID      
      
 FROM  cdg_Quote_Addon_Premium_AU_AG AS A INNER JOIN (       
      
select  DISTINCT Sessiontoken,                       
json_value([PartnerMetaData],'$.LinkID') as LinkID,                      
json_value([PartnerMetaData],'$.gclid') as gclid,                        
json_value([PartnerMetaData],'$.gaClientID') as gaClientID,                    
json_value([PartnerMetaData],'$.quoteReference') as Quote_Reference_ID,                    
json_value([PartnerMetaData],'$.quoteTransactionID') as Quote_Transaction_ID                
FROM (                
SELECT Sessiontoken,[PartnerMetaData] from [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG                                                       
as Y2X with(nolock) WHERE --y2x.Sessiontoken=e.SessionToken AND                        
SessionToken IN (                      
                      
SELECT SessionToken from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 with(nolock) inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                            
as b with(nolock) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c with(nolock) on a1.QuoteTransactionTimeID=c.DimTimeID                       
inner join  [db-au-stage].dbo.cdg_factsession_AU_AG AS D with(nolock) ON A1.SESSIONID=D.FACTSESSIONID                                         
WHERE A1.BusinessUnitID=142 AND A1.CampaignID=335 and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)=convert(date,getdate()-1,103)  
AND A1.ProductID<>'-1'  
AND                      
 (                    
 PartnerMetaData like '%LinkID%' or                    
 PartnerMetaData like '%gclid%' or                    
 PartnerMetaData like '%gaClientID%' or                    
 PartnerMetaData like '%quoteReference%' or                    
 PartnerMetaData like '%quoteTransactionID%'                 
 ))) as a      
 ) AS B ON A.sessiontoken=B.SessionToken      
      
      
      
 UPDATE cdg_Quote_Addon_Premium_AU_AG      
SET Link_ID=B.LinkID,      
GCLID=B.gclid,      
GA_Client_ID=b.gaClientID,      
Quote_Reference_ID=b.Quote_Reference_ID,      
Quote_Transaction_ID=b.Quote_Transaction_ID      
      
 FROM  cdg_Quote_Addon_Premium_AU_AG AS A INNER JOIN (         
 select                 
Sessiontoken,                
json_value([PartnerMetaData],'$.LinkID') as LinkID,                        
json_value([PartnerMetaData],'$.gclid') as gclid,                        
json_value([PartnerMetaData],'$.gaClientID') as gaClientID,                    
json_value([PartnerMetaData],'$.quoteReference') as Quote_Reference_ID,                    
json_value([PartnerMetaData],'$.quoteTransactionID') as Quote_Transaction_ID                
                
FROM (                
                
   SELECT  [PartnerMetaData],Sessiontoken from [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG                                                       
as Y2X with(nolock) WHERE                         
                      
SessionToken IN (                      
                      
SELECT SessionToken from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 with(nolock) inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                            
as b with(nolock) on A1.QuoteTransactionDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID                       
inner join  [db-au-stage].dbo.cdg_factsession_AU_AG AS D ON A1.SESSIONID=D.FACTSESSIONID                                         
WHERE A1.BusinessUnitID=142 AND A1.CampaignID=335 and ProductID<>'-1'                      
and sessionid in (              
              
SELECT sessionid from [db-au-stage].dbo.cdg_factQuote_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG     as b on A1.QuoteTransactionDateID=b.DimDateID inner join        
[db-au-stage].dbo.cdg_dimTime_AU as c  on a1.QuoteTransactionTimeID=c.DimTimeID       
        
         
  and ProductID<>'-1'            
                                                 
WHERE BusinessUnitID=142 AND CampaignID=335                               
Except                              
select Lead_Number from [db-au-cmdwh].dbo.Quote_Tbl   )             
              
              
)                     
                      
                      
AND                      
 (                    
 PartnerMetaData like '%LinkID%' or                    
 PartnerMetaData like '%gclid%' or                    
 PartnerMetaData like '%gaClientID%' or                    
 PartnerMetaData like '%quoteReference%' or                    
 PartnerMetaData like '%quoteTransactionID%'                    
 )                    
 ) AS A      
      
 ) AS B ON A.sessiontoken=B.SessionToken      
      
      
      
 END 
GO
