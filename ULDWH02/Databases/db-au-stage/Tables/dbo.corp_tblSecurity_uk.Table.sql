USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblSecurity_uk]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblSecurity_uk](
	[ID] [int] NOT NULL,
	[Login] [varchar](15) NULL,
	[Password] [varchar](15) NULL,
	[FullName] [varchar](50) NULL,
	[SecurityLevel] [varchar](50) NULL
) ON [PRIMARY]
GO
