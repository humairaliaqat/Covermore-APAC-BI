USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblJobError_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblJobError_aucm](
	[Id] [int] NOT NULL,
	[JobId] [int] NOT NULL,
	[Description] [varchar](max) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[ErrorSource] [varchar](15) NOT NULL,
	[DataId] [varchar](300) NULL,
	[SourceData] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
