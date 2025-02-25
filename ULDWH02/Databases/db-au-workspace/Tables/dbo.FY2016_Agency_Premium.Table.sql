USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[FY2016_Agency_Premium]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FY2016_Agency_Premium](
	[AlphaCode] [nvarchar](255) NULL,
	[Data Date] [date] NULL,
	[Premium Budget] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[FY2016_Agency_Premium]
(
	[AlphaCode] ASC,
	[Data Date] ASC
)
INCLUDE([Premium Budget]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
