USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPartialRefund_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPartialRefund_autp](
	[MonthNumber] [int] NOT NULL,
	[RefundPercentage] [numeric](18, 5) NOT NULL,
	[DomainId] [int] NOT NULL
) ON [PRIMARY]
GO
