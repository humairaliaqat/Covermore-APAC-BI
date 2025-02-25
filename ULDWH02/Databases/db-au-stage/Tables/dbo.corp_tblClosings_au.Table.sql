USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblClosings_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblClosings_au](
	[ClosingID] [int] NOT NULL,
	[QtID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[IssuedDt] [datetime] NULL,
	[ClosingTypID] [int] NULL,
	[BenefitID] [int] NULL,
	[UWAcceptDt] [datetime] NULL,
	[ClosingLoad] [money] NULL,
	[CloseAccept] [bit] NULL,
	[AgtComm] [money] NULL,
	[CMComm] [money] NULL,
	[BankRec] [int] NULL,
	[Comments] [varchar](255) NULL,
	[IntlTravelOnly] [bit] NULL,
	[TravellerID] [int] NULL,
	[ExtraDays] [int] NULL
) ON [PRIMARY]
GO
