USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpClosing]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpClosing](
	[CountryKey] [varchar](2) NOT NULL,
	[ClosingKey] [varchar](10) NULL,
	[QuoteKey] [varchar](10) NULL,
	[BankRecordKey] [varchar](10) NULL,
	[TravellerKey] [varchar](33) NULL,
	[ClosingID] [int] NOT NULL,
	[QuoteID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[IssuedDate] [datetime] NULL,
	[ClosingTypeID] [int] NULL,
	[ClosingTypeDesc] [varchar](50) NULL,
	[BenefitID] [int] NULL,
	[BenefitCode] [varchar](3) NULL,
	[BenefitDesc] [varchar](200) NULL,
	[UWAcceptDate] [datetime] NULL,
	[ClosingLoad] [money] NULL,
	[CloseAccept] [bit] NULL,
	[AgentCommission] [money] NULL,
	[CMCommission] [money] NULL,
	[BankRecord] [int] NULL,
	[Comments] [varchar](255) NULL,
	[IntTravelOnly] [bit] NULL,
	[TravellerID] [int] NULL
) ON [PRIMARY]
GO
