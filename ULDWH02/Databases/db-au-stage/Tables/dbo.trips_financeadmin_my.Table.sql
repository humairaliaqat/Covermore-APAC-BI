USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_financeadmin_my]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_financeadmin_my](
	[id] [int] NULL,
	[Name] [varchar](100) NULL,
	[Initial] [varchar](4) NULL,
	[Phone] [varchar](20) NULL,
	[Email] [varchar](100) NULL,
	[Fax] [varchar](50) NULL,
	[InUse] [bit] NULL
) ON [PRIMARY]
GO
