USE [db-au-stage]
GO
/****** Object:  Table [dbo].[web_GigyaAccounts]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[web_GigyaAccounts](
	[UID] [nvarchar](100) NULL,
	[createdDate] [datetime2](7) NULL,
	[createdTimestamp] [bigint] NULL,
	[data] [nvarchar](4000) NULL,
	[emails] [nvarchar](2000) NULL,
	[identities] [nvarchar](4000) NULL,
	[iRank] [int] NULL,
	[isActive] [bit] NULL,
	[isLockedOut] [bit] NULL,
	[isRegistered] [bit] NULL,
	[isVerified] [bit] NULL,
	[lastLoginDate] [datetime2](7) NULL,
	[lastLoginLocation] [nvarchar](1000) NULL,
	[lastLoginTimestamp] [bigint] NULL,
	[lastUpdatedDate] [datetime2](7) NULL,
	[lastUpdatedTimestamp] [bigint] NULL,
	[loginIDs] [nvarchar](1000) NULL,
	[loginProvider] [varchar](100) NULL,
	[oldestDataUpdatedDate] [datetime2](7) NULL,
	[oldestDataUpdatedTimestamp] [bigint] NULL,
	[password] [nvarchar](1000) NULL,
	[profile] [nvarchar](4000) NULL,
	[rbaPolicy] [nvarchar](1000) NULL,
	[registeredDate] [datetime2](7) NULL,
	[registeredTimestamp] [bigint] NULL,
	[regSource] [varchar](200) NULL,
	[socialProviders] [varchar](100) NULL,
	[verifiedDate] [datetime2](7) NULL,
	[verifiedTimestamp] [bigint] NULL,
	[firstName] [nvarchar](50) NULL,
	[lastName] [nvarchar](50) NULL,
	[age] [int] NULL,
	[dob] [date] NULL,
	[birthYear] [int] NULL,
	[birthMonth] [int] NULL,
	[birthDay] [int] NULL,
	[gender] [varchar](10) NULL,
	[title] [nvarchar](50) NULL,
	[email] [nvarchar](100) NULL,
	[phoneNumber] [nvarchar](50) NULL,
	[address] [nvarchar](100) NULL,
	[city] [nvarchar](50) NULL,
	[state] [nvarchar](50) NULL,
	[country] [nvarchar](50) NULL,
	[postcode] [nvarchar](50) NULL,
	[lastLoginLocationCountry] [nvarchar](50) NULL,
	[createdDateUTC] [datetime2](7) NULL,
	[lastUpdatedDateUTC] [datetime2](7) NULL,
	[lastLoginDateUTC] [datetime2](7) NULL
) ON [PRIMARY]
GO
