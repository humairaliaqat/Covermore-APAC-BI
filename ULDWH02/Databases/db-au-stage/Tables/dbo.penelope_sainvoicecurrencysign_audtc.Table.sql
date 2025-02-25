USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_sainvoicecurrencysign_audtc]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_sainvoicecurrencysign_audtc](
	[kinvoicecurrencysignid] [int] NOT NULL,
	[currencycode] [nvarchar](10) NOT NULL,
	[country] [nvarchar](30) NOT NULL,
	[currencysign] [nvarchar](10) NOT NULL
) ON [PRIMARY]
GO
