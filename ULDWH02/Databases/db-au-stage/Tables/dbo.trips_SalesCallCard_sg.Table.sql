USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_SalesCallCard_sg]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_SalesCallCard_sg](
	[SalesCallCardID] [numeric](18, 0) NOT NULL,
	[CLALPHA] [char](7) NULL,
	[StocksChecked] [varchar](50) NULL,
	[Duration] [int] NULL,
	[CallDate] [datetime] NULL,
	[CallTime] [datetime] NULL,
	[UserDate] [datetime] NULL
) ON [PRIMARY]
GO
