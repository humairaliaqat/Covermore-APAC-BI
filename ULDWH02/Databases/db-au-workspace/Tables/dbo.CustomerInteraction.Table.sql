USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[CustomerInteraction]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInteraction](
	[MetaDataID] [bigint] NOT NULL,
	[InteractionType] [varchar](50) NULL,
	[InteractionReference] [varchar](max) NULL,
	[InteractionTime] [datetime] NULL,
	[InteractionDuration] [int] NULL,
	[Title] [nvarchar](max) NULL,
	[FirstName] [nvarchar](max) NULL,
	[Surname] [nvarchar](max) NULL,
	[Sex] [nvarchar](max) NULL,
	[DOB] [date] NULL,
	[Street] [nvarchar](max) NULL,
	[Suburb] [nvarchar](max) NULL,
	[State] [nvarchar](max) NULL,
	[PostCode] [nvarchar](max) NULL,
	[ContactPhone] [nvarchar](70) NULL,
	[Phone] [nvarchar](max) NULL,
	[MobilePhone] [nvarchar](max) NULL,
	[Email] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[CustomerInteraction]
(
	[MetaDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
