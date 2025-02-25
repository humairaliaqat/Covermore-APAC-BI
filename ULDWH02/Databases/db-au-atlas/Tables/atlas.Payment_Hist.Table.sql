USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Payment_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Payment_Hist](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[Amount_c] [money] NULL,
	[ChequeNumber_c] [varchar](255) NULL,
	[Comments_c] [varchar](255) NULL,
	[Contact_c] [varchar](25) NULL,
	[DeadlineForPayment_c] [varchar](50) NULL,
	[ExternalId_c] [varchar](255) NULL,
	[Integration_c] [bit] NULL,
	[InvoiceAmount_c] [money] NULL,
	[InvoiceNumber_c] [varchar](25) NULL,
	[LastActivityDate] [varchar](50) NULL,
	[LastChangedOn__c] [varchar](50) NULL,
	[Name] [varchar](255) NULL,
	[PaidBy_c] [varchar](255) NULL,
	[PayeeName_c] [varchar](255) NULL,
	[Payee_c] [nvarchar](50) NULL,
	[Payer_c] [nvarchar](50) NULL,
	[PaymentAge_c] [int] NULL,
	[PaymentDate_c] [varchar](50) NULL,
	[PaymentType_c] [nvarchar](50) NULL,
	[ReasonForPayment_c] [varchar](255) NULL,
	[SLAForCompletion_c] [int] NULL,
	[StateCountryTax_c] [money] NULL,
	[Status_c] [nvarchar](50) NULL,
	[SysStartTime] [datetime2](7) NOT NULL,
	[SysEndTime] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ix_Payment_Hist]    Script Date: 21/02/2025 11:28:24 AM ******/
CREATE CLUSTERED INDEX [ix_Payment_Hist] ON [atlas].[Payment_Hist]
(
	[SysEndTime] ASC,
	[SysStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
