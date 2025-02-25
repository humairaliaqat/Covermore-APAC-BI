USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Medallia_Voc_Q1]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medallia_Voc_Q1](
	[FirstName] [varchar](8000) NULL,
	[LastName] [varchar](8000) NULL,
	[OutletId] [int] NOT NULL,
	[Brand_Outlet] [varchar](8000) NULL,
	[GroupName] [varchar](8000) NULL,
	[SubGroupName] [varchar](8000) NULL,
	[SuperGroupName] [nvarchar](25) NULL,
	[Email] [nvarchar](200) NULL,
	[Status] [varchar](20) NULL,
	[CountryKey] [varchar](2) NOT NULL,
	[Createdatetime] [date] NULL,
	[LastLoggedIn] [date] NULL
) ON [PRIMARY]
GO
