USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vpenPolicyFinanceProductCode_Test007]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vpenPolicyFinanceProductCode_Test007]     
/*    
    20140926, LS, change mapping to use dimProduct    
 20180831, LT, get FinanceProductCode from penPolicy, else use dimProduct    
 20181112, LT, Remove reference to penProductPlan. This table has been decommissioned. It is still in use for TRIPS policy, but no longer relevant for Penguin policy.    
 20181204, LT, Re-instated pp.FinanceProductCode. UK finance codes are not populate in Penguin.    
*/    
as    
select     
    pt.PolicyTransactionKey,    
    isnull(isnull(nullif(
	case when p.CountryKey='AU' and p.PrimaryCountry='New Zealand' and AreaType='International'
	then 'TT'+substring(p.FinanceProductCode,2,len(p.FinanceProductCode))
	when p.CountryKey='NZ' and p.PrimaryCountry='Australia' and AreaType='International' 
    then 'TT'+substring(p.FinanceProductCode,2,len(p.FinanceProductCode)) else p.FinanceProductCode
	end, 'Unknown'),map.FinanceProductCode),pp.FinanceProductCode) as FinanceProductCode,    
    map.OldFinanceProductCode,    
    GLProductParent,    
    GLProductType    
from    
    [db-au-cmdwh].[dbo].penPolicyTransSummary pt    
    inner join [db-au-cmdwh].[dbo].penPolicy p on    
        p.PolicyKey = pt.PolicyKey    
    outer apply    
    (    
        select top 1    
            pp.PlanName,    
   pp.FinanceProductCode    
        from    
            [db-au-cmdwh].[dbo].penProductPlan pp    
            inner join [db-au-cmdwh].[dbo].penOutlet o on    
                o.OutletKey = pp.OutletKey and    
                o.OutletStatus = 'Current'    
        where    
            o.OutletAlphaKey = pt.OutletAlphaKey and    
            pp.ProductId = p.ProductID and    
            pp.UniquePlanId = p.UniquePlanID    
    ) pp    
    outer apply    
    (    
        select    
         isnull(p.CountryKey,'') + '-' +     
         isnull(p.CompanyKey,'') + '' +     
         convert(varchar,isnull(p.DomainID,0)) + '-' +     
         isnull(p.ProductCode,'') + '-' +     
         isnull(p.ProductName,'') + '-' +     
         isnull(p.ProductDisplayName,'') + '-' +     
         isnull(p.PlanName,isnull(p.PlanDisplayName,'')) ProductKey    
    ) pk    
    outer apply    
    (    
        select top 1    
            FinanceProductCode,    
            FinanceProductCodeOld OldFinanceProductCode    
        from    
            [db-au-star]..dimProduct dp    
        where    
            dp.ProductKey = pk.ProductKey    
    ) map    
    outer apply    
    (    
        select top 1    
            gp.Product_Parent_Code GLProductParent,    
            gp.Product_Type_Code GLProductType    
        from    
            [db-au-star]..Dim_GL_Product gp    
        where    
            gp.Product_Code = map.FinanceProductCode    
    ) gp    
        
    
    
    
    
    
    
    
GO
