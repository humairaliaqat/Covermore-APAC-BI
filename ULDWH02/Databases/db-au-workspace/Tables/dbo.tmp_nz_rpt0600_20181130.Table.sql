USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_nz_rpt0600_20181130]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_nz_rpt0600_20181130](
	[OutletKey] [varchar](41) NULL,
	[ClaimNo] [int] NOT NULL,
	[RegisterDate] [datetime] NULL,
	[ReceivedDate] [datetime] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NULL,
	[ClaimStatus] [varchar](50) NULL,
	[StatusChangeDate] [datetime] NULL,
	[Section] [nvarchar](200) NULL,
	[EstimateValue] [decimal](38, 6) NOT NULL,
	[RecoveryEstimateValue] [decimal](38, 6) NOT NULL,
	[Paid] [money] NOT NULL,
	[Recovered] [money] NOT NULL,
	[EstimateDate] [date] NULL,
	[LastPayment] [date] NULL,
	[ClaimStatusElapsed] [int] NULL,
	[e5ID] [varchar](50) NULL,
	[e5Reference] [int] NULL,
	[e5Status] [nvarchar](100) NULL,
	[e5DiariseToDate] [datetime] NULL,
	[e5AssignedUser] [nvarchar](445) NULL
) ON [PRIMARY]
GO
