USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penQuotePlan]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE Procedure [dbo].[etlsp_cmdwh_penQuotePlan]  
as  
begin  
  
if OBJECT_ID('etl_penQuotePlan') is not null  
drop table etl_penQuotePlan  
  
select      CountryKey,  
            CompanyKey,  
   DomainKey,  
      PrefixKey + convert(varchar, qsp.QuoteID) as QuoteCountryKey,  
         PrefixKey + convert(varchar, qsp.QuotePlanID) as QuotePlanKey,  
   DomainID,  
   qsp.QuoteID,  
   ProductCode,  
   ProductName,  
   PlanID,  
   PlanName,  
   PlanCode,  
   PlanType,  
   IsUpSell,  
   Excess,  
   IsDefaultExcess,  
   PolicyStart,  
   PolicyEnd,  
            DaysCovered,  
            MaxDuration,  
         GrossPremium,  
         PDSUrl,  
         SortOrder,  
         PlanDisplayName,  
         RiskNet,  
         PlanProductPricingTierID,  
         VolumeCommission,  
         Discount,  
         CommissionTier,  
         qsp.Area,  
         COI,  
         UniquePlanID,  
         TripCost,  
         PolicyID,  
         IsPriceBeat,  
         CancellationValueText,  
         ProductDisplayName,  
         AreaID,  
         AgeBandID,  
         DurationID,  
         ExcessID,  
         LeadTimeID,  
         RateCardID,  
         IsSelected,  
         qsp.AreaCode  
   into etl_penquoteplan  
   from  penguin_tblquoteplan_aucm as qsp inner join penguin_tblquote_aucm  
   as q on qsp.QuoteID=q.QuoteID  
     cross apply dbo.fn_GetDomainKeys(q.DomainID, 'CM', 'AU') dk  
  
            union all  
   select   
    CountryKey,  
             CompanyKey,  
    DomainKey,  
    PrefixKey + convert(varchar, qsp.QuoteID) as QuoteCountryKey,  
    PrefixKey + convert(varchar, qsp.QuotePlanID) as QuotePlanKey,  
    DomainID,  
   qsp.QuoteID,  
   ProductCode,  
   ProductName,  
   PlanID,  
   PlanName,  
   PlanCode,  
   PlanType,  
   IsUpSell,  
   Excess,  
   IsDefaultExcess,  
   PolicyStart,  
   PolicyEnd,  
            DaysCovered,  
            MaxDuration,  
         GrossPremium,  
         PDSUrl,  
         SortOrder,  
         PlanDisplayName,  
         RiskNet,  
         PlanProductPricingTierID,  
         VolumeCommission,  
         Discount,  
         CommissionTier,  
         qsp.Area,  
         COI,  
         UniquePlanID,  
         TripCost,  
         PolicyID,  
         IsPriceBeat,  
         CancellationValueText,  
         ProductDisplayName,  
         AreaID,  
         AgeBandID,  
         DurationID,  
         ExcessID,  
         LeadTimeID,  
         RateCardID,  
         IsSelected,  
         qsp.AreaCode from penguin_tblQuotePlan_autp as qsp inner join penguin_tblquote_autp  
   as q on qsp.QuoteID=q.QuoteID  
     cross apply dbo.fn_GetDomainKeys(q.DomainID, 'TIP', 'AU') dk  
     
   union all  
  
   select   
    CountryKey,  
             CompanyKey,  
    DomainKey,  
    PrefixKey + convert(varchar, qsp.QuoteID) as QuoteCountryKey,  
    PrefixKey + convert(varchar, qsp.QuotePlanID) as QuotePlanKey,  
    DomainID,  
   qsp.QuoteID,  
   ProductCode,  
   ProductName,  
   PlanID,  
   PlanName,  
   PlanCode,  
   PlanType,  
   IsUpSell,  
   Excess,  
   IsDefaultExcess,  
   PolicyStart,  
   PolicyEnd,  
            DaysCovered,  
            MaxDuration,  
         GrossPremium,  
         PDSUrl,  
         SortOrder,  
         PlanDisplayName,  
         RiskNet,  
         PlanProductPricingTierID,  
         VolumeCommission,  
         Discount,  
         CommissionTier,  
         qsp.Area,  
         COI,  
         UniquePlanID,  
         TripCost,  
         PolicyID,  
         IsPriceBeat,  
         CancellationValueText,  
         ProductDisplayName,  
         AreaID,  
         AgeBandID,  
         DurationID,  
         ExcessID,  
         LeadTimeID,  
         RateCardID,  
         IsSelected,  
         qsp.AreaCode from penguin_tblQuotePlan_ukcm as qsp inner join penguin_tblQuote_ukcm  
   as q on qsp.QuoteID=q.QuoteID  
     cross apply dbo.fn_GetDomainKeys(q.DomainID, 'CM', 'UK') dk  
     
   union all  
  
   select   
   CountryKey,  
         CompanyKey,  
   DomainKey,  
   PrefixKey + convert(varchar, qsp.QuoteID) as QuoteCountryKey,  
   PrefixKey + convert(varchar, qsp.QuotePlanID) as QuotePlanKey,  
   DomainID,  
   qsp.QuoteID,  
   ProductCode,  
   ProductName,  
   PlanID,  
   PlanName,  
   PlanCode,  
   PlanType,  
   IsUpSell,  
   Excess,  
   IsDefaultExcess,  
   PolicyStart,  
   PolicyEnd,  
            DaysCovered,  
            MaxDuration,  
         GrossPremium,  
         PDSUrl,  
         SortOrder,  
         PlanDisplayName,  
         RiskNet,  
         PlanProductPricingTierID,  
         VolumeCommission,  
         Discount,  
         CommissionTier,  
         qsp.Area,  
         COI,  
         UniquePlanID,  
         TripCost,  
         PolicyID,  
         IsPriceBeat,  
         CancellationValueText,  
         ProductDisplayName,  
         AreaID,  
         AgeBandID,  
         DurationID,  
         ExcessID,  
         LeadTimeID,  
         RateCardID,  
         IsSelected,  
         qsp.AreaCode   
   from penguin_tblQuotePlan_uscm as qsp inner join penguin_tblQuote_uscm  
   as q on qsp.QuoteID=q.QuoteID  
     cross apply dbo.fn_GetDomainKeys(q.DomainID, 'CM', 'US') dk  
  
    if object_id('[db-au-cmdwh].dbo.penQuoteSelectedPlan') is null      
    begin   
  
 CREATE TABLE [dbo].[penQuoteSelectedPlan](  
 [BIRowID] [bigint] IDENTITY(1,1) NOT NULL,  
 [CountryKey] [varchar](2) NULL,  
 [CompanyKey] [varchar](5) NULL,  
 [DomainKey] [varchar](41) NULL,  
 [QuoteCountryKey] [varchar](41) NULL,  
 [QuotePlanKey] [varchar](41) NULL,  
 [DomainID] [int] NOT NULL,  
 [QuoteID] [int] NULL,  
 [ProductCode] [nvarchar](50) NULL,  
 [ProductName] [nvarchar](50) NOT NULL,  
 [PlanID] [int] NULL,  
 [PlanName] [nvarchar](50) NOT NULL,  
 [PlanCode] [nvarchar](50) NULL,  
 [PlanType] [nvarchar](50) NOT NULL,  
 [IsUpSell] [bit] NOT NULL,  
 [Excess] [money] NOT NULL,  
 [IsDefaultExcess] [bit] NOT NULL,  
 [PolicyStart] [datetime] NOT NULL,  
 [PolicyEnd] [datetime] NOT NULL,  
 [DaysCovered] [int] NULL,  
 [MaxDuration] [int] NULL,  
 [GrossPremium] [money] NOT NULL,  
 [PDSUrl] [varchar](100) NULL,  
 [SortOrder] [int] NULL,  
 [PlanDisplayName] [nvarchar](100) NULL,  
 [RiskNet] [money] NULL,  
 [PlanProductPricingTierID] [int] NULL,  
 [VolumeCommission] [decimal](18, 9) NOT NULL,  
 [Discount] [decimal](18, 9) NOT NULL,  
 [CommissionTier] [varchar](50) NULL,  
 [Area] [nvarchar](100) NULL,  
 [COI] [varchar](100) NULL,  
 [UniquePlanID] [int] NULL,  
 [TripCost] [nvarchar](100) NULL,  
 [PolicyID] [int] NULL,  
 [IsPriceBeat] [bit] NOT NULL,  
 [CancellationValueText] [nvarchar](50) NULL,  
 [ProductDisplayName] [nvarchar](50) NULL,  
 [AreaID] [int] NULL,  
 [AgeBandID] [int] NULL,  
 [DurationID] [int] NULL,  
 [ExcessID] [int] NULL,  
 [LeadTimeID] [int] NULL,  
 [RateCardID] [int] NULL,  
 [IsSelected] [bit] NULL,  
 [AreaCode] [nvarchar](3) NULL  
)   
end  
else  
begin  
        delete [db-au-cmdwh].dbo.penQuoteSelectedPlan      
        where      
            QuoteCountryKey in      
            (      
                select distinct      
                    QuoteCountryKey      
                from      
                    etl_penquoteplan      
            )    
