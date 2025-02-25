USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[corpEMC]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpEMC](
	[CountryKey] [varchar](2) NOT NULL,
	[EMCKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[BankRecordKey] [varchar](10) NULL,
	[EMCID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[IssuedDate] [datetime] NULL,
	[EMCApplicatioNo] [varchar](50) NULL,
	[EMCInsuredName] [varchar](50) NULL,
	[EMCLoading] [money] NULL,
	[isEMCAccepted] [bit] NULL,
	[AgentCommission] [money] NULL,
	[CMCommission] [money] NULL,
	[BankRecord] [int] NULL,
	[Comments] [varchar](255) NULL,
	[TravellerKey] [varchar](41) NULL,
	[TravellerID] [int] NULL
) ON [PRIMARY]
GO
