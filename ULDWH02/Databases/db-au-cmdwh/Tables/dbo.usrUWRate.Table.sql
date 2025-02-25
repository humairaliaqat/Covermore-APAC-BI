USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrUWRate]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrUWRate](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[GroupCode] [nvarchar](50) NULL,
	[Excess] [money] NULL,
	[Area] [varchar](20) NULL,
	[MinimumAge] [int] NULL,
	[MaximumAge] [int] NULL,
	[UWRate] [decimal](10, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrUWRate_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE UNIQUE CLUSTERED INDEX [idx_usrUWRate_BIRowID] ON [dbo].[usrUWRate]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrUWRate_GroupCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrUWRate_GroupCode] ON [dbo].[usrUWRate]
(
	[GroupCode] ASC,
	[CountryKey] ASC,
	[CompanyKey] ASC
)
INCLUDE([Excess],[Area],[MinimumAge],[MaximumAge],[UWRate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
