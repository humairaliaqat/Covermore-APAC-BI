USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clmEstimateMovement]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmEstimateMovement](
	[ClaimKey] [varchar](40) NOT NULL,
	[SectionKey] [varchar](40) NOT NULL,
	[SectionCode] [varchar](25) NULL,
	[EstimateDate] [datetime] NULL,
	[Currency] [varchar](3) NOT NULL,
	[FXRate] [numeric](5, 4) NOT NULL,
	[EstimateValue] [money] NULL,
	[RecoveryEstimateValue] [money] NULL,
	[EstimateMovement] [money] NULL,
	[RecoveryEstimateMovement] [money] NULL
) ON [PRIMARY]
GO
