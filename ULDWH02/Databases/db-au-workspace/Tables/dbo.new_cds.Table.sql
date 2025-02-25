USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[new_cds]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[new_cds](
	[ClaimNo] [int] NOT NULL,
	[EstimateMovement] [decimal](38, 6) NULL,
	[IncurredMovement] [decimal](38, 6) NULL,
	[SectionCount] [int] NULL,
	[NetPayment] [decimal](38, 6) NULL,
	[NetRecoveryMovement] [decimal](38, 6) NULL,
	[NetIncurredMovement] [decimal](38, 6) NULL
) ON [PRIMARY]
GO
