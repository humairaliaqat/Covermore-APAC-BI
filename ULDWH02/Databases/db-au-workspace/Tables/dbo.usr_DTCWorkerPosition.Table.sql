USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCWorkerPosition]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCWorkerPosition](
	[OrgUnitDescription] [nvarchar](255) NULL,
	[PositionTitle] [nvarchar](255) NULL,
	[Location] [int] NOT NULL,
	[LocationText] [varchar](100) NULL
) ON [PRIMARY]
GO
