USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[cdg_Quote_BreakDown_Premium_AU_AG_ALLJVs]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[cdg_Quote_BreakDown_Premium_AU_AG_ALLJVs]  
  
as   
BEGIN  
insert into CDG_Quote_Addon_Premium_AU_AG_Temp(sessiontoken,LineTitle,LineCategoryCode,LineGrossPrice,LineDiscountPercent,LineDiscountedGross,LineActualGross,LineFormattedActualGross,QuoteTransactionDateTime,SessionID)  
  
  
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
   end
GO
