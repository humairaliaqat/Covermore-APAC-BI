USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RedshiftQuote_Load]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL054_RedshiftQuote_Load]
as
begin
/************************************************************************************************************************************
Author:         Leonardus S L
Date:           20160201
Description:    load quote data from S3
Parameters:     
Change History:
                20160201 - LS - create

*************************************************************************************************************************************/

    set nocount on

    --prepare staging tables
    execute
    (
    '
    drop table if exists staging_cdgquote
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table staging_cdgquote
    (
        PlatformVersion int,
        AnalyticsSessionID bigint,
        OutletGroup nvarchar (255),
        TransactionHour int,
        Destination varchar (256),
        LeadTime int,
        Duration int,
        TravellerAge int,
        ConvertedFlag smallint,
        TransactionTime datetime,
        CampaignID int,
        CampaignSessionID varchar (128),
        BusinessUnitID int,
        ChannelID int,
        TravellerID varchar (128),
        ImpressionID varchar (128),
        ProductID int,
        StartDate datetime,
        EndDate datetime,
        RegionID int,
        DestinationCountryID int,
        GrossIncludingTax numeric,
        GrossExcludingTax numeric,
        NumAdults int,
        NumChildren int,
        IsAdult smallint,
        IsPrimaryTraveller smallint,
        PolicyID varchar (128),
        isDeleted smallint
    )
    sortkey (TransactionTime,AnalyticsSessionID,CampaignID)
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    drop table if exists staging_penquote
    '
    ) at [CMDWH-REDSHIFT-PROD]

    execute
    (
    '
    create table staging_penquote
    (
        QuoteKey varchar (30),
        CreateTime datetime,
        OutletGroup nvarchar (50),
        TransactionHour int,
        Destination varchar (256),
        LeadTime int,
        Duration int,
        TravellerAge int,
        ConvertedFlag int,
        SessionID nvarchar (255),
        DepartureDate datetime,
        ReturnDate datetime,
        IsExpo smallint,
        IsAgentSpecial smallint,
        PromoCode varchar (256),
        NumberOfAdults int,
        NumberOfChildren int,
        IsSaved smallint,
        AgentReference varchar (256),
        QuotedPrice numeric,
        ProductCode nvarchar (50),
        CRMUserName varchar (256),
        PreviousPolicyNumber varchar (50),
        IsPriceBeat smallint,
        ParentQuoteID int
    )
    sortkey (CreateTime,QuoteKey,SessionID)
    '
    ) at [CMDWH-REDSHIFT-PROD]


    --load Impulse
    execute
    (
    '
    copy staging_cdgquote from ''s3://bi-redshift-bucket/prod/in/cdgQuote.csv.gz''
    credentials ''aws_access_key_id=AKIAIRXFLH7TIYRZCD4Q;aws_secret_access_key=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''
    gzip;
    '
    ) at [CMDWH-REDSHIFT-PROD]


    --load Penguin
    execute
    (
    '
    copy staging_penquote from ''s3://bi-redshift-bucket/prod/in/penQuote.csv.gz''
    credentials ''aws_access_key_id=AKIAIRXFLH7TIYRZCD4Q;aws_secret_access_key=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''
    gzip;
    '
    ) at [CMDWH-REDSHIFT-PROD]

end
GO
