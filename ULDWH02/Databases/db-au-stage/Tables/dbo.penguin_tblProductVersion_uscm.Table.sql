USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblProductVersion_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblProductVersion_uscm](
	[ProductVersionID] [int] NOT NULL,
	[VersionNo] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[EffectiveStartDate] [datetime] NOT NULL,
	[EffectiveEndDate] [datetime] NULL,
	[VersionStatus] [varchar](25) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Status] [varchar](15) NOT NULL,
	[InvalidateOldQuotes] [bit] NOT NULL,
	[IsNewPdsVersion] [bit] NOT NULL,
	[PdsVersionNo] [int] NULL
) ON [PRIMARY]
GO
