USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_trwAgentbranchMe]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_trwAgentbranchMe](
	[AgentbranchMeId] [numeric](18, 0) NULL,
	[AgentId] [numeric](18, 0) NULL,
	[AgentBranchId] [numeric](18, 0) NULL,
	[BranchId] [numeric](18, 0) NULL,
	[MarketingEmployeeId] [numeric](18, 0) NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[CreatedDateTime] [datetime] NULL,
	[ModifiedDateTime] [datetime] NULL,
	[Session] [nvarchar](500) NULL,
	[Ip] [nvarchar](500) NULL,
	[CreatedBy] [nvarchar](500) NULL,
	[ModifiedBy] [nvarchar](500) NULL,
	[HashKey] [varbinary](50) NULL
) ON [PRIMARY]
GO
