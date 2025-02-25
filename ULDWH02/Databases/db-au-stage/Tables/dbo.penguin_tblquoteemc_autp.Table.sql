USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblquoteemc_autp]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblquoteemc_autp](
	[ID] [int] NOT NULL,
	[QuotePlanID] [int] NOT NULL,
	[QuoteCustomerID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[DOB] [datetime] NULL,
	[EMCRef] [varchar](100) NOT NULL,
	[EMCScore] [numeric](10, 4) NOT NULL,
	[PremiumIncrease] [numeric](18, 5) NOT NULL,
	[IsPercentage] [bit] NOT NULL,
	[AddOnId] [int] NULL
) ON [PRIMARY]
GO
