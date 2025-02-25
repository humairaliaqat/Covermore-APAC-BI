USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblEDMRetarget_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblEDMRetarget_autp](
	[Id] [int] NOT NULL,
	[RecallId] [varchar](200) NULL,
	[SessionToken] [varchar](200) NULL,
	[ExternalUniqueId] [varchar](200) NOT NULL,
	[PolicyId] [int] NULL,
	[Consultant] [varchar](100) NOT NULL,
	[ExternalStoreCode] [varchar](20) NULL,
	[DomainId] [int] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
