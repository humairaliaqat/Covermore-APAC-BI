USE [db-au-bobjaudit]
GO
/****** Object:  Table [dbo].[ADS_STATUS_STR]    Script Date: 21/02/2025 11:29:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ADS_STATUS_STR](
	[Status_ID] [int] NOT NULL,
	[Event_Type_ID] [int] NOT NULL,
	[Language] [varchar](10) NOT NULL,
	[Status_Name] [nvarchar](255) NULL,
 CONSTRAINT [ADS_STATUS_STR_PK] PRIMARY KEY CLUSTERED 
(
	[Status_ID] ASC,
	[Event_Type_ID] ASC,
	[Language] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
