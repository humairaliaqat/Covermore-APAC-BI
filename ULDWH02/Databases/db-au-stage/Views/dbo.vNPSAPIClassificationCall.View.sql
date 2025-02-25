USE [db-au-stage]
GO
/****** Object:  View [dbo].[vNPSAPIClassificationCall]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE view [dbo].[vNPSAPIClassificationCall]
as
select --top 5000
    BIRowID,
    replace(ltrim(rtrim(Reason)), char(13), ' ') Reason,
    ClassificationResponse,
    TopicResponse,
    SentimentResponse
from
    (
        select 
            BIRowID,
            isnull([Q2a#  Score reason], '') + '. ' +
            isnull([C5# Claim comment], '') + '. ' +
            isnull([M3# Case comment], '') + '. ' + 
            isnull([Is there anything else about your experience with the Global SIM], '') Reason,
            convert(nvarchar(4000), '') ClassificationResponse,
            convert(nvarchar(4000), '') TopicResponse,
            convert(nvarchar(4000), '') SentimentResponse
        from
            [db-au-cmdwh]..npsData
        where
            Classification is null 
            or
            len(Classification) < 180

    ) t
where
    ltrim(rtrim(Reason)) <> '' and
    ltrim(rtrim(replace(Reason, '.', ''))) <> '' and
    len(ltrim(rtrim(Reason))) >= 4 and
    len(ltrim(rtrim(Reason))) < 7500
--order by BIRowID desc








GO
