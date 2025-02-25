USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[dimPolicy_NewFields]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimPolicy_NewFields](
	[PolicySK] [int] NOT NULL,
	[EMCFlag] [varchar](7) NOT NULL,
	[TotalEMCScore] [decimal](38, 2) NOT NULL,
	[MaxEMCScore] [decimal](18, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:16 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[dimPolicy_NewFields]
(
	[PolicySK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
