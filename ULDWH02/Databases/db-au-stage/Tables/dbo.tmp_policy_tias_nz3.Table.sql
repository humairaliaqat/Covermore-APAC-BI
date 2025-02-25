USE [db-au-stage]
GO
/****** Object:  Table [dbo].[tmp_policy_tias_nz3]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_policy_tias_nz3](
	[CountryKey] [varchar](2) NULL,
	[AgencySuperGroupName] [varchar](25) NULL,
	[AgencyGroupName] [varchar](25) NULL,
	[BDM] [varchar](20) NULL,
	[CreateDate] [smalldatetime] NULL,
	[B2BPolicy] [int] NULL,
	[B2BSellPrice] [money] NULL,
	[B2BNetPrice] [money] NULL,
	[B2CPolicy] [int] NULL,
	[B2CSellPrice] [money] NULL,
	[B2CNetPrice] [money] NULL,
	[Policy] [int] NULL,
	[SellPrice] [money] NULL,
	[NetPrice] [money] NULL,
	[LYPolicy] [int] NULL,
	[LYSellPrice] [money] NULL,
	[LYNetPrice] [money] NULL,
	[BudgetValue] [numeric](38, 5) NULL
) ON [PRIMARY]
GO
