USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[clrtest]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clrtest](
	[PolicyTravellerKey] [varchar](41) NULL,
	[fullname] [nvarchar](201) NULL,
	[gender] [nchar](2) NULL,
	[firstname] [nvarchar](100) NULL,
	[lastname] [nvarchar](100) NULL,
	[emailaddress] [nvarchar](255) NULL,
	[homephone] [varchar](50) NULL,
	[mobilephone] [varchar](50) NULL,
	[workphone] [varchar](50) NULL,
	[fulladdress] [nvarchar](404) NULL,
	[streetname] [nvarchar](201) NULL,
	[suburb] [nvarchar](50) NULL,
	[state] [nvarchar](100) NULL,
	[postcode] [nvarchar](50) NULL,
	[country] [nvarchar](100) NULL,
	[pidtype] [nvarchar](100) NULL,
	[pidvalue] [nvarchar](256) NULL,
	[membernumber] [nvarchar](25) NULL,
	[velocitynumber] [nvarchar](50) NULL
) ON [PRIMARY]
GO
