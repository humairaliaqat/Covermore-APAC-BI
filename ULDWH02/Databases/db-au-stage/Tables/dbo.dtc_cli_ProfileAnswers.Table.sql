USE [db-au-stage]
GO
/****** Object:  Table [dbo].[dtc_cli_ProfileAnswers]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dtc_cli_ProfileAnswers](
	[ProfileAnswer_id] [varchar](32) NOT NULL,
	[ProfileQuestion_id] [varchar](32) NULL,
	[Answer_Number] [varchar](3) NULL,
	[Answer] [varchar](60) NULL,
	[RSChangeDate] [datetime] NULL,
	[RSArriveDate] [datetime] NULL,
	[RSSiteID] [varchar](10) NULL,
	[DisplayCategory] [varchar](100) NULL,
	[DisplayName] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_dtc_cli_ProfileAnswers_ProfileQuestion_ID_]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_dtc_cli_ProfileAnswers_ProfileQuestion_ID_] ON [dbo].[dtc_cli_ProfileAnswers]
(
	[ProfileQuestion_id] ASC,
	[Answer_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
