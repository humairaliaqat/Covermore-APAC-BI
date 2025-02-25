USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_Import]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL054_RedshiftQuote_Import]
as

SET NOCOUNT ON

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20150910
Description:    imports cdgQuoteBot and penQuoteBot data from Redshift, and loads into
                [db-au-cmdwh].dbo.usrCDGQuoteBot
                [db-au-cmdwh].dbo.usrpenQuoteBot
Change History:
                20150910 - LT - Procedure created

*************************************************************************************************************************************/

--import etl_usrpenQuoteBot from Redshift
if object_id('[db-au-stage].dbo.etl_usrpenQuoteBot') is not null drop table [db-au-stage].dbo.etl_usrpenQuoteBot
select *
into [db-au-stage].dbo.etl_usrpenQuoteBot
from openquery([cmdwh-redshift-prod],'select * from public.penquotebot')


--import etl_usrCDGQuoteBot from Redshift
if object_id('[db-au-stage].dbo.etl_usrCDGQuoteBot') is not null drop table [db-au-stage].dbo.etl_usrCDGQuoteBot
select *
into [db-au-stage].dbo.etl_usrCDGQuoteBot
from openquery([cmdwh-redshift-prod],'select * from public.cdgquotebot')


--load etl_usrpenQuoteBot to [db-au-cmdwh].dbo.usrpenQuoteBot
if object_id('[db-au-cmdwh].dbo.usrpenQuoteBot') is null
begin
    create table [db-au-cmdwh].dbo.usrpenQuoteBot
    (
        QuoteKey varchar(50) null,
        BatchCreateTime datetime null
    )
    create index idx_usrpenQuoteBot_QuoteKey on [db-au-cmdwh].dbo.usrpenQuoteBot(QuoteKey)
end
else
    delete a
    from
        [db-au-cmdwh].dbo.usrpenQuoteBot a
        join [db-au-stage].dbo.etl_usrpenQuoteBot b on
            a.QuoteKey = b.QuoteKey

--insert usrpenQuoteBot
insert [db-au-cmdwh].dbo.usrpenQuoteBot with(tablockx)
    (
        QuoteKey,
        BatchCreateTime
    )
    select
        QuoteKey,
        getdate() as BatchCreateTime
    from
        [db-au-stage].dbo.etl_usrpenQuoteBot


--load etl_usrCDGQuoteBot to [db-au-cmdwh].dbo.usrCDGQuoteBot
if object_id('[db-au-cmdwh].dbo.usrCDGQuoteBot') is null
begin
    create table [db-au-cmdwh].dbo.usrCDGQuoteBot
    (
        AnalyticsSessionID bigint null,
        BatchCreateTime datetime null
    )
    create index idx_usrCDGQuoteBot_AnalyticsSessionID on [db-au-cmdwh].dbo.usrCDGQuoteBot(AnalyticsSessionID)
end
else
    delete a
    from
        [db-au-cmdwh].dbo.usrCDGQuoteBot a
        join [db-au-stage].dbo.etl_usrCDGQuoteBot b on
            a.AnalyticsSessionID = b.AnalyticsSessionID

--insert usrpenQuoteBot
insert [db-au-cmdwh].dbo.usrCDGQuoteBot with(tablockx)
    (
        AnalyticsSessionID,
        BatchCreateTime
    )
    select
        AnalyticsSessionID,
        getdate() as BatchCreateTime
    from
        [db-au-stage].dbo.etl_usrCDGQuoteBot



GO
