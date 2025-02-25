USE [db-au-stage]
GO
/****** Object:  View [dbo].[tmp_cdgQuote_Impulse2]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[tmp_cdgQuote_Impulse2]
as
select 
    2 PlatformVersion,
    AnalyticsSessionID,
    Channel OutletGroup,
    datepart(hh, TransactionTime) TransactionHour,
    case 
        when DestinationCountryCode = '' then null
        when DestinationCountryCode = 'STP' then 'Sao Tome and Principe' 
        else [db-au-cmdwh].dbo.fn_RemoveSpecialChars(DestinationCountry)
    end Destination,
    datediff(day, convert(date, TransactionTime), convert(date, StartDate)) LeadTime,
    datediff(day, convert(date, StartDate), convert(date, EndDate)) + 1 Duration,
    TravellerAge,
    isnull(IsOfferPurchased, 0) ConvertedFlag,
    TransactionTime,
    CampaignID,
    convert(varchar(128), CampaignSessionID) CampaignSessionID,
    BusinessUnitID,
    ChannelID,
    convert(varchar(128), TravellerID) TravellerID,
    convert(varchar(128), ImpressionID) ImpressionID,
    ProductID,
    StartDate,
    EndDate,
    RegionID,
    DestinationCountryID,
    GrossIncludingTax,
    GrossExcludingTax,
    NumAdults,
    NumChildren,
    IsAdult,
    IsPrimaryTraveller,
    convert(varchar(128), PolicyID) PolicyID,
    isDeleted
from 
    [db-au-cmdwh].dbo.cdgQuote_Impulse2 with(nolock)
GO
