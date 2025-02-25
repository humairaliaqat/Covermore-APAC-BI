USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblDaysPaid_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblDaysPaid_nz](
	[DaysPaidID] [int] NOT NULL,
	[QtID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[IssuedDt] [datetime] NULL,
	[PropBal] [char](1) NULL,
	[CalcLoad] [money] NULL,
	[VolDisc] [money] NULL,
	[NewPolDisc] [money] NULL,
	[XSDisc] [money] NULL,
	[MinPremPenalty] [money] NULL,
	[InterimPrem] [money] NULL,
	[CMCommDisc] [money] NULL,
	[DestLoad] [money] NULL,
	[AssistFees] [money] NULL,
	[AgtComm] [money] NULL,
	[CMComm] [money] NULL,
	[DomRatio] [real] NULL,
	[BankRec] [int] NULL
) ON [PRIMARY]
GO
