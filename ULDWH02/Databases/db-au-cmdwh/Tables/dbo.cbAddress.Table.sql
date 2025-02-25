USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbAddress]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbAddress](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[AddressKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[AddressID] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[CreateDateUTC] [datetime] NULL,
	[AddressType] [nvarchar](25) NULL,
	[IsOverwrite] [bit] NULL,
	[IsDefault] [bit] NULL,
	[IsConsent] [bit] NULL,
	[FirstName] [varbinary](500) NULL,
	[Surname] [varbinary](500) NULL,
	[DOB] [varbinary](200) NULL,
	[Company] [varbinary](500) NULL,
	[Street] [varbinary](500) NULL,
	[Town] [varbinary](500) NULL,
	[Country] [varbinary](500) NULL,
	[PostCode] [varbinary](500) NULL,
	[Phone] [varbinary](500) NULL,
	[Mobile] [varbinary](500) NULL,
	[Fax] [varbinary](500) NULL,
	[Telex] [varbinary](500) NULL,
	[Email] [varbinary](500) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedByID] [nvarchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[isCurrentLocation] [bit] NULL,
	[ArrivedDate] [date] NULL,
	[CountryCode] [nvarchar](3) NULL,
	[CountryName] [nvarchar](25) NULL,
	[CreatedByID] [nvarchar](30) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbAddress_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cbAddress_BIRowID] ON [dbo].[cbAddress]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddress_AddressKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddress_AddressKey] ON [dbo].[cbAddress]
(
	[AddressKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddress_AddressType]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddress_AddressType] ON [dbo].[cbAddress]
(
	[AddressType] ASC,
	[CaseNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddress_CaseKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddress_CaseKey] ON [dbo].[cbAddress]
(
	[CaseKey] ASC,
	[isCurrentLocation] ASC
)
INCLUDE([AddressType],[Country]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddress_CountryCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddress_CountryCode] ON [dbo].[cbAddress]
(
	[CountryCode] ASC
)
INCLUDE([CountryName]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
