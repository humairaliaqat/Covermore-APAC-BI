USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trwdimAge]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trwdimAge](
	[Age] [float] NULL,
	[Code] [nvarchar](50) NULL,
	[AgeBand] [nvarchar](50) NULL,
	[AgeBandDisplay] [nvarchar](150) NULL
) ON [PRIMARY]
GO
