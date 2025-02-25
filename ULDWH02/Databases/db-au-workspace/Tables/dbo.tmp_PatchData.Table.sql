USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_PatchData]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_PatchData](
	[PolicyNumber] [nvarchar](50) NULL,
	[PolicyID] [int] NULL,
	[policyStatus] [int] NULL,
	[PolicyTransID] [int] NULL,
	[PriceID] [int] NULL,
	[priceGroupId] [int] NULL,
	[priceGrossPremium] [money] NULL,
	[priceCommission] [money] NULL,
	[priceBasePremium] [money] NULL,
	[priceBaseAdminFee] [money] NULL,
	[priceAdjustedNet] [money] NULL,
	[priceGrossAdminFee] [money] NULL,
	[customerId] [int] NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[TransactionStatus] [int] NULL,
	[HasEMC] [bit] NULL,
	[GrossPremium] [money] NULL,
	[EmcGrossPremium] [money] NULL,
	[policyTaxId] [int] NULL,
	[TaxAmount] [money] NULL,
	[TaxName] [nvarchar](50) NULL,
	[RiskNet] [money] NULL,
	[TotalNet] [money] NULL,
	[TotalCommission] [money] NULL,
	[Commission] [money] NULL,
	[AutoComments] [nvarchar](200) NULL,
	[IsPOSDiscount] [bit] NULL,
	[PolicyTaxKey] [varchar](37) NULL,
	[PolicyTransactionKey] [varchar](37) NULL,
	[PolicyKey] [varchar](37) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PatchData_PolicyTaxKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_PatchData_PolicyTaxKey] ON [dbo].[tmp_PatchData]
(
	[PolicyTaxKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PatchData_PolicyTransactionKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_PatchData_PolicyTransactionKey] ON [dbo].[tmp_PatchData]
(
	[PolicyTransactionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_PatchData_PriceID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_PatchData_PriceID] ON [dbo].[tmp_PatchData]
(
	[PriceID] ASC,
	[priceGroupId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
