USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_rpt0491_pivot]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_rpt0491_pivot](
	[Row] [bigint] NULL,
	[PolicyKey] [varchar](41) NULL,
	[isPrimary] [bit] NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[MemberNumber] [nvarchar](25) NULL,
	[State] [nvarchar](100) NULL
) ON [PRIMARY]
GO
