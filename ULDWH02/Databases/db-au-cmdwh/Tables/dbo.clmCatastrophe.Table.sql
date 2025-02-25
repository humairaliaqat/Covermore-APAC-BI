USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmCatastrophe]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmCatastrophe](
	[CountryKey] [varchar](2) NULL,
	[CatastropheCode] [varchar](3) NULL,
	[TotalIncurred] [money] NULL,
	[UpdateDateTime] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[clmCatastrophe]
(
	[CountryKey] ASC,
	[CatastropheCode] ASC
)
INCLUDE([TotalIncurred]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
