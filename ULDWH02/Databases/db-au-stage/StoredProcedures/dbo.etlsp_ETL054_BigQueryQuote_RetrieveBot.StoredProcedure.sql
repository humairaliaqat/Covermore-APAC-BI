USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_BigQueryQuote_RetrieveBot]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--CREATE 
CREATE procedure [dbo].[etlsp_ETL054_BigQueryQuote_RetrieveBot]
as
begin
/************************************************************************************************************************************
Author:         Leonardus S L
Date:           20160201
Description:    import flagged bot data
Parameters:     
Change History:
                20160201 - LS - create
                20160413 - LS - INC0007173
                                20160404 fix in etlsp_cmdwh_cdgQuote (missing isPrimaryTraveller on Impulse 2) causes some quotes botflag to fliped
                                this wasn't properly reflected in BI's data as we only retrieve newly flagged bots
                                fix: we need to retrieve newly flagged *records*, delete existing bots and replace with the new one
                                this is to avoid unwanted consequences of data fixes in the future
                20160630 - LL - don't retrieve any bot flagged records pre 20160630 for now (redshift rebuilt)
				20180105 - RS - Modified proc for Bigquery data processing.

*************************************************************************************************************************************/

    set nocount on

    if object_id('[db-au-stage]..bot_impulse') is not null
        drop table [db-au-stage]..bot_impulse

			/*
    select 
	    [PlatformVersion],
	    [AnalyticsSessionID],
	    [DestinationMAFactor],
	    [DurationMAFactor],
	    [LeadTimeMAFactor],
	    [AgeMAFactor],
	    [TransactionHourMAFactor],
	    [SameSessionQuoteCount],
	    [ConvertedFlag],
	    [BotFlag]
    into [db-au-stage]..bot_impulse
    from
        openquery
        (
            [CMDWH-REDSHIFT-PROD],
            '
            select
	            [PlatformVersion],
	            [AnalyticsSessionID],
	            [DestinationMA] as [DestinationMAFactor],
	            [DurationMA] as [DurationMAFactor],
	            [LeadTimeMA] as [LeadTimeMAFactor],
	            [AgeMA] as [AgeMAFactor],
	            [TransactionHourMA] as [TransactionHourMAFactor],
	            [SameSessionQuoteCount],
	            [ConvertedFlag],
	            [BotFlag]
            from
                innate_quote_ma
            where
                UpdateTime >= ''2016-06-30'' and
                UpdateTime >= cast(convert_timezone(''Australia/Sydney'', getdate()) as date)
            '
        )*/

	CREATE TABLE [db-au-stage].[dbo].[bot_impulse](
	[PlatformVersion] [int] NULL,
	[AnalyticsSessionID] [bigint] NULL,
	[DestinationMAFactor] [float] NULL,
	[DurationMAFactor] [float] NULL,
	[LeadTimeMAFactor] [float] NULL,
	[AgeMAFactor] [float] NULL,
	[TransactionHourMAFactor] [float] NULL,
	[SameSessionQuoteCount] [int] NULL,
	[ConvertedFlag] [smallint] NULL,
	[BotFlag] [smallint] NULL
    ) ON [PRIMARY]

	BULK INSERT [db-au-stage].[dbo].bot_impulse
        FROM 'E:\ETL\Data\BigQuery\In\bot_impulse.csv'
        WITH
        (
         -- FORMAT = 'CSV', 
         --    FIELDQUOTE = '"',
         FIRSTROW = 2,
         FIELDTERMINATOR = ',',  --CSV field delimiter
         --ROWTERMINATOR = '\n',   --Use to shift the control to next row
	     ROWTERMINATOR = '0x0a',--Files are generated with this row terminator in Google Bigquery
         TABLOCK
        )

	

    delete q
    from
        [db-au-cmdwh]..botQuoteImpulse q
        inner join [db-au-stage]..bot_impulse r on
            r.[PlatformVersion] = q.[PlatformVersion] and
            r.[AnalyticsSessionID] = q.[AnalyticsSessionID]

    insert into [db-au-cmdwh]..botQuoteImpulse
    (
	    [PlatformVersion],
	    [AnalyticsSessionID],
	    [DestinationMAFactor],
	    [DurationMAFactor],
	    [LeadTimeMAFactor],
	    [AgeMAFactor],
	    [TransactionHourMAFactor],
	    [SameSessionQuoteCount],
	    [ConvertedFlag],
	    [BotFlag]
    )
    select 
	    [PlatformVersion],
	    [AnalyticsSessionID],
	    [DestinationMAFactor],
	    [DurationMAFactor],
	    [LeadTimeMAFactor],
	    [AgeMAFactor],
	    [TransactionHourMAFactor],
	    [SameSessionQuoteCount],
	    [ConvertedFlag],
	    [BotFlag]
    from
        [db-au-stage]..bot_impulse
    where
        [BotFlag] = 1

		if object_id('[db-au-stage]..bot_penguin') is not null
        drop table [db-au-stage]..bot_penguin

    /*select 
	    [QuoteKey],
	    [DestinationMAFactor],
	    [DurationMAFactor],
	    [LeadTimeMAFactor],
	    [AgeMAFactor],
	    [TransactionHourMAFactor],
	    [SameSessionQuoteCount],
	    [ConvertedFlag],
	    [BotFlag]
    into [db-au-stage]..bot_penguin
    from
        openquery
        (
            [CMDWH-REDSHIFT-PROD],
            '
            select
	            [QuoteKey],
	            [DestinationMA] as [DestinationMAFactor],
	            [DurationMA] as [DurationMAFactor],
	            [LeadTimeMA] as [LeadTimeMAFactor],
	            [AgeMA] as [AgeMAFactor],
	            [TransactionHourMA] as [TransactionHourMAFactor],
	            [SameSessionQuoteCount],
	            [ConvertedFlag],
	            [BotFlag]
            from
                penguin_quote_ma
            where
                UpdateTime >= ''2016-06-30'' and
                UpdateTime >= cast(convert_timezone(''Australia/Sydney'', getdate()) as date)
            '
        )*/

		  
		CREATE TABLE [db-au-stage].[dbo].[bot_penguin](
		[QuoteKey] [nvarchar](30) NULL,
		[DestinationMAFactor] [float] NULL,
		[DurationMAFactor] [float] NULL,
		[LeadTimeMAFactor] [float] NULL,
		[AgeMAFactor] [float] NULL,
		[TransactionHourMAFactor] [float] NULL,
		[SameSessionQuoteCount] [int] NULL,
		[ConvertedFlag] [smallint] NULL,
		[BotFlag] [smallint] NULL
     ) ON [PRIMARY]

		BULK INSERT [db-au-stage].[dbo].bot_penguin
        FROM 'E:\ETL\Data\BigQuery\In\bot_penguin.csv'
        WITH
        (
         -- FORMAT = 'CSV', 
         --    FIELDQUOTE = '"',
         FIRSTROW = 2,
         FIELDTERMINATOR = ',',  --CSV field delimiter
         --ROWTERMINATOR = '\n',   --Use to shift the control to next row
	     ROWTERMINATOR = '0x0a',--Files are generated with this row terminator in Google Bigquery
         TABLOCK
        )

    delete q
    from
        [db-au-cmdwh]..botQuotePenguin q
        inner join [db-au-stage]..bot_penguin r on
            r.[QuoteKey] = q.[QuoteKey]

    insert into [db-au-cmdwh]..botQuotePenguin
    (
	    [QuoteKey],
	    [DestinationMAFactor],
	    [DurationMAFactor],
	    [LeadTimeMAFactor],
	    [AgeMAFactor],
	    [TransactionHourMAFactor],
	    [SameSessionQuoteCount],
	    [ConvertedFlag],
	    [BotFlag]
    )
    select 
	    [QuoteKey],
	    [DestinationMAFactor],
	    [DurationMAFactor],
	    [LeadTimeMAFactor],
	    [AgeMAFactor],
	    [TransactionHourMAFactor],
	    [SameSessionQuoteCount],
	    [ConvertedFlag],
	    [BotFlag]
    from
        [db-au-stage]..bot_penguin
    where
        [BotFlag] = 1

end


GO
