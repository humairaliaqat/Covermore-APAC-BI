USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[JobConfig]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[JobConfig](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EntityName] [varchar](100) NULL,
	[LastDatetime] [datetime] NULL,
	[Flag] [bit] NULL
) ON [PRIMARY]
GO
