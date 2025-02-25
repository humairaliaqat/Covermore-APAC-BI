USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penAUDIT_PolicyTax]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penAUDIT_PolicyTax](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AuditPolicyTaxKey] [varchar](41) NULL,
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_RECORDTYPE] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_DATETIME_UTC] [datetime] NULL,
	[AUDIT_tblPolicyTax_ID] [int] NOT NULL,
	[ID] [int] NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[TaxID] [int] NOT NULL,
	[TaxAmount] [money] NOT NULL,
	[TaxOnAgentComm] [money] NOT NULL,
	[IsPOSDiscount] [bit] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAudit_PolicyTax_AuditPolicyTaxKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penAudit_PolicyTax_AuditPolicyTaxKey] ON [dbo].[penAUDIT_PolicyTax]
(
	[AuditPolicyTaxKey] ASC,
	[AUDIT_DATETIME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
