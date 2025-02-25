USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[entSanctionedNames]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entSanctionedNames](
	[Country] [varchar](2) NOT NULL,
	[SanctionID] [varchar](50) NULL,
	[Reference] [varchar](61) NULL,
	[Name] [nvarchar](max) NULL,
	[NameFragment] [nvarchar](256) NULL,
	[LastName] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
