USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwPolicies]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwPolicies](
	[PolicyID] [numeric](18, 0) NULL,
	[PolicyNumber] [numeric](22, 0) NULL,
	[MasterPolicyNumber] [varchar](50) NULL,
	[DateOfPolicy] [datetime] NULL,
	[EmployeeID] [numeric](18, 0) NULL,
	[AgentEmployeeID] [numeric](18, 0) NULL,
	[ReferralAgentID] [numeric](18, 0) NULL,
	[OldPolicyReferenceNo] [numeric](22, 0) NULL,
	[ReferralCommissionPercent] [numeric](18, 2) NULL,
	[DiscountPercent] [numeric](18, 2) NULL,
	[BranchID] [numeric](18, 0) NULL,
	[CurrentPolicyDetailID] [numeric](18, 0) NULL,
	[RefNo] [varchar](100) NULL,
	[AuthenticationCode] [varchar](50) NULL,
	[Remarks] [varchar](500) NULL,
	[MasterNumber] [varchar](100) NULL,
	[CancellationCharges] [numeric](18, 2) NULL,
	[TrawellAssistNumber] [varchar](100) NULL,
	[EarlyArrivalRefund] [numeric](18, 2) NULL,
	[ReferenceNumber] [nvarchar](100) NULL,
	[PolicyCommencts] [varchar](max) NULL,
	[Status] [varchar](50) NULL,
	[CreatedDateTime] [datetime] NULL,
	[CreatedBy] [varchar](256) NULL,
	[ModifiedDateTime] [datetime] NULL,
	[ModifiedBy] [varchar](256) NULL,
	[IP] [varchar](50) NULL,
	[Session] [varchar](500) NULL,
	[RowID] [uniqueidentifier] NULL,
	[CreditNoteId] [numeric](18, 0) NULL,
	[ContinentName] [nvarchar](500) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
