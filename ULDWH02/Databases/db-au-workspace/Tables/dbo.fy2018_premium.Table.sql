USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[fy2018_premium]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fy2018_premium](
	[JV] [nvarchar](255) NULL,
	[Channel] [nvarchar](255) NULL,
	[Product] [nvarchar](255) NULL,
	[Jan 18] [float] NULL,
	[Feb 18] [float] NULL,
	[Mar 18] [float] NULL,
	[Apr 18] [float] NULL,
	[May 18] [float] NULL,
	[Jun 18] [float] NULL,
	[Jul 18] [float] NULL,
	[Aug 18] [float] NULL,
	[Sep 18] [float] NULL,
	[Oct 18] [float] NULL,
	[Nov 18] [float] NULL,
	[Dec 18] [float] NULL,
	[Total Insurance Premium] [nvarchar](255) NULL,
	[Working Plan] [nvarchar](255) NULL
) ON [PRIMARY]
GO
