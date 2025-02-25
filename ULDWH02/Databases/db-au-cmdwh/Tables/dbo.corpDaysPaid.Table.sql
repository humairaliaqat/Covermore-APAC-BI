USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpDaysPaid]    Script Date: 24/02/2025 12:39:34 PM ******/
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
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpDaysPaid_QuoteKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_corpDaysPaid_QuoteKey] ON [dbo].[corpDaysPaid]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpDaysPaid_BankRecordKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpDaysPaid_BankRecordKey] ON [dbo].[corpDaysPaid]
(
	[BankRecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
