USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_factABSTraveller]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_ic_factABSTraveller] as
select 
    DateSK,
    DomainSK,
    DestinationSK,
    DurationSK,
    AgeBandSK,
    LeisureTravellerCount,
    NonLeisureTravellerCount,
    FriendRelativeCount,
    HolidayCount
from
    factABSTraveller
GO
