USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[entPolicy_XFREF]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entPolicy_XFREF](
	[CustomerID] [bigint] NOT NULL,
	[CUstomerName] [nvarchar](255) NULL,
	[DOB] [date] NULL,
	[PolicyKey] [varchar](41) NULL,
	[RefCount] [int] NULL
) ON [PRIMARY]
GO
