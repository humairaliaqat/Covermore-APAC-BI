USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_state_uk]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_state_uk](
	[Code] [varchar](3) NOT NULL,
	[Descript] [varchar](20) NULL,
	[FullDescript] [varchar](50) NULL,
	[State] [bit] NOT NULL
) ON [PRIMARY]
GO
