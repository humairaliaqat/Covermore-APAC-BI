USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_PolicyPlan]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_PolicyPlan](
	[PolicyKey] [varchar](50) NULL,
	[Plan Name] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_PolicyKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_PolicyKey] ON [dbo].[tmp_PolicyPlan]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
