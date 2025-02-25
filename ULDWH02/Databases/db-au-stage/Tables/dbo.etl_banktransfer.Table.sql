USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_banktransfer]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_banktransfer](
	[CountryKey] [varchar](2) NOT NULL,
	[BankRecordKey] [varchar](13) NULL,
	[TransferKey] [varchar](13) NULL,
	[TransferID] [int] NOT NULL,
	[BankRec] [int] NOT NULL,
	[Account] [varchar](6) NOT NULL,
	[Amount] [money] NOT NULL
) ON [PRIMARY]
GO
