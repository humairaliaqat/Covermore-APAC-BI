USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblTaxes_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblTaxes_nz](
	[TaxID] [int] NOT NULL,
	[QtID] [int] NULL,
	[ItemID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[ActPeriod] [datetime] NULL,
	[ItemType] [varchar](50) NULL,
	[PropBal] [char](1) NULL,
	[DomPremIncGST] [money] NULL,
	[DomStamp] [money] NULL,
	[IntStamp] [money] NULL,
	[GSTGross] [money] NULL,
	[UWSaleExGST] [money] NULL,
	[GSTAgtComm] [money] NULL,
	[AgtCommExGST] [money] NULL,
	[GSTCMComm] [money] NULL,
	[CMCommExGST] [money] NULL
) ON [PRIMARY]
GO
