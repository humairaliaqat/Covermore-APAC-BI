USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[dqcPolicyDataset]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dqcPolicyDataset](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[CalendarDate] [date] NULL,
	[CountryCode] [nvarchar](2) NULL,
	[OutletAlphaKeySRC] [nvarchar](100) NULL,
	[OutletAlphaKeyODS] [nvarchar](100) NULL,
	[OutletAlphaKeySTR] [nvarchar](100) NULL,
	[OutletAlphaKeyCUB] [nvarchar](100) NULL,
	[OutletAlphaKeyACT] [nvarchar](100) NULL,
	[JVCodeSRC] [nvarchar](100) NULL,
	[JVCodeODS] [nvarchar](100) NULL,
	[JVCodeSTR] [nvarchar](100) NULL,
	[JVCodeCUB] [nvarchar](100) NULL,
	[JVCodeACT] [nvarchar](100) NULL,
	[ChannelSRC] [nvarchar](100) NULL,
	[ChannelODS] [nvarchar](100) NULL,
	[ChannelSTR] [nvarchar](100) NULL,
	[ChannelCUB] [nvarchar](100) NULL,
	[ChannelACT] [nvarchar](100) NULL,
	[PolicyCountSRC] [int] NULL,
	[PolicyCountODSvsSRC] [int] NULL,
	[PolicyCountSTRvsSRC] [int] NULL,
	[PolicyCountCUBvsSRC] [int] NULL,
	[PolicyCountACTvsSRC] [int] NULL,
	[SellPriceSRC] [money] NULL,
	[SellPriceODSvsSRC] [money] NULL,
	[SellPriceSTRvsSRC] [money] NULL,
	[SellPriceCUBvsSRC] [money] NULL,
	[SellPriceACTvsSRC] [money] NULL,
	[CommissionSRC] [money] NULL,
	[CommissionODSvsSRC] [money] NULL,
	[CommissionSTRvsSRC] [money] NULL,
	[CommissionCUBvsSRC] [money] NULL,
	[CommissionACTvsSRC] [money] NULL,
	[PolicyNumberStringSRC] [nvarchar](4000) NULL,
	[LastUpdated] [datetime] NULL,
 CONSTRAINT [PK_dqcPolicyDataset] PRIMARY KEY CLUSTERED 
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dqcPolicyDataset] ADD  DEFAULT (getdate()) FOR [LastUpdated]
GO
