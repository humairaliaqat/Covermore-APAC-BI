USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vCDGBusinessUnitMappingChecker]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vCDGBusinessUnitMappingChecker] as
select 'cdgQuote' as TableName,
    q.Domain,
	q.BusinessUnitID,
    q.BusinessUnit,
	q.ChannelID,
    q.Channel,
	q.AlphaCode,
    min(TransactionTime) MinTransactionTime,
    max(TransactionTime) MaxTransactionTime,
	count(TransactionTime) QuoteCount
from
    [db-au-cmdwh]..cdgQuote q
    left join [db-au-cmdwh]..usrCDGQuoteAlpha om on
        om.Domain = q.Domain and
        om.BusinessUnit = q.BusinessUnit and
        om.Channel = q.Channel
where
    q.Domain is not null and
    --q.TransactionTime >= '2014-07-01' and
    om.BIRowID is null
group by
    q.Domain,
	q.BusinessUnitID,
    q.BusinessUnit,
	q.ChannelID,
    q.Channel,
	q.AlphaCode
union
	select 'cdgQuote_Impulse2' as TableName,
    q.Domain,
	q.BusinessUnitID,
    q.BusinessUnit,
	q.ChannelID,
    q.Channel,
	q.AlphaCode,
    min(TransactionTime) MinTransactionTime,
    max(TransactionTime) MaxTransactionTime,
	count(TransactionTime) QuoteCount
from
    [db-au-cmdwh]..cdgQuote_Impulse2 q
    left join [db-au-cmdwh]..usrCDGQuoteAlpha om on
        om.Domain = q.Domain and
        om.BusinessUnit = q.BusinessUnit and
        om.Channel = q.Channel
where
    q.Domain is not null and
    --q.TransactionTime >= '2014-07-01' and
    om.BIRowID is null
group by
    q.Domain,
	q.BusinessUnitID,
    q.BusinessUnit,
	q.ChannelID,
    q.Channel,
	q.AlphaCode
GO
