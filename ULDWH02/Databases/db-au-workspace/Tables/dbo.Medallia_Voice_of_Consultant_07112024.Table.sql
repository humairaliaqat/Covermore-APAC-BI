USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Medallia_Voice_of_Consultant_07112024]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medallia_Voice_of_Consultant_07112024](
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
	[New_Alert_Email] [nvarchar](200) NULL,
	[Overdue_Alert_Email] [nvarchar](200) NULL,
	[Escalated_Alert_Email] [nvarchar](200) NULL,
	[Survey_Group] [nvarchar](200) NULL,
	[Quarter_Flag] [int] NULL,
	[CreatedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
