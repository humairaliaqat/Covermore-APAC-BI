USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblUserAccreditationApplication_autp]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblUserAccreditationApplication_autp](
	[ID] [int] NOT NULL,
	[UserId] [int] NOT NULL,
	[RefereeName] [nvarchar](255) NULL,
	[ReasonableChecksMade] [bit] NOT NULL,
	[RefereedDate] [datetime] NOT NULL,
	[DeclaredDate] [datetime] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[PreviouslyKnownAs] [nvarchar](100) NULL,
	[YearsOfExperience] [varchar](15) NULL,
	[BusinessName] [nvarchar](100) NULL,
	[BusinessAddress] [nvarchar](200) NULL,
	[PhoneNumber] [varchar](20) NULL,
	[EmailAddress] [nvarchar](200) NULL,
	[Fax] [varchar](20) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[ExternalId] [varchar](100) NULL
) ON [PRIMARY]
GO
