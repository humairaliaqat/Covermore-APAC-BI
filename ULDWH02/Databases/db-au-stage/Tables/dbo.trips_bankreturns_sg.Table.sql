USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_bankreturns_sg]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_bankreturns_sg](
	[RtnID] [int] NOT NULL,
	[Alpha] [varchar](7) NULL,
	[Op] [varchar](10) NULL,
	[Account] [varchar](4) NULL,
	[BankDate] [datetime] NULL,
	[BankTime] [datetime] NULL
) ON [PRIMARY]
GO
