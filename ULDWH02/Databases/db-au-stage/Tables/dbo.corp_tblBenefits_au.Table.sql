USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblBenefits_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblBenefits_au](
	[BenefitID] [int] NOT NULL,
	[BenCode] [varchar](3) NULL,
	[BenDesc] [varchar](200) NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY]
GO
