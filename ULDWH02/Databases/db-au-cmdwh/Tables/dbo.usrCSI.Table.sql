USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCSI]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCSI](
	[Company] [varchar](100) NULL,
	[Month] [datetime] NULL,
	[CSI] [float] NULL
) ON [PRIMARY]
GO
