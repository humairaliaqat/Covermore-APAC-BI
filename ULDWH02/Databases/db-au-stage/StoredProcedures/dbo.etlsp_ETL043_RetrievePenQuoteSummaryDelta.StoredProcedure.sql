USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL043_RetrievePenQuoteSummaryDelta]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--CREATE 
CREATE 
procedure [dbo].[etlsp_ETL043_RetrievePenQuoteSummaryDelta]
 @StartDate date = null,
    @EndDate date = null
    
as
begin
/************************************************************************************************************************************
Author:         Ratnesh Sharma
Date:           20181121
Description:    import flagged bot data
Parameters:     
Change History:
                20181121 - RS - created

*************************************************************************************************************************************/
    set nocount on

--uncomment to debug
/*
	declare @StartDate datetime
	declare @EndDate datetime
	select @StartDate = '2018-10-11', @EndDate = '2018-10-14'
*/

    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    --declare @mergeoutput table (MergeAction varchar(20))


    if @StartDate is null and @EndDate is null
    begin
    
        exec syssp_getrunningbatch
            @SubjectArea = 'CDG Quote Bigquery',
            @BatchID = @batchid out,
            @StartDate = @start out,
            @EndDate = @end out

        select
            @name = object_name(@@procid)

        exec syssp_genericerrorhandler
            @LogToTable = 1,
            @ErrorCode = '0',
            @BatchID = @batchid,
            @PackageID = @name,
            @LogStatus = 'Running'
            
    end
    else
        select
            @start = @StartDate,
            @end = @EndDate


    if object_id('[db-au-stage]..etl_penQuoteSummary') is not null
        drop table [db-au-stage]..etl_penQuoteSummary

	CREATE TABLE [db-au-stage].[dbo].[etl_penQuoteSummary](
    [QuoteDate] [datetime] NOT NULL,
	[QuoteSource] [int] NOT NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[StoreCode] [varchar](10) NULL,
	[UserKey] [varchar](41) NULL,
	[CRMUserKey] [varchar](41) NULL,
	[SaveStep] [int] NULL,
	[CurrencyCode] [varchar](3) NULL,
	[Area] [nvarchar](200) NULL,
	[Destination] [nvarchar](200) NULL,
	[PurchasePath] [nvarchar](100) NULL,
	[ProductKey] [nvarchar](200) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](100) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanName] [nvarchar](100) NULL,
	[PlanType] [nvarchar](100) NULL,
	[MaxDuration] [int] NULL,
	[Duration] [int] NULL,
	[LeadTime] [int] NULL,
	[Excess] [money] NULL,
	[CompetitorName] [nvarchar](200) NULL,
	[CompetitorGap] [int] NULL,
	[PrimaryCustomerAge] [int] NULL,
	[PrimaryCustomerSuburb] [nvarchar](200) NULL,
	[PrimaryCustomerState] [nvarchar](200) NULL,
	[YoungestAge] [int] NULL,
	[OldestAge] [int] NULL,
	[NumberOfChildren] [int] NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfPersons] [int] NULL,
	[QuotedPrice] [money] NULL,
	[QuoteSessionCount] [int] NULL,
	[QuoteCount] [int] NULL,
	[QuoteWithPriceCount] [int] NULL,
	[SavedQuoteCount] [int] NULL,
	[ConvertedCount] [int] NULL,
	[ExpoQuoteCount] [int] NULL,
	[AgentSpecialQuoteCount] [int] NULL,
	[PromoQuoteCount] [int] NULL,
	[UpsellQuoteCount] [int] NULL,
	[PriceBeatQuoteCount] [int] NULL,
	[QuoteRenewalCount] [int] NULL,
	[CancellationQuoteCount] [int] NULL,
	[LuggageQuoteCount] [int] NULL,
	[MotorcycleQuoteCount] [int] NULL,
	[WinterQuoteCount] [int] NULL,
	[EMCQuoteCount] [int] NULL
    ) ON [PRIMARY]

	BULK INSERT [db-au-stage].[dbo].etl_penQuoteSummary
        FROM 'E:\ETL\Data\BigQuery\In\ETL043_etl_penQuoteSummary.csv'
        WITH
        (
         -- FORMAT = 'CSV', 
         --    FIELDQUOTE = '"',
         FIRSTROW = 2,
         FIELDTERMINATOR = '|',  --CSV field delimiter
         --ROWTERMINATOR = '\n',   --Use to shift the control to next row
	     ROWTERMINATOR = '0x0a',--Files are generated with this row terminator in Google Bigquery
         TABLOCK
        )

	

    /*delete q
    from
        [db-au-cmdwh]..penQuoteSummary q
        inner join [db-au-stage]..etl_penQuoteSummary r on
            --r.[PlatformVersion] = q.[PlatformVersion] and
            --r.[AnalyticsSessionID] = q.[AnalyticsSessionID]
			 r.[QuoteDate]=q.[QuoteDate] and
	r.[QuoteSource]=q.[QuoteSource] and
	r.[CountryKey]=q.[CountryKey] and
	r.[CompanyKey] =q.[CompanyKey]  and
	r.[OutletAlphaKey] =q.[OutletAlphaKey]  and
	--[StoreCode] [varchar](10) NULL,
	r.[UserKey]=q.[UserKey];*/

	 delete [db-au-cmdwh]..penQuoteSummary
        where
            QuoteDate >= @start and
            QuoteDate <  dateadd(day, 1, @end)
	

    insert into [db-au-cmdwh]..penQuoteSummary
	(QuoteDate,QuoteSource,CountryKey,CompanyKey,OutletAlphaKey,StoreCode,UserKey,CRMUserKey,SaveStep,CurrencyCode,Area,Destination,PurchasePath,ProductKey,ProductCode,ProductName,PlanCode,PlanName,PlanType,MaxDuration,Duration,LeadTime,Excess,CompetitorName,CompetitorGap,PrimaryCustomerAge,PrimaryCustomerSuburb,PrimaryCustomerState,YoungestAge,OldestAge,NumberOfChildren,NumberOfAdults,NumberOfPersons,QuotedPrice,QuoteSessionCount,QuoteCount,QuoteWithPriceCount,SavedQuoteCount,ConvertedCount,ExpoQuoteCount,AgentSpecialQuoteCount,PromoQuoteCount,UpsellQuoteCount,PriceBeatQuoteCount,QuoteRenewalCount,CancellationQuoteCount,LuggageQuoteCount,MotorcycleQuoteCount,WinterQuoteCount,EMCQuoteCount)
    select 
	QuoteDate,QuoteSource,CountryKey,CompanyKey,OutletAlphaKey,StoreCode,UserKey,CRMUserKey,SaveStep,CurrencyCode,Area,Destination,PurchasePath,ProductKey,ProductCode,ProductName,PlanCode,PlanName,PlanType,MaxDuration,Duration,LeadTime,Excess,CompetitorName,CompetitorGap,PrimaryCustomerAge,PrimaryCustomerSuburb,PrimaryCustomerState,YoungestAge,OldestAge,NumberOfChildren,NumberOfAdults,NumberOfPersons,QuotedPrice,QuoteSessionCount,QuoteCount,QuoteWithPriceCount,SavedQuoteCount,ConvertedCount,ExpoQuoteCount,AgentSpecialQuoteCount,PromoQuoteCount,UpsellQuoteCount,PriceBeatQuoteCount,QuoteRenewalCount,CancellationQuoteCount,LuggageQuoteCount,MotorcycleQuoteCount,WinterQuoteCount,EMCQuoteCount
    from
        [db-au-stage]..etl_penQuoteSummary
    --where
    --   

end


GO
