USE [db-au-stage]
GO
/****** Object:  Table [dbo].[FINAL$]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FINAL$](
	[Month] [datetime] NULL,
	[PCC] [nvarchar](255) NULL,
	[INT Tickets (excl Reissues)] [float] NULL,
	[DOM Tickets (excl Reissues)] [float] NULL,
	[INT Policies] [float] NULL,
	[DOM Policies] [float] NULL
) ON [PRIMARY]
GO
