USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblExpo_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblExpo_uscm](
	[ExpoID] [int] NOT NULL,
	[Name] [varchar](250) NOT NULL,
	[ActiveFrom] [datetime] NOT NULL,
	[ActiveTo] [datetime] NOT NULL,
	[DomainId] [int] NOT NULL
) ON [PRIMARY]
GO
