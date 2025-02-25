USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[live_dashboard_repeatoffender]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[live_dashboard_repeatoffender](
	[IDType] [varchar](50) NULL,
	[IDValue] [varchar](300) NULL,
	[ClaimCount] [int] NULL,
	[CustomerCount] [int] NULL,
	[ClaimCost] [decimal](16, 2) NULL,
	[MaxClaimCost] [decimal](16, 2) NULL,
	[MinClaimCost] [decimal](16, 2) NULL
) ON [PRIMARY]
GO
