USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCRMUserDepartment_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCRMUserDepartment_autp](
	[ID] [int] NOT NULL,
	[CRMUserID] [int] NOT NULL,
	[DepartmentID] [int] NOT NULL,
	[AccessLevel] [int] NOT NULL
) ON [PRIMARY]
GO
