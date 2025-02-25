USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[npsDataHistory]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[npsDataHistory](
	[HistoryDate] [datetime] NOT NULL,
	[DomainCountry] [varchar](5) NOT NULL,
	[Policy No] [nvarchar](50) NULL,
	[Claim No] [nvarchar](50) NULL,
	[MA Case No] [nvarchar](50) NULL,
	[Classification] [nvarchar](max) NULL,
	[Topic] [nvarchar](max) NULL,
	[Sentiment] [nvarchar](max) NULL,
	[BIRowID] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
