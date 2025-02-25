USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmFinancialSummary]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmFinancialSummary](
	[UniqueIdentifier] [nvarchar](27) NOT NULL,
	[Date] [datetime] NOT NULL,
	[PolicyCount] [int] NULL,
	[QuoteCount] [int] NULL,
	[GrossSales] [money] NULL,
	[CurrencyCode] [char](3) NULL,
	[Commission] [money] NULL,
	[isSynced] [nvarchar](1) NULL,
	[SyncedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
