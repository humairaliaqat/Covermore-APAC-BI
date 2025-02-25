USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[temp_Medallia2]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_Medallia2](
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
	[LastLoggedIn] [date] NULL,
	[EMail1] [varchar](1) NOT NULL,
	[Email2] [varchar](1) NOT NULL,
	[Email3] [varchar](1) NOT NULL,
	[Sent_Flag] [int] NULL,
	[Quarter_FLag] [int] NULL,
	[Sent_Date_FLag] [datetime] NULL
) ON [PRIMARY]
GO
