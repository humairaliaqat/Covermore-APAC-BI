USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL054_RetrievepenQuoteSummaryBotDelta_OG]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
--CREATE   
CREATE   
procedure [dbo].[etlsp_ETL054_RetrievepenQuoteSummaryBotDelta_OG]  
 @StartDate date = null,  
    @EndDate date = null  
      
as  
begin  
/************************************************************************************************************************************  
Author:         Ratnesh Sharma  
Date:           20190124  
Description:    import pen quote summary bot delta  
Parameters:       
Change History:  
                20190124 - RS - created  
  
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
  
  
  
    if object_id('[db-au-stage]..etl_penQuoteSummaryBot') is not null  
        drop table [db-au-stage]..etl_penQuoteSummaryBot  
  
 CREATE TABLE [dbo].[etl_penQuoteSummaryBot](  
 [QuoteDate] [date] NULL,  
 [QuoteSource] [int] NOT NULL,  
 [CountryKey] [varchar](2) NOT NULL,  
 [CompanyKey] [varchar](5) NOT NULL,  
 [OutletAlphaKey] [nvarchar](50) NULL,  
 [StoreCode] [varchar](10) NULL,  
 [UserKey] [varchar](41) NULL,  
 [CRMUserKey] [varchar](41) NULL,  
 [SaveStep] [int] NULL,  
 [CurrencyCode] [varchar](3) NULL,  
 [Area] [nvarchar](100) NULL,  
 [Destination] [nvarchar](max) NULL,  
 [PurchasePath] [nvarchar](50) NULL,  
 [ProductKey] [nvarchar](243) NULL,  
 [ProductCode] [nvarchar](50) NULL,  
 [ProductName] [nvarchar](50) NULL,  
 [PlanCode] [nvarchar](50) NULL,  
 [PlanName] [nvarchar](50) NULL,  
 [PlanType] [nvarchar](50) NULL,  
 [MaxDuration] [int] NULL,  
 [Duration] [int] NULL,  
 [LeadTime] [int] NULL,  
 [Excess] [money] NULL,  
 [CompetitorName] [nvarchar](50) NULL,  
 [CompetitorGap] [numeric](28, 8) NULL,  
 [PrimaryCustomerAge] [int] NULL,  
 [PrimaryCustomerSuburb] [nvarchar](50) NULL,  
 [PrimaryCustomerState] [nvarchar](100) NULL,  
 [YoungestAge] [int] NULL,  
 [OldestAge] [int] NULL,  
 [NumberOfChildren] [int] NULL,  
 [NumberOfAdults] [int] NULL,  
 [NumberOfPersons] [int] NULL,  
 [QuotedPrice] [numeric](38, 4) NULL,  
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
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]  
  
 BULK INSERT [db-au-stage].[dbo].etl_penQuoteSummaryBot  
        FROM 'E:\ETL\Data\BigQuery\In\ETL054_etl_penQuoteSummaryBot.csv'  
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
  
   
  
end  
  
  
GO
