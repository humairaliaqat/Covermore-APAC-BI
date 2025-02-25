USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblIndicentTypeFeePricingMatrix_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblIndicentTypeFeePricingMatrix_aucm](
	[ID] [int] NOT NULL,
	[NIT_INCIDENTTYPE_ID] [int] NULL,
	[ChannelId] [int] NULL,
	[Fee] [nvarchar](50) NULL,
	[Tax] [nvarchar](50) NULL
) ON [PRIMARY]
GO
