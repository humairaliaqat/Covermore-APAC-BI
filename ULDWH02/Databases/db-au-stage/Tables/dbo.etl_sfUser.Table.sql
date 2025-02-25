USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_sfUser]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_sfUser](
	[UserID] [nvarchar](18) NULL,
	[UserType] [nvarchar](40) NULL,
	[Username] [nvarchar](80) NULL,
	[Name] [nvarchar](121) NULL,
	[FirstName] [nvarchar](40) NULL,
	[LastName] [nvarchar](80) NULL,
	[Alias] [nvarchar](8) NULL,
	[IsActive] [bit] NULL,
	[BDM] [nvarchar](250) NULL,
	[Manager] [nvarchar](121) NULL,
	[Profile] [nvarchar](255) NULL,
	[RoleType] [nvarchar](255) NULL,
	[CommunityNickname] [nvarchar](40) NULL,
	[CompanyName] [nvarchar](80) NULL,
	[CRMUser] [nvarchar](80) NULL,
	[Department] [nvarchar](80) NULL,
	[Division] [nvarchar](80) NULL,
	[Title] [nvarchar](80) NULL,
	[Street] [nvarchar](255) NULL,
	[City] [nvarchar](40) NULL,
	[State] [nvarchar](80) NULL,
	[Postcode] [nvarchar](20) NULL,
	[Country] [nvarchar](80) NULL,
	[Phone] [nvarchar](40) NULL,
	[MobilePhone] [nvarchar](40) NULL,
	[Fax] [nvarchar](40) NULL,
	[Email] [nvarchar](128) NULL,
	[CreatedBy] [nvarchar](121) NULL,
	[CreatedDate] [datetime] NULL,
	[LastLoginDate] [datetime] NULL,
	[LastModifiedBy] [nvarchar](121) NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[Timezone] [nvarchar](40) NULL
) ON [PRIMARY]
GO
