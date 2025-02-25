USE [db-au-atlas]
GO
/****** Object:  Table [atlas].[Household]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [atlas].[Household](
	[Id] [varchar](25) NOT NULL,
	[IsDeleted] [bit] NULL,
	[Currency_ISOCode] [varchar](10) NULL,
	[CreatedById] [varchar](20) NULL,
	[CreatedDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[LastModifiedById] [varchar](20) NULL,
	[LastReferencedDate] [datetime] NULL,
	[LastViewedDate] [datetime] NULL,
	[SystemModstamp] [datetime] NULL,
	[Name] [varchar](50) NULL,
	[RelationBetweenTo_c] [nvarchar](50) NULL,
	[RelationBetween_c] [nvarchar](50) NULL,
	[RelationshipFrom_c] [nvarchar](50) NULL,
	[RelationshipToToFrom_c] [nvarchar](50) NULL,
	[WTPCustomerFrom_c] [varchar](25) NULL,
	[WTPCustomerTo_c] [varchar](25) NULL,
	[SysStartTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[SysEndTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
 CONSTRAINT [PK_Household] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
	PERIOD FOR SYSTEM_TIME ([SysStartTime], [SysEndTime])
) ON [PRIMARY]
WITH
(
SYSTEM_VERSIONING = ON (HISTORY_TABLE = [atlas].[Household_Hist])
)
GO
ALTER TABLE [atlas].[Household]  WITH CHECK ADD  CONSTRAINT [FK_Household] FOREIGN KEY([WTPCustomerTo_c])
REFERENCES [atlas].[Account] ([Id])
GO
ALTER TABLE [atlas].[Household] CHECK CONSTRAINT [FK_Household]
GO
