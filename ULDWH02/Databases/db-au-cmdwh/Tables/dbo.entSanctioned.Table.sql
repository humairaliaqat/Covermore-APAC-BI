USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entSanctioned]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entSanctioned](
	[Country] [varchar](2) NOT NULL,
	[SanctionID] [varchar](50) NULL,
	[Reference] [varchar](61) NULL,
	[Name] [nvarchar](max) NULL,
	[DOBString] [nvarchar](max) NULL,
	[Control Date] [datetime] NULL,
	[InsertionDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
