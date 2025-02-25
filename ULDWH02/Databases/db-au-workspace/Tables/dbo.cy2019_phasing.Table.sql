USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cy2019_phasing]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cy2019_phasing](
	[Domain] [nvarchar](255) NULL,
	[Date] [nvarchar](255) NULL,
	[JV] [nvarchar](128) NULL,
	[Phasing] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[cy2019_phasing]
(
	[Date] ASC,
	[Domain] ASC,
	[JV] ASC
)
INCLUDE([Phasing]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
