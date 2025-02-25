USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[scrmConsultant_UAT]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[scrmConsultant_UAT](
	[UniqueIdentifier] [nvarchar](200) NULL,
	[Name] [nvarchar](200) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[UserName] [nvarchar](100) NULL,
	[UserType] [nvarchar](50) NULL,
	[OutletUniqueIdentifier] [nvarchar](50) NOT NULL,
	[Status] [varchar](10) NOT NULL,
	[InactiveStatusDate] [date] NULL,
	[Email] [nvarchar](250) NULL,
	[DateOfBirth] [date] NULL,
	[HashKey] [binary](30) NULL,
	[LoadDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[isSynced] [nvarchar](1) NULL,
	[SyncedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
