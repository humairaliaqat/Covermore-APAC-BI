USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_clmLocationHistory]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_clmLocationHistory](
	[CountryKey] [varchar](2) NULL,
	[ClaimKey] [varchar](33) NULL,
	[LocationHistoryKey] [varchar](64) NULL,
	[LocationKey] [varchar](33) NULL,
	[ClaimNo] [int] NULL,
	[LocationHistoryID] [int] NOT NULL,
	[LocationID] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[CorroReceivedDate] [datetime] NULL,
	[CreatedDateTimeUTC] [datetime] NULL,
	[CorroReceivedDateTimeUTC] [datetime] NULL,
	[CreatedByName] [varchar](30) NULL,
	[Location] [varchar](50) NULL,
	[LocationDescription] [nvarchar](50) NULL,
	[Note] [nvarchar](50) NULL
) ON [PRIMARY]
GO
