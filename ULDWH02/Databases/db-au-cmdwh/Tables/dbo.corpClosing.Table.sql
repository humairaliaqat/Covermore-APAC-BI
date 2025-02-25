USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[corpClosing]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corpClosing](
	[CountryKey] [varchar](2) NOT NULL,
	[ClosingKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[BankRecordKey] [varchar](10) NULL,
	[ClosingID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[IssuedDate] [datetime] NULL,
	[ClosingTypeID] [int] NULL,
	[ClosingTypeDesc] [varchar](50) NULL,
	[BenefitID] [int] NULL,
	[BenefitCode] [varchar](3) NULL,
	[BenefitDesc] [varchar](50) NULL,
	[UWAcceptDate] [datetime] NULL,
	[ClosingLoad] [money] NULL,
	[CloseAccept] [bit] NULL,
	[AgentCommission] [money] NULL,
	[CMCommission] [money] NULL,
	[BankRecord] [int] NULL,
	[Comments] [varchar](255) NULL,
	[IntTravelOnly] [bit] NULL,
	[TravellerKey] [varchar](41) NULL,
	[TravellerID] [int] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpClosing_QuoteKey]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_corpClosing_QuoteKey] ON [dbo].[corpClosing]
(
	[QuoteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_corpClosing_BankRecordKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_corpClosing_BankRecordKey] ON [dbo].[corpClosing]
(
	[BankRecordKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
