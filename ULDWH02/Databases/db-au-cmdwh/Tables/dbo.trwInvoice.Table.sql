USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[trwInvoice]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwInvoice](
	[InvoiceSK] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NULL,
	[InvoiceNo] [numeric](18, 0) NULL,
	[InvoiceDate] [datetime] NULL,
	[ByName] [nvarchar](100) NULL,
	[ByAddress1] [nvarchar](500) NULL,
	[ByAddress2] [nvarchar](500) NULL,
	[ByCity] [nvarchar](50) NULL,
	[ByDistrict] [nvarchar](50) NULL,
	[ByState] [nvarchar](50) NULL,
	[ByPinCode] [nvarchar](10) NULL,
	[ByCountry] [nvarchar](100) NULL,
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
	[Status] [nvarchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [nvarchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[AgentReferenceName] [nvarchar](1000) NULL,
	[BranchID] [int] NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwInvoice_InvoiceSK]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_trwInvoice_InvoiceSK] ON [dbo].[trwInvoice]
(
	[InvoiceSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwInvoice_BranchID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwInvoice_BranchID] ON [dbo].[trwInvoice]
(
	[BranchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_trwInvoice_HashKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwInvoice_HashKey] ON [dbo].[trwInvoice]
(
	[hashkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwInvoice_InvoiceID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwInvoice_InvoiceID] ON [dbo].[trwInvoice]
(
	[InvoiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
