USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penelope_aiccasemembers_audtc]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penelope_aiccasemembers_audtc](
	[kcasemembersid] [int] NOT NULL,
	[kcaseid] [int] NOT NULL,
	[kindid] [int] NOT NULL,
	[lucmemfamilytreeid] [int] NULL,
	[cmemsafety] [varchar](5) NULL,
	[cmeminitiator] [varchar](5) NOT NULL,
	[cmemprimary] [varchar](5) NOT NULL,
	[slogin] [datetime2](7) NOT NULL,
	[slogmod] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
