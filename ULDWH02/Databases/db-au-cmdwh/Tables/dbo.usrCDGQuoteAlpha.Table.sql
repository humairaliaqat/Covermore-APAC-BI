USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCDGQuoteAlpha]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCDGQuoteAlpha](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[Domain] [nvarchar](5) NULL,
	[BusinessUnit] [nvarchar](255) NULL,
	[Channel] [nvarchar](255) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletAlphaKey] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrCDGQuoteAlpha_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrCDGQuoteAlpha_BIRowID] ON [dbo].[usrCDGQuoteAlpha]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrCDGQuoteAlpha_BusinessUnit]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrCDGQuoteAlpha_BusinessUnit] ON [dbo].[usrCDGQuoteAlpha]
(
	[BusinessUnit] ASC,
	[Domain] ASC
)
INCLUDE([Channel],[AlphaCode],[OutletAlphaKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
