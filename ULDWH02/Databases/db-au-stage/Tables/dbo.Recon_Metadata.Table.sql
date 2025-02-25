USE [db-au-stage]
GO
/****** Object:  Table [dbo].[Recon_Metadata]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Recon_Metadata](
	[ID] [float] NULL,
	[Active] [float] NULL,
	[SubjectArea] [nvarchar](255) NULL,
	[ETLName] [nvarchar](255) NULL,
	[Group] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Target] [nvarchar](255) NULL,
	[Source1] [nvarchar](255) NULL,
	[Source2] [nvarchar](255) NULL,
	[Source3] [nvarchar](255) NULL,
	[AllZero] [float] NULL,
	[Comment] [nvarchar](255) NULL
) ON [PRIMARY]
GO
