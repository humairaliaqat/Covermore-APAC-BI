USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penOutletOutgoingEmailInfo]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penOutletOutgoingEmailInfo](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[OutletKey] [varchar](33) NOT NULL,
	[OutletID] [int] NOT NULL,
	[EmailTypeID] [int] NULL,
	[EmailType] [nvarchar](50) NULL,
	[EmailSubject] [nvarchar](250) NULL,
	[EmailFromDisplayName] [nvarchar](50) NULL,
	[EmailFromAddress] [varchar](50) NOT NULL,
	[EmailCertOnPurchase] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penOutletOutgoingEmailInfo_OutletKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penOutletOutgoingEmailInfo_OutletKey] ON [dbo].[penOutletOutgoingEmailInfo]
(
	[OutletKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
