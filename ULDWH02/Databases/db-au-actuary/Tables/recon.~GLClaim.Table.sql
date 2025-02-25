USE [db-au-actuary]
GO
/****** Object:  Table [recon].[~GLClaim]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [recon].[~GLClaim](
	[Period] [int] NULL,
	[GLMonth] [smalldatetime] NULL,
	[TransactionReference] [varchar](50) NULL,
	[Description] [varchar](50) NULL,
	[GLAmount] [numeric](38, 3) NULL
) ON [PRIMARY]
GO
