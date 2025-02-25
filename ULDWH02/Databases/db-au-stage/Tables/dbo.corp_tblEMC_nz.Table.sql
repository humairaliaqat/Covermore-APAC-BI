USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblEMC_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblEMC_nz](
	[EmcID] [int] NOT NULL,
	[QtID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[IssuedDt] [datetime] NULL,
	[EmcAppNo] [varchar](50) NULL,
	[EmcInsName] [varchar](50) NULL,
	[EmcLoad] [money] NULL,
	[EmcAccept] [bit] NULL,
	[AgtComm] [money] NULL,
	[CMComm] [money] NULL,
	[BankRec] [int] NULL,
	[Comments] [varchar](255) NULL
) ON [PRIMARY]
GO
