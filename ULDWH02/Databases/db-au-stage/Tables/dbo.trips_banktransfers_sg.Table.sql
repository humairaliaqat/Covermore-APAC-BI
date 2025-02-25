USE [db-au-stage]
GO
/****** Object:  Table [dbo].[trips_banktransfers_sg]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[trips_banktransfers_sg](
	[TransferID] [int] NOT NULL,
	[BankRec] [int] NOT NULL,
	[Account] [varchar](6) NOT NULL,
	[Amount] [money] NOT NULL
) ON [PRIMARY]
GO
