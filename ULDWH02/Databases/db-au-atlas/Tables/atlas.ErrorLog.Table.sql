USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[ErrorLog]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[ErrorLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ColName] [varchar](1000) NULL,
	[ErrorDescription] [varchar](8000) NULL,
	[InsertedDate] [datetime] NULL,
	[DataflowTaskName] [varchar](100) NULL
) ON [PRIMARY]
GO
ALTER TABLE [atlas].[ErrorLog] ADD  DEFAULT (getdate()) FOR [InsertedDate]
GO
