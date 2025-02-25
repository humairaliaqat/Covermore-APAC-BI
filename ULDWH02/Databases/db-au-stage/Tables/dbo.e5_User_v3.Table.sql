USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_User_v3]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_User_v3](
	[Id] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](128) NOT NULL,
	[Title] [nvarchar](128) NULL,
	[GivenName] [nvarchar](128) NOT NULL,
	[FamilyName] [nvarchar](128) NULL,
	[DisplayName] [nvarchar](256) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[Active] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[CreatedDateTime] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[ModifiedDateTime] [datetime2](7) NULL,
	[ModifiedBy] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
