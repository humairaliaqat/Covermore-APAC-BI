USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblCompany_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblCompany_autp](
	[CompanyId] [tinyint] NOT NULL,
	[CompanyName] [varchar](255) NOT NULL,
	[FullName] [varchar](255) NULL,
	[Code] [varchar](3) NOT NULL,
	[DomainId] [int] NOT NULL,
	[UnderWriter] [varchar](255) NULL,
	[ABN] [varchar](50) NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[BusinessUnitId] [int] NULL
) ON [PRIMARY]
GO
