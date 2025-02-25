USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblMemberType_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblMemberType_aucm](
	[ID] [int] NOT NULL,
	[Name] [nvarchar](100) NULL,
	[Code] [varchar](50) NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Status] [nvarchar](50) NULL
) ON [PRIMARY]
GO
