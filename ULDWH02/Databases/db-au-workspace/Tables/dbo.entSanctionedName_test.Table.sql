USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[entSanctionedName_test]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entSanctionedName_test](
	[Country] [varchar](50) NULL,
	[SanctionID] [varchar](50) NULL,
	[Name] [nvarchar](500) NULL,
	[NameFragment] [varchar](500) NULL,
	[LastName] [varchar](50) NULL,
	[COB] [varchar](500) NULL,
	[Address] [varchar](1000) NULL
) ON [PRIMARY]
GO
