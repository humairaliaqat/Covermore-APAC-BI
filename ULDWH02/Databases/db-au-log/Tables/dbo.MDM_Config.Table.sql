USE [db-au-log]
GO
/****** Object:  Table [dbo].[MDM_Config]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MDM_Config](
	[OrsId] [varchar](255) NULL,
	[UserName] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
	[Encrypted] [varchar](50) NULL
) ON [PRIMARY]
GO
