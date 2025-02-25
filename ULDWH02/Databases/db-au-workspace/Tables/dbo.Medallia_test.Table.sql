USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Medallia_test]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medallia_test](
	[FirstName] [varchar](8000) NULL,
	[LastName] [varchar](8000) NULL,
	[OutletId] [int] NULL,
	[Brand_Outlet] [varchar](8000) NULL,
	[GroupName] [varchar](8000) NULL,
	[SubGroupName] [varchar](8000) NULL,
	[SuperGroupName] [nvarchar](25) NULL,
	[Email] [nvarchar](200) NULL,
	[Status] [varchar](20) NULL,
	[CountryKey] [varchar](2) NULL,
	[Createdatetime] [date] NULL,
	[LastLoggedIn] [date] NULL,
	[CreatedDate] [datetime] NULL,
	[Quarter_No] [int] NULL
) ON [PRIMARY]
GO
