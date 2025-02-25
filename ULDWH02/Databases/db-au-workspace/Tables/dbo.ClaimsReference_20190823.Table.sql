USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ClaimsReference_20190823]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimsReference_20190823](
	[Domain Country] [varchar](2) NOT NULL,
	[ClaimKey] [varchar](40) NOT NULL,
	[ClaimNo] [int] NOT NULL,
	[Reference] [int] NULL
) ON [PRIMARY]
GO
