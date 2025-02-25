USE [db-au-workspace]
GO
/****** Object:  Table [ws].[ClaimEstimateMovement_06022024]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[ClaimEstimateMovement_06022024](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NOT NULL,
	[SectionCode] [varchar](25) NULL,
	[EstimateDate] [datetime] NULL,
	[Currency] [varchar](3) NOT NULL,
	[FXRate] [numeric](5, 4) NOT NULL,
	[EstimateValue] [decimal](20, 6) NULL,
	[RecoveryEstimateValue] [decimal](20, 6) NULL,
	[EstimateMovement] [decimal](20, 6) NULL,
	[RecoveryEstimateMovement] [decimal](20, 6) NULL
) ON [PRIMARY]
GO
