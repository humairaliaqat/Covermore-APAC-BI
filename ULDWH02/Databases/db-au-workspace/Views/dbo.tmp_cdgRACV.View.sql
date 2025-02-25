USE [db-au-workspace]
GO
/****** Object:  View [dbo].[tmp_cdgRACV]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[tmp_cdgRACV] as
select 
    QuoteDate,
    Age,
    Destination,
    Duration,
    LeadTime,
    LeadTimeVariance,
    DurationVariance,
    AgeVariance,
    DestinationVariance,
    VarianceScore,
    ImpressionID
from
    cdgQuoteRACV_Variance t
    cross apply
    (
        select
            (
                case 
                    when LeadTimeVariance >= 3*6 then 2 
                    when LeadTimeVariance >= 3 then 1 
                    when LeadTimeVariance >= 0.5 then 0.75
                    else 0 
                end
            ) * 2.0 + 
            (
                case 
                    when DurationVariance >= 3*6 then 2 
                    when DurationVariance >= 3 then 1 
                    when DurationVariance >= 0.5 then 0.75
                    else 0 
                end
            ) * 1.0 + 
            (
                case
                    when AgeVariance >= 3*6 then 2 
                    when AgeVariance >= 3 then 1 
                    when AgeVariance >= 0.5 then 0.5
                    else 0 
                end
            ) * 0.5 + 
            (
                case 
                    when DestinationVariance >= 3*6 then 2 
                    when DestinationVariance >= 3 then 1 
                    when DestinationVariance >= 0.5 then 0.5
                    else 0 
                end
            ) * 0.5 
            VarianceScore
    ) r
--group by
--    QuoteDate,
--    Age,
--    Destination,
--    Duration,
--    LeadTime,
--    LeadTimeVariance,
--    DurationVariance,
--    AgeVariance,
--    DestinationVariance,
--    VarianceScore



GO
