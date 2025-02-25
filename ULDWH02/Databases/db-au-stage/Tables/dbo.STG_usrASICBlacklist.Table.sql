USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_usrASICBlacklist]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_usrASICBlacklist](
	[BanRegisterName] [varchar](255) NULL,
	[FullNameASIC] [varchar](255) NULL,
	[FirstName] [varchar](255) NULL,
	[MiddleName] [varchar](255) NULL,
	[LastName] [varchar](255) NULL,
	[FullNamePenguin] [varchar](255) NULL,
	[BanType] [varchar](255) NULL,
	[BanDocumentNumber] [varchar](255) NULL,
	[BanStartDate] [datetime] NULL,
	[BanEndDate] [datetime] NULL,
	[LocalAddress] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[PostCode] [varchar](255) NULL,
	[Country] [varchar](255) NULL,
	[Comments] [varchar](1000) NULL
) ON [PRIMARY]
GO
