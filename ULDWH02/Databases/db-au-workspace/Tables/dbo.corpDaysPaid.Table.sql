USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[corpDaysPaid]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpDaysPaid](
	[CountryKey] [varchar](2) NOT NULL,
	[DaysPaidKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[BankRecordKey] [varchar](10) NULL,
	[DaysPaidID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[CreateDate] [datetime] NULL,
	[IssuedDate] [datetime] NULL,
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
	[BankRecord] [int] NULL
) ON [PRIMARY]
GO
