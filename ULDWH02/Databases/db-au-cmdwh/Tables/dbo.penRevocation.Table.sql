USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penRevocation]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penRevocation](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[DomainKey] [varchar](41) NULL,
	[RevocationKey] [varchar](41) NULL,
	[OutletKey] [varchar](33) NOT NULL,
	[RevocationID] [int] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[AlphaCode] [nvarchar](50) NULL,
	[UserID] [int] NULL,
	[UserName] [nvarchar](101) NULL,
	[TemplateName] [nvarchar](1000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penRevocationRevocationKey]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_penRevocationRevocationKey] ON [dbo].[penRevocation]
(
	[RevocationKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penRevocation_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_penRevocation_OutletKey] ON [dbo].[penRevocation]
(
	[OutletKey] ASC,
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
