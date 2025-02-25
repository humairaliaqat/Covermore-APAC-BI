USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbAddressPassport_BKP20190122_deleted_records]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbAddressPassport_BKP20190122_deleted_records](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[AddressKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[AddressID] [int] NOT NULL,
	[PassportNumber] [nvarchar](500) NULL,
	[PassportCountry] [nvarchar](500) NULL,
	[PassportExpiryDate] [nvarchar](500) NULL,
	[PassportType] [nvarchar](500) NULL
) ON [PRIMARY]
GO
