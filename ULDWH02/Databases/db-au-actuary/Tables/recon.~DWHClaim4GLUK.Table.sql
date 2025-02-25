USE [db-au-actuary]
GO
/****** Object:  Table [recon].[~DWHClaim4GLUK]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [recon].[~DWHClaim4GLUK](
	[PaymentMonth] [date] NULL,
	[TransactionReference] [varchar](16) NOT NULL,
	[LineDescription] [varchar](100) NULL,
	[PaymentMovement] [decimal](38, 6) NULL,
	[NonITCFixPaymentMovement] [decimal](38, 6) NULL
) ON [PRIMARY]
GO
