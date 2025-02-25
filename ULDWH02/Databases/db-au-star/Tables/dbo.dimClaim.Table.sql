USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimClaim]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimClaim](
	[ClaimSK] [bigint] IDENTITY(1,1) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[ClaimNo] [int] NOT NULL,
	[DevelopmentDay] [bigint] NOT NULL,
	[ReceiptDate] [date] NULL,
	[RegisterDate] [date] NULL,
	[EventDate] [date] NULL,
	[FirstNilDate] [date] NULL,
	[LastNilDate] [date] NULL,
	[FirstPaymentDate] [date] NULL,
	[LastPaymentDate] [date] NULL,
	[LodgementType] [varchar](20) NOT NULL,
	[OnlineLodgementType] [varchar](20) NOT NULL,
	[CustomerCareType] [varchar](25) NOT NULL,
	[WorkType] [nvarchar](100) NOT NULL,
	[WorkGroupType] [nvarchar](100) NOT NULL,
	[WorkStatus] [nvarchar](100) NOT NULL,
	[TimeInStatus] [int] NOT NULL,
	[AbsoluteAge] [int] NOT NULL,
	[Assignee] [nvarchar](255) NOT NULL,
	[ReopenCount] [int] NOT NULL,
	[DiarisedCount] [int] NOT NULL,
	[ReassignCount] [int] NOT NULL,
	[DeclinedCount] [int] NOT NULL,
	[FirstNilLag] [int] NOT NULL,
	[FirstPaymentLag] [int] NOT NULL,
	[LastPaymentLag] [int] NOT NULL,
	[CreateBatchID] [int] NULL,
	[UpdateBatchID] [int] NULL,
	[OtherClaimsOnPolicy] [varchar](3) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_dimClaim_ClaimSK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [idx_dimClaim_ClaimSK] ON [dbo].[dimClaim]
(
	[ClaimSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dimClaim_ClaimKey]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [idx_dimClaim_ClaimKey] ON [dbo].[dimClaim]
(
	[ClaimKey] ASC
)
INCLUDE([ClaimSK],[FirstNilDate],[FirstPaymentDate],[ReceiptDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dimClaim] ADD  DEFAULT ('No') FOR [OtherClaimsOnPolicy]
GO
