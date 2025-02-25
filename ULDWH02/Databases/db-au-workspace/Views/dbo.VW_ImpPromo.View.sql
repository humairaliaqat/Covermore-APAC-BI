USE [db-au-workspace]
GO
/****** Object:  View [dbo].[VW_ImpPromo]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_ImpPromo]  
AS  
(  
select b.CountryKey,b.CompanyKey,c.PolicyTransactionKey,b.PolicyNumber,a.PromoCodeID as ImpPromoID,a.PROMOCODE as ImpPromoCode,a.PromoType as ImpPromoType,a.DiscountPercent as ImpDiscount,PROMOCODE_Additional,IsMember from [db-au-stage]..ETL_PROMO as a inner join 
[db-au-cmdwh]..penPolicy as b on a.PolicyNumber=b.PolicyNumber  
inner join [db-au-cmdwh]..penPolicyTransaction as c on b.PolicyKey=c.PolicyKey where TransactionType='Base' and TransactionStatus='Active'

)  
GO
