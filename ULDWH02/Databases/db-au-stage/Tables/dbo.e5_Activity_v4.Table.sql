USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_Activity_v4]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_Activity_v4](
	[ExternalId] [uniqueidentifier] NOT NULL,
	[Id] [int] NOT NULL,
	[Code] [nvarchar](32) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Status] [smallint] NULL,
	[Type] [int] NOT NULL,
	[Menu_Id] [int] NOT NULL,
	[Index_Id] [int] NOT NULL,
	[AssemblyName] [varchar](256) NULL,
	[ClassName] [varchar](256) NULL,
	[MethodName] [varchar](256) NULL,
	[PostProcessorRuleSetName] [nvarchar](64) NULL,
	[PostProcessorAssemblyName] [varchar](256) NULL,
	[PostProcessorClassName] [varchar](256) NULL,
	[PostProcessorMethodName] [varchar](256) NULL,
	[CreatedDateTime] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](128) NULL,
	[ModifiedDateTime] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](128) NULL
) ON [PRIMARY]
GO
