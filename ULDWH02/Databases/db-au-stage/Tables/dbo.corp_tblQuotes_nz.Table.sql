USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblQuotes_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblQuotes_nz](
	[QtID] [int] NOT NULL,
	[QtDt] [datetime] NULL,
	[Alpha] [varchar](7) NULL,
	[CompID] [int] NULL,
	[NewRen] [char](1) NULL,
	[ConvToPol] [bit] NULL,
	[IssueDt] [datetime] NULL,
	[PolNo] [int] NULL,
	[PolStDt] [datetime] NULL,
	[PolExpDt] [datetime] NULL,
	[Excess] [money] NULL,
	[PrevClaim] [bit] NULL,
	[InsCanxd] [bit] NULL,
	[QtRefused] [bit] NULL,
	[RefusalTypeID] [int] NULL,
	[PolCanxReasonID] [smallint] NULL,
	[PrevPol] [int] NULL,
	[BusDevMgrID] [int] NULL,
	[DirSalesExecID] [int] NULL,
	[LeadTypeID] [int] NULL,
	[Op] [varchar](10) NULL,
	[GroupPol] [bit] NULL
) ON [PRIMARY]
GO
