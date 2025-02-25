USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCancellationValue_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCancellationValue_ukcm](
	[ID] [int] NOT NULL,
	[CancellationValueSetID] [int] NOT NULL,
	[CancellationValue] [money] NOT NULL,
	[CancellationValueText] [nvarchar](50) NOT NULL,
	[CancellationValueFamily] [money] NULL,
	[SortOrder] [int] NOT NULL
) ON [PRIMARY]
GO
