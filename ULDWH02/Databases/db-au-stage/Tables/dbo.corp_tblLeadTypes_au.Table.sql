USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblLeadTypes_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblLeadTypes_au](
	[LeadTypeID] [int] NOT NULL,
	[LeadTypeDesc] [varchar](50) NULL
) ON [PRIMARY]
GO
