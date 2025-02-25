USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPersonalIdentifier_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPersonalIdentifier_uscm](
	[ID] [int] NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Code] [varchar](50) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Status] [nvarchar](50) NOT NULL,
	[DomainId] [int] NOT NULL,
	[GroupCode] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
