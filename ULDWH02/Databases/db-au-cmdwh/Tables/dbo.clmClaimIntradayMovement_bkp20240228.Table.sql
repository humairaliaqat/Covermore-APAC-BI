USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[clmClaimIntradayMovement_bkp20240228]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clmClaimIntradayMovement_bkp20240228](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[FirstIncurredDate] [date] NULL,
	[AbsoluteAge] [int] NULL,
	[PreviousAbsoluteAge] [int] NULL,
	[IncurredDate] [date] NULL,
	[IncurredTime] [datetime] NULL,
	[IncurredAge] [int] NULL,
	[Estimate] [decimal](20, 6) NULL,
	[Paid] [decimal](20, 6) NULL,
	[IncurredValue] [decimal](20, 6) NULL,
	[PreviousEstimate] [decimal](20, 6) NULL,
	[PreviousPaid] [decimal](20, 6) NULL,
	[PreviousIncurred] [decimal](20, 6) NULL,
	[EstimateDelta] [decimal](20, 6) NULL,
	[PaymentDelta] [decimal](20, 6) NULL,
	[IncurredDelta] [decimal](20, 6) NULL,
	[NewCount] [int] NULL,
	[ReopenedCount] [int] NULL,
	[ClosedCount] [int] NULL,
	[BatchID] [int] NULL
) ON [PRIMARY]
GO
