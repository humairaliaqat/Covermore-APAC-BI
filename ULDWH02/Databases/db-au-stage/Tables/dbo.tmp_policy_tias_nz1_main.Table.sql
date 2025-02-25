USE [db-au-stage]
GO
/****** Object:  Table [dbo].[tmp_policy_tias_nz1_main]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_policy_tias_nz1_main](
	[CountryKey] [varchar](2) NOT NULL,
	[AgencySuperGroupName] [varchar](25) NULL,
	[AgencyGroupName] [varchar](25) NULL,
	[BDM] [varchar](20) NULL,
	[CreateDate] [smalldatetime] NOT NULL,
	[B2BPolicy] [int] NULL,
	[B2BSellPrice] [money] NULL,
	[B2BNetPrice] [money] NULL,
	[B2CPolicy] [int] NULL,
	[B2CSellPrice] [money] NULL,
	[B2CNetPrice] [money] NULL,
	[Policy] [int] NULL,
	[SellPrice] [money] NULL,
	[NetPrice] [money] NULL
) ON [PRIMARY]
GO
