USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[corpLuggage]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpLuggage](
	[CountryKey] [varchar](2) NOT NULL,
	[LuggageKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[BankRecordKey] [varchar](10) NULL,
	[LuggageID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[LuggageTypeID] [int] NULL,
	[LuggageTypeDesc] [varchar](50) NULL,
	[LuggageTypeCoverage] [money] NULL,
	[CreatedDate] [datetime] NULL,
	[IssuedDate] [datetime] NULL,
	[LuggageDesc] [varchar](50) NULL,
	[LuggageValue] [money] NULL,
	[LuggageLoading] [money] NULL,
	[isLuggageAccepted] [bit] NULL,
	[AgentCommission] [money] NULL,
	[CMCommission] [money] NULL,
	[BankRecord] [int] NULL,
	[Comments] [varchar](255) NULL
) ON [PRIMARY]
GO
