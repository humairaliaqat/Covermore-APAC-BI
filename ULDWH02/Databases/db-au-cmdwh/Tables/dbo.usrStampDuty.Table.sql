USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrStampDuty]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrStampDuty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Country] [varchar](3) NULL,
	[AreaType] [varchar](25) NULL,
	[State] [varchar](50) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[Rate] [decimal](18, 5) NULL,
	[RateExSD] [decimal](18, 5) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_main]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_main] ON [dbo].[usrStampDuty]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_area]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_area] ON [dbo].[usrStampDuty]
(
	[Country] ASC,
	[State] ASC,
	[AreaType] ASC
)
INCLUDE([StartDate],[EndDate],[Rate],[RateExSD]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
