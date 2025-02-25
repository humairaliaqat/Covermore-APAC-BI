USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmName]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmName](
	[CountryKey] [varchar](2) NOT NULL,
	[NameKey] [varchar](40) NULL,
	[ClaimKey] [varchar](40) NULL,
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
	[UpdateBatchID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_clmName_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_clmName_BIRowID] ON [dbo].[clmName]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmName_ClaimKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmName_ClaimKey] ON [dbo].[clmName]
(
	[ClaimKey] ASC,
	[isPrimary] DESC
)
INCLUDE([NameKey],[NameID],[Title],[Firstname],[Surname],[DOB],[Email],[isThirdParty],[AddressStreet],[AddressCountry],[AddressPostCode],[HomePhone],[WorkPhone]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_clmName_NameKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_clmName_NameKey] ON [dbo].[clmName]
(
	[NameKey] ASC
)
INCLUDE([ClaimKey],[isPrimary],[NameID],[Title],[Firstname],[Surname],[DOB],[Email],[BusinessName],[AddressStreet],[AddressSuburb],[AddressState],[AddressPostCode],[isThirdParty]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
