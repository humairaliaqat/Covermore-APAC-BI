USE [db-au-log]
GO
/****** Object:  Table [dbo].[ETL_Exception]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_Exception](
	[ExceptionID] [int] IDENTITY(1,1) NOT NULL,
	[REF_ExceptionID] [int] NULL,
	[CountryKey] [varchar](50) NULL,
	[CompanyKey] [varchar](50) NULL,
	[DomainID] [int] NULL,
	[EntityKey] [varchar](255) NULL,
	[SourceTab] [varchar](50) NULL,
	[ExceptionType] [varchar](50) NULL,
	[InsertDate] [date] NULL,
	[UpdateDate] [date] NULL,
	[isValid] [char](1) NULL,
	[ErrorDescrition] [nvarchar](255) NULL
) ON [PRIMARY]
GO
