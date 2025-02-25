USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[bobjUser]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bobjUser](
	[UserID] [float] NULL,
	[UserName] [nvarchar](255) NULL,
	[UserFullName] [nvarchar](255) NULL,
	[Owner] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[LastLogonDate] [datetime] NULL,
	[Kind] [nvarchar](255) NULL
) ON [PRIMARY]
GO
