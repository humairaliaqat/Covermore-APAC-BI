USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_Policy_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_Policy_AU](
	[PolicyId] [int] NOT NULL,
	[Number] [nvarchar](255) NOT NULL,
	[TransactionId] [nvarchar](255) NULL,
	[PolicyIdByDomain] [int] NULL,
	[PolicyIdByBusinessUnit] [int] NULL,
	[Excess] [int] NULL,
	[IssuedDate] [datetime] NULL,
	[TotalCommissionAmount] [numeric](19, 5) NULL,
	[TotalCommissionPercentage] [numeric](19, 5) NULL,
	[TotalGrossPremium] [numeric](19, 5) NULL,
	[TotalAdjustedGrossPremium] [numeric](19, 5) NULL,
	[TotalTax] [numeric](19, 5) NULL,
	[MaxDuration] [int] NULL,
	[MaxDurationType] [nvarchar](255) NULL,
	[Discount] [numeric](19, 5) NULL,
	[BusinessUnit_FK] [int] NULL,
	[Product_FK] [int] NULL,
	[Address_FK] [int] NULL,
	[IssuedByAgency_FK] [int] NULL,
	[Payment_FK] [int] NULL,
	[Trip_FK] [int] NULL,
	[RiskNet] [numeric](19, 5) NULL,
	[Type] [nvarchar](255) NULL,
	[Culture] [nvarchar](255) NULL,
	[MemberId] [nvarchar](255) NULL,
	[Currency] [varchar](50) NULL,
	[ExchangeRate] [numeric](19, 5) NULL,
	[BusinessUnitApiKey_FK] [int] NULL,
	[CampaignSession_FK] [int] NULL,
	[PriceAdjustmentRule] [varchar](20) NULL,
	[PriceAdjustmentValue] [numeric](3, 1) NULL
) ON [PRIMARY]
GO
