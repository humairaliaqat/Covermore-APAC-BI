USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblDestTypes_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblDestTypes_uk](
	[DestTypeID] [int] NOT NULL,
	[DestIntDom] [varchar](50) NULL,
	[DestDesc] [varchar](150) NULL,
	[DestDailyRt] [money] NULL,
	[DestValidFromDt] [datetime] NULL,
	[DestValidToDt] [datetime] NULL,
	[DestCode] [char](1) NULL,
	[PayCommission] [bit] NULL
) ON [PRIMARY]
GO
