USE [db-au-stage]
GO
/****** Object:  Table [dbo].[corp_tblLuggage_nz]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[corp_tblLuggage_nz](
	[LuggID] [int] NOT NULL,
	[QtID] [int] NULL,
	[LuggTypID] [int] NULL,
	[CreatedDt] [datetime] NULL,
	[IssuedDt] [datetime] NULL,
	[LuggDesc] [varchar](50) NULL,
	[LuggVal] [money] NULL,
	[LuggLoad] [money] NULL,
	[LuggAccept] [bit] NULL,
	[AgtComm] [money] NULL,
	[CMComm] [money] NULL,
	[BankRec] [int] NULL,
	[Comments] [varchar](255) NULL
) ON [PRIMARY]
GO
