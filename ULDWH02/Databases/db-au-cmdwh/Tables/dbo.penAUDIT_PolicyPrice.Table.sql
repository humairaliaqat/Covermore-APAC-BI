USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penAUDIT_PolicyPrice]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penAUDIT_PolicyPrice](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[AuditPolicyPriceKey] [varchar](41) NULL,
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_RECORDTYPE] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[AUDIT_DATETIME_UTC] [datetime] NULL,
	[AUDIT_tblPolicyPrice_ID] [int] NOT NULL,
	[ID] [int] NOT NULL,
	[GroupID] [int] NOT NULL,
	[ComponentID] [int] NOT NULL,
	[GrossPremium] [money] NULL,
	[BasePremium] [money] NOT NULL,
	[AdjustedNet] [money] NOT NULL,
	[Commission] [money] NOT NULL,
	[CommissionRate] [numeric](10, 9) NULL,
	[Discount] [money] NOT NULL,
	[DiscountRate] [numeric](12, 9) NULL,
	[BaseAdminFee] [money] NULL,
	[GrossAdminFee] [money] NULL,
	[IsPOSDiscount] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penAudit_PolicyPrice_AuditPolicyPriceKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penAudit_PolicyPrice_AuditPolicyPriceKey] ON [dbo].[penAUDIT_PolicyPrice]
(
	[AuditPolicyPriceKey] ASC,
	[AUDIT_DATETIME] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
