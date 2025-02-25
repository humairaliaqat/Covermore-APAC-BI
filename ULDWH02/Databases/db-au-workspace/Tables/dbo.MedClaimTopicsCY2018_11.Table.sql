USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MedClaimTopicsCY2018_11]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedClaimTopicsCY2018_11](
	[ID] [nvarchar](255) NULL,
	[Text] [nvarchar](max) NULL,
	[Topic Form] [nvarchar](255) NULL,
	[Topic Category] [nvarchar](255) NULL,
	[Rank] [int] NULL,
	[Type] [nvarchar](255) NULL,
	[Theme] [nvarchar](255) NULL,
	[Frequency] [int] NULL,
	[Mentions] [nvarchar](255) NULL,
	[Sense ID] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
