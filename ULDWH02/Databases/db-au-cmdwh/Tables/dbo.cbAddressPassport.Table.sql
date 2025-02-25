USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbAddressPassport]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbAddressPassport](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[AddressKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[AddressID] [int] NOT NULL,
	[PassportNumber] [nvarchar](500) NULL,
	[PassportCountry] [nvarchar](500) NULL,
	[PassportExpiryDate] [nvarchar](500) NULL,
	[PassportType] [nvarchar](500) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbAddressPassport_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cbAddressPassport_BIRowID] ON [dbo].[cbAddressPassport]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddressPassport_AddressKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddressPassport_AddressKey] ON [dbo].[cbAddressPassport]
(
	[AddressKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddressPassport_CaseKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddressPassport_CaseKey] ON [dbo].[cbAddressPassport]
(
	[CaseKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
