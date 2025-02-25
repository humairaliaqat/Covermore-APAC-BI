USE [db-au-stage]
GO
/****** Object:  Table [dbo].[eFrontOfficeDW_vwBankOfHours_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eFrontOfficeDW_vwBankOfHours_audtc](
	[GLApplyDate] [date] NULL,
	[trx_ctrl_num] [varchar](30) NOT NULL,
	[ServiceEventActivityID] [int] NULL,
	[ServiceEventActivityInvID] [int] NULL,
	[ServiceEventID] [int] NULL,
	[ServiceFileID] [int] NULL,
	[ItemDeleted] [datetime] NULL,
	[Sign] [money] NULL,
	[BankHours] [money] NULL,
	[Amount] [money] NULL,
	[Billable_Qty] [money] NULL,
	[RateID] [varchar](32) NULL
) ON [PRIMARY]
GO
