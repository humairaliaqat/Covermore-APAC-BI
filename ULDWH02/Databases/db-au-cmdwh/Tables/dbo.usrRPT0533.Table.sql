USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT0533]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT0533](
	[GroupName] [nvarchar](50) NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[OutletType] [nvarchar](50) NULL,
	[ContactState] [nvarchar](100) NULL,
	[Branch] [nvarchar](60) NULL,
	[BDMName] [nvarchar](101) NULL,
	[Consultant] [nvarchar](101) NULL,
	[SalesSegment] [nvarchar](50) NULL,
	[TradingStatus] [nvarchar](50) NULL,
	[Date] [smalldatetime] NOT NULL,
	[PolicyCount] [int] NULL,
	[AgencyCommission] [money] NULL,
	[SellPrice] [money] NULL,
	[QuoteCount] [int] NULL,
	[YAGO_PolicyCount] [int] NULL,
	[YAGO_AgencyCommission] [money] NULL,
	[YAGO_SellPrice] [money] NULL,
	[YAGO_QuoteCount] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0533_AlphaCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrRPT0533_AlphaCode] ON [dbo].[usrRPT0533]
(
	[AlphaCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0533_Date]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0533_Date] ON [dbo].[usrRPT0533]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
