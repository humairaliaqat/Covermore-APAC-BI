USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblCaseTypeFeePricingMatrix_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblCaseTypeFeePricingMatrix_aucm](
	[ID] [int] NOT NULL,
	[POL_POLICY_ID] [int] NULL,
	[ChannelId] [int] NULL,
	[UCT_CASE_TYPE_ID] [int] NULL,
	[ProtocolCode] [int] NULL,
	[Fee] [money] NULL,
	[Tax] [money] NULL
) ON [PRIMARY]
GO
