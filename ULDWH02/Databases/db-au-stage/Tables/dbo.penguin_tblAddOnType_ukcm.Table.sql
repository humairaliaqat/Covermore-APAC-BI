USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnType_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnType_ukcm](
	[AddOnTypeId] [int] NOT NULL,
	[AddOnType] [nvarchar](50) NULL,
	[ValueList] [bit] NULL,
	[Text] [bit] NULL
) ON [PRIMARY]
GO
