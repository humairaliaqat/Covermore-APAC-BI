USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[temp_Final]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[temp_Final](
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
	[RN] [bigint] NULL,
	[Sent_Flag] [int] NULL,
	[Sent_Flag_Date] [datetime] NULL,
	[Quarter_No] [int] NULL
) ON [PRIMARY]
GO
