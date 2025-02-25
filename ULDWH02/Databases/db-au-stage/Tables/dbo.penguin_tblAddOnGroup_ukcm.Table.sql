USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnGroup_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnGroup_ukcm](
	[AddOnGroupId] [int] NOT NULL,
	[GroupName] [nvarchar](50) NOT NULL,
	[Comments] [nvarchar](50) NULL,
	[Code] [varchar](10) NULL
) ON [PRIMARY]
GO
