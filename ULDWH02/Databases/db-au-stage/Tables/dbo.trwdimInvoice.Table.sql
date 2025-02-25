USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimInvoice]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimInvoice](
	[InvoiceSK] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [numeric](18, 0) NOT NULL,
	[InvoiceNo] [numeric](18, 0) NULL,
	[InvoiceDate] [datetime] NULL,
	[BranchID] [int] NULL,
	[ByName] [nvarchar](50) NULL,
	[ByAddress1] [nvarchar](500) NULL,
	[ByAddress2] [nvarchar](500) NULL,
	[ByCity] [nvarchar](50) NULL,
	[ByDistrict] [nvarchar](50) NULL,
	[ByState] [nvarchar](50) NULL,
	[ByPinCode] [nvarchar](10) NULL,
	[ByCountry] [nvarchar](100) NULL,
	[AgentID] [int] NULL,
	[AgentPanDetailID] [int] NULL,
	[ToCompanyName] [nvarchar](250) NULL,
	[ToContactPerson] [nvarchar](50) NULL,
	[ToAddress1] [nvarchar](500) NULL,
	[ToAddress2] [nvarchar](500) NULL,
	[ToCity] [nvarchar](50) NULL,
	[ToDistrict] [nvarchar](50) NULL,
	[ToState] [nvarchar](50) NULL,
	[ToPinCode] [nvarchar](10) NULL,
	[ToCountry] [nvarchar](100) NULL,
	[ToPhoneNo] [nvarchar](50) NULL,
	[ToMobileNo] [nvarchar](50) NULL,
	[ToEmailAddress] [nvarchar](50) NULL,
	[EntityID] [int] NULL,
	[DocumentID] [int] NULL,
	[TotalAmount] [numeric](18, 2) NULL,
	[ServiceTaxRate] [numeric](18, 2) NULL,
	[CESS1Rate] [numeric](18, 2) NULL,
	[CESS2Rate] [numeric](18, 2) NULL,
	[ServiceTax] [numeric](18, 2) NULL,
	[CESS1] [numeric](18, 2) NULL,
	[CESS2] [numeric](18, 2) NULL,
	[GrossAmount] [numeric](18, 2) NULL,
	[DiscountAmount] [numeric](18, 2) NULL,
	[DiscountServiceTax] [numeric](18, 2) NULL,
	[DiscountCESS1] [numeric](18, 2) NULL,
	[DiscountCESS2] [numeric](18, 2) NULL,
	[NetServiceTax] [numeric](18, 2) NULL,
	[NetCESS1] [numeric](18, 2) NULL,
	[NetCESS2] [numeric](18, 2) NULL,
	[NetAmount] [numeric](18, 2) NULL,
	[CommissionAmount] [numeric](18, 2) NULL,
	[TDSAmount] [numeric](18, 2) NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [nvarchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[AgentReferenceName] [nvarchar](1000) NULL,
	[ManualPremiumTotal] [numeric](18, 2) NULL,
	[ManualPremiumBasic] [numeric](18, 2) NULL,
	[ManualPremiumServiceTax] [numeric](18, 2) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimInvoice_InvoiceSK]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE CLUSTERED INDEX [idx_dimInvoice_InvoiceSK] ON [dbo].[trwdimInvoice]
(
	[InvoiceSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimInvoice_BranchID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimInvoice_BranchID] ON [dbo].[trwdimInvoice]
(
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimInvoice_DocumentID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimInvoice_DocumentID] ON [dbo].[trwdimInvoice]
(
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimInvoice_EntityID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimInvoice_EntityID] ON [dbo].[trwdimInvoice]
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimInvoice_HashKey]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimInvoice_HashKey] ON [dbo].[trwdimInvoice]
(
	[HashKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimInvoice_InvoiceID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimInvoice_InvoiceID] ON [dbo].[trwdimInvoice]
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
