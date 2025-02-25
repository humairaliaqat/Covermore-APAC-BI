USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[tmpMalaysia_Data]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpMalaysia_Data](
	[seqNumber] [int] IDENTITY(1,1) NOT NULL,
	[Data] [varchar](4016) NULL,
	[xOutputFileNamex] [varchar](13) NULL,
	[xDataIDx] [varchar](41) NOT NULL,
	[xDataValuex] [varchar](11) NULL
) ON [PRIMARY]
GO
