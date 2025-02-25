USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_Sanctioned_AU]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_Sanctioned_AU](
	[Reference] [varchar](max) NULL,
	[Name of Individual or Entity] [nvarchar](max) NULL,
	[Type] [varchar](max) NULL,
	[Name Type] [varchar](max) NULL,
	[Date of Birth] [varchar](max) NULL,
	[Place of Birth] [varchar](max) NULL,
	[Citizenship] [varchar](max) NULL,
	[Address] [nvarchar](max) NULL,
	[Additional Information] [varchar](max) NULL,
	[Listing Information] [varchar](max) NULL,
	[Committees] [varchar](max) NULL,
	[Control Date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
