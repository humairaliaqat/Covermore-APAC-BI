USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[logdashboard]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[logdashboard](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[RequestTimestamp] [datetime] NULL,
	[Organisation] [varchar](max) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[BusinessUnit] [varchar](max) NULL,
	[SubLevel] [varchar](max) NULL,
	[Debug] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[logdashboard] ADD  DEFAULT (getdate()) FOR [RequestTimestamp]
GO
