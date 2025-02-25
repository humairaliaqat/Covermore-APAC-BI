USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[cdg_SessionPartnerMetaData_AU_AG]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[cdg_SessionPartnerMetaData_AU_AG]                
AS                
BEGIN                
                
                
                
with cte (PartnerMetaData,QuoteTransactionDateTime,SessionToken,gaClientID,rno)                
as                 
(                
select PartnerMetaData,QuoteTransactionDateTime ,SessionToken,json_value([PartnerMetaData],'$.gaClientID') as gaClientID,                
ROW_NUMBER()over(partition by sessiontoken order by QuoteTransactionDateTime desc) as rno  from                 
[db-au-stage].dbo.cdg_SessionPartnerMetaData_AU_AG where SessionToken in (                
SELECT distinct SessionToken FROM(                                                                                                                                                
SELECT SessionToken from [db-au-stage].dbo.cdg_factSession_AU_AG AS A1 inner join [db-au-stage].dbo.cdg_dimdate_au_AG                                      
as b on A1.SessionCreateDateID=b.DimDateID inner join  [db-au-stage].dbo.cdg_dimTime_AU_AG as c  on a1.SessionCreateTimeID=c.DimTimeID                                          
--WHERE BusinessUnitID IN (142,146)               
--and convert(date,dbo.xfn_ConvertUTCtoLocal(b.Date+''+c.StandardTime,'E. Australia Standard TIme'),103)>=convert(date,getdate()-7,103)                                                                            
                                                  
) AS A                   
            
)                
)                
DELETE from cte where rno>1                
END 
GO
