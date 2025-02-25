USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_Sanctioned_UK]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_Sanctioned_UK](
	[Name 6] [varchar](max) NULL,
	[Name 1] [varchar](max) NULL,
	[Name 2] [varchar](max) NULL,
	[Name 3] [varchar](max) NULL,
	[Name 4] [varchar](max) NULL,
	[Name 5] [varchar](max) NULL,
	[Title] [varchar](max) NULL,
	[DOB] [varchar](max) NULL,
	[Town of Birth] [varchar](max) NULL,
	[Country of Birth] [varchar](max) NULL,
	[Nationality] [varchar](max) NULL,
	[Passport Details] [varchar](max) NULL,
	[NI Number] [varchar](max) NULL,
	[Position] [varchar](max) NULL,
	[Address 1] [varchar](max) NULL,
	[Address 2] [varchar](max) NULL,
	[Address 3] [varchar](max) NULL,
	[Address 4] [varchar](max) NULL,
	[Address 5] [varchar](max) NULL,
	[Address 6] [varchar](max) NULL,
	[Post/Zip Code] [varchar](max) NULL,
	[Country] [varchar](max) NULL,
	[Other Information] [varchar](max) NULL,
	[Group Type] [varchar](max) NULL,
	[Alias Type] [varchar](max) NULL,
	[Regime] [varchar](max) NULL,
	[Listed On] [varchar](max) NULL,
	[Last Updated] [varchar](max) NULL,
	[Group ID] [bigint] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
