USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[trwPolicy]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwPolicy](
	[PolicySK] [int] IDENTITY(1,1) NOT NULL,
	[PolicyID] [int] NULL,
	[PolicyNumber] [numeric](22, 0) NULL,
	[MasterPolicyNumber] [nvarchar](50) NULL,
	[DateOfPolicy] [datetime] NULL,
	[OldPolicyReferenceNo] [numeric](22, 0) NULL,
	[ReferralCommissionPercent] [numeric](18, 2) NULL,
	[DiscountPercent] [numeric](18, 2) NULL,
	[CurrentPolicyDetailID] [int] NULL,
	[RefNo] [nvarchar](100) NULL,
	[AuthenticationCode] [nvarchar](50) NULL,
	[Remarks] [nvarchar](500) NULL,
	[MasterNumber] [nvarchar](100) NULL,
	[CancellationCharges] [numeric](18, 2) NULL,
	[TrawellAssistNumber] [nvarchar](100) NULL,
	[EarlyArrivalRefund] [numeric](18, 2) NULL,
	[ReferenceNumber] [nvarchar](200) NULL,
	[PolicyCommencts] [nvarchar](max) NULL,
	[Status] [nvarchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [nvarchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ContinentName] [nvarchar](1000) NULL,
	[EmployeeID] [int] NULL,
	[AgentEmployeeID] [int] NULL,
	[BranchCode] [int] NULL,
	[Branch] [nvarchar](256) NULL,
	[AreaCode] [int] NULL,
	[Area] [nvarchar](256) NULL,
	[RegionCode] [int] NULL,
	[Region] [nvarchar](256) NULL,
	[InsertDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[hashkey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicy_PolicySK]    Script Date: 24/02/2025 12:39:36 PM ******/
CREATE CLUSTERED INDEX [idx_trwPolicy_PolicySK] ON [dbo].[trwPolicy]
(
	[PolicySK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_trwPolicy_HashKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicy_HashKey] ON [dbo].[trwPolicy]
(
	[hashkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_trwPolicy_PolicyID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_trwPolicy_PolicyID] ON [dbo].[trwPolicy]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
