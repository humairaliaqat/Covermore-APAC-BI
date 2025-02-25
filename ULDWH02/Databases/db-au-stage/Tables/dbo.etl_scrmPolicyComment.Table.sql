USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmPolicyComment]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmPolicyComment](
	[UniqueIdentifier] [nvarchar](27) NOT NULL,
	[PolicyNumber] [varchar](25) NULL,
	[CallCommentID] [int] NOT NULL,
	[CommentDateTime] [datetime] NULL,
	[Comment] [nvarchar](max) NULL,
	[User] [nvarchar](101) NULL,
	[Subject] [nvarchar](200) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
