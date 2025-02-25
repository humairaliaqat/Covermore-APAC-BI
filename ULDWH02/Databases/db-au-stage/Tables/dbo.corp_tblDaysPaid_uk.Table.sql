USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblDaysPaid_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblDaysPaid_uk](
	[DaysPaidID] [int] NOT NULL,
	[QtID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[IssuedDt] [datetime] NULL,
	[PropBal] [char](1) NULL,
	[CalcLoad] [money] NULL,
	[DestLoad] [money] NULL,
	[AgtComm] [money] NULL,
	[IPT] [money] NULL,
	[BankRec] [int] NULL,
	[ActPeriod] [datetime] NULL
) ON [PRIMARY]
GO
