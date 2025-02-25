USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl013_TIASTargetAU]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl013_TIASTargetAU](
	[YearStartDate] [datetime] NULL,
	[YearEndDate] [datetime] NULL,
	[Group] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[TargetType] [nvarchar](255) NULL,
	[Jul] [float] NULL,
	[Aug] [float] NULL,
	[Sep] [float] NULL,
	[Oct] [float] NULL,
	[Nov] [float] NULL,
	[Dec] [float] NULL,
	[Jan] [float] NULL,
	[Feb] [float] NULL,
	[Mar] [float] NULL,
	[Apr] [float] NULL,
	[May] [float] NULL,
	[Jun] [float] NULL
) ON [PRIMARY]
GO
