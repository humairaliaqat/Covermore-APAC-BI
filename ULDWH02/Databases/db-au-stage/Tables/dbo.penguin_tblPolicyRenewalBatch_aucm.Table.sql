USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyRenewalBatch_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyRenewalBatch_aucm](
	[PolicyRenewalBatchId] [int] NOT NULL,
	[JobId] [int] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
