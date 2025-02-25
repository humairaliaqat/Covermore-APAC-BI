USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbAddressHistory]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbAddressHistory](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NULL,
	[AddressKey] [nvarchar](20) NOT NULL,
	[AddressHistoryKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NULL,
	[AddressHistoryID] [int] NOT NULL,
	[AddressID] [int] NOT NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedByID] [nvarchar](30) NULL,
	[ArrivedDate] [datetime] NULL,
	[AddedDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cbAddressHistory_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cbAddressHistory_BIRowID] ON [dbo].[cbAddressHistory]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddressHistory_AddressHistoryKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddressHistory_AddressHistoryKey] ON [dbo].[cbAddressHistory]
(
	[AddressKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddressHistory_AddressKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddressHistory_AddressKey] ON [dbo].[cbAddressHistory]
(
	[AddressKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cbAddressHistory_CaseKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cbAddressHistory_CaseKey] ON [dbo].[cbAddressHistory]
(
	[CaseKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
