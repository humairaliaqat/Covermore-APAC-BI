USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactQuoteSummary_test]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create view [dbo].[vfactQuoteSummary_test] as  
select *,dateadd(day, LeadTime, convert(date, convert(varchar, DateSK))) DepartureDateSK,  
    dateadd(day, LeadTime + DurationSK - 1, convert(date, convert(varchar, DateSK))) ReturnDateSK    
from  
    (  
        select  
            BIRowID,  
            DateSK,  
            DomainSK,  
            q.OutletSK,  
            q.ConsultantSK,  
            AreaSK,  
            DestinationSK,  
            DurationSK,  
            AgeBandSK,  
            ProductSK,  
            QuoteSessionCount,  
            QuoteCount,  
            QuoteWithPriceCount,  
            SavedQuoteCount,  
            ConvertedCount,  
            ExpoQuoteCount,  
            AgentSpecialQuoteCount,  
            PromoQuoteCount,  
            UpsellQuoteCount,  
            PriceBeatQuoteCount,  
            QuoteRenewalCount,  
            CancellationQuoteCount,  
            LuggageQuoteCount,  
            MotorcycleQuoteCount,  
            WinterQuoteCount,  
            EMCQuoteCount,  
            0 BotQuoteSessionCount,  
            0 BotQuoteCount,  
            0 BotQuoteWithPriceCount,  
            0 BotSavedQuoteCount,  
            0 BotConvertedCount,  
            0 BotExpoQuoteCount,  
            0 BotAgentSpecialQuoteCount,  
            0 BotPromoQuoteCount,  
            0 BotUpsellQuoteCount,  
            0 BotPriceBeatQuoteCount,  
            0 BotQuoteRenewalCount,  
            0 BotCancellationQuoteCount,  
            0 BotLuggageQuoteCount,  
            0 BotMotorcycleQuoteCount,  
            0 BotWinterQuoteCount,  
            0 BotEMCQuoteCount,  
            case  
                --use quote count for integrated  
                when exists  
                (  
                    select  
                        null  
                    from  
                        [db-au-star]..dimIntegratdOutlet r  
                    where  
                        r.OutletSK = q.OutletSK  
                ) then q.QuoteCount  
                when c.ConsultantSK is not null then q.QuoteSessionCount  
                else q.QuoteCount  
            end SelectedQuoteCount,  
            q.LoadDate,  
            q.LoadID,  
            q.updateDate,  
            q.updateID,  
            case  
                when q.LeadTime < -1 then -1  
                when q.LeadTime > 2000 then -1  
                else q.LeadTime  
            end LeadTime  
        from  
            factQuoteSummary q  
            outer apply  
            (  
                select top 1  
                    ConsultantSK  
                from  
                    dimConsultant c  
                where  
                    c.ConsultantSK = q.ConsultantSK and  
                    c.ConsultantName like '%webuser%'  
            ) c  
        where  
            DateSK >= 20150101  
			
        union all  
  
        select  
            BIRowID,  
            DateSK,  
            DomainSK,  
            q.OutletSK,  
            q.ConsultantSK,  
            AreaSK,  
            DestinationSK,  
            DurationSK,  
            AgeBandSK,  
            ProductSK,  
            QuoteSessionCount,  
            QuoteCount,  
            QuoteWithPriceCount,  
            SavedQuoteCount,  
            ConvertedCount,  
            ExpoQuoteCount,  
            AgentSpecialQuoteCount,  
            PromoQuoteCount,  
            UpsellQuoteCount,  
            PriceBeatQuoteCount,  
            QuoteRenewalCount,  
            CancellationQuoteCount,  
            LuggageQuoteCount,  
            MotorcycleQuoteCount,  
            WinterQuoteCount,  
            EMCQuoteCount,  
            -QuoteSessionCount BotQuoteSessionCount,  
            case  
                --no bot for integrated  
                when exists  
                (  
                    select  
                        null  
                    from  
                        [db-au-star]..dimIntegratdOutlet r  
                    where  
                        r.OutletSK = q.OutletSK  
                ) then 0  
                when c.ConsultantSK is not null then -q.QuoteSessionCount  
                else -q.QuoteCount  
            end BotQuoteCount,  
            -QuoteWithPriceCount BotQuoteWithPriceCount,  
            -SavedQuoteCount BotSavedQuoteCount,  
            -ConvertedCount BotConvertedCount,  
            -ExpoQuoteCount BotExpoQuoteCount,  
            -AgentSpecialQuoteCount BotAgentSpecialQuoteCount,  
            -PromoQuoteCount BotPromoQuoteCount,  
            -UpsellQuoteCount BotUpsellQuoteCount,  
            -PriceBeatQuoteCount BotPriceBeatQuoteCount,  
            -QuoteRenewalCount BotQuoteRenewalCount,  
            -CancellationQuoteCount BotCancellationQuoteCount,  
            -LuggageQuoteCount BotLuggageQuoteCount,  
            -MotorcycleQuoteCount BotMotorcycleQuoteCount,  
            -WinterQuoteCount BotWinterQuoteCount,  
            -EMCQuoteCount BotEMCQuoteCount,  
            case  
                --no bot for integrated  
                when exists  
                (  
                    select  
                        null  
                    from  
                        [db-au-star]..dimIntegratdOutlet r  
                    where  
                        r.OutletSK = q.OutletSK  
                ) then 0  
                when c.ConsultantSK is not null then q.QuoteSessionCount  
                else q.QuoteCount  
            end SelectedQuoteCount,  
            q.LoadDate,  
            q.LoadID,  
            q.updateDate,  
            q.updateID,  
            case  
                when q.LeadTime < -1 then -1  
                when q.LeadTime > 2000 then -1  
                else q.LeadTime  
            end LeadTime  
        from  
            factQuoteSummaryBot q  
            outer apply  
            (  
                select top 1  
                    ConsultantSK  
                from  
                    dimConsultant c  
                where  
                    c.ConsultantSK = q.ConsultantSK and  
                    c.ConsultantName like '%webuser%'  
            ) c  
        where  
            DateSK >= 20150101  
    ) q  
    cross apply  
    (  
        select 'Point in time' OutletReference  
        union all  
        select 'Latest alpha' OutletReference  
    ) ref
GO
