USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblUser_Audit_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblUser_Audit_ukcm](
	[UserAuditId] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[OutletId] [int] NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[Login] [nvarchar](100) NULL,
	[Initial] [nvarchar](50) NOT NULL,
	[ASICNumber] [varchar](50) NULL,
	[AgreementDate] [datetime] NULL,
	[AccessLevel] [int] NOT NULL,
	[AccreditationNumber] [varchar](50) NULL,
	[AllowAdjustPricing] [bit] NULL,
	[Status] [datetime] NULL,
	[AgentCode] [nvarchar](50) NULL,
	[Password] [varbinary](100) NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NULL,
	[MustChangePassword] [bit] NOT NULL,
	[ASICCheck] [int] NULL,
	[AccountLocked] [bit] NOT NULL,
	[LoginFailedTimes] [int] NOT NULL,
	[Email] [nvarchar](200) NULL,
	[IsSuperUser] [bit] NOT NULL,
	[LastLoggedInDateTime] [datetime] NULL,
	[DateOfBirth] [datetime] NULL,
	[LastUpdateUserId] [int] NULL,
	[LastUpdateCrmUserId] [int] NULL,
	[AuditDateTime] [datetime] NULL
) ON [PRIMARY]
GO
