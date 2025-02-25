USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_agencygroup_uk]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_agencygroup_uk](
	[id] [int] NOT NULL,
	[Companyid] [int] NOT NULL,
	[Code] [varchar](2) NOT NULL,
	[Descript] [varchar](25) NULL,
	[PenguinEnabled] [bit] NULL,
	[EmailTemplate] [varchar](255) NULL,
	[Color] [varchar](20) NULL,
	[Vpctype] [varchar](255) NULL,
	[PhoneNumber] [varchar](14) NULL,
	[WebAddress] [varchar](46) NULL,
	[PenguinBaseURL] [varchar](500) NULL,
	[Style] [varchar](20) NULL
) ON [PRIMARY]
GO
