USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cbAddress_BKP20190122_deleted_records]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cbAddress_BKP20190122_deleted_records](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [nvarchar](2) NOT NULL,
	[CaseKey] [nvarchar](20) NOT NULL,
	[AddressKey] [nvarchar](20) NOT NULL,
	[CaseNo] [nvarchar](15) NOT NULL,
	[AddressID] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[CreateDateUTC] [datetime] NULL,
	[AddressType] [nvarchar](25) NULL,
	[IsOverwrite] [bit] NULL,
	[IsDefault] [bit] NULL,
	[IsConsent] [bit] NULL,
	[FirstName] [varbinary](500) NULL,
	[Surname] [varbinary](500) NULL,
	[DOB] [varbinary](200) NULL,
	[Company] [varbinary](500) NULL,
	[Street] [varbinary](500) NULL,
	[Town] [varbinary](500) NULL,
	[Country] [varbinary](500) NULL,
	[PostCode] [varbinary](500) NULL,
	[Phone] [varbinary](500) NULL,
	[Mobile] [varbinary](500) NULL,
	[Fax] [varbinary](500) NULL,
	[Telex] [varbinary](500) NULL,
	[Email] [varbinary](500) NULL,
	[CreatedBy] [nvarchar](50) NULL,
	[ModifiedBy] [nvarchar](50) NULL,
	[ModifiedByID] [nvarchar](30) NULL,
	[ModifiedDate] [datetime] NULL,
	[isCurrentLocation] [bit] NULL,
	[ArrivedDate] [date] NULL,
	[CountryCode] [nvarchar](3) NULL,
	[CountryName] [nvarchar](25) NULL,
	[CreatedByID] [nvarchar](30) NULL
) ON [PRIMARY]
GO
