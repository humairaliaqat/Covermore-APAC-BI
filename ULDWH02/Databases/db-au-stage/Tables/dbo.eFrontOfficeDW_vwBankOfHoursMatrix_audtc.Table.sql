USE [db-au-stage]
GO
/****** Object:  Table [dbo].[eFrontOfficeDW_vwBankOfHoursMatrix_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eFrontOfficeDW_vwBankOfHoursMatrix_audtc](
	[RateID] [varchar](32) NULL,
	[Customer] [nvarchar](80) NULL,
	[Service] [nvarchar](255) NULL,
	[Country] [nvarchar](255) NULL,
	[RateName] [nvarchar](255) NULL,
	[Method] [nvarchar](255) NULL,
	[Rate] [money] NULL,
	[RateExtra] [money] NULL,
	[equivalentEAPHours] [money] NULL,
	[ReportingDisplayService] [nvarchar](255) NULL,
	[ReportOrdering] [int] NULL
) ON [PRIMARY]
GO
