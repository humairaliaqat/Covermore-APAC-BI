USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCRMAccessRole_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCRMAccessRole_ukcm](
	[ID] [int] NOT NULL,
	[DeptID] [int] NOT NULL,
	[AccessLvl] [int] NOT NULL,
	[RoleID] [int] NOT NULL
) ON [PRIMARY]
GO
