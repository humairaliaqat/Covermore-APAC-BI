USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MedClaimTopicsCY2018_42]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedClaimTopicsCY2018_42](
	[ID] [nvarchar](255) NULL,
	[Text] [nvarchar](255) NULL,
	[Topic Form] [nvarchar](255) NULL,
	[Topic Category] [nvarchar](255) NULL,
	[Rank] [int] NULL,
	[Type] [nvarchar](255) NULL,
	[Theme] [nvarchar](255) NULL,
	[Frequency] [int] NULL,
	[Mentions] [nvarchar](255) NULL,
	[Sense ID] [nvarchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ClaimKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_ClaimKey] ON [dbo].[MedClaimTopicsCY2018_42]
(
	[ID] ASC
)
INCLUDE([Topic Form],[Type],[Mentions]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
