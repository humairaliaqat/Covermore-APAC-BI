USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblDuration_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblDuration_autp](
	[DurationID] [int] NOT NULL,
	[DurationSetID] [int] NOT NULL,
	[Length] [int] NOT NULL,
	[Period] [nchar](1) NOT NULL
) ON [PRIMARY]
GO
