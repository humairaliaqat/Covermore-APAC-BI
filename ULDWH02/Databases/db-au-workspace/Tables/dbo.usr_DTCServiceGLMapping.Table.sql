USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usr_DTCServiceGLMapping]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usr_DTCServiceGLMapping](
	[BIRowID] [int] IDENTITY(1,1) NOT NULL,
	[GLSeg2Code] [char](2) NOT NULL,
	[ServiceSK] [int] NULL
) ON [PRIMARY]
GO
