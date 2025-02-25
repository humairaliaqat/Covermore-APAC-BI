USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[impQuoteDepartureCountryCode]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impQuoteDepartureCountryCode](
	[BIRowID] [bigint] IDENTITY(0,1) NOT NULL,
	[QuoteIDKey] [nvarchar](50) NULL,
	[CountryCode] [nvarchar](50) NULL,
	[CreateBatchID] [int] NULL
) ON [PRIMARY]
GO
