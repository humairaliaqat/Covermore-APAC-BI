USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Invoice_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Invoice_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[ABN_c] [varchar](255) NULL,
	[BankAccountName_c] [varchar](255) NULL,
	[BankAccountNumber_c] [varchar](255) NULL,
	[BankAddressCity_c] [varchar](255) NULL,
	[BankAddressCountry_c] [varchar](255) NULL,
	[BankAddressPostcode_c] [varchar](255) NULL,
	[BankAddressState_c] [varchar](255) NULL,
	[BankAddressStreet_c] [varchar](255) NULL,
	[BankName_c] [varchar](255) NULL,
	[Case_c] [varchar](25) NULL,
	[Comments_c] [varchar](8000) NULL,
	[ContractSavings_c] [money] NULL,
	[DiscountedInvoiceAmount_c] [money] NULL,
	[ExternalId_c] [varchar](255) NULL,
	[GrossSavings_c] [money] NULL,
	[IBAN_c] [varchar](255) NULL,
	[Integration_c] [bit] NULL,
	[InvoiceAmount_c] [money] NULL,
	[InvoiceDate_c] [varchar](50) NULL,
	[InvoiceDueDate_c] [varchar](50) NULL,
	[InvoiceNumber_c] [varchar](80) NULL,
	[InvoicePaidDate_c] [varchar](50) NULL,
	[LastActivityDate] [varchar](50) NULL,
	[MerchantName_c] [varchar](255) NULL,
	[Name] [varchar](50) NOT NULL,
	[PPOFee_c] [money] NULL,
	[PreviousPayments_c] [money] NULL,
	[ProviderEmail_c] [varchar](80) NULL,
	[ProviderName1_c] [varchar](255) NULL,
	[ProviderName__c] [varchar](255) NULL,
	[Provider_c] [varchar](25) NULL,
	[ScrubbedSavings_c] [money] NULL,
	[Status_c] [nvarchar](50) NULL,
	[SwiftBIC_c] [varchar](255) NULL,
	[TotalduetoCostContainmentAgent_c] [money] NULL,
	[TotalPayments_c] [money] NULL,
	[Type_c] [nvarchar](50) NULL,
	[WTPAUFee_c] [varchar](50) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Invoice_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
CREATE CLUSTERED INDEX [ix_Invoice_Hist] ON [atlas].[Invoice_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
