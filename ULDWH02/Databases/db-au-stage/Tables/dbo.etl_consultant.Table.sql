USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_consultant]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_consultant](
	[CountryKey] [varchar](2) NOT NULL,
	[ConsultantKey] [varchar](13) NULL,
	[ConsultantName] [varchar](50) NULL,
	[ConsultantInitial] [varchar](4) NOT NULL,
	[UserName] [varchar](50) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[AgencyCode] [varchar](7) NOT NULL,
	[AccessLevel] [int] NOT NULL,
	[ApprovalCode] [varchar](50) NULL,
	[AccreditationNo] [varchar](50) NULL,
	[ASICNo] [varchar](50) NULL,
	[AgreementDate] [datetime] NULL,
	[Email] [varchar](100) NULL,
	[PayrollID] [varchar](50) NULL,
	[ConsultantID] [int] NOT NULL
) ON [PRIMARY]
GO
