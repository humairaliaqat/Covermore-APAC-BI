USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAssistanceFee_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAssistanceFee_aucm](
	[AssistanceFeeId] [int] NOT NULL,
	[JointVentureId] [int] NOT NULL,
	[Value] [numeric](18, 4) NOT NULL,
	[EffectiveFrom] [date] NOT NULL,
	[CrmUserId] [int] NULL,
	[IsPolicyCount] [bit] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Status] [nvarchar](15) NOT NULL,
	[DomainId] [int] NULL
) ON [PRIMARY]
GO
