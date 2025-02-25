USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[call_peak]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[call_peak](
	[Date] [smalldatetime] NOT NULL,
	[Hour] [smalldatetime] NULL,
	[Minute] [smalldatetime] NULL,
	[CallsPresented] [int] NOT NULL
) ON [PRIMARY]
GO