end  
insert into [db-au-cmdwh].dbo.penQuoteSelectedPlan with (tablock)  
(  
  
   CountryKey,  
         CompanyKey,  
   DomainKey,  
   QuoteCountryKey,  
   QuotePlanKey,  
   DomainID,  
   QuoteID,  
   ProductCode,  
   ProductName,  
   PlanID,  
   PlanName,  
   PlanCode,  
   PlanType,  
   IsUpSell,  
   Excess,  
   IsDefaultExcess,  
   PolicyStart,  
   PolicyEnd,  
            DaysCovered,  
            MaxDuration,  
         GrossPremium,  
         PDSUrl,  
         SortOrder,  
         PlanDisplayName,  
         RiskNet,  
         PlanProductPricingTierID,  
         VolumeCommission,  
         Discount,  
         CommissionTier,  
         qsp.Area,  
         COI,  
         UniquePlanID,  
         TripCost,  
         PolicyID,  
         IsPriceBeat,  
         CancellationValueText,  
         ProductDisplayName,  
         AreaID,  
         AgeBandID,  
         DurationID,  
         ExcessID,  
         LeadTimeID,  
         RateCardID,  
         IsSelected,  
         AreaCode  
  
)  
  
select   
  
            CountryKey,  
         CompanyKey,  
   DomainKey,  
   QuoteCountryKey,  
   QuotePlanKey,  
   DomainID,  
   QuoteID,  
   ProductCode,  
   ProductName,  
   PlanID,  
   PlanName,  
   PlanCode,  
   PlanType,  
   IsUpSell,  
   Excess,  
   IsDefaultExcess,  
   PolicyStart,  
   PolicyEnd,  
            DaysCovered,  
            MaxDuration,  
         GrossPremium,  
         PDSUrl,  
         SortOrder,  
         PlanDisplayName,  
         RiskNet,  
         PlanProductPricingTierID,  
         VolumeCommission,  
         Discount,  
         CommissionTier,  
         Area,  
         COI,  
         UniquePlanID,  
         TripCost,  
         PolicyID,  
         IsPriceBeat,  
         CancellationValueText,  
         ProductDisplayName,  
         AreaID,  
         AgeBandID,  
         DurationID,  
         ExcessID,  
         LeadTimeID,  
         RateCardID,  
         IsSelected,  
         AreaCode  
   from etl_penquoteplan  
  
  
end
GO
