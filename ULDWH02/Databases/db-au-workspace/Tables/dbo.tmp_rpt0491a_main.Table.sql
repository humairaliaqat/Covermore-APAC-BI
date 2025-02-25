USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rpt0491a_main]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rpt0491a_main](
	[xDataIDx] [varchar](41) NULL,
	[DATA_FILENAME] [varchar](50) NULL,
	[DATA_DATE] [varchar](10) NULL,
	[POSTING_DATE] [datetime] NULL,
	[Data_Status] [int] NULL,
	[RECORD_IDENTIFIER] [varchar](11) NULL,
	[BUSINESS_CHANNEL] [varchar](50) NULL,
	[CHANNEL_STATE] [varchar](50) NULL,
	[CONSULTANT_ID] [varchar](50) NULL,
	[COVER_TYPE_SS] [varchar](100) NULL,
	[DATE_OF_BIRTH] [varchar](10) NULL,
	[CUSTOMER_BEST_ADDRESS_POSTCODE] [varchar](50) NULL,
	[CUSTOMER_BEST_ADDRESS_STATE] [varchar](50) NULL,
	[CUSTOMER_FIRST_NAME] [varchar](100) NULL,
	[CUSTOMER_LAST_NAME] [varchar](100) NULL,
	[CUSTOMER_TITLE] [varchar](50) NULL,
	[CUSTOMER_TYPE] [varchar](1) NULL,
	[EMAIL_ADDRESS] [varchar](255) NULL,
	[EMAIL_INVITE_BRAND] [varchar](100) NULL,
	[EXTRACTION_DATE] [varchar](10) NULL,
	[HOME_TELEPHONE_NUMBER] [varchar](50) NULL,
	[MARKETING_CONSENT] [varchar](1) NULL,
	[MOBILE_NUMBER] [varchar](50) NULL,
	[SITE_CODE] [varchar](20) NULL,
	[SSBREFERENCE] [varchar](50) NULL,
	[TRANSACTION_DATE] [varchar](10) NULL,
	[TRANSACTION_TYPE] [varchar](50) NULL,
	[SUM_TOTAL_BASIC_PREM] [varchar](50) NULL,
	[PRODUCT NAME] [varchar](100) NULL,
	[SCHEME_PROMOTION] [varchar](100) NULL,
	[DESTINATION] [varchar](200) NULL,
	[FILE_DATE] [varchar](19) NULL,
	[TRANSACTION_STATUS] [varchar](100) NULL,
	[TRANSACTION_NUMBER] [varchar](50) NULL,
	[SITE_DESCRIPTION] [varchar](50) NULL
) ON [PRIMARY]
GO
