USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmAuditName]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmAuditName](
	[CountryKey] [varchar](2) NOT NULL,
	[AuditKey] [varchar](50) NOT NULL,
	[NameKey] [varchar](40) NULL,
	[ClaimKey] [varchar](40) NULL,
	[AuditUserName] [nvarchar](150) NULL,
	[AuditDateTime] [datetime] NOT NULL,
	[AuditAction] [char](1) NOT NULL,
	[NameID] [int] NOT NULL,
	[ClaimNo] [int] NULL,
	[Num] [smallint] NULL,
	[Surname] [nvarchar](100) NULL,
	[Firstname] [nvarchar](100) NULL,
	[Title] [nvarchar](50) NULL,
	[DOB] [datetime] NULL,
	[AddressStreet] [nvarchar](100) NULL,
	[AddressSuburb] [nvarchar](50) NULL,
	[AddressState] [nvarchar](100) NULL,
	[AddressCountry] [nvarchar](100) NULL,
	[AddressPostCode] [nvarchar](50) NULL,
	[HomePhone] [nvarchar](50) NULL,
	[WorkPhone] [nvarchar](50) NULL,
	[Fax] [varchar](20) NULL,
	[Email] [nvarchar](255) NULL,
	[isDirectCredit] [bit] NULL,
	[AccountNo] [varchar](20) NULL,
	[AccountName] [nvarchar](200) NULL,
	[BSB] [nvarchar](15) NULL,
	[isPrimary] [bit] NULL,
	[isThirdParty] [bit] NULL,
	[isForeign] [bit] NULL,
	[ProviderID] [int] NULL,
	[BusinessName] [nvarchar](100) NULL,
	[isEmailOK] [bit] NULL,
	[PaymentMethodID] [int] NULL,
	[EMC] [varchar](10) NULL,
	[ITC] [bit] NULL,
	[ITCPCT] [float] NULL,
	[isGST] [bit] NULL,
	[GSTPercentage] [float] NULL,
	[GoodsSupplier] [bit] NULL,
	[ServiceProvider] [bit] NULL,
	[SupplyBy] [int] NULL,
	[EncryptAccount] [varbinary](256) NULL,
	[EncryptBSB] [varbinary](256) NULL,
	[isPayer] [bit] NULL,
	[BankName] [nvarchar](50) NULL,
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[AuditDateTimeUTC] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmAuditName_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_clmAuditName_BIRowID] ON [dbo].[clmAuditName]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmAuditName_AuditDateTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditName_AuditDateTime] ON [dbo].[clmAuditName]
(
	[AuditDateTime] ASC
)
INCLUDE([NameKey],[ClaimKey],[CountryKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditName_AuditKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditName_AuditKey] ON [dbo].[clmAuditName]
(
	[AuditKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditName_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditName_ClaimKey] ON [dbo].[clmAuditName]
(
	[ClaimKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmAuditName_NameKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmAuditName_NameKey] ON [dbo].[clmAuditName]
(
	[NameKey] ASC
)
INCLUDE([ClaimKey],[AuditDateTime]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
