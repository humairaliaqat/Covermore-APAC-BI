USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Employee_Info]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee_Info](
	[EMPID] [varchar](200) NULL,
	[EMPEmail] [varchar](500) NULL,
	[FirstName] [varchar](500) NULL,
	[LastName] [varchar](500) NULL,
	[Active] [varchar](500) NULL,
	[CreatedDate] [datetime] NULL,
	[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
