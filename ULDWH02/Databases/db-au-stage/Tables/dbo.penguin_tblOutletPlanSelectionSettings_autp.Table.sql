USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutletPlanSelectionSettings_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutletPlanSelectionSettings_autp](
	[Id] [int] NOT NULL,
	[OutletOTCId] [int] NOT NULL,
	[AccordianView] [int] NULL
) ON [PRIMARY]
GO
