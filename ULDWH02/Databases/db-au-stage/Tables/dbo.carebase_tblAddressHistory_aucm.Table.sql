USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_tblAddressHistory_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_tblAddressHistory_aucm](
	[HistoryID] [int] NOT NULL,
	[ModifiedBy] [varchar](30) NULL,
	[AddressID] [int] NULL,
	[ArrivedDate] [datetime] NULL,
	[AddedDate] [datetime] NULL,
	[CaseNo] [varchar](30) NULL
) ON [PRIMARY]
GO
