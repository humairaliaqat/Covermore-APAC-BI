USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblArea_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblArea_ukcm](
	[AreaId] [int] NOT NULL,
	[DomainId] [int] NULL,
	[Area] [nvarchar](100) NOT NULL,
	[Domestic] [bit] NOT NULL,
	[MinimumDuration] [numeric](5, 4) NOT NULL,
	[ChildAreaId] [int] NULL,
	[AreaGroup] [int] NULL,
	[NonResident] [bit] NULL,
	[Weighting] [int] NULL,
	[AreaSetID] [int] NULL,
	[Code] [nvarchar](3) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblArea_ukcm_AreaID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblArea_ukcm_AreaID] ON [dbo].[penguin_tblArea_ukcm]
(
	[AreaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
