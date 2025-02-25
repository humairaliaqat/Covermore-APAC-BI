USE [db-au-actuary]
GO
/****** Object:  Table [recon].[~GLClaimUK]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [recon].[~GLClaimUK](
	[Period] [int] NOT NULL,
	[GLMonth] [smalldatetime] NULL,
	[TransactionReference] [char](30) NULL,
	[Description] [char](50) NULL,
	[GLAmount] [numeric](38, 3) NULL
) ON [PRIMARY]
GO
