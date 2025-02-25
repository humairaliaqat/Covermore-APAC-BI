USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_tblEMCApproval_nz]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_tblEMCApproval_nz](
	[Counter] [int] NOT NULL,
	[ClientID] [int] NULL,
	[Condition] [varchar](50) NULL,
	[DeniedAccepted] [varchar](1) NULL,
	[CONDCODE] [varchar](1) NULL,
	[AssessorID] [int] NULL
) ON [PRIMARY]
GO
