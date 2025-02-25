USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwInvoices]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwInvoices](
	[InvoiceID] [numeric](18, 0) NULL,
	[InvoiceNo] [numeric](18, 0) NULL,
	[InvoiceDate] [datetime] NULL,
	[BranchID] [numeric](18, 0) NULL,
	[ByName] [varchar](50) NULL,
	[ByAddress1] [varchar](500) NULL,
	[ByAddress2] [varchar](500) NULL,
	[ByCity] [varchar](50) NULL,
	[ByDistrict] [varchar](50) NULL,
	[ByState] [varchar](50) NULL,
	[ByPinCode] [varchar](10) NULL,
	[ByCountry] [varchar](100) NULL,
	[AgentID] [numeric](18, 0) NULL,
	[AgentPanDetailID] [numeric](18, 0) NULL,
	[ToCompanyName] [varchar](250) NULL,
	[ToContactPerson] [varchar](50) NULL,
	[ToAddress1] [varchar](500) NULL,
	[ToAddress2] [varchar](500) NULL,
	[ToCity] [varchar](50) NULL,
	[ToDistrict] [varchar](50) NULL,
	[ToState] [varchar](50) NULL,
	[ToPinCode] [varchar](10) NULL,
	[ToCountry] [varchar](100) NULL,
	[ToPhoneNo] [varchar](50) NULL,
	[ToMobileNo] [varchar](50) NULL,
	[ToEmailAddress] [varchar](50) NULL,
	[EntityID] [numeric](18, 0) NULL,
	[DocumentID] [numeric](18, 0) NULL,
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
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[AgentReferenceName] [nvarchar](500) NULL,
	[ManualPremiumTotal] [numeric](18, 2) NULL,
	[ManualPremiumBasic] [numeric](18, 2) NULL,
	[ManualPremiumServiceTax] [numeric](18, 2) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
