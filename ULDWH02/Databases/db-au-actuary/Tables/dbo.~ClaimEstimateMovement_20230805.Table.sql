USE [db-au-actuary]
GO
/****** Object:  Table [dbo].[~ClaimEstimateMovement_20230805]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[~ClaimEstimateMovement_20230805](
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
