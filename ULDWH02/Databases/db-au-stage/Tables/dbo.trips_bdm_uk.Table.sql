USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_bdm_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_bdm_uk](
	[ExecName] [varchar](50) NULL,
	[Code] [smallint] NULL,
	[id] [int] NOT NULL,
	[InUseFlag] [int] NULL,
	[State] [varchar](50) NULL
) ON [PRIMARY]
GO
