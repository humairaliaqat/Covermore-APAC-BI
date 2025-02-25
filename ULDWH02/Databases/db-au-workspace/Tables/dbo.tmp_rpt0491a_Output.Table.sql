USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rpt0491a_Output]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rpt0491a_Output](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[data] [varchar](max) NULL,
	[xDataIDx] [varchar](41) NULL,
	[PolicyPremiumGWP] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[tmp_rpt0491a_Output]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
